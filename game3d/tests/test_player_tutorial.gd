extends SceneTree

var checks := 0
var failures := 0
var total_traveled := 0.0

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
	var tutorial = load("res://scripts/onboarding.gd").new()
	tutorial.init_from({})
	var world := Node3D.new()
	root.add_child(world)
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(60, 1, 60)
	shape.shape = box
	floor_body.position.y = -0.5
	floor_body.add_child(shape)
	world.add_child(floor_body)
	var player = load("res://scripts/player.gd").new()
	player.position = Vector3(0, 0.5, 0)
	world.add_child(player)
	player.traveled.connect(func(distance: float): total_traveled += distance; tutorial.record_move(distance))
	player.looked.connect(func(radians: float): tutorial.record_look(radians))
	for i in 30:
		await physics_frame
	check(tutorial.data.step == 0 and is_zero_approx(total_traveled), "gravity settling without input earns no movement progress")
	player.position = Vector3(10, 0.1, 10)
	for i in 5:
		await physics_frame
	check(tutorial.data.step == 0 and is_zero_approx(total_traveled), "teleporting with no input cannot complete movement tutorial")
	player.move_input = Vector2(0, -1)
	for i in 30:
		await physics_frame
	player.move_input = Vector2.ZERO
	check(tutorial.data.step == 1 and total_traveled >= 2.0, "continuous physics walking completes 2 m movement step")
	player.look(Vector2(30, 0))
	check(tutorial.data.step == 1, "actual look delta below threshold stays in look step")
	player.look(Vector2(30, 0))
	check(tutorial.data.step == 2, "actual player camera input accumulates to advance look step")
	var yaw_before: float = player.yaw
	player.camera_sensitivity = 0.6
	player.look(Vector2(20, 0))
	check(is_equal_approx(absf(player.yaw - yaw_before), 0.06), "low sensitivity applies live to actual player yaw")
	yaw_before = player.yaw
	player.camera_sensitivity = 1.4
	player.look(Vector2(20, 0))
	check(is_equal_approx(absf(player.yaw - yaw_before), 0.14), "high sensitivity applies live to actual player yaw")
	tutorial.replay()
	player.yaw = 0
	player.position = Vector3(0, 0.05, 0)
	var wall := StaticBody3D.new()
	var wall_shape := CollisionShape3D.new()
	var wall_box := BoxShape3D.new()
	wall_box.size = Vector3(1, 4, 10)
	wall_shape.shape = wall_box
	wall.position = Vector3(1, 2, 0)
	wall.add_child(wall_shape)
	world.add_child(wall)
	for i in 3:
		await physics_frame
	player.move_input = Vector2(1, 0)
	for i in 90:
		await physics_frame
	player.move_input = Vector2.ZERO
	check(tutorial.data.step == 0 and tutorial.data.move_distance < 1.0, "pushing against collision does not count requested speed as traveled distance")
	check(player.position.x < 0.3, "player really remains blocked at test wall")
	world.queue_free()
	await process_frame
	print("RESULT player/tutorial: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
