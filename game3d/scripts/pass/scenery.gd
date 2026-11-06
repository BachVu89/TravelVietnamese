class_name PassScenery
extends RefCounted

static func build(world: Node3D) -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("7F9DAA")
	sky_mat.sky_horizon_color = Color("B7C5C4")
	sky_mat.ground_horizon_color = Color("A6B6B3")
	sky_mat.ground_bottom_color = Color("586F62")
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("C1CFCA")
	env.ambient_light_energy = 0.65
	env.fog_enabled = true
	env.fog_light_color = Color("A6B6B3")
	env.fog_density = 0.004
	environment.environment = env
	world.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-46,-30,0)
	sun.light_energy = 0.85
	sun.light_color = Color("E7E5D6")
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
	var rail := PassArt.material("B6BFBE",0.38)
	for s in range(0,750,5):
		for side: float in [-1.0,1.0]:
			var offset := -4.2 if side<0 else PassRoute.outer_edge(s)
			var a := PassRoute.at(s,offset)
			var b := PassRoute.at(minf(s+5,750),offset)
			var beam := PassArt.box(world,(a+b)*0.5+Vector3.UP*0.78,Vector3(0.14,0.36,a.distance_to(b)+0.08),rail,true)
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
		var sign := PassArt.box(world,PassRoute.at(stop-19,5)+Vector3.UP*2.2,Vector3(2,1.2,0.12),PassArt.material("285B4C"))
		var label := Label3D.new()
		label.text = "P  ĐIỂM DỪNG\nGIẢM TỐC"
		label.position = Vector3(0,0,0.09)
		label.font_size = 36
		label.pixel_size = 0.014
		sign.add_child(label)
	_forest(world)
	_far_ridges(world)
	_batch_static_boxes(world)

static func _strip(world: Node3D, title: String, left: float, right: float, mat: Material, collision: bool, terrain: bool = false, from_distance: float = 0.0, to_distance: float = 750.0) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for segment in range(int(from_distance/5),int(to_distance/5)):
		var s := segment*5.0
		var vertices: Array[Vector3] = []
		for spec: Vector2 in [Vector2(s,left),Vector2(s+5,left),Vector2(s,right),Vector2(s+5,right)]:
			var p := PassRoute.at(spec.x,spec.y)
			if terrain:
				var offset := absf(spec.y)-4.25
				p.y += offset*0.72 if spec.y<0 else -offset*0.55
				p.y += sin(spec.x*0.07)*offset*0.08
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
	var rng := RandomNumberGenerator.new()
	rng.seed = 41004
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.12
	trunk_mesh.bottom_radius = 0.27
	trunk_mesh.height = 5.0
	trunk_mesh.radial_segments = 6
	var crown_mesh := SphereMesh.new()
	crown_mesh.radial_segments = 8
	crown_mesh.rings = 4
	var trunks := MultiMesh.new()
	trunks.transform_format = MultiMesh.TRANSFORM_3D
	trunks.mesh = trunk_mesh
	trunks.instance_count = 420
	var crowns := MultiMesh.new()
	crowns.transform_format = MultiMesh.TRANSFORM_3D
	crowns.use_colors = true
	crowns.mesh = crown_mesh
	crowns.instance_count = 420
	for i in range(420):
		var s := rng.randf_range(0,750)
		var side := -1.0 if i%2==0 else 1.0
		var offset := rng.randf_range(8 if side<0 else 18,65)*side
		var p := PassRoute.at(s,offset)
		p.y += (absf(offset)-4.25)*(0.72 if side<0 else -0.55)+sin(s*0.07)*(absf(offset)-4.25)*0.08
		trunks.set_instance_transform(i,Transform3D(Basis.IDENTITY,p+Vector3.UP*2.5))
		var size_value := rng.randf_range(3.5,6.5)
		crowns.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3(size_value,size_value*1.25,size_value)),p+Vector3.UP*5.5))
		crowns.set_instance_color(i,Color("345C45").lerp(Color("223E33"),rng.randf()))
	var wood := MultiMeshInstance3D.new()
	wood.multimesh = trunks
	wood.material_override = PassArt.material("4A4C3F")
	world.add_child(wood)
	var leaves := MultiMeshInstance3D.new()
	leaves.multimesh = crowns
	var green := PassArt.material("FFFFFF")
	green.vertex_color_use_as_albedo = true
	leaves.material_override = green
	world.add_child(leaves)

static func _far_ridges(world: Node3D) -> void:
	for layer in range(3):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(25):
			var z := -1000.0+i*60
			var x := 180.0+layer*95
			var height := 65.0+sin(i*1.7+layer)*35+layer*30
			for p: Vector3 in [Vector3(x,-90,z),Vector3(x,height,z),Vector3(x,-90,z+60),Vector3(x,height,z),Vector3(x,height+sin(i)*30,z+60),Vector3(x,-90,z+60)]:
				st.add_vertex(p)
		st.generate_normals()
		var ridge := MeshInstance3D.new()
		ridge.mesh = st.commit()
		var mat := PassArt.material("617C72" if layer==0 else "7E9890" if layer==1 else "9FB1AD")
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		ridge.material_override = mat
		world.add_child(ridge)

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
