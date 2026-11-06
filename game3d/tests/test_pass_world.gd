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
	var world_script = load("res://scripts/mountain_pass.gd")
	var route = load("res://scripts/pass/route.gd")
	check(world_script != null, "complete mountain pass world script loads")
	if world_script == null:
		quit(1)
		return
	var world = world_script.new()
	root.add_child(world)
	world.build({"id": "mountain_pass_demo", "name": "Đèo mẫu", "type": "demo"})
	check(world.traffic.size() >= 2, "demo contains at least two physical traffic vehicles")
	check(world.pois.size() >= 2 and world.pois[0].title != world.pois[1].title, "two stop POIs have distinct names")
	check(world.pois[0].description != world.pois[1].description and world.pois[0].description.length() > 100 and world.pois[1].description.length() > 100, "two viewpoints include distinct substantive descriptions rather than renamed generic content")
	check(world.riding and world.active_avatar() == world.bike and not world.player.visible, "demo starts on motorbike with active vehicle camera")
	for vehicle in world.traffic:
		vehicle.paused = true
	for station in [5.0, 100.0, 230.0, 400.0, 550.0, 740.0]:
		world.bike.reset_to_distance(station)
		for i in 30:
			await physics_frame
		check(world.bike.is_on_floor() and world.bike.position.is_finite(), "bike rests on generated mesh/collision at station %.0f" % station)
	world.bike.look(Vector2(100000, 100000))
	check(absf(world.bike.view_yaw) <= 1.8 and world.bike.view_pitch >= -0.55, "riding camera yaw and downward pitch clamp to configured bounds")
	world.bike.look(Vector2(-100000, -100000))
	check(world.bike.view_pitch <= 0.4 and world.bike.camera.get_parent().collision_mask == 1, "riding camera upward pitch clamps and spring arm checks terrain collision")
	world.bike.reset_to_distance(740.0)
	world.bike.speed = 8
	world.set_drive_input(Vector2(0, 1))
	var collisions_before: int = world.bike.collisions
	for i in 100:
		await physics_frame
	check(world.bike.collisions > collisions_before and world.bike.position.z > -752, "actual generated endpoint barrier blocks bike before leaving route")
	world.bike.reset_to_distance(100.0)
	for i in 30:
		await physics_frame
	var right: Vector3 = route.right(100.0)
	world.bike.rotation.y = atan2(-right.x, -right.z)
	world.bike.speed = 8
	world.set_drive_input(Vector2(0, 1))
	collisions_before = world.bike.collisions
	for i in 60:
		await physics_frame
	check(world.bike.collisions > collisions_before and route.lateral_at(world.bike.position) <= 4.3, "actual generated roadside rail physically blocks outward riding")
	world.set_drive_input(Vector2.ZERO)
	world.bike.reset_to_distance(100.0)
	check(not world.toggle_vehicle() and world.riding, "dismount outside stop zone is rejected even at zero speed")
	for stop: float in route.STOPS:
		world.bike.reset_to_distance(stop, 8.0)
		world.bike.speed = 0.51
		check(not world.toggle_vehicle() and world.riding, "dismount rejects speed above 0.5 at stop %.0f" % stop)
		world.bike.speed = 0.5
		check(world.toggle_vehicle() and not world.riding, "dismount permits safe layby and threshold speed at stop %.0f" % stop)
		check(world.active_avatar() == world.player and world.player.camera.current and world.player.visible, "walking avatar and camera activate at stop %.0f" % stop)
		for i in 30:
			await physics_frame
		var standing_at: Vector3 = world.player.position
		for i in 30:
			await physics_frame
		check(Vector2(world.player.position.x, world.player.position.z).distance_to(Vector2(standing_at.x, standing_at.z)) <= 0.05, "idle walking avatar does not drift along curved road at stop %.0f" % stop)
		check(world.player.is_on_floor(), "dismounted walking avatar stands on real layby floor at stop %.0f" % stop)
		check(not world.nearest_poi().is_empty(), "nearby viewpoint becomes interactable only while walking at stop %.0f" % stop)
		var walk_from: Vector3 = world.player.position
		world.player.move_input = Vector2(0.5, 0)
		for i in 12:
			await physics_frame
		world.player.move_input = Vector2.ZERO
		check(world.player.position.distance_to(walk_from) > 0.15, "dismounted character can really walk at stop %.0f" % stop)
		world.player.position = world.bike.position + route.right(stop) * 6.0
		check(not world.toggle_vehicle() and not world.riding, "remount outside bike proximity is rejected at stop %.0f" % stop)
		world.player.position = world.bike.position + route.right(stop) * 1.3 + Vector3.UP * 0.2
		var original_bike = world.bike
		check(world.toggle_vehicle() and world.riding and world.bike == original_bike, "remount reuses same vehicle and restores riding at stop %.0f" % stop)
		check(world.nearest_poi().is_empty(), "riding past viewpoint cannot interact or auto-award a visit at stop %.0f" % stop)
	for checkpoint_case in [[100.0, 0.0], [220.0, 0.0], [229.0, 0.0], [230.0, 230.0], [231.0, 230.0], [470.0, 230.0], [540.0, 230.0], [551.0, 550.0], [570.0, 550.0]]:
		world.bike.reset_to_distance(checkpoint_case[0])
		world.bike.speed = 10
		world.return_to_start()
		check(world.checkpoint == checkpoint_case[1] and absf(route.distance_at(world.bike.position) - maxf(5.0, checkpoint_case[1])) < 0.05, "reset uses latest passed safe checkpoint at station %.0f → %.0f" % checkpoint_case)
	check(world.bike.speed == 0 and route.in_layby(world.bike.position), "reset returns moving bike to safe stop with zero speed")
	var captured: Dictionary = world.capture_road_state()
	check(captured.has("bike_s") and captured.has("lateral") and captured.has("checkpoint"), "world captures separate station/lateral road state")
	world.set_drive_input(Vector2(1, 1))
	world.set_paused(true)
	check(world.bike.drive_input == Vector2.ZERO and world.player.move_input == Vector2.ZERO and world.bike.paused, "modal pause clears riding and walking input")
	world.set_paused(false)
	check(world.bike.drive_input == Vector2.ZERO, "unpausing does not restore stale throttle")
	world.queue_free()
	await process_frame
	print("RESULT pass/world: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
