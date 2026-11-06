class_name PassArt
extends RefCounted

static var _materials: Dictionary = {}

static func material(color: String, roughness: float = 0.8) -> StandardMaterial3D:
	var key := color+str(roughness)
	if _materials.has(key):
		return _materials[key]
	var mat := StandardMaterial3D.new()
	_materials[key] = mat
	mat.albedo_color = Color(color)
	mat.roughness = roughness
	return mat

static func box(parent: Node3D, at: Vector3, dimensions: Vector3, mat: Material, collision: bool = false) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var primitive := BoxMesh.new()
	primitive.size = dimensions
	mesh.mesh = primitive
	mesh.position = at
	mesh.material_override = mat
	parent.add_child(mesh)
	if collision:
		var body := StaticBody3D.new()
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = dimensions
		shape.shape = box_shape
		body.add_child(shape)
		mesh.add_child(body)
	return mesh

static func ellipsoid(parent: Node3D, at: Vector3, scale_value: Vector3, mat: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radial_segments = 12
	sphere.rings = 6
	node.mesh = sphere
	node.position = at
	node.scale = scale_value
	node.material_override = mat
	parent.add_child(node)
	return node

static func limb(parent: Node3D, from: Vector3, to: Vector3, radius: float, mat: Material) -> void:
	var mesh := MeshInstance3D.new()
	var tube := CylinderMesh.new()
	tube.top_radius = radius
	tube.bottom_radius = radius
	tube.height = from.distance_to(to)
	tube.radial_segments = 8
	mesh.mesh = tube
	mesh.position = (from + to) * 0.5
	mesh.material_override = mat
	parent.add_child(mesh)
	if absf((to-from).normalized().dot(Vector3.UP)) < 0.99:
		mesh.look_at_from_position(mesh.position, to, Vector3.UP)
		mesh.rotate_object_local(Vector3.RIGHT, PI / 2)

static func bike_model(parent: Node3D) -> Node3D:
	var model := Node3D.new()
	parent.add_child(model)
	var rubber := material("151B1D")
	var steel := material("949E9E", 0.25)
	var paint := material("B4AA99", 0.5)
	var cloth := material("536B59")
	var denim := material("283C50")
	for z: float in [-0.72, 0.72]:
		var wheel := MeshInstance3D.new()
		var tire := TorusMesh.new()
		tire.inner_radius = 0.22
		tire.outer_radius = 0.36
		tire.rings = 16
		tire.ring_segments = 8
		wheel.mesh = tire
		wheel.rotation.z = PI/2
		wheel.position = Vector3(0, 0.39, z)
		wheel.material_override = rubber
		model.add_child(wheel)
		limb(model, Vector3(-0.12,0.39,z), Vector3(0.12,0.39,z), 0.08, steel)
	box(model, Vector3(0,0.83,0.1), Vector3(0.39,0.25,0.8), paint)
	# Two-level Cub seat: lower rider saddle, slightly higher rear step.
	box(model, Vector3(0,1.0,0.02), Vector3(0.4,0.09,0.52), rubber)
	box(model, Vector3(0,1.05,0.44), Vector3(0.42,0.09,0.34), rubber)
	# Front fender hugging the wheel, three angled segments.
	box(model, Vector3(0,0.79,-0.87), Vector3(0.3,0.04,0.24), paint).rotation.x = -0.5
	box(model, Vector3(0,0.85,-0.72), Vector3(0.3,0.04,0.24), paint)
	box(model, Vector3(0,0.79,-0.57), Vector3(0.3,0.04,0.24), paint).rotation.x = 0.5
	# Weathered Cub-style leg shield at the front, like the reference bike.
	box(model, Vector3(0,0.66,-0.52), Vector3(0.44,0.6,0.1), material("C9C2B0",0.55)).rotation.x = 0.22
	# Rear rack with a strapped luggage roll — the touring load in the photo.
	box(model, Vector3(0,1.08,0.6), Vector3(0.36,0.05,0.42), steel)
	ellipsoid(model, Vector3(0,1.27,0.62), Vector3(0.66,0.36,0.44), material("5C6650",0.9))
	for strap_x: float in [-0.14,0.14]:
		box(model, Vector3(strap_x,1.27,0.62), Vector3(0.05,0.4,0.48), rubber)
	# Cloth panniers hanging at both sides of the rack, plus a red tail light.
	for side: float in [-1,1]:
		box(model, Vector3(side*0.31,0.9,0.58), Vector3(0.17,0.36,0.46), material("4C5B4A",0.9))
	box(model, Vector3(0,1.0,0.87), Vector3(0.16,0.09,0.04), material("A33327",0.3))
	ellipsoid(model, Vector3(0,0.65,0), Vector3(0.5,0.48,0.6), steel)
	# Exhaust pipe and muffler low on the right side.
	limb(model, Vector3(0.17,0.42,0.05), Vector3(0.21,0.44,0.4), 0.04, steel)
	limb(model, Vector3(0.21,0.44,0.4), Vector3(0.22,0.47,0.8), 0.068, steel)
	for x: float in [-0.14,0.14]:
		limb(model,Vector3(x,0.4,-0.72),Vector3(x,1.14,-0.49),0.045,steel)
	limb(model,Vector3(-0.38,1.19,-0.5),Vector3(0.38,1.19,-0.5),0.045,steel)
	# Round headlight in a steel bucket, amber indicators, stalk mirrors.
	var lamp := MeshInstance3D.new()
	var lamp_mesh := CylinderMesh.new()
	lamp_mesh.top_radius = 0.105
	lamp_mesh.bottom_radius = 0.115
	lamp_mesh.height = 0.09
	lamp_mesh.radial_segments = 14
	lamp.mesh = lamp_mesh
	lamp.rotation.x = PI / 2
	lamp.position = Vector3(0, 1.04, -0.64)
	lamp.material_override = material("F5E4B5", 0.15)
	model.add_child(lamp)
	box(model, Vector3(0,1.04,-0.585), Vector3(0.19,0.17,0.06), steel)
	for side: float in [-1,1]:
		box(model, Vector3(side*0.22,1.05,-0.6), Vector3(0.07,0.06,0.05), material("D98A2B",0.3))
		limb(model, Vector3(side*0.36,1.19,-0.5), Vector3(side*0.5,1.44,-0.52), 0.02, steel)
		box(model, Vector3(side*0.53,1.47,-0.52), Vector3(0.17,0.11,0.03), material("22363C",0.15))
	# An: articulated silhouette, boots, jacket, hands and helmet.
	var rider := Node3D.new()
	rider.name = "Rider"
	model.add_child(rider)
	box(rider,Vector3(0,1.5,0.15),Vector3(0.46,0.62,0.28),cloth).rotation.x = -0.16
	ellipsoid(rider,Vector3(0,1.76,0.13),Vector3(0.54,0.24,0.3),cloth)
	box(rider,Vector3(0,1.6,0.4),Vector3(0.37,0.48,0.17),material("46523F",0.9))
	box(rider,Vector3(0,1.5,0.53),Vector3(0.27,0.32,0.05),material("384B3D",0.9))
	ellipsoid(rider,Vector3(0,1.9,0.4),Vector3(0.34,0.16,0.2),material("8A7B52",0.9))
	ellipsoid(rider,Vector3(0,2.01,0.06),Vector3(0.5,0.53,0.5),material("41474E",0.35))
	box(rider,Vector3(0,2.0,-0.15),Vector3(0.37,0.14,0.08),material("22363C",0.2))
	box(rider,Vector3(0,1.88,-0.13),Vector3(0.33,0.11,0.12),material("41474E",0.35))
	for side: float in [-1,1]:
		limb(rider,Vector3(side*0.2,1.7,0.1),Vector3(side*0.33,1.38,-0.2),0.09,cloth)
		limb(rider,Vector3(side*0.33,1.38,-0.2),Vector3(side*0.33,1.2,-0.5),0.07,cloth)
		ellipsoid(rider,Vector3(side*0.33,1.2,-0.5),Vector3(0.15,0.13,0.17),material("2A2E33",0.6))
		limb(rider,Vector3(side*0.16,1.22,0.3),Vector3(side*0.32,0.8,-0.05),0.105,denim)
		limb(rider,Vector3(side*0.32,0.8,-0.05),Vector3(side*0.27,0.48,0.3),0.09,denim)
		box(rider,Vector3(side*0.27,0.43,0.19),Vector3(0.18,0.13,0.35),rubber)
	return model

static func walker_model(parent: Node3D) -> Node3D:
	var model := Node3D.new()
	model.name = "AnWalkingRider"
	parent.add_child(model)
	var cloth := material("536B59")
	var denim := material("283C50")
	var boots := material("151B1D")
	var skin := material("CCA889")
	box(model,Vector3(0,1.15,0),Vector3(0.47,0.6,0.29),cloth)
	ellipsoid(model,Vector3(0,1.42,0),Vector3(0.54,0.22,0.3),cloth)
	# Same helmet, visor and touring jacket as the rider, now standing upright.
	ellipsoid(model,Vector3(0,1.69,0),Vector3(0.5,0.53,0.5),material("41474E",0.35))
	box(model,Vector3(0,1.69,0.21),Vector3(0.37,0.14,0.08),material("22363C",0.2))
	box(model,Vector3(0,1.57,0.18),Vector3(0.33,0.11,0.12),material("41474E",0.35))
	box(model,Vector3(0,1.14,-0.17),Vector3(0.34,0.42,0.16),material("384B3D"))
	box(model,Vector3(0,1.06,-0.28),Vector3(0.26,0.3,0.05),material("46523F",0.9))
	ellipsoid(model,Vector3(0,1.42,-0.17),Vector3(0.32,0.15,0.18),material("8A7B52",0.9))
	for side: float in [-1,1]:
		limb(model,Vector3(side*0.25,1.36,0),Vector3(side*0.31,1.02,0.03),0.085,cloth)
		limb(model,Vector3(side*0.31,1.02,0.03),Vector3(side*0.31,0.79,0.08),0.065,cloth)
		ellipsoid(model,Vector3(side*0.31,0.75,0.08),Vector3(0.13,0.19,0.13),skin)
		limb(model,Vector3(side*0.13,0.88,0),Vector3(side*0.14,0.48,0.02),0.105,denim)
		limb(model,Vector3(side*0.14,0.48,0.02),Vector3(side*0.14,0.14,0.01),0.09,denim)
		box(model,Vector3(side*0.14,0.1,0.08),Vector3(0.19,0.16,0.34),boots)
	return model
