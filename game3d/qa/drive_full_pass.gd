extends SceneTree

const Route = preload("res://scripts/pass/route.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world = load("res://scripts/mountain_pass.gd").new()
	root.add_child(world)
	world.build({"id": "mountain_pass_demo", "name": "QA route"})
	for _i in range(45):
		await physics_frame
	var max_progress := 0.0
	var stalled := 0
	for tick in range(12000):
		var progress: float = Route.distance_at(world.bike.position)
		if progress >= 738:
			print("FULL_PASS_DRIVE_PASS: physics path driven from 5 to ", progress, "; collisions=", world.bike.collisions, "; ticks=", tick)
			world.queue_free()
			await process_frame
			quit(0)
			return
		var goal: Vector3 = Route.at(minf(progress + 9.0, 745), 1.7)
		var direction: Vector3 = goal - world.bike.position
		var wanted_yaw := atan2(-direction.x, -direction.z)
		var error := wrapf(wanted_yaw - world.bike.rotation.y, -PI, PI)
		var steering := clampf(-error * 3.0, -1, 1)
		var gas := 0.45 if world.bike.speed < 8 else 0.0
		world.set_drive_input(Vector2(steering, gas))
		if progress > max_progress + 0.2:
			max_progress = progress
			stalled = 0
		else:
			stalled += 1
		if stalled > 450 or world.bike.position.y < Route.point(progress).y - 3:
			push_error("FULL_PASS_DRIVE_FAIL at " + str(progress) + ", pos=" + str(world.bike.position))
			quit(1)
			return
		await physics_frame
	push_error("FULL_PASS_DRIVE_FAIL: max ticks, progress=" + str(max_progress))
	quit(1)
