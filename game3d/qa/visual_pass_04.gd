extends SceneTree

func _initialize() -> void:
	create_timer(120).timeout.connect(func():
		push_error("Pass visual smoke timed out")
		quit(2))
	call_deferred("run")

func settle(frames: int = 25) -> void:
	for _i in range(frames):
		await physics_frame
	await process_frame
	await RenderingServer.frame_post_draw

func capture(label: String) -> void:
	root.get_texture().get_image().save_png("/tmp/pass04-" + label + ".png")

func touch(controls: Node, id: int, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = id
	event.position = position
	event.pressed = pressed
	controls._input(event)

func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.save_enabled = false
	assert(app.enter_region("mountain_pass_demo", false))
	await settle(40)
	assert(app.is_pass_demo() and app.controls.drive_mode)
	assert(app.world.bike.is_on_floor())
	capture("start")
	var before: Vector3 = app.world.bike.position
	touch(app.controls, 0, app.controls.gas_center(), true)
	await settle(90)
	assert(app.world.bike.position.distance_to(before) > 2.0)
	capture("riding")
	touch(app.controls, 1, app.controls.brake_center(), true)
	await settle(90)
	assert(app.world.bike.speed < 0.5)
	touch(app.controls, 0, app.controls.gas_center(), false)
	touch(app.controls, 1, app.controls.brake_center(), false)
	app.world.bike.reset_to_distance(350, 1.7)
	await settle()
	capture("bend")
	for station: float in [230.0, 550.0]:
		app.world.bike.reset_to_distance(station, 8.0)
		await settle()
		assert(app.toggle_pass_vehicle(), "Cannot dismount at layby")
		await settle()
		assert(not app.world.riding and not app.controls.drive_mode)
		assert(app.interact(), "Cannot inspect viewpoint while on foot")
		capture("viewpoint-" + str(int(station)))
		app.description_dialog.hide()
		await settle(5)
		assert(app.toggle_pass_vehicle(), "Cannot remount parked bike")
		await settle(5)
	app.capture_position()
	assert(app.state.road_demo.bike_s > 41)
	assert(not app.state.positions.has("mountain_pass_demo"))
	app.open_menu()
	await settle(5)
	capture("menu")
	print("PASS04_VISUAL_PASS: real touch throttle/brake; 750m route preview; both layby dismount/POI/remount; separate checkpoint and menu")
	app.queue_free()
	await process_frame
	quit(0)
