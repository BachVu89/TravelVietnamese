class_name PassScenery
extends RefCounted

static func build(world: Node3D) -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("6B8296")
	sky_mat.sky_horizon_color = Color("D3DCD8")
	sky_mat.ground_horizon_color = Color("AEBBAF")
	sky_mat.ground_bottom_color = Color("2E4238")
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("BCCDC2")
	env.ambient_light_energy = 0.5
	env.fog_enabled = true
	env.fog_light_color = Color("C2CFCB")
	env.fog_density = 0.0021
	environment.environment = env
	world.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-46,-30,0)
	sun.light_energy = 0.9
	sun.light_color = Color("E6E1D0")
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 85
	world.add_child(sun)
	var asphalt := PassArt.material("252D30",0.27)
	asphalt.metallic_specular = 0.75
	var rock := PassArt.material("68716A")
	var grass := PassArt.material("405A42")
	if ResourceLoader.exists("res://scripts/pass_materials.gd"):
		var materials = load("res://scripts/pass_materials.gd")
		asphalt = materials.road()
		rock = materials.rock()
		grass = materials.grass()
	_strip(world,"WetAsphalt",-3.5,3.5,asphalt,true)
	_strip(world,"LeftShoulder",-4.25,-3.5,PassArt.material("74766C"),true)
	_strip(world,"RightShoulder",3.5,4.25,PassArt.material("74766C"),true)
	_strip(world,"MountainWall",-75,-4.25,rock,false,true)
	_strip(world,"ValleySlope",4.25,110,grass,false,true)
	var gold := PassArt.material("E4B84C",0.5)
	var white := PassArt.material("D2D5C6",0.6)
	for s in range(2,748,7):
		_mark(world,float(s),0,0.12,3.5,gold)
	for s in range(0,750,5):
		_mark(world,float(s),-3.25,0.09,5.1,white)
		_mark(world,float(s),3.25,0.09,5.1,white)
	var rail := preload("res://scripts/pass_materials.gd").metal()
	var rust := PassArt.material("6B564A",0.95)
	for s in range(0,750,5):
		for side: float in [-1.0,1.0]:
			var offset := -4.2 if side<0 else PassRoute.outer_edge(s)
			var a := PassRoute.at(s,offset)
			var b := PassRoute.at(minf(s+5,750),offset)
			var beam_mat: Material = rust if (s/5 + (0 if side<0 else 1)) % 6 == 2 else rail
			var beam := PassArt.box(world,(a+b)*0.5+Vector3.UP*0.78,Vector3(0.14,0.36,a.distance_to(b)+0.08),beam_mat,true)
			beam.rotation.y = atan2(b.x-a.x,b.z-a.z)
			PassArt.box(world,a+Vector3.UP*0.4,Vector3(0.12,0.8,0.14),PassArt.material("545D5C"))
	# End barriers protect the two route terminals.
	for end: float in [0.0,750.0]:
		var gate := PassArt.box(world,PassRoute.at(end)+Vector3.UP,Vector3(8.4,2,0.5),rail,true)
		gate.rotation.y = atan2(PassRoute.tangent(end).x,PassRoute.tangent(end).z)
	for stop: float in PassRoute.STOPS:
		_strip(world,"Layby"+str(int(stop)),4.25,13.0,PassArt.material("7B8074"),true,false,stop-20,stop+20)
		for i in range(3):
			PassArt.box(world,PassRoute.at(stop-9+i*7,11.8)+Vector3.UP*0.65,Vector3(0.4,1.3,0.4),rail)
		# Weathered concrete barriers guard the outer edge of each layby.
		for i in range(4):
			var barrier_mat := PassArt.material("A9A89C" if i%2==0 else "9C9A8E",0.9)
			var barrier := PassArt.box(world,PassRoute.at(stop-13.5+i*6.4,12.55)+Vector3.UP*0.4,Vector3(0.45,0.8,5.6),barrier_mat,true)
			barrier.rotation.y = atan2(-PassRoute.tangent(stop).x,-PassRoute.tangent(stop).z)
		var sign := PassArt.box(world,PassRoute.at(stop-19,5)+Vector3.UP*2.2,Vector3(2,1.2,0.12),PassArt.material("285B4C"))
		var label := Label3D.new()
		label.text = "P  ĐIỂM DỪNG\nGIẢM TỐC"
		label.position = Vector3(0,0,0.09)
		label.font_size = 36
		label.pixel_size = 0.014
		sign.add_child(label)
	_forest(world)
	_far_ridges(world)
	_mist_banks(world)
	_puddles(world)
	_milestones(world)
	_waterfalls(world)
	_batch_static_boxes(world)

static func _strip(world: Node3D, title: String, left: float, right: float, mat: Material, collision: bool, terrain: bool = false, from_distance: float = 0.0, to_distance: float = 750.0) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for segment in range(int(from_distance/5),int(to_distance/5)):
		var s := segment*5.0
		var columns := 12 if terrain else 1
		for column in range(columns):
			var lateral_a := lerpf(left,right,float(column)/columns)
			var lateral_b := lerpf(left,right,float(column+1)/columns)
			var vertices: Array[Vector3] = []
			for spec: Vector2 in [Vector2(s,lateral_a),Vector2(s+5,lateral_a),Vector2(s,lateral_b),Vector2(s+5,lateral_b)]:
				var p := preload("res://scripts/pass/vegetation.gd").terrain_point(spec.x,spec.y) if terrain else PassRoute.at(spec.x,spec.y)
				vertices.append(p)
			for index: int in [0,1,2,1,3,2]:
				st.set_uv(Vector2(vertices[index].x*0.16,vertices[index].z*0.16))
				st.add_vertex(vertices[index])
	st.generate_normals()
	var mesh := st.commit()
	var visual := MeshInstance3D.new()
	visual.name = title
	visual.mesh = mesh
	visual.material_override = mat
	world.add_child(visual)
	if collision:
		var body := StaticBody3D.new()
		body.name = title+"Collision"
		var shape := CollisionShape3D.new()
		shape.shape = mesh.create_trimesh_shape()
		body.add_child(shape)
		world.add_child(body)

static func _mark(world: Node3D, s: float, lateral: float, width: float, length_value: float, mat: Material) -> void:
	var mark := PassArt.box(world,PassRoute.at(s,lateral)+Vector3.UP*0.025,Vector3(width,0.018,length_value),mat)
	mark.rotation.y = atan2(-PassRoute.tangent(s).x,-PassRoute.tangent(s).z)
	mark.rotation.x = atan(0.065)

static func _forest(world: Node3D) -> void:
	preload("res://scripts/pass/vegetation.gd").build(world)

static func _far_ridges(world: Node3D) -> void:
	# Closed-width mountain masses replace single vertical paper planes.
	# Layered blue-green silhouettes on BOTH sides so bends looking either
	# way read depth through the mist instead of flat white-cyan shapes.
	for side: float in [1.0,-1.0]:
		for layer in range(3):
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			for i in range(65):
				for row in range(6):
					var points: Array[Vector3] = []
					for uv: Vector2i in [Vector2i(i,row),Vector2i(i+1,row),Vector2i(i,row+1),Vector2i(i+1,row+1)]:
						var z := -1100.0+uv.x*25.0
						var cross_section := float(uv.y)/6.0
						var x := side*(105.0+layer*120.0+cross_section*200.0+sin(z*0.007+layer)*30.0)
						var peak := 105.0+layer*28.0+sin(z*0.011+layer)*30.0+sin(z*0.023)*13.0+sin(z*0.11+layer)*10.0+sin(z*0.043+layer*2.0)*16.0
						var y := -65.0+pow(sin(cross_section*PI),0.7)*peak
						points.append(Vector3(x,y,z))
					for index: int in [0,1,2,1,3,2]:
						st.add_vertex(points[index])
			st.generate_normals()
			var ridge := MeshInstance3D.new()
			ridge.name = "ContinuousMountainMass"+str(layer)+("L" if side<0 else "R")
			ridge.mesh = st.commit()
			var mat := PassArt.material("3E5C4C" if layer==0 else "5F7F6E" if layer==1 else "8AA696")
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			ridge.material_override = mat
			ridge.set_meta("pass_far_mass",true)
			ridge.set_meta("mountain_layer",layer)
			world.add_child(ridge)
	_rock_outcrops(world)

static func _mist_banks(world: Node3D) -> void:
	# Low translucent mist banks drifting over the valley side and between
	# the far ridge layers; very low alpha so they layer, never hide the road.
	var mist := StandardMaterial3D.new()
	mist.albedo_color = Color(0.88,0.92,0.91,0.08)
	mist.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist.roughness = 1.0
	mist.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var mist_far := StandardMaterial3D.new()
	mist_far.albedo_color = Color(0.86,0.90,0.89,0.10)
	mist_far.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist_far.roughness = 1.0
	mist_far.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in range(5):
		var s := 80.0+i*135.0
		var bank := PassArt.ellipsoid(world,PassRoute.at(s,58)+Vector3.UP*(-4.0+float(i%3)*2.0),Vector3(46,5,20),mist)
		bank.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in range(3):
		var s := 150.0+i*270.0
		var bank := PassArt.ellipsoid(world,PassRoute.at(s,150)+Vector3.UP*(2.0+float(i)*2.0),Vector3(90,9,40),mist_far)
		bank.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func _puddles(world: Node3D) -> void:
	# Dark low-roughness patches read as standing water on the damp asphalt.
	var water := StandardMaterial3D.new()
	water.albedo_color = Color("454F57")
	water.roughness = 0.14
	water.metallic_specular = 0.65
	var rng := RandomNumberGenerator.new()
	rng.seed = 7707
	for i in range(16):
		var s := rng.randf_range(25.0,735.0)
		var lateral := rng.randf_range(-2.4,2.4)
		var patch := PassArt.box(world,PassRoute.at(s,lateral)+Vector3.UP*0.02,Vector3(rng.randf_range(1.2,2.2),0.012,rng.randf_range(2.2,4.5)),water)
		patch.rotation.y = atan2(-PassRoute.tangent(s).x,-PassRoute.tangent(s).z)
		patch.rotation.x = atan(0.065)

static func _milestones(world: Node3D) -> void:
	# Red-topped destination milestones like the reference photo: white post,
	# red cap, black "ĐÀ LẠT / KHÁNH LÊ" lettering facing the road.
	var post_mat := PassArt.material("E8E6DA",0.7)
	var cap_mat := PassArt.material("B03A2E",0.6)
	for s: float in [60.0,245.0,565.0]:
		var base := preload("res://scripts/pass/vegetation.gd").terrain_point(s,5.1)
		var right := PassRoute.right(s)
		var yaw := atan2(-right.x,-right.z)
		var post := PassArt.box(world,base+Vector3.UP*0.48,Vector3(0.55,0.95,0.14),post_mat)
		post.rotation.y = yaw
		var cap := PassArt.box(world,base+Vector3.UP*0.98,Vector3(0.55,0.3,0.145),cap_mat)
		cap.rotation.y = yaw
		var label := Label3D.new()
		label.text = "ĐÀ LẠT\nKHÁNH LÊ"
		label.font_size = 44
		label.pixel_size = 0.0085
		label.modulate = Color("191919")
		label.position = Vector3(0,-0.12,0.085)
		post.add_child(label)

static func _waterfalls(world: Node3D) -> void:
	# Stepped cascades down the rock wall, with a dark wet streak behind and
	# foam where the water lands — the reference pass has falls on the wall.
	var fall_mat := PassArt.material("D9E4DF",0.3)
	var wet_mat := PassArt.material("33413C",0.95)
	var foam_mat := PassArt.material("EDF2EE",0.5)
	for s: float in [372.0,470.0]:
		var right := PassRoute.right(s)
		var yaw := atan2(right.x,right.z)
		var back := preload("res://scripts/pass/vegetation.gd").terrain_point(s,-8.1)
		var streak := PassArt.box(world,back+Vector3.UP*2.1-right*0.07,Vector3(1.5,5.6,0.06),wet_mat)
		streak.rotation.y = yaw
		for i in range(5):
			var lat := -11.0+float(i)*1.45
			var p := preload("res://scripts/pass/vegetation.gd").terrain_point(s,lat)
			var step := PassArt.box(world,p+Vector3.UP*0.55,Vector3(1.0,2.0,0.09),fall_mat)
			step.rotation.y = yaw
		var base := preload("res://scripts/pass/vegetation.gd").terrain_point(s,-4.9)
		var foam := PassArt.ellipsoid(world,base+Vector3.UP*0.12,Vector3(0.95,0.22,0.95),foam_mat)
		foam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func _rock_outcrops(world: Node3D) -> void:
	var mesh := SphereMesh.new()
	mesh.radial_segments = 9
	mesh.rings = 5
	var rng := RandomNumberGenerator.new()
	rng.seed = 510051
	for chunk in range(6):
		var transforms: Array[Transform3D] = []
		for i in range(34):
			var distance := rng.randf_range(chunk*125,(chunk+1)*125)
			var offset := -rng.randf_range(8.0,33.0)
			var size_value := rng.randf_range(3.0,7.0)
			var basis := Basis(Vector3.UP,rng.randf_range(0,TAU))*Basis(Vector3.FORWARD,rng.randf_range(-0.3,0.3))
			basis = basis.scaled(Vector3(minf(size_value,absf(offset)-5),size_value*1.8,size_value*1.1))
			var p := preload("res://scripts/pass/vegetation.gd").terrain_point(distance,offset)
			transforms.append(Transform3D(basis,p+Vector3.UP*size_value*0.35))
		preload("res://scripts/pass/vegetation.gd").add_group(world,"RockOutcrops",mesh,preload("res://scripts/pass_materials.gd").rock(),transforms,[],chunk,0.6)

static func _batch_static_boxes(world: Node3D) -> void:
	var groups: Dictionary = {}
	var originals: Array[MeshInstance3D] = []
	for child in world.get_children():
		if not child is MeshInstance3D or not child.mesh is BoxMesh:
			continue
		var has_label := false
		for nested in child.get_children():
			if not nested is StaticBody3D:
				has_label = true
		if has_label:
			continue
		var material: Material = child.material_override
		var key := material.get_instance_id()
		if not groups.has(key):
			var surface := SurfaceTool.new()
			surface.begin(Mesh.PRIMITIVE_TRIANGLES)
			surface.set_material(material)
			groups[key] = surface
		groups[key].append_from(child.mesh,0,child.transform)
		for nested in child.get_children():
			var transform_value: Transform3D = child.transform*nested.transform
			child.remove_child(nested)
			world.add_child(nested)
			nested.transform = transform_value
		originals.append(child)
	for key in groups:
		var batch := MeshInstance3D.new()
		batch.name = "StaticSceneryBatch"
		batch.mesh = groups[key].commit()
		world.add_child(batch)
	for original in originals:
		world.remove_child(original)
		original.queue_free()
