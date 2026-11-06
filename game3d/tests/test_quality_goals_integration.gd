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
	root.size = Vector2i(1280, 720)
	var store = load("res://scripts/save_store.gd")
	var prior_exists := FileAccess.file_exists(store.SAVE_PATH)
	var prior_bytes := FileAccess.get_file_as_bytes(store.SAVE_PATH) if prior_exists else PackedByteArray()
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/progress-v0.3.json"))
	check(store.save_data(fixture), "prepare legacy file with no quality and no road stamps")
	var packed = load("res://scenes/main.tscn")
	var game = packed.instantiate()
	if not game.has_method("start_pass_demo"):
		check(false, "parsed main exposes one-action demo entry")
		game.free()
		quit(1)
		return
	root.add_child(game)
	game.save_enabled = false
	await process_frame
	check(not game.is_pass_demo() and game.catalog.size() == 47 and game.state.preferences.visual_quality == "economy", "legacy startup retains geography access and defaults quality to economy")
	check(game.demo_entry_button.visible and game.demo_entry_button.focus_mode == Control.FOCUS_ALL, "one-action demo entry is visible and keyboard focusable without searching catalog")
	game.demo_entry_button.pressed.emit()
	game._process(0.016)
	check(game.is_pass_demo() and game.route_objective.phase == "ride_to_stop" and game.route_objective.target_station == 230.0, "one entry button press opens road with first stop objective")
	check(game.state.visited == fixture.visited and not game.tutorial_row.visible, "entering demo does not award stamps or force geographic tutorial")
	var initial_goal: Dictionary = game.route_objective.duplicate(true)
	game.open_settings()
	await process_frame
	await process_frame
	game._process(0.016)
	check(game.quality_option.item_count == 2 and game.quality_option.selected == 0, "settings show two quality profiles and select migrated economy")
	var dialog_rect := Rect2(Vector2(game.settings_dialog.position), Vector2(game.settings_dialog.size))
	check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(dialog_rect), "expanded quality settings dialog fits full 1280x720 viewport")
	check(Rect2(Vector2.ZERO, Vector2(game.settings_dialog.size)).encloses(game.settings_dialog.get_ok_button().get_global_rect()), "expanded settings return button remains reachable inside dialog")
	game.quality_option.select(1)
	game.quality_option.item_selected.emit(1)
	game._process(0.016)
	check(game.state.preferences.visual_quality == "detail" and game.world.get_visual_statistics().profile == "detail" and game.state.preferences.shadows == false, "quality UI callback applies detail live without changing independent shadows choice")
	check(game.route_objective == initial_goal and game.state.visited == fixture.visited, "changing quality leaves route objective and stamp progress unchanged")
	game.settings_dialog.hide()
	game._process(0.016)
	for stop_index in 2:
		var station: float = [230.0, 550.0][stop_index]
		# Set up objective states directly; this verifies state integration and
		# guards, not an end-to-end driving claim. Root owns real-input GUI loop.
		game.world.bike.reset_to_distance(station, 8.0)
		game.world.bike.speed = 1.0
		game._process(0.016)
		check(game.route_objective.phase == "park" and game.route_objective.target_station == station and not game.route_objective.detail.contains("Đã đỗ an toàn"), "moving at target stop still instructs player to park: " + str(station))
		game.world.bike.speed = 0
		game._process(0.016)
		check(game.route_objective.detail.contains("Đã đỗ an toàn"), "safe stationary layby enables dismount objective: " + str(station))
		check(game.toggle_pass_vehicle(), "main dismounts for real POI interaction at target stop: " + str(station))
		game._process(0.016)
		check(game.route_objective.phase == "walk_to_poi" and not game.route_objective.complete, "walking stage requires interaction rather than merely entering stop: " + str(station))
		check(game.interact(), "existing walking proximity guard permits nearby stop interaction: " + str(station))
		game.description_dialog.hide()
		game._process(0.016)
		check(game.route_objective.visited_count == stop_index + 1 and game.route_objective.phase == "return_to_bike", "actual POI stamp advances objective back to bike: " + str(station))
		check(game.toggle_pass_vehicle(), "remount continues objective sequence without scene replacement: " + str(station))
		game._process(0.016)
		check(game.route_objective.phase == ("ride_to_stop" if stop_index == 0 else "ride_to_finish"), "remount targets next missing stop or finish from actual stamps: " + str(station))
		if stop_index == 0:
			game.world._physics_process(0.016)
			check(game.save_now() and store.load_data().data.road_demo.checkpoint == 230.0, "first-stop checkpoint and stamp can be saved before second stop")
			var partial_restart = packed.instantiate()
			root.add_child(partial_restart)
			partial_restart.save_enabled = false
			partial_restart._process(0.016)
			check(partial_restart.route_objective.visited_count == 1 and partial_restart.route_objective.target_station == 550.0 and partial_restart.route_objective.phase == "ride_to_stop", "mid-route restart resumes next missing stop without asking for first stamp again")
			partial_restart.queue_free()
			await process_frame
	game.world.bike.reset_to_distance(738.5)
	game._process(0.016)
	check(game.route_objective.complete and game.route_objective.phase == "complete" and game.route_objective.visited_count == 2, "both recorded POIs and end zone complete only demo route")
	var preserved_visits: Array = game.state.visited.duplicate()
	var preserved_positions: Dictionary = game.state.positions.duplicate(true)
	var preserved_preferences: Dictionary = game.state.preferences.duplicate(true)
	game.demo_entry_button.pressed.emit()
	game._process(0.016)
	check(game.world.bike.speed == 0 and game.world.get_hud_state().progress < 10 and game.world.riding, "same entry action safely replays road from beginning at zero speed")
	check(game.state.visited == preserved_visits and game.state.positions == preserved_positions and game.state.preferences == preserved_preferences, "replay retains both road stamps, old geographic positions and quality/settings")
	check(game.route_objective.phase == "ride_to_finish" and game.route_objective.visited_count == 2 and not game.route_objective.complete, "replay does not pretend completed stop POIs are unvisited")
	var entered_geography: bool = game.enter_region("hanoi")
	game._process(0.016)
	check(entered_geography and not game.is_pass_demo() and not game.route_objective_label.visible, "geographic scene remains accessible after road replay")
	check(game.start_pass_demo() and game.world.get_visual_statistics().profile == "detail", "returning to road retains live detail profile")
	game._process(0.016)
	check(game.route_objective.phase == "ride_to_finish" and game.state.visited == preserved_visits, "scene changes derive resumed objective without requiring old POIs again")
	check(game.save_now(), "save stores replay progress and selected detail profile locally")
	game.queue_free()
	await process_frame
	var restarted = packed.instantiate()
	root.add_child(restarted)
	restarted.save_enabled = false
	restarted._process(0.016)
	check(restarted.is_pass_demo() and restarted.state.preferences.visual_quality == "detail" and restarted.world.get_visual_statistics().profile == "detail", "restart restores selected quality and road scene")
	check(restarted.route_objective.phase == "ride_to_finish" and restarted.state.visited == preserved_visits and restarted.state.preferences.shadows == false, "restart derives replay objective from retained stamps and preserves independent shadow choice")
	restarted.queue_free()
	await process_frame
	if prior_exists:
		var restore_file := FileAccess.open(store.SAVE_PATH, FileAccess.WRITE)
		restore_file.store_buffer(prior_bytes)
		restore_file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(store.SAVE_PATH))
	print("RESULT quality/goals integration: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
