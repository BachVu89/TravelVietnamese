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

func touch(index: int, position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	return event

func inspect_key(game) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.physical_keycode = KEY_F
	game._unhandled_key_input(event)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var store = load("res://scripts/save_store.gd")
	var route = load("res://scripts/pass/route.gd")
	var prior_exists := FileAccess.file_exists(store.SAVE_PATH)
	var prior_bytes := FileAccess.get_file_as_bytes(store.SAVE_PATH) if prior_exists else PackedByteArray()
	var legacy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/progress-v0.3.json"))
	check(store.save_data(legacy), "prepare actual legacy 0.3 file for road integration")
	var packed = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	if not game.has_method("is_pass_demo"):
		check(false, "main attaches parsed road integration script")
		game.free()
		quit(1)
		return
	root.add_child(game)
	game.save_enabled = false
	check(game.catalog.size() == 47 and not game.catalog.any(func(entry): return entry.id == "mountain_pass_demo"), "road demo is separate from unchanged 47 geography registry entries")
	check(game.enter_region("mountain_pass_demo", false) and game.is_pass_demo(), "main opens dedicated road demo through normal transition API")
	for i in 30:
		await physics_frame
	game._process(0.016)
	check(game.controls.drive_mode and game.world.bike.camera.current and not game.world.player.camera.current, "riding HUD uses driving touch mode and actual bike camera")
	check(is_equal_approx(game.world.bike.camera_sensitivity, 1.4), "legacy camera preferences apply to new bike camera")
	game.controls._input(touch(1, game.controls.gas_center(), true))
	game.controls._input(touch(3, Vector2(100, 550), true))
	var drag := InputEventScreenDrag.new()
	drag.index = 3
	drag.position = Vector2(120, 550)
	drag.relative = Vector2(20, 0)
	game.controls._input(drag)
	var initial: Vector3 = game.world.bike.position
	for i in 20:
		await physics_frame
	check(game.world.bike.drive_input.y == 1 and game.world.bike.drive_input.x > 0, "main forwards simultaneous touch steering and full throttle to bike")
	check(game.world.bike.speed > 0.5 and game.world.bike.position.distance_to(initial) > 0.1, "touch throttle actually moves main-scene bike")
	game.controls._input(touch(5, game.controls.brake_center(), true))
	game._process(0.016)
	check(game.world.bike.drive_input.y == -1 and game.world.bike.drive_input.x > 0, "third touch finger brakes with priority while steering")
	game.open_settings()
	game._process(0.016)
	var modal_at: Vector3 = game.world.bike.position
	var traffic_at: Array[Vector3] = []
	for car in game.world.traffic:
		traffic_at.append(car.position)
	for i in 10:
		await physics_frame
	var traffic_still := true
	for i in game.world.traffic.size():
		traffic_still = traffic_still and game.world.traffic[i].position.distance_to(traffic_at[i]) < 0.001
	check(game.world.paused and game.controls.gas_id == -1 and game.controls.brake_id == -1 and game.world.bike.position.distance_to(modal_at) < 0.001 and traffic_still, "modal cancels all held pedals and freezes bike plus all traffic")
	game.settings_dialog.hide()
	game._process(0.016)
	check(not game.world.paused and game.world.bike.drive_input == Vector2.ZERO, "closing modal resumes road without stale throttle")
	game.controls._input(touch(1, game.controls.gas_center(), true))
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	game._process(0.016)
	check(game.application_suspended and game.world.paused and game.controls.drive_input == Vector2.ZERO, "losing application focus cancels touch driving and pauses road")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	game._process(0.016)
	check(not game.application_suspended and game.world.bike.drive_input == Vector2.ZERO, "focus return does not reapply held throttle")
	var stamps_before: Array = game.state.visited.duplicate()
	for stop_index in 2:
		var stop: float = route.STOPS[stop_index]
		game.world.bike.reset_to_distance(stop, 8.0)
		for i in 30:
			await physics_frame
		check(not game.interact() and game.state.visited.size() == stamps_before.size() + stop_index, "riding through stop cannot interact or auto-award stamp: " + str(stop))
		inspect_key(game)
		check(not game.description_dialog.visible and game.state.visited.size() == stamps_before.size() + stop_index, "keyboard F cannot inspect a viewpoint while riding: " + str(stop))
		game.world.bike.speed = 0.51
		check(not game.toggle_pass_vehicle(), "main cannot bypass dismount speed guard: " + str(stop))
		game.world.bike.speed = 0
		check(game.toggle_pass_vehicle() and not game.world.riding, "main dismounts inside stationary layby: " + str(stop))
		game._process(0.016)
		check(not game.controls.drive_mode and game.world.player.camera.current, "dismount switches touch/camera to walking: " + str(stop))
		game.world.player.position = route.at(stop, 0.0) + Vector3.UP * 0.2
		inspect_key(game)
		check(not game.description_dialog.visible and game.state.visited.size() == stamps_before.size() + stop_index, "keyboard F cannot bypass walking POI proximity guard: " + str(stop))
		game.world.player.position = game.world.pois[stop_index].position + Vector3.UP * 0.2
		game.open_settings()
		inspect_key(game)
		check(not game.description_dialog.visible and game.state.visited.size() == stamps_before.size() + stop_index, "keyboard F cannot inspect nearby POI through open settings modal: " + str(stop))
		game.settings_dialog.hide()
		game._process(0.016)
		await process_frame
		check(game.vehicle_button.visible and game.interact_button.visible and not game.vehicle_button.get_global_rect().intersects(game.interact_button.get_global_rect()), "walking remount and interact button rectangles do not overlap at 1280x720: " + str(stop))
		inspect_key(game)
		check(game.description_dialog.visible and game.state.visited.has(game.world.pois[stop_index].id), "keyboard F inspects nearby walking viewpoint and records its unique stamp: " + str(stop))
		game.description_dialog.hide()
		var stamp_count: int = game.state.visited.size()
		check(game.interact() and game.state.visited.size() == stamp_count, "revisiting viewpoint does not duplicate stamp: " + str(stop))
		game.description_dialog.hide()
		game._process(0.016)
		game.world.player.position = game.world.bike.position + route.right(stop) * 1.3 + Vector3.UP * 0.2
		var original_bike = game.world.bike
		check(game.toggle_pass_vehicle() and game.world.riding and game.world.bike == original_bike, "walking visit remounts same bike to continue route: " + str(stop))
		game._process(0.016)
	game.capture_position()
	check(not game.state.positions.has("mountain_pass_demo") and game.state.positions == legacy.positions, "road coordinates never pollute or clamp legacy geography position map")
	check(game.state.road_demo.bike_s > 500 and game.state.road_demo.checkpoint == 550, "road station and last safe stop persist beyond legacy ±41 bounds")
	var all_stamps: Array = game.state.visited.duplicate()
	game.return_to_entry()
	check(game.world.bike.speed == 0 and game.state.visited == all_stamps, "reset safely stops bike without erasing old or new stamps")
	check(game.save_now(), "main saves road state and both viewpoints to actual local file")
	game.queue_free()
	await process_frame
	var restarted = packed.instantiate()
	root.add_child(restarted)
	restarted.save_enabled = false
	check(restarted.is_pass_demo() and restarted.world.bike.speed == 0 and restarted.state.visited == all_stamps, "restart restores road scene at safe zero-speed mode and retains stamps")
	check(restarted.state.preferences.shadows == false and is_equal_approx(restarted.world.bike.camera_sensitivity, 1.4) and restarted.onboarding.data.status == "skipped", "road restart preserves legacy settings and skipped onboarding")
	check(restarted.enter_region("hanoi") and not restarted.is_pass_demo() and restarted.world.player.position.x == legacy.positions.hanoi.x, "returning from road restores unchanged old geography save")
	restarted.queue_free()
	await process_frame
	if prior_exists:
		var restore_file := FileAccess.open(store.SAVE_PATH, FileAccess.WRITE)
		restore_file.store_buffer(prior_bytes)
		restore_file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(store.SAVE_PATH))
	print("RESULT pass/integration: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
