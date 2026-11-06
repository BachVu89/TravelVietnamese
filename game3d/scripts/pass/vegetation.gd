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
	var materials = preload("res://scripts/pass_materials.gd")
	var rng := RandomNumberGenerator.new()
	rng.seed = 51005
	for chunk in range(6):
		for form in range(3):
			var transforms: Array[Transform3D] = []
			var colors: Array[Color] = []
			for i in range(40):
				var distance := rng.randf_range(chunk*125,(chunk+1)*125)
				var side := -1.0 if i%2==0 else 1.0
				var offset := rng.randf_range(8 if side<0 else 18,69 if side<0 else 100)*side
				var p := terrain_point(distance,offset)
				var size_value := rng.randf_range(0.7,1.4)
				var basis := Basis(Vector3.UP,rng.randf_range(0,TAU)).scaled(Vector3(size_value,size_value*rng.randf_range(0.9,1.25),size_value))
				transforms.append(Transform3D(basis,p))
				colors.append(Color("1E3626").lerp(Color("4E6B41"),rng.randf()))
			add_group(world,"ForestTrunkForm"+str(form),tree_mesh(form,false),materials.bark(),transforms,[],chunk)
			add_group(world,"ForestCanopyForm"+str(form),tree_mesh(form,true),materials.foliage(),transforms,colors,chunk)
		var shrubs: Array[Transform3D] = []
		var shrub_colors: Array[Color] = []
		for i in range(215):
			var distance := rng.randf_range(chunk*125,(chunk+1)*125)
			var side := -1.0 if i%2==0 else 1.0
			var offset := rng.randf_range(5.8 if side<0 else 15,37)*side
			var size_value := rng.randf_range(0.65,1.6)
			shrubs.append(Transform3D(Basis(Vector3.UP,rng.randf_range(0,TAU)).scaled(Vector3.ONE*size_value),terrain_point(distance,offset)))
			shrub_colors.append(Color("2C422A").lerp(Color("5C6E42"),rng.randf()))
		add_group(world,"Understory",understory_mesh(),materials.foliage(),shrubs,shrub_colors,chunk,0.42)
		# Dense fern band hugging the road edges, like the reference photo's
		# roadside undergrowth; kept out of the paved laybys on the valley side.
		var ferns: Array[Transform3D] = []
		var fern_colors: Array[Color] = []
		for i in range(70):
			var distance := rng.randf_range(chunk*125,(chunk+1)*125)
			var side := -1.0 if i%2==0 else 1.0
			if side > 0:
				var near_stop := false
				for stop: float in PassRoute.STOPS:
					if absf(distance-stop) < 24.0:
						near_stop = true
				if near_stop:
					continue
			var offset := rng.randf_range(4.7,6.6)*side
			var size_value := rng.randf_range(0.8,1.5)
			ferns.append(Transform3D(Basis(Vector3.UP,rng.randf_range(0,TAU)).scaled(Vector3.ONE*size_value),terrain_point(distance,offset)))
			fern_colors.append(Color("2A4630").lerp(Color("5F7A48"),rng.randf()))
		add_group(world,"RoadsideFerns",understory_mesh(),materials.foliage(),ferns,fern_colors,chunk,0.5)
