extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)

func run() -> void:
	var store = load("res://scripts/save_store.gd")
	check(store != null, "save store script loads")
	if store == null:
		quit(1)
		return
	var prior_exists := FileAccess.file_exists(store.SAVE_PATH)
	var prior_bytes := FileAccess.get_file_as_bytes(store.SAVE_PATH) if prior_exists else PackedByteArray()
	var valid: Dictionary = store.default_data()
	valid.positions.hanoi = {"x": 2.0, "y": 0.2, "z": 8.0, "yaw": 0.5, "pitch": -0.5}
	valid.visited = ["hanoi:lake", "hanoi:lake"]
	var decoded: Dictionary = store.decode(JSON.stringify(valid))
	check(decoded.ok and decoded.data.visited == ["hanoi:lake"], "decode preserves progress and deduplicates POI rewards")
	check(store.save_data(decoded.data), "save writes atomic local progress file")
	var loaded: Dictionary = store.load_data()
	check(loaded.ok and loaded.data == decoded.data, "save/load round-trip preserves region, positions, view and visited POIs")
	var good_bytes := FileAccess.get_file_as_bytes(store.SAVE_PATH)
	var bad_cases: Array = ["{bad json", "null", "[]", "{}", '{"version":999,"region_id":"hanoi","positions":{},"visited":[]}']
	for text in bad_cases:
		check(not store.decode(text).ok, "reject malformed/unsupported save: " + text)
	for field in ["x", "y", "z", "yaw", "pitch"]:
		var malformed: Dictionary = valid.duplicate(true)
		malformed.positions.hanoi.erase(field)
		check(not store.decode(JSON.stringify(malformed)).ok, "reject missing position field: " + field)
	for change in [{"x": 42.0}, {"z": -42.0}, {"y": -6.0}, {"pitch": 0.0}, {"yaw": "east"}]:
		var malformed: Dictionary = valid.duplicate(true)
		malformed.positions.hanoi.merge(change, true)
		check(not store.decode(JSON.stringify(malformed)).ok, "reject invalid position value: " + str(change))
	var invalid: Dictionary = valid.duplicate(true)
	invalid.version = 2
	check(not store.save_data(invalid), "invalid save cannot replace good file")
	check(FileAccess.get_file_as_bytes(store.SAVE_PATH) == good_bytes, "rejected save leaves prior file intact")
	check(store.save_data(store.default_data()), "prepare isolated scene test progress")
	var packed = load("res://scenes/main.tscn")
	check(packed is PackedScene, "main scene loads")
	if not packed is PackedScene:
		_restore(store, prior_exists, prior_bytes)
		quit(1)
		return
	var game = packed.instantiate()
	root.add_child(game)
	game.save_enabled = false
	await process_frame
	check(game.catalog.size() == 47, "main scene exposes all 47 registry destinations")
	game.controls.movement = Vector2(0.5, -0.5)
	game._process(0.016)
	check(game.world.player.move_input == Vector2(0.5, -0.5), "main gameplay forwards virtual joystick movement to character")
	var old_yaw: float = game.world.player.yaw
	game.controls.camera_drag.emit(Vector2(20, 0))
	check(game.world.player.yaw < old_yaw, "main gameplay forwards touch camera drag to player")
	game.open_menu()
	game._process(0.016)
	check(game.world.player.move_input == Vector2.ZERO and not game.controls.enabled and game.controls.movement == Vector2.ZERO, "location menu stops movement and cancels held touches")
	game.controls.camera_drag.emit(Vector2(20, 0))
	check(is_equal_approx(game.world.player.yaw, old_yaw - 0.1), "camera does not rotate behind open location menu")
	game.close_menu()
	var previous = game.world
	check(not game.enter_region("nonexistent-region") and game.world == previous, "invalid destination keeps existing scene and progress")
	for entry in game.catalog:
		check(game.enter_region(entry.id, false) and game.world.region.id == entry.id, "real scene transition enters " + entry.id)
		await process_frame
		var worlds := 0
		for child in game.get_children():
			if child.get_script() == load("res://scripts/world.gd"):
				worlds += 1
		check(worlds == 1, "transition retains exactly one active world: " + entry.id)
	check(game.enter_region("hanoi", false), "return to Hanoi sample")
	game.world.player.position = Vector3(35, 1, 35)
	check(not game.interact() and game.state.visited.is_empty(), "out-of-range POI interaction does not award visit")
	var poi: Dictionary = game.world.pois[0]
	game.world.player.position = poi.position + Vector3(0, 0.1, 0)
	check(game.interact() and game.state.visited.has(poi.id), "nearby POI interaction awards visit")
	game.description_dialog.hide()
	check(game.interact() and game.state.visited.size() == 1, "repeated POI interaction does not duplicate visit")
	game.description_dialog.hide()
	game.world.player.position = Vector3(1, 0.2, 7)
	game.world.player.yaw = 0.8
	game.world.player.pitch = -0.5
	game.capture_position()
	game.enter_region("island_phu_quoc", false)
	check(game.world.is_island, "island entry opens a playable island world")
	game.enter_region("hanoi", false)
	check(game.world.player.position.distance_to(Vector3(1, 0.2, 7)) < 0.01 and is_equal_approx(game.world.player.yaw, 0.8), "returning restores previous player position and camera yaw")
	check(game.save_now(), "main scene persists player position and visited POIs")
	game.queue_free()
	await process_frame
	var restarted = packed.instantiate()
	root.add_child(restarted)
	restarted.save_enabled = false
	check(restarted.state.region_id == "hanoi" and restarted.state.visited.has(poi.id), "new game instance restores saved current region and visited POI")
	restarted.queue_free()
	await process_frame
	var unknown: Dictionary = store.default_data()
	unknown.region_id = "region-removed-in-later-dataset"
	check(store.save_data(unknown), "prepare valid save referring to unknown registry ID")
	var recovered = packed.instantiate()
	root.add_child(recovered)
	recovered.save_enabled = false
	check(recovered.world.region.id == "hanoi", "unknown saved region recovers to first enterable region")
	recovered.queue_free()
	await process_frame
	var corrupt := FileAccess.open(store.SAVE_PATH, FileAccess.WRITE)
	corrupt.store_string("{broken-original-save")
	corrupt.close()
	var invalid_session = packed.instantiate()
	root.add_child(invalid_session)
	check(not invalid_session.save_enabled and invalid_session.world != null, "corrupt save starts recoverable session with automatic writes disabled")
	invalid_session._process(6.0)
	check(FileAccess.get_file_as_string(store.SAVE_PATH) == "{broken-original-save", "startup and autosave preserve corrupt original until user explicitly saves")
	invalid_session.queue_free()
	await process_frame
	_restore(store, prior_exists, prior_bytes)
	print("RESULT save/transitions: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func _restore(store, prior_exists: bool, prior_bytes: PackedByteArray) -> void:
	if prior_exists:
		var file := FileAccess.open(store.SAVE_PATH, FileAccess.WRITE)
		file.store_buffer(prior_bytes)
		file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(store.SAVE_PATH))
