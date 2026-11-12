class_name TravelNavigation
extends RefCounted

static func next_target(pois: Array, visited: Array, origin: Vector3, camera_yaw: float) -> Dictionary:
	var target: Dictionary = {}
	var best := INF
	for poi in pois:
		if visited.has(poi.id):
			continue
		var offset := Vector2(poi.position.x - origin.x, poi.position.z - origin.z)
		var distance := offset.length()
		if distance >= best:
			continue
		best = distance
		var angle := wrapf(atan2(offset.x, -offset.y) + camera_yaw, -PI, PI)
		var bearing := "trước"
		if absf(angle) >= PI * 5.0 / 6.0:
			bearing = "sau"
		elif angle > PI / 6.0:
			bearing = "phải"
		elif angle < -PI / 6.0:
			bearing = "trái"
		target = {"id": poi.id, "title": poi.title, "distance": distance, "bearing": bearing}
	return target
