class_name PassVegetation
extends RefCounted

# Original geometry: no imported tree assets, alpha foliage or per-tree nodes.
static func _append(surface: SurfaceTool, mesh: Mesh, at: Vector3, scale_value: Vector3, rotation_y: float = 0.0) -> void:
	var basis := Basis(Vector3.UP, rotation_y).scaled(scale_value)
	surface.append_from(mesh,0,Transform3D(basis,at))

static func tree_mesh(form: int, leaves: bool) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	if leaves:
		if form == 1:
			# Overlapping irregular needle tiers; a readable conifer silhouette.
			for level in range(5):
				var cone := CylinderMesh.new()
				cone.radial_segments = 9
				cone.top_radius = 0.08
				cone.bottom_radius = 2.6-float(level)*0.38
				cone.height = 2.8
				_append(st,cone,Vector3(sin(level*2.3)*0.18,4.0+level*0.95,cos(level)*0.16),Vector3(1,1,0.87),level*0.7)
		else:
			var cluster := SphereMesh.new()
			cluster.radial_segments = 9
			cluster.rings = 5
			var count := 8 if form==0 else 6
			for i in range(count):
				var angle := float(i)*2.399
				var radius := 1.65 if form==0 else 0.75
				var p := Vector3(cos(angle)*radius,5.0+sin(i*1.9)*0.8+float(i%3)*0.6,sin(angle)*radius)
				var size_value := Vector3(3.2,2.1,2.8) if form==0 else Vector3(1.9,3.2,1.8)
				_append(st,cluster,p,size_value*(0.85+float(i%3)*0.12),angle)
	else:
		var trunk := CylinderMesh.new()
		trunk.top_radius = 0.13
		trunk.bottom_radius = 0.31 if form==0 else 0.22
		trunk.height = 5.7 if form!=2 else 7.0
		trunk.radial_segments = 7
		_append(st,trunk,Vector3(0,trunk.height/2,0),Vector3.ONE)
		for i in range(4):
			var branch := CylinderMesh.new()
			branch.top_radius = 0.055
			branch.bottom_radius = 0.12
			branch.height = 2.2
			branch.radial_segments = 5
			var angle := i*2.399
			var branch_basis := Basis(Vector3.UP,angle)*Basis(Vector3.FORWARD,0.85)
			st.append_from(branch,0,Transform3D(branch_basis,Vector3(cos(angle)*0.6,3.5+i*0.4,sin(angle)*0.6)))
	return st.commit()

static func understory_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cluster := SphereMesh.new()
	cluster.radial_segments = 7
	cluster.rings = 3
	for i in range(4):
		var a := i*2.399
		_append(st,cluster,Vector3(cos(a)*0.45,0.45+float(i%2)*0.2,sin(a)*0.45),Vector3(1.2,0.9,1.0),a)
	# Opaque fern fronds add broken outlines at knee height.
	for i in range(7):
		var a := i*TAU/7
		var base := Vector3(0,0.15,0)
		var tip := Vector3(cos(a)*1.1,0.75,sin(a)*1.1)
		var side := Vector3(-sin(a),0,cos(a))*0.13
		for v: Vector3 in [base,tip+side,tip-side,base,tip-side,tip+side]:
			st.add_vertex(v)
	st.generate_normals()
	return st.commit()

static func terrain_point(distance: float, lateral: float) -> Vector3:
	var p := PassRoute.at(distance,lateral)
	var offset := maxf(0,absf(lateral)-4.25)
	p.y += offset*(0.72 if lateral<0 else -0.55)
	p.y += sin(distance*0.07)*offset*0.08
	# Irregular rock terraces, blended to zero at the shoulder.
	p.y += sin(distance*0.12+lateral*0.25)*sin(lateral*0.41)*minf(offset*0.13,2.7)
	return p

const MODEL_DIR := "res://assets/models/quaternius/"
# Native AABB heights (m) of the CC0 Quaternius models, probed on import
# (qa/probe_assets.gd); instances are scaled from these to target heights.
const MODEL_HEIGHTS := {"Pine_1": 7.32, "Pine_2": 8.72, "Pine_3": 10.24, "Tree_1": 9.43, "Tree_2": 9.44, "Tree_3": 7.64, "Tree_4": 7.26, "Tree_5": 7.01, "Bush_with_Flowers_1": 1.58, "Fern_1": 2.69, "Grass_Wispy_1": 1.07, "Tall_Grass_1": 1.87, "Rock_Medium_1": 1.90, "Rock_Medium_2": 2.26, "Plant_1": 1.01, "Plant_Big_1": 0.25}
static var _model_meshes: Dictionary = {}

static func _model_mesh(model_name: String) -> ArrayMesh:
	if _model_meshes.has(model_name):
		return _model_meshes[model_name]
	var scene: PackedScene = load(MODEL_DIR + model_name + ".glb")
	var instance := scene.instantiate()
	var found: ArrayMesh = null
	var stack: Array[Node] = [instance]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is MeshInstance3D and node.mesh is ArrayMesh:
			found = node.mesh
			break
		for child in node.get_children():
			stack.append(child)
	instance.free()
	_model_meshes[model_name] = found
	return found

static func add_group_imported(world: Node3D, title: String, mesh: Mesh, positions: Array[Transform3D], chunk: int, economy_ratio: float = 0.58) -> void:
	if positions.is_empty():
		return
	var origin := PassRoute.point(float(chunk) * 125.0 + 62.5)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = positions.size()
	for i in positions.size():
		var transform_value := positions[i]
		transform_value.origin -= origin
		mm.set_instance_transform(i, transform_value)
	var group := MultiMeshInstance3D.new()
	group.name = title + "Chunk" + str(chunk)
	group.position = origin
	group.multimesh = mm
	group.set_meta("pass_decoration", true)
	group.set_meta("economy_ratio", economy_ratio)
	group.set_meta("detail_count", positions.size())
	group.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	world.add_child(group)

static func _scatter(world: Node3D, rng: RandomNumberGenerator, chunk: int, model_name: String, count: int, off_min: float, off_max: float, h_min: float, h_max: float, sink: float, economy_ratio: float, avoid_stops_band: bool = false) -> void:
	var transforms: Array[Transform3D] = []
	var native := float(MODEL_HEIGHTS[model_name])
	for i in range(count):
		var distance := rng.randf_range(chunk * 125, (chunk + 1) * 125)
		var side := -1.0 if i % 2 == 0 else 1.0
		if avoid_stops_band and side > 0:
			var near_stop := false
			for stop: float in PassRoute.STOPS:
				if absf(distance - stop) < 24.0:
					near_stop = true
			if near_stop:
				continue
		var p := terrain_point(distance, rng.randf_range(off_min, off_max) * side)
		p.y -= sink
		var s := rng.randf_range(h_min, h_max) / native
		var basis := Basis(Vector3.UP, rng.randf_range(0, TAU)).scaled(Vector3(s, s * rng.randf_range(0.92, 1.15), s))
		transforms.append(Transform3D(basis, p))
	add_group_imported(world, model_name, _model_mesh(model_name), transforms, chunk, economy_ratio)

static func add_group(world: Node3D, title: String, mesh: Mesh, material: Material, positions: Array[Transform3D], colors: Array[Color], chunk: int, economy_ratio: float = 0.58) -> void:
	if positions.is_empty():
		return
	var origin := PassRoute.point(float(chunk)*125.0+62.5)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = not colors.is_empty()
	mm.mesh = mesh
	mm.instance_count = positions.size()
	for i in positions.size():
		var transform_value := positions[i]
		transform_value.origin -= origin
		mm.set_instance_transform(i,transform_value)
		if mm.use_colors:
			mm.set_instance_color(i,colors[i])
	var group := MultiMeshInstance3D.new()
	group.name = title+"Chunk"+str(chunk)
	group.position = origin
	group.multimesh = mm
	group.material_override = material
	group.set_meta("pass_decoration",true)
	group.set_meta("economy_ratio",economy_ratio)
	group.set_meta("detail_count",positions.size())
	group.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if title.begins_with("Understory") else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	world.add_child(group)

static func build(world: Node3D) -> void:
	# Vegetation is now real CC0 game models (Quaternius Stylized Nature
	# MegaKit) instanced with MultiMesh, replacing the primitive blob trees:
	# two pines and three broadleaf forms plus a twisted accent tree, model
	# bushes/plants, fern patches and grass tufts in the roadside band, and
	# scattered medium rocks. Placement, chunking and the economy/detail
	# instance budget follow the same rules as the procedural set before.
	var rng := RandomNumberGenerator.new()
	rng.seed = 51005
	for chunk in range(6):
		_scatter(world, rng, chunk, "Pine_1", 10, 9, 70, 7.0, 11.5, 0.10, 0.6)
		_scatter(world, rng, chunk, "Pine_2", 9, 9, 85, 7.5, 12.5, 0.10, 0.6)
		_scatter(world, rng, chunk, "Pine_3", 9, 9, 80, 8.0, 13.0, 0.10, 0.6)
		_scatter(world, rng, chunk, "Tree_1", 6, 10, 75, 7.5, 11.5, 0.10, 0.6)
		_scatter(world, rng, chunk, "Tree_2", 6, 10, 85, 7.5, 12.0, 0.10, 0.6)
		_scatter(world, rng, chunk, "Tree_3", 6, 10, 70, 6.5, 10.5, 0.10, 0.6)
		_scatter(world, rng, chunk, "Tree_4", 6, 10, 75, 6.0, 9.5, 0.10, 0.6)
		_scatter(world, rng, chunk, "Tree_5", 6, 10, 70, 6.0, 9.0, 0.10, 0.6)
		_scatter(world, rng, chunk, "Bush_with_Flowers_1", 40, 5.8, 34, 0.9, 1.8, 0.06, 0.45)
		_scatter(world, rng, chunk, "Fern_1", 40, 4.7, 7.2, 1.1, 1.7, 0.05, 0.5, true)
		_scatter(world, rng, chunk, "Grass_Wispy_1", 42, 4.6, 7.6, 0.7, 1.3, 0.03, 0.5, true)
		_scatter(world, rng, chunk, "Tall_Grass_1", 30, 4.6, 7.6, 1.0, 1.7, 0.03, 0.5, true)
		_scatter(world, rng, chunk, "Plant_1", 24, 5.5, 24, 0.7, 1.2, 0.03, 0.5)
		_scatter(world, rng, chunk, "Plant_Big_1", 16, 5.0, 18, 0.25, 0.5, 0.0, 0.5)
		_scatter(world, rng, chunk, "Rock_Medium_1", 5, 6, 45, 1.2, 2.6, 0.35, 0.8)
		_scatter(world, rng, chunk, "Rock_Medium_2", 5, 6, 45, 1.3, 2.8, 0.35, 0.8)
