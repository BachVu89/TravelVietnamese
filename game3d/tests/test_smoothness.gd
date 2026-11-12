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

func drag(index: int, from: Vector2, to: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = to
	event.relative = to - from
	return event

func touch(index: int, position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	return event

func run() -> void:
	var performance = load("res://scripts/performance.gd").new()
	check(not performance.sample(0.5) and performance.average_fps == 0.0, "first long pause frame is ignored instead of counting as slow")
	for i in range(130):
		performance.sample(1.0 / 60.0)
	check(performance.average_fps > 57.0 and performance.is_smooth(), "steady 60 FPS window reports smooth frame pacing")
	var low = load("res://scripts/performance.gd").new()
	var downgraded := false
	for i in range(130):
		if low.sample(1.0 / 30.0):
			downgraded = true
	check(downgraded and low.average_fps < 48.0 and not low.is_smooth(), "sustained 30 FPS window requests a detail downgrade")
	check(not low.sample(0.0) and not low.sample(0.9), "zero-length and resume spikes never request a downgrade")

	var controls = load("res://scripts/touch_controls.gd").new()
	root.add_child(controls)
	controls.size = Vector2(1280, 720)
	controls.set_drive_mode(true)
	controls._input(touch(3, Vector2(100, 550), true))
	controls._input(drag(3, Vector2(100, 550), Vector2(104, 552)))
	check(controls.movement == Vector2.ZERO, "thumb jitter inside the deadzone does not steer the bike")
	controls._input(drag(3, Vector2(104, 552), Vector2(210, 550)))
	check(is_equal_approx(controls.movement.x, 1.0) and is_zero_approx(controls.movement.y), "full joystick deflection still reaches exactly 1.0 after deadzone rescale")
	controls._input(touch(1, controls.gas_center(), true))
	check(controls.drive_input == Vector2(1, 1), "throttle and steering still combine on separate fingers")
	check(controls.pedal_radius() >= 44.0 and controls.gas_center().distance_to(controls.brake_center()) > 100.0, "pedal hit area and spacing stay thumb-sized")
	controls.cancel_touches()
	controls.queue_free()

	var settings = ProjectSettings.get_setting("physics/common/physics_interpolation")
	check(settings == true, "project enables 3D physics interpolation for smooth motion between ticks")

	var world = load("res://scripts/mountain_pass.gd").new()
	root.add_child(world)
	world.build({"id": "mountain_pass_demo", "name": "Smoothness test", "type": "sample"})
	world.set_physics_process(false)
	world.bike.set_physics_process(false)
	for car in world.traffic:
		car.set_physics_process(false)
	world.apply_visual_quality("detail")
	var base: Dictionary = world.get_visual_statistics()
	check(base.adaptive_detail == 0 and base.visible_instances > 0, "full quality profile starts with no adaptive downgrade")
	var shadows_before := 0
	for child in world.get_children():
		if child is MultiMeshInstance3D and child.get_meta("pass_decoration", false) and child.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_ON:
			shadows_before += 1
	check(shadows_before > 0, "detail profile still casts decorative shadows near the player")
	var camera_far: float = world.bike.camera.far
	world.set_adaptive_detail(1)
	var reduced: Dictionary = world.get_visual_statistics()
	check(reduced.adaptive_detail == 1 and reduced.visible_instances < base.visible_instances, "first adaptive step removes decorative instances")
	check(world.bike.camera.far < camera_far, "first adaptive step shortens view distance")
	var shadows_after := 0
	for child in world.get_children():
		if child is MultiMeshInstance3D and child.get_meta("pass_decoration", false) and child.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_ON:
			shadows_after += 1
	check(shadows_after == 0, "adaptive step stops decorative shadow casting")
	world.set_adaptive_detail(2)
	var lowest: Dictionary = world.get_visual_statistics()
	check(lowest.visible_instances < reduced.visible_instances and world.bike.camera.far <= 260.0, "second adaptive step trims instances and distance further")
	world.set_adaptive_detail(2)
	check(world.get_visual_statistics() == lowest, "repeated adaptive request is idempotent")
	world.set_adaptive_detail(9)
	check(world.get_visual_statistics() == lowest, "out-of-range adaptive level clamps safely")
	world.set_adaptive_detail(0)
	check(world.get_visual_statistics().visible_instances == base.visible_instances, "clearing the adaptive tier restores the full decorative budget")
	world.queue_free()
	await process_frame
	print("RESULT smoothness: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
