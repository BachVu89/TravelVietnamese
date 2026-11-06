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

func obstacle(parent: Node3D, point: Vector3, dimensions: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collision.shape = shape
	body.add_child(collision)
	body.position = point
	parent.add_child(body)
	return body

func run() -> void:
	var bike_script = load("res://scripts/pass/bike.gd")
	var traffic_script = load("res://scripts/pass/traffic.gd")
	var route = load("res://scripts/pass/route.gd")
	check(bike_script != null and traffic_script != null, "vehicle physics scripts load")
	if bike_script == null or traffic_script == null:
		quit(1)
		return
	var world := Node3D.new()
	root.add_child(world)
	obstacle(world, Vector3(0, -0.5, 0), Vector3(300, 1, 300))
	var bike = bike_script.new()
	bike.position = Vector3(0, 0.5, 0)
	world.add_child(bike)
	for i in 40:
		await physics_frame
	check(bike.is_on_floor(), "bike settles on physical road floor")
	bike.drive_input = Vector2(0, 1)
	var initial: Vector3 = bike.position
	for i in 60:
		await physics_frame
	check(bike.speed > 4 and bike.speed < 6 and bike.position.distance_to(initial) > 1, "holding throttle accelerates and moves bike through physics")
	var speed_before: float = bike.speed
	bike.drive_input = Vector2.ZERO
	for i in 30:
		await physics_frame
	check(bike.speed <= speed_before and bike.speed >= 0, "releasing throttle does not increase speed")
	bike.drive_input = Vector2(0, -1)
	for i in 60:
		await physics_frame
	check(is_zero_approx(bike.speed), "brake reduces running speed to a complete stop")
	bike.drive_input = Vector2(1, 1)
	var yaw_before: float = bike.rotation.y
	for i in 60:
		await physics_frame
	check(absf(bike.rotation.y - yaw_before) > 0.1 and absf(bike.position.x) > 0.1, "simultaneous throttle and steering changes heading and lateral position")
	bike.position = Vector3(0, 0.2, 0)
	bike.rotation.y = 0
	bike.speed = 0
	bike.velocity = Vector3.ZERO
	bike.drive_input = Vector2(0, 1)
	for i in 300:
		await physics_frame
	check(is_finite(bike.speed) and bike.speed <= bike.MAX_SPEED + 0.001 and bike.speed >= bike.MAX_SPEED - 0.1, "sustained throttle reaches finite configured maximum speed")
	bike.paused = true
	var paused_at: Vector3 = bike.position
	for i in 10:
		await physics_frame
	check(is_zero_approx(bike.speed) and bike.position.distance_to(paused_at) < 0.01, "paused bike stops receiving throttle and stays stationary")
	bike.paused = false
	bike.position = Vector3(0, 0.2, 0)
	bike.rotation.y = 0
	bike.speed = 8
	bike.velocity = Vector3.ZERO
	bike.drive_input = Vector2(0, 1)
	var car = traffic_script.new()
	world.add_child(car)
	car.paused = true
	car.position = Vector3(0, 0, -7)
	car.rotation.y = 0
	for i in 90:
		await physics_frame
	check(bike.collisions > 0 and bike.position.z > -5, "actual traffic collider blocks the moving player bike")
	check(bike.speed < 1.0, "bike speed is reduced on traffic contact")
	car.queue_free()
	await process_frame
	bike.position = Vector3(0, 0.2, 0)
	bike.rotation.y = 0
	bike.speed = 8
	bike.velocity = Vector3.ZERO
	var before_collisions: int = bike.collisions
	obstacle(world, Vector3(0, 2, -5), Vector3(15, 4, 0.5))
	for i in 75:
		await physics_frame
	check(bike.collisions > before_collisions and bike.position.z > -4.2, "physical road-edge obstacle prevents bike passing through")
	bike.paused = true
	var snapshots: Array[Vector3] = []
	for trial in 2:
		var vehicle = traffic_script.new()
		world.add_child(vehicle)
		vehicle.set_physics_process(false)
		for i in 180:
			vehicle._physics_process(1.0 / 60.0)
		snapshots.append(vehicle.position)
		check(vehicle.route_distance > 80.0, "traffic moves locally along fixed route in deterministic trial " + str(trial))
		vehicle.queue_free()
		await process_frame
	check(snapshots[0].distance_to(snapshots[1]) <= 0.0001, "identical traffic initial state and 180 fixed ticks reproduce position within 0.0001 scene units")
	world.queue_free()
	await process_frame
	print("RESULT pass/physics: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
