extends SceneTree

var checks := 0
var failures := 0
var camera_deltas: Array[Vector2] = []

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)

func touch(index: int, position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	return event

func drag(index: int, position: Vector2, relative: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	event.relative = relative
	return event

func run() -> void:
	var control_script = load("res://scripts/touch_controls.gd")
	check(control_script != null, "touch controller script loads")
	if control_script == null:
		quit(1)
		return
	var controls = control_script.new()
	root.add_child(controls)
	controls.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	controls.size = Vector2(1280, 720)
	controls.camera_drag.connect(func(delta: Vector2): camera_deltas.append(delta))
	controls._input(touch(3, Vector2(100, 550), true))
	controls._input(drag(3, Vector2(500, 550), Vector2(400, 0)))
	check(controls.joystick_id == 3, "left thumb owns joystick")
	check(is_equal_approx(controls.movement.length(), 1.0), "joystick clamps oversized drag to unit movement")
	check(controls.movement.x > 0.99, "joystick preserves intended direction")
	controls._input(touch(7, Vector2(900, 320), true))
	controls._input(drag(7, Vector2(940, 300), Vector2(40, -20)))
	check(controls.camera_id == 7, "second thumb independently owns camera")
	check(camera_deltas.size() == 1 and camera_deltas[0] == Vector2(40, -20), "camera receives second-thumb drag")
	check(controls.movement.x > 0.99, "camera drag does not change held joystick")
	controls._input(touch(12, Vector2(0, 0), false))
	check(controls.joystick_id == 3 and controls.camera_id == 7, "unrelated finger release preserves active controls")
	controls._input(touch(3, Vector2(500, 550), false))
	check(controls.movement == Vector2.ZERO and controls.joystick_id == -1, "releasing joystick immediately clears movement")
	check(controls.camera_id == 7, "releasing joystick preserves camera finger")
	controls.cancel_touches()
	check(controls.camera_id == -1 and controls.joystick_id == -1 and controls.movement == Vector2.ZERO, "cancelling touches resets both pointers and movement")
	controls.enabled = false
	controls._input(touch(1, Vector2(100, 550), true))
	check(controls.joystick_id == -1, "disabled touch controls ignore new input")
	controls.queue_free()

	var player_script = load("res://scripts/player.gd")
	check(player_script != null, "player script loads")
	if player_script == null:
		quit(1)
		return
	var world := Node3D.new()
	root.add_child(world)
	var ground := StaticBody3D.new()
	var ground_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(50, 1, 50)
	ground_shape.shape = floor_box
	ground.position.y = -0.5
	ground.add_child(ground_shape)
	world.add_child(ground)
	var wall := StaticBody3D.new()
	var wall_shape := CollisionShape3D.new()
	var wall_box := BoxShape3D.new()
	wall_box.size = Vector3(1, 4, 10)
	wall_shape.shape = wall_box
	wall.position = Vector3(3, 2, 0)
	wall.add_child(wall_shape)
	world.add_child(wall)
	var player = player_script.new()
	player.position = Vector3(0, 1, 0)
	world.add_child(player)
	for i in 60:
		await physics_frame
	check(player is CharacterBody3D, "player is a physics CharacterBody3D")
	check(player.get_child_count() >= 3 and player.camera is Camera3D, "player has collider, visible avatar and third-person camera")
	check(player.is_on_floor() and player.position.y > -0.05 and player.position.y < 0.2, "player lands on solid floor without falling through")
	player.move_input = Vector2(1, 0)
	for i in 60:
		await physics_frame
	check(player.position.x > 1.5, "movement input moves the character in physics world")
	check(player.position.x < 2.3, "wall collision blocks forward movement")
	player.move_input = Vector2.ZERO
	player.look(Vector2(100, 100000))
	check(is_equal_approx(player.yaw, -0.5) and player.pitch >= -1.12, "camera horizontal rotation works and downward pitch clamps")
	player.look(Vector2(0, -100000))
	check(player.pitch <= -0.08 and is_finite(player.pitch), "camera upward pitch clamps to finite value")
	player.global_position = Vector3(0, -20, 0)
	await physics_frame
	await physics_frame
	check(player.global_position.y > 0, "out-of-bounds fall recovers to safe spawn")
	world.queue_free()
	await process_frame
	print("RESULT controls/player: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
