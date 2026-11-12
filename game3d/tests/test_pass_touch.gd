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

func run() -> void:
	var controls = load("res://scripts/touch_controls.gd").new()
	root.add_child(controls)
	controls.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	controls.size = Vector2(1280, 720)
	controls.set_drive_mode(true)
	controls._input(touch(1, controls.gas_center(), true))
	check(controls.gas_id == 1 and controls.drive_input.y == 1, "gas finger presses virtual throttle")
	controls._input(touch(3, Vector2(100, 550), true))
	var drag := InputEventScreenDrag.new()
	drag.index = 3
	drag.position = Vector2(200, 550)
	drag.relative = Vector2(100, 0)
	controls._input(drag)
	check(controls.drive_input == Vector2(1, 1), "steering and gas hold full independent axes simultaneously")
	controls._input(touch(8, Vector2(900, 300), true))
	check(controls.camera_id == 8 and controls.gas_id == 1 and controls.joystick_id == 3, "camera finger is independent of throttle and steering")
	controls._input(touch(5, controls.brake_center(), true))
	check(controls.brake_id == 5 and controls.drive_input == Vector2(1, -1), "brake takes priority while steering and gas are held")
	controls._input(touch(5, controls.brake_center(), false))
	check(controls.drive_input == Vector2(1, 1), "releasing brake restores still-held throttle without losing steering")
	controls._input(touch(1, controls.gas_center(), false))
	check(controls.drive_input == Vector2(1, 0), "releasing gas removes throttle while steering remains held")
	controls._input(touch(99, Vector2.ZERO, false))
	check(controls.joystick_id == 3 and controls.camera_id == 8, "unrelated touch release cannot clear driving pointers")
	controls.cancel_touches()
	check(controls.drive_input == Vector2.ZERO and controls.gas_id == -1 and controls.brake_id == -1 and controls.camera_id == -1 and controls.joystick_id == -1, "cancel clears all pedals, steering and camera ownership")
	controls.blocked_rectangles.append(Rect2(1050, 570, 220, 140))
	controls._input(touch(7, controls.gas_center(), true))
	check(controls.gas_id == -1 and controls.drive_input == Vector2.ZERO, "UI blocked rectangle cannot simultaneously trigger throttle")
	controls.blocked_rectangles.clear()
	controls.enabled = false
	controls._input(touch(7, controls.gas_center(), true))
	check(controls.gas_id == -1, "disabled modal controls ignore throttle touch")
	controls.enabled = true
	controls._input(touch(7, controls.gas_center(), true))
	controls.set_drive_mode(false)
	check(controls.gas_id == -1 and controls.drive_input == Vector2.ZERO and not controls.drive_mode, "switching to walking cancels held vehicle controls")
	controls.queue_free()
	await process_frame
	print("RESULT pass/touch: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
