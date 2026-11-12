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
	var route = load("res://scripts/pass/route.gd")
	check(route != null, "mountain pass route script loads")
	if route == null:
		quit(1)
		return
	var measured_length := 0.0
	var continuous := true
	var frames_valid := true
	var previous: Vector3 = route.point(0.0)
	var start_height: float = previous.y
	var bends := 0.0
	var previous_tangent: Vector3 = route.tangent(0.0)
	for i in range(1, int(route.LENGTH) + 1):
		var point: Vector3 = route.point(float(i))
		var tangent: Vector3 = route.tangent(float(i))
		var right: Vector3 = route.right(float(i))
		var segment := previous.distance_to(point)
		measured_length += segment
		continuous = continuous and point.is_finite() and segment > 0 and segment < 2.0
		frames_valid = frames_valid and is_equal_approx(tangent.length(), 1.0) and is_equal_approx(right.length(), 1.0) and absf(tangent.dot(right)) < 0.001
		bends += absf(previous_tangent.x - tangent.x)
		previous = point
		previous_tangent = tangent
	check(measured_length >= 700 and measured_length <= 800, "sampled 3D centerline length is 700–800 scene units: %.3f" % measured_length)
	check(continuous, "centerline samples are finite, connected and free of jumps")
	check(frames_valid, "route tangent and lateral axes are normalized and orthogonal")
	check(absf(previous.y - start_height) > 10 and bends > 0.5, "route has meaningful elevation change and bends")
	check(route.point(-100) == route.point(0) and route.point(route.LENGTH + 100) == route.point(route.LENGTH), "sampling outside route endpoints clamps safely")
	check(route.STOPS.size() >= 2 and absf(route.STOPS[1] - route.STOPS[0]) > 100, "at least two separated stops are configured")
	var station_error := 0.0
	var lateral_error := 0.0
	for station in [30.0, 100.0, 214.0, 230.0, 246.0, 400.0, 534.0, 550.0, 566.0, 710.0]:
		for lateral in [-3.0, 0.0, 1.7, 7.0, 12.0]:
			var projected: Vector3 = route.at(station, lateral)
			station_error = maxf(station_error, absf(route.distance_at(projected) - station))
			lateral_error = maxf(lateral_error, absf(route.lateral_at(projected) - lateral))
	check(station_error <= 0.05, "station projection round-trip within SA tolerance 0.05: %.6f" % station_error)
	check(lateral_error <= 0.05, "lateral projection round-trip within SA tolerance 0.05: %.6f" % lateral_error)
	for stop: float in route.STOPS:
		check(route.in_layby(route.at(stop, 7.0)), "safe layby point is recognized at stop %.0f" % stop)
		check(not route.in_layby(route.at(stop, 0.0)), "driving lane is not a parking area at stop %.0f" % stop)
		check(not route.in_layby(route.at(stop + 35.0, 7.0)), "leaving stop distance rejects parking at stop %.0f" % stop)
		check(route.outer_edge(stop) > route.outer_edge(stop + 35.0), "stop widens the safe road edge at %.0f" % stop)
	print("RESULT pass/route: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
