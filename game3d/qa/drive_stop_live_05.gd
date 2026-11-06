extends SceneTree

const Route = preload("res://scripts/pass/route.gd")
var headless := false

func _initialize() -> void:
	headless = DisplayServer.get_name() == "headless"
	create_timer(180).timeout.connect(func(): quit(2))
	call_deferred("run")

func touch(controls: Node, id: int, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = id
	event.position = point
	event.pressed = pressed
	controls._input(event)

func set_pedals(app: Node, gas: bool, brake: bool) -> void:
	if gas != (app.controls.gas_id >= 0):
		touch(app.controls, 0, app.controls.gas_center(), gas)
	if brake != (app.controls.brake_id >= 0):
		touch(app.controls, 2, app.controls.brake_center(), brake)

func steer(app: Node, value: float) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 1
	event.position = app.controls.joystick_origin + Vector2(value, 0) * app.controls.RADIUS
	app.controls._input(event)

func capture(name: String) -> void:
	if headless:
		return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/travel05-live-" + name + ".png")

func settle(frames: int = 6) -> void:
	for _i in range(frames):
		await physics_frame
	await process_frame
	if headless:
		await process_frame
	else:
		await RenderingServer.frame_post_draw

func walk_to(app: Node, target: Vector3) -> bool:
	for _i in range(240):
		var delta: Vector3 = (target - app.world.player.position).rotated(Vector3.UP, -app.world.player.yaw)
		if Vector2(delta.x, delta.z).length() <= 1.7:
			app.controls.cancel_touches()
			await settle()
			return true
		app.controls.movement = Vector2(delta.x, delta.z).normalized() * 0.4
		await physics_frame
	app.controls.cancel_touches()
	return false

func fail(message: String) -> void:
	push_error(message)
	quit(1)

func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.save_enabled = false
	app.demo_entry_button.pressed.emit()
	for _i in range(40):
		await physics_frame
	if not app.is_pass_demo():
		fail("One-action entry failed")
		return
	await capture("start")
	touch(app.controls, 1, Vector2(115, app.controls.size.y - 120), true)
	var parked := false
	for tick in range(9500):
		var progress: float = Route.distance_at(app.world.bike.position)
		var side: float = Route.lateral_at(app.world.bike.position)
		if progress >= 232 and side >= 6.0:
			set_pedals(app, false, true)
			steer(app, 0)
			if app.world.bike.speed <= 0.25:
				parked = true
				break
		else:
			var goal_lane := 8.0 if progress >= 213 else 1.7
			var lookahead := 6.0 if progress >= 205 else 9.0
			var goal: Vector3 = Route.at(progress + lookahead, goal_lane)
			var offset: Vector3 = goal - app.world.bike.position
			var wanted := atan2(-offset.x, -offset.z)
			var error := wrapf(wanted - app.world.bike.rotation.y, -PI, PI)
			steer(app, clampf(-error * 3.0, -1, 1))
			var target_speed := 2.2 if progress >= 201 else 8.0
			set_pedals(app, app.world.bike.speed < target_speed - 0.2, app.world.bike.speed > target_speed + 0.6)
		if tick % 1200 == 0:
			print("LIVE_DRIVE_PROGRESS ", progress, " lane=", side)
		if progress > 248:
			fail("Pilot missed the first layby")
			return
		await physics_frame
	app.controls.cancel_touches()
	for _i in range(5):
		await physics_frame
	if not parked or app.vehicle_button.disabled:
		fail("Could not park by driving into the layby")
		return
	await capture("parked")
	app.vehicle_button.pressed.emit()
	await settle()
	if app.world.riding:
		fail("Dismount UI failed")
		return
	var poi: Dictionary = app.world.pois[0]
	var walk_start: Vector3 = app.world.player.position
	if not await walk_to(app, poi.position) or app.world.player.position.distance_to(walk_start) < 0.4:
		fail("Actual walking toward the viewpoint failed")
		return
	var inspect := InputEventKey.new()
	inspect.pressed = true
	inspect.physical_keycode = KEY_F
	app._unhandled_key_input(inspect)
	if not app.state.visited.has(poi.id):
		fail("Walk and inspect did not record viewpoint")
		return
	await capture("inspect")
	app.description_dialog.get_ok_button().pressed.emit()
	await settle()
	if not await walk_to(app, app.world.bike.position):
		fail("Could not walk back to parked bike")
		return
	app.vehicle_button.pressed.emit()
	await settle()
	if not app.world.riding or app.route_objective.target_station != 550.0:
		fail("Remount/next objective failed: riding=" + str(app.world.riding) + ", paused=" + str(app.world.paused) + ", suspended=" + str(app.application_suspended) + ", objective=" + str(app.route_objective))
		return
	await capture("next-objective")
	print("LIVE_LOOP05_PASS: UI entry, actual touch ride 5->", Route.distance_at(app.world.bike.position), ", layby brake, dismount, walking, F inspect, remount; no position reset or teleport used")
	app.queue_free()
	await process_frame
	quit(0)
