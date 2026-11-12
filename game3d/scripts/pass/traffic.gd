class_name PassTraffic
extends CharacterBody3D

var route_distance := 80.0
var travel_speed := 8.0
var direction := 1.0
var lane := -1.65
var paused := false
var blocked := false
var bus := false

func _ready() -> void:
	collision_layer = 8
	collision_mask = 1 | 2 | 4 | 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.65,2.6 if bus else 1.5,5.8 if bus else 3.5)
	shape.shape = box
	shape.position.y = box.size.y/2+0.1
	add_child(shape)
	var paint := PassArt.material("D9D8CF" if bus else "637C83",0.35)
	PassArt.box(self,Vector3(0,1.4 if bus else 0.75,0),Vector3(1.6,2.3 if bus else 1.15,5.6 if bus else 3.3),paint)
	PassArt.box(self,Vector3(0,2.0 if bus else 1.35,-0.1),Vector3(1.63,0.7,4.5 if bus else 1.7),PassArt.material("2F464E",0.2))
	for x: float in [-0.83,0.83]:
		for z: float in [-1.8 if bus else -1.0,1.8 if bus else 1.0]:
			PassArt.ellipsoid(self,Vector3(x,0.4,z),Vector3(0.35,0.7,0.7),PassArt.material("151C20"))
	position = PassRoute.at(route_distance,lane)
	_orient()

func _orient() -> void:
	var tangent := PassRoute.tangent(route_distance) * direction
	rotation.y = atan2(-tangent.x,-tangent.z)

func _physics_process(delta: float) -> void:
	if paused:
		return
	# Physical motion stops on obstruction; route progress advances only with actual movement.
	var target_s := clampf(route_distance + direction*travel_speed*delta,0,PassRoute.LENGTH)
	var target := PassRoute.at(target_s,lane)
	var motion := target - global_position
	var hit := move_and_collide(motion)
	blocked = hit != null
	if not blocked:
		route_distance = target_s
		_orient()
	if route_distance <= 1 or route_distance >= PassRoute.LENGTH-1:
		# Endpoints are terminal parking areas: no visible teleport/recycle.
		paused = true
