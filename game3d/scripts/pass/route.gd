class_name PassRoute
extends RefCounted

const LENGTH := 750.0
const STOPS := [230.0, 550.0]
const HALF_WIDTH := 3.5

static func point(distance: float, lane: float = 0.0) -> Vector3:
	var s := clampf(distance, 0, LENGTH)
	return Vector3(26.0 * sin(s / 85.0) + 10.0 * sin(s / 37.0) + lane, 4.0 + s * 0.065 + 3.0 * sin(s / 100.0), -s)

static func tangent(distance: float) -> Vector3:
	return (point(minf(distance + 0.3, LENGTH)) - point(maxf(distance - 0.3, 0))).normalized()

static func right(distance: float) -> Vector3:
	return tangent(distance).cross(Vector3.UP).normalized()

static func at(distance: float, lateral: float = 0.0) -> Vector3:
	return point(distance) + right(distance) * lateral

static func distance_at(position: Vector3) -> float:
	var distance := clampf(-position.z,0,LENGTH)
	for i in range(4):
		var center := point(distance)
		var t := tangent(distance)
		distance = clampf(distance + (position-center).dot(t) * absf(t.z),0,LENGTH)
	return distance

static func lateral_at(position: Vector3) -> float:
	var d := distance_at(position)
	return (position - point(d)).dot(right(d))

static func in_layby(position: Vector3) -> bool:
	for stop: float in STOPS:
		if absf(distance_at(position) - stop) < 17.0 and lateral_at(position) > 4.3 and lateral_at(position) < 12.5:
			return true
	return false

static func outer_edge(distance: float) -> float:
	for stop: float in STOPS:
		if absf(distance - stop) < 21.0:
			return 13.0
	return 4.25
