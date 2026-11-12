class_name TravelPlayer
extends CharacterBody3D

signal traveled(distance: float)
signal looked(radians: float)
var camera_sensitivity := 1.0

var move_input := Vector2.ZERO
var yaw := 0.0
var pitch := -0.42
var speed := 6.0
var orbit: Node3D
var arm: SpringArm3D
var camera: Camera3D
var avatar: Node3D

func _ready() -> void:
	name = "An"
	collision_layer = 2
	collision_mask = 1
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.65
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position.y = 0.84
	add_child(collider)
	avatar = Node3D.new()
	add_child(avatar)
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.31
	capsule.height = 1.1
	body.mesh = capsule
	body.position.y = 0.94
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("d08048")
	body.material_override = material
	avatar.add_child(body)
	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.25
	sphere.height = 0.5
	head.mesh = sphere
	head.position.y = 1.69
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color("edc49a")
	head.material_override = skin
	avatar.add_child(head)
	var hat := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.02
	cone.bottom_radius = 0.5
	cone.height = 0.23
	hat.mesh = cone
	hat.position.y = 1.99
	var straw := StandardMaterial3D.new()
	straw.albedo_color = Color("e8c67b")
	hat.material_override = straw
	avatar.add_child(hat)
	orbit = Node3D.new()
	orbit.position.y = 1.45
	add_child(orbit)
	arm = SpringArm3D.new()
	arm.spring_length = 7.2
	arm.margin = 0.3
	arm.collision_mask = 1
	arm.add_excluded_object(get_rid())
	orbit.add_child(arm)
	camera = Camera3D.new()
	camera.fov = 65.0
	camera.near = 0.1
	camera.current = true
	arm.add_child(camera)
	update_camera()

func look(delta: Vector2) -> void:
	var previous_yaw := yaw
	var previous_pitch := pitch
	yaw -= delta.x * 0.005 * camera_sensitivity
	pitch = clampf(pitch - delta.y * 0.004 * camera_sensitivity, -1.12, -0.08)
	update_camera()
	looked.emit(absf(yaw - previous_yaw) + absf(pitch - previous_pitch))

func update_camera() -> void:
	if orbit:
		orbit.rotation = Vector3(pitch, yaw, 0)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 22.0 * delta
	else:
		velocity.y = -0.5
	var direction := Vector3(move_input.x, 0, move_input.y).rotated(Vector3.UP, yaw)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if direction.length_squared() > 0.01:
		avatar.rotation.y = lerp_angle(avatar.rotation.y, atan2(direction.x, direction.z), minf(delta * 12, 1.0))
	var before := global_position
	move_and_slide()
	var actual_distance := Vector2(global_position.x - before.x, global_position.z - before.z).length()
	if move_input.length_squared() > 0.01 and is_on_floor() and actual_distance > 0 and actual_distance <= speed * delta * 1.5 + 0.05:
		traveled.emit(actual_distance)
	if global_position.y < -8:
		global_position = Vector3(0, 5, 9)
		velocity = Vector3.ZERO
		reset_physics_interpolation()
