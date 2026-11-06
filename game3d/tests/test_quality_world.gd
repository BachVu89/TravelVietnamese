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

func physics_snapshot(node: Node, result: Dictionary) -> void:
	if node is CollisionObject3D:
		result[str(node.get_instance_id())] = {"transform": node.global_transform, "layer": node.collision_layer, "mask": node.collision_mask}
	elif node is CollisionShape3D:
		result[str(node.get_instance_id())] = {"transform": node.global_transform, "shape_id": node.shape.get_instance_id(), "bounds": node.shape.get_debug_mesh().get_aabb(), "disabled": node.disabled}
	for child in node.get_children():
		physics_snapshot(child, result)

func motion_snapshot(world) -> Dictionary:
	var traffic: Array = []
	for car in world.traffic:
		traffic.append({"id": car.get_instance_id(), "pose": car.transform, "station": car.route_distance, "speed": car.travel_speed, "direction": car.direction, "paused": car.paused})
	return {"bike_id": world.bike.get_instance_id(), "bike_pose": world.bike.transform, "speed": world.bike.speed, "input": world.bike.drive_input, "velocity": world.bike.velocity, "riding": world.riding, "checkpoint": world.checkpoint, "traffic": traffic, "pois": world.pois.duplicate(true), "player_pose": world.player.transform, "bike_camera_pose": world.bike.camera.global_transform, "player_camera_pose": world.player.camera.global_transform}

func lights_match(world: Node3D, expected: bool) -> bool:
	var lights := world.find_children("*", "DirectionalLight3D", true, false)
	if lights.is_empty():
		return false
	for light in lights:
		if light.shadow_enabled != expected:
			return false
	return true

func same_motion(world, baseline: Dictionary) -> bool:
	var current := motion_snapshot(world)
	var expected := baseline.duplicate()
	var cameras_match := true
	for key in ["bike_camera_pose", "player_camera_pose"]:
		var before: Transform3D = expected[key]
		var after: Transform3D = current[key]
		# SpringArm3D internal updates can introduce tiny floating point jitter
		# even with gameplay frozen. Permit at most 0.001 scene-unit movement.
		cameras_match = cameras_match and before.origin.distance_to(after.origin) <= 0.001 and before.basis.is_equal_approx(after.basis)
		current.erase(key)
		expected.erase(key)
	return cameras_match and current == expected

func run() -> void:
	var world_script = load("res://scripts/mountain_pass.gd")
	var preferences = load("res://scripts/preferences.gd")
	var world = world_script.new()
	root.add_child(world)
	world.build({"id": "mountain_pass_demo", "name": "Quality test", "type": "sample"})
	world.set_physics_process(false)
	world.bike.set_physics_process(false)
	world.player.set_physics_process(false)
	for car in world.traffic:
		car.set_physics_process(false)
	world.bike.reset_to_distance(230.0, 8.0)
	world.bike.speed = 5.0
	world.bike.drive_input = Vector2(0.5, 1.0)
	world.checkpoint = 230.0
	# SpringArm3D has its own internal physics update; settle it after teleport
	# before measuring profile invariance. Gameplay bodies remain frozen.
	for i in 3:
		await physics_frame
	await process_frame
	var baseline: Dictionary = motion_snapshot(world)
	var colliders := {}
	physics_snapshot(world, colliders)
	check(colliders.size() > 20, "quality invariance test snapshots real generated road and vehicle colliders")
	preferences.apply(world, {"visual_quality": "economy", "shadows": false, "sensitivity": 1.4})
	await process_frame
	var economy: Dictionary = world.get_visual_statistics()
	check(economy.profile == "economy" and economy.decoration_groups > 0 and economy.visible_instances > 0, "economy profile selects a real nonempty decorative budget")
	check(lights_match(world, false), "economy honors independent shadows-off choice")
	check(is_equal_approx(world.bike.camera_sensitivity, 1.4) and is_equal_approx(world.player.camera_sensitivity, 1.4), "quality application preserves chosen camera sensitivity for both modes")
	check(same_motion(world, baseline), "economy application does not change pose, speed, input, mode, traffic, POIs or camera transforms")
	var current_colliders := {}
	physics_snapshot(world, current_colliders)
	check(current_colliders == colliders, "economy leaves collider identities, dimensions, layers and transforms unchanged")
	preferences.apply(world, {"visual_quality": "detail", "shadows": false, "sensitivity": 1.4})
	await process_frame
	var detail: Dictionary = world.get_visual_statistics()
	check(detail.profile == "detail" and detail.visible_instances > economy.visible_instances and detail.detail_instances == economy.detail_instances, "detail visibly enables more decorative instances without rebuilding gameplay world")
	check(lights_match(world, false), "detail cannot override independent shadows-off choice")
	check(same_motion(world, baseline), "detail leaves vehicle/player state, traffic and POIs unchanged")
	current_colliders.clear()
	physics_snapshot(world, current_colliders)
	check(current_colliders == colliders, "detail leaves complete physics collider snapshot unchanged")
	world.apply_visual_quality("detail")
	check(world.get_visual_statistics() == detail, "applying same quality twice is idempotent")
	preferences.apply(world, {"visual_quality": "economy", "shadows": true, "sensitivity": 1.4})
	check(lights_match(world, true) and world.get_visual_statistics() == economy, "returning to economy restores budget while shadows-on remains independent")
	world.apply_visual_quality("unknown")
	check(world.get_visual_statistics().profile == "economy", "direct invalid world profile falls back to economy safely")
	check(same_motion(world, baseline), "repeated quality toggles do not reset checkpoint or riding state")
	world.queue_free()
	await process_frame
	print("RESULT quality/world: %d checks, %d failures; economy %d/detail %d visible decoration instances" % [checks, failures, economy.visible_instances, detail.visible_instances])
	quit(1 if failures else 0)
