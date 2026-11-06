class_name PassBike
extends CharacterBody3D

signal recovery_requested

const MAX_SPEED := 18.0
const ACCELERATION := 5.0
const BRAKING := 12.0
var speed := 0.0
var drive_input := Vector2.ZERO
var riding := true
var paused := false
var model: Node3D
var camera: Camera3D
var orbit: Node3D
var camera_sensitivity := 1.0
var view_yaw := 0.0
var view_pitch := 0.0
var collisions := 0
var distance_traveled := 0.0

func _ready() -> void:
	name = "Motorbike"
	collision_layer = 4
	collision_mask = 1 | 8
	floor_snap_length = 1.0
	floor_max_angle = deg_to_rad(48)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.68,1.55,1.8)
	shape.shape = box
	shape.position.y = 0.95
	add_child(shape)
	model = PassArt.bike_model(self)
	orbit = Node3D.new()
	orbit.position = Vector3(0,1.5,0)
	add_child(orbit)
	var arm := SpringArm3D.new()
	arm.spring_length = 7.0
	arm.rotation.x = -0.23
	arm.collision_mask = 1
	arm.add_excluded_object(get_rid())
	orbit.add_child(arm)
	camera = Camera3D.new()
	camera.fov = 69
	camera.far = 420
	arm.add_child(camera)
	camera.current = true

func look(motion: Vector2) -> void:
	view_yaw = clampf(view_yaw-motion.x*0.004*camera_sensitivity,-1.8,1.8)
	view_pitch = clampf(view_pitch-motion.y*0.003*camera_sensitivity,-0.55,0.4)
	orbit.rotation = Vector3(view_pitch,view_yaw,0)

func _physics_process(delta: float) -> void:
	if paused or not riding:
		speed = 0
		velocity = Vector3.ZERO
		return
	if drive_input.y > 0:
		speed = move_toward(speed, MAX_SPEED, ACCELERATION * drive_input.y * delta)
	elif drive_input.y < 0:
		speed = move_toward(speed, 0, BRAKING * -drive_input.y * delta)
	else:
		speed = move_toward(speed, 0, 1.2 * delta)
	rotation.y -= drive_input.x * minf(speed / 7.0, 1.0) * 0.85 * delta
	var direction := -global_basis.z
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y = -2.0 if is_on_floor() else velocity.y - 24.0 * delta
	var before := global_position
	move_and_slide()
	var travel := Vector2(global_position.x-before.x,global_position.z-before.z).length()
	distance_traveled += travel
	for i in get_slide_collision_count():
		var hit := get_slide_collision(i)
		if absf(hit.get_normal().y) < 0.45 and speed > 0.1:
			speed = 0
			collisions += 1
	model.rotation.z = lerpf(model.rotation.z, -drive_input.x * speed / MAX_SPEED * 0.16, delta * 5)
	if global_position.y < PassRoute.point(PassRoute.distance_at(global_position)).y - 12:
		if recovery_requested.has_connections():
			recovery_requested.emit()
		else:
			reset_to_distance(5.0)

func reset_to_distance(distance: float, lateral: float = 1.7) -> void:
	position = PassRoute.at(distance,lateral) + Vector3.UP * 0.15
	rotation.y = atan2(-PassRoute.tangent(distance).x,-PassRoute.tangent(distance).z)
	speed = 0
	velocity = Vector3.ZERO
	drive_input = Vector2.ZERO
