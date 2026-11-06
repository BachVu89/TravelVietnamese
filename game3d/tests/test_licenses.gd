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
	var packed = load("res://scenes/main.tscn")
	check(packed is PackedScene, "main scene loads with license module")
	if not packed is PackedScene:
		quit(1)
		return
	var game = packed.instantiate()
	root.add_child(game)
	game.save_enabled = false
	var visits_before: Array = game.state.visited.duplicate()
	game.controls.joystick_id = 3
	game.controls.camera_id = 8
	game.controls.movement = Vector2(0.5, -0.5)
	game._show_licenses()
	check(is_instance_valid(game.license_dialog) and game.license_dialog.visible, "license action opens its dialog")
	check(game.license_dialog.exclusive, "license dialog is modal")
	check(game.controls.joystick_id == -1 and game.controls.camera_id == -1 and game.controls.movement == Vector2.ZERO, "opening license dialog cancels both held touch pointers")
	game._process(0.016)
	check(not game.controls.enabled and game.world.player.move_input == Vector2.ZERO, "gameplay movement pauses while licenses are open")
	var event := InputEventScreenTouch.new()
	event.index = 5
	event.position = Vector2(100, 550)
	event.pressed = true
	game.controls._input(event)
	check(game.controls.joystick_id == -1 and game.controls.movement == Vector2.ZERO, "touches on license dialog cannot claim joystick")
	var text: TextEdit
	for child in game.license_dialog.get_children():
		if child is TextEdit:
			text = child
	check(text != null, "license dialog includes scrollable text widget")
	if text:
		check(not text.editable and text.wrap_mode == TextEdit.LINE_WRAPPING_BOUNDARY, "notice text is read-only and wraps within dialog")
		check(text.custom_minimum_size.y <= 400 and text.custom_minimum_size.x <= 800, "license viewport stays bounded instead of expanding to full notice length")
		check(text.text.contains("Permission is hereby granted") and text.text.contains("GODOT ENGINE"), "dialog includes full Godot permission text")
		check(text.text.contains("THIRD-PARTY LICENSE TEXTS") and text.text.contains("DỮ LIỆU ĐỊA DANH"), "dialog includes third-party and dataset sections")
		var dataset_notice := FileAccess.get_file_as_string("res://data/geography/LICENSE-vietnamese-provinces-database.txt")
		check(not dataset_notice.is_empty() and text.text.contains(dataset_notice), "complete packaged dataset license is available offline")
		await process_frame
		text.set_caret_line(text.get_line_count() - 1)
		text.center_viewport_to_caret()
		await process_frame
		check(text.get_v_scroll_bar().max_value > text.get_v_scroll_bar().page and text.scroll_vertical > 0, "long copyright notices can actually scroll to the end")
	check(game.state.visited == visits_before, "reading or scrolling licenses does not award a POI stamp")
	var first_dialog = game.license_dialog
	game.license_dialog.hide()
	game._process(0.016)
	check(game.controls.enabled, "closing licenses resumes gameplay controls")
	game.open_menu()
	game._show_licenses()
	check(game.license_dialog == first_dialog, "reopening reuses one license dialog without duplication")
	game.license_dialog.hide()
	game._process(0.016)
	check(game.menu.visible and not game.controls.enabled, "closing licenses over location menu keeps gameplay paused")
	game.close_menu()
	game._process(0.016)
	check(game.controls.enabled and game.state.visited == visits_before, "closing menu after licenses restores controls without changing exploration progress")
	game.queue_free()
	await process_frame
	print("RESULT licenses: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
