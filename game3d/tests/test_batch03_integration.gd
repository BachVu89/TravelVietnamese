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

func shadow_state(world: Node3D, expected: bool) -> bool:
	var found := false
	for child in world.get_children():
		if child is DirectionalLight3D:
			found = true
			if child.shadow_enabled != expected:
				return false
	return found

func run() -> void:
	root.size = Vector2i(1280, 720)
	var store = load("res://scripts/save_store.gd")
	var prior_exists := FileAccess.file_exists(store.SAVE_PATH)
	var prior_bytes := FileAccess.get_file_as_bytes(store.SAVE_PATH) if prior_exists else PackedByteArray()
	var fixture_text := FileAccess.get_file_as_string("res://tests/fixtures/progress-v0.2.json")
	var fixture: Dictionary = JSON.parse_string(fixture_text)
	var old_file := FileAccess.open(store.SAVE_PATH, FileAccess.WRITE)
	old_file.store_string(fixture_text)
	old_file.close()
	var packed = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	if not game.has_method("replay_tutorial"):
		check(false, "main scene attaches parsed batch 0.3 gameplay script")
		game.free()
		quit(1)
		return
	root.add_child(game)
	game.save_enabled = false
	check(game.state.region_id == fixture.region_id and game.state.visited == fixture.visited and game.state.positions == fixture.positions, "main startup migrates actual 0.2 file without resetting core progress")
	check(game.onboarding.data.status == "active" and game.onboarding.data.step == 0, "old save shows new onboarding once at movement step")
	check(shadow_state(game.world, true) and is_equal_approx(game.world.player.camera_sensitivity, 1.0), "migrated scene receives default rendering and camera settings")
	game.enter_region("hanoi", false)
	for i in 20:
		await physics_frame
	game.save_enabled = true
	game.controls.movement = Vector2(0, -1)
	for i in 30:
		await physics_frame
	game.controls.cancel_touches()
	game._process(0.016)
	check(game.onboarding.data.step == 1, "actual main-scene joystick walking advances tutorial movement step")
	check(store.load_data().data.onboarding.step == 1, "movement checkpoint persists before five-second autosave interval")
	game.controls.camera_drag.emit(Vector2(30, 0))
	game.controls.camera_drag.emit(Vector2(30, 0))
	check(game.onboarding.data.step == 2, "actual main-scene camera input advances tutorial look step")
	check(store.load_data().data.onboarding.step == 2, "look checkpoint persists immediately on step transition")
	game.world.player.position = Vector3(35, 1, 35)
	check(not game.interact() and game.onboarding.data.step == 2, "failed out-of-range interaction cannot complete onboarding")
	var prior_visits: Array = game.state.visited.duplicate()
	game.world.player.position = game.world.pois[0].position + Vector3(0, 0.1, 0)
	check(game.interact() and game.onboarding.data.status == "completed", "successful nearby already-visited POI still completes onboarding")
	check(store.load_data().data.onboarding.status == "completed", "successful interaction persists completed tutorial status immediately")
	game.save_enabled = false
	check(game.state.visited == prior_visits, "tutorial replay-style interaction does not duplicate existing POI stamp")
	game.description_dialog.hide()
	check(game.save_now(), "completed tutorial state can be saved")
	var completed_restart = packed.instantiate()
	root.add_child(completed_restart)
	completed_restart.save_enabled = false
	check(completed_restart.onboarding.data.status == "completed" and not completed_restart.tutorial_row.visible, "completed tutorial remains completed and hidden after startup")
	completed_restart.queue_free()
	await process_frame
	game.capture_position()
	var positions_before: Dictionary = game.state.positions.duplicate(true)
	var position_before: Vector3 = game.world.player.position
	game.replay_tutorial()
	check(game.onboarding.data.status == "active" and game.onboarding.data.step == 0, "main replay returns onboarding to step zero")
	check(game.state.visited == prior_visits and game.state.positions == positions_before and game.world.player.position == position_before, "main replay preserves stamps, saved positions and current player location")
	game.skip_tutorial()
	check(game.onboarding.data.status == "skipped", "main skip uses skipped rather than completed status")
	game.apply_preferences({"shadows": false, "sensitivity": 1.4})
	check(shadow_state(game.world, false) and is_equal_approx(game.world.player.camera_sensitivity, 1.4), "settings apply live to world shadows and player camera")
	game.enter_region("island_phu_quoc", false)
	check(shadow_state(game.world, false) and is_equal_approx(game.world.player.camera_sensitivity, 1.4), "settings survive scene changes")
	game.controls.movement = Vector2(1, 0)
	game.open_settings()
	await process_frame
	await process_frame
	game._process(0.016)
	check(game.settings_dialog.visible and not game.controls.enabled and game.controls.movement == Vector2.ZERO and game.world.player.move_input == Vector2.ZERO, "settings dialog pauses gameplay and cancels held movement")
	var settings_size: Vector2i = game.settings_dialog.size
	var settings_position: Vector2i = game.settings_dialog.position
	check(settings_size.x <= 1280 and settings_size.y <= 720 and settings_size.x > 0 and settings_size.y > 0, "settings dialog dimensions fit the 1280x720 viewport")
	check(settings_position.x >= 0 and settings_position.y >= 0 and settings_position.x + settings_size.x <= 1280 and settings_position.y + settings_size.y <= 720, "entire settings dialog stays within the 1280x720 viewport")
	var close_button: Button = game.settings_dialog.get_ok_button()
	check(close_button.visible and Rect2(Vector2.ZERO, Vector2(settings_size)).encloses(close_button.get_global_rect()), "settings return button stays visible inside the dialog client area")
	var paused_yaw: float = game.world.player.yaw
	game.controls.camera_drag.emit(Vector2(50, 0))
	check(is_equal_approx(game.world.player.yaw, paused_yaw), "settings dialog blocks camera look as well as character movement")
	game.settings_dialog.hide()
	game._process(0.016)
	check(game.controls.enabled, "closing settings restores gameplay input")
	game._process(0.016)
	check(not game.waypoint_target.is_empty() and not game.state.visited.has(game.waypoint_target.id), "HUD targets an unvisited POI")
	for poi in game.world.pois:
		game.world.player.position = poi.position + Vector3(0, 0.1, 0)
		check(game.interact(), "island POI interaction remains playable with batch 0.3: " + poi.id)
		game.description_dialog.hide()
		game._process(0.016)
		check(game.waypoint_target.is_empty() or not game.state.visited.has(game.waypoint_target.id), "HUD never retains a newly visited target: " + poi.id)
	check(game.waypoint_target.is_empty() and game.navigation_label.text.contains("3/3"), "all local POIs produces local completion with no navigation target")
	check(game.save_now(), "batch 0.3 main scene saves migrated progress, tutorial and settings")
	var expected_visits: Array = game.state.visited.duplicate()
	game.queue_free()
	await process_frame
	var restarted = packed.instantiate()
	root.add_child(restarted)
	restarted.save_enabled = false
	check(restarted.onboarding.data.status == "skipped" and restarted.state.visited == expected_visits, "restart preserves explicit tutorial skip and exploration progress")
	check(not restarted.tutorial_row.visible, "skipped tutorial stays hidden on restart until explicit replay")
	check(shadow_state(restarted.world, false) and is_equal_approx(restarted.world.player.camera_sensitivity, 1.4), "restart reapplies persisted rendering and camera settings")
	restarted.replay_tutorial()
	restarted.onboarding.record_move(2.0)
	restarted.onboarding.record_look(0.1)
	check(restarted.save_now(), "partial replay tutorial state can be saved")
	restarted.queue_free()
	await process_frame
	var resumed = packed.instantiate()
	root.add_child(resumed)
	resumed.save_enabled = false
	check(resumed.onboarding.data.status == "active" and resumed.onboarding.data.step == 1 and is_equal_approx(resumed.onboarding.data.look_radians, 0.1), "restart restores in-progress onboarding step and accumulated look input")
	resumed.queue_free()
	await process_frame
	if prior_exists:
		var restore_file := FileAccess.open(store.SAVE_PATH, FileAccess.WRITE)
		restore_file.store_buffer(prior_bytes)
		restore_file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(store.SAVE_PATH))
	print("RESULT batch03/integration: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
