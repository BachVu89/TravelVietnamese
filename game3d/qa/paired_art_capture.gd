extends SceneTree

var label := "05"
var profile := "economy"
var samples: Array[Dictionary] = []
var extra_stop := false

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	extra_stop = args.has("--extra-stop")
	for i in range(args.size() - 1):
		if args[i] == "--label":
			label = args[i + 1]
		if args[i] == "--profile":
			profile = args[i + 1]
	create_timer(90).timeout.connect(func(): quit(2))
	call_deferred("run")

func vector_data(v: Vector3) -> Array:
	return [v.x, v.y, v.z]

func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.save_enabled = false
	if not app.enter_region("mountain_pass_demo", false):
		quit(1)
		return
	app.apply_preferences({"shadows": true, "sensitivity": 1.0, "visual_quality": profile})
	app.ui.hide()
	app.set_process(false)
	for traffic in app.world.traffic:
		traffic.paused = true
	var targets: Array[Dictionary] = [{"name": "start", "station": 5.0, "lane": 1.7}, {"name": "bend", "station": 350.0, "lane": 1.7}, {"name": "stop", "station": 230.0, "lane": 8.0}]
	if extra_stop:
		targets.append({"name": "stop-550", "station": 550.0, "lane": 8.0})
	for target: Dictionary in targets:
		app.world.bike.paused = false
		app.world.bike.reset_to_distance(target.station, target.lane)
		for _i in range(40):
			await physics_frame
		app.world.bike.paused = true
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/travel05-pair-" + label + "-" + profile + "-" + target.name + ".png")
		var camera = app.world.bike.camera
		var transform: Transform3D = camera.global_transform
		samples.append({"view": target.name, "station": target.station, "lane": target.lane, "camera_origin": vector_data(transform.origin), "camera_basis": [vector_data(transform.basis.x), vector_data(transform.basis.y), vector_data(transform.basis.z)], "fov": camera.fov, "far": camera.far, "size": [root.size.x, root.size.y]})
	var stats: Dictionary = app.world.get_visual_statistics() if app.world.has_method("get_visual_statistics") else {}
	var file := FileAccess.open("/tmp/travel05-pair-" + label + "-" + profile + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"label": label, "profile": profile, "samples": samples, "statistics": stats}, "  "))
	file.close()
	print("PAIRED_CAPTURE_PASS: ", label, " ", profile, " ", targets.size(), " fixed views, shadows ON, no UI")
	app.queue_free()
	await process_frame
	quit(0)
