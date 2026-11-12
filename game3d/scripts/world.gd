class_name TravelWorld
extends Node3D

var region: Dictionary = {}
var pois: Array[Dictionary] = []
var player: TravelPlayer
var is_island := false
var terrain_size := 84.0
var seed_value := 0

func build(entry: Dictionary) -> void:
	region = entry
	seed_value = absi(str(entry.get("id", "hanoi")).hash())
	is_island = str(entry.get("type", "province")) == "island" or str(entry.get("scene_style", "city")) == "island"
	var environment := WorldEnvironment.new()
	var sky := Environment.new()
	sky.background_mode = Environment.BG_COLOR
	sky.background_color = Color("a8d4db")
	sky.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	sky.ambient_light_color = Color("d9e8df")
	sky.ambient_light_energy = 0.4
	sky.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.environment = sky
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_color = Color("fff0d2")
	sun.light_energy = 0.7
	sun.shadow_enabled = true
	add_child(sun)
	_build_terrain()
	_build_bounds()
	if is_island:
		_build_island()
	elif str(entry.get("id", "")).to_lower().replace("-", "").replace("_", "") in ["hanoi", "hànội", "01"]:
		_build_hanoi()
	else:
		_build_province()
	player = TravelPlayer.new()
	add_child(player)
	player.position = Vector3(0, terrain_height(0, 15) + 0.4, 15)

func terrain_height(x: float, z: float) -> float:
	if is_island:
		var distance := Vector2(x, z).length()
		var ridge := sin(x * 0.13 + seed_value % 13) * cos(z * 0.11) * 0.9
		return maxf(-2.3, 2.0 + ridge - pow(distance / 26.0, 4) * 2.0)
	if str(region.get("scene_style", "city")) == "highland":
		return (sin(x * 0.07 + float(seed_value % 10)) + cos(z * 0.08)) * 1.2
	return 0.0

func _build_terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cells := 32
	var step := terrain_size / float(cells)
	for x in range(cells):
		for z in range(cells):
			var a := Vector3(x * step - terrain_size / 2, 0, z * step - terrain_size / 2)
			var b := a + Vector3(step, 0, 0)
			var c := a + Vector3(0, 0, step)
			var d := a + Vector3(step, 0, step)
			for point: Vector3 in [a, b, c, b, d, c]:
				point.y = terrain_height(point.x, point.z)
				var color := Color("8ca770")
				if is_island:
					color = Color("e1c895") if point.y < 0.8 else Color("83a365")
				elif str(region.get("scene_style", "")) == "city":
					color = Color("b3bc92")
				st.set_color(color)
				st.add_vertex(point)
	st.generate_normals()
	var mesh := st.commit()
	var instance := MeshInstance3D.new()
	instance.name = "Terrain"
	instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.95
	instance.material_override = material
	add_child(instance)
	var ground := StaticBody3D.new()
	ground.name = "TerrainCollision"
	var collider := CollisionShape3D.new()
	collider.shape = mesh.create_trimesh_shape()
	ground.add_child(collider)
	add_child(ground)
	if is_island or str(region.get("scene_style", "")) == "coast":
		var sea := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2(260, 260)
		sea.mesh = plane
		sea.position.y = -0.05
		sea.material_override = _material(Color("4e9ca6"))
		add_child(sea)

func _build_bounds() -> void:
	for data: Array in [[Vector3(0, 3, -42), Vector3(86, 8, 1)], [Vector3(0, 3, 42), Vector3(86, 8, 1)], [Vector3(-42, 3, 0), Vector3(1, 8, 86)], [Vector3(42, 3, 0), Vector3(1, 8, 86)]]:
		var body := StaticBody3D.new()
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = data[1]
		shape.shape = box
		body.position = data[0]
		body.add_child(shape)
		add_child(body)

func _build_hanoi() -> void:
	# Small illustrative walking area; proportions intentionally not survey-accurate.
	_box(Vector3(0, 0.025, 3), Vector3(7, 0.05, 58), Color("d8c9a9"), false)
	var lake := MeshInstance3D.new()
	var lake_mesh := CylinderMesh.new()
	lake_mesh.top_radius = 9.0
	lake_mesh.bottom_radius = 9.0
	lake_mesh.height = 0.12
	lake_mesh.radial_segments = 32
	lake.mesh = lake_mesh
	lake.position = Vector3(0, 0.07, -13)
	lake.material_override = _material(Color("67a6a1"))
	add_child(lake)
	var lake_block := StaticBody3D.new()
	var lake_shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 8.9
	cylinder.height = 2
	lake_shape.shape = cylinder
	lake_block.position = Vector3(0, 0.4, -13)
	lake_block.add_child(lake_shape)
	add_child(lake_block)
	for level in range(3):
		_box(Vector3(0, 0.7 + level * 1.15, -13), Vector3(2.7 - level * 0.4, 1.1, 2.3 - level * 0.4), Color("c1aa7a"))
		_box(Vector3(0, 1.3 + level * 1.15, -13), Vector3(3.0 - level * 0.4, 0.18, 2.7 - level * 0.4), Color("986d4c"))
	for i in range(7):
		var x := -18.0 + (i % 3) * 4.4
		var z := -18.0 + (i / 3) * 5.2
		_box(Vector3(x, 2, z), Vector3(3.5, 4, 4.2), Color("dcc28d") if i % 2 == 0 else Color("d5a982"))
		_box(Vector3(x, 4.1, z), Vector3(3.9, 0.35, 4.6), Color("925849"))
	_box(Vector3(16, 1.7, -10), Vector3(6, 3.4, 5), Color("bc7858"))
	_box(Vector3(16, 3.5, -10), Vector3(7.4, 0.4, 6), Color("704a3a"))
	for x in [-27, -22, 21, 27]:
		for z in [-25, 1, 15, 25]:
			_tree(Vector3(x, 0, z))
	_add_poi("lake", "Hồ Gươm · Tháp Rùa", "Mô hình gợi nhớ Hồ Gươm và Tháp Rùa. Hồ gắn với truyền thuyết vua Lê Lợi trả gươm. Đây là cảnh thu nhỏ để đi bộ, không phải bản đồ thực địa.", Vector3(0, 0, -2))
	_add_poi("quarter", "Góc phố Hà Nội", "Những ngôi nhà mái ngói gợi không khí phố cũ. Hãy đi vòng qua các dãy nhà: công trình có va chạm và camera tự thu gần khi gặp vật cản.", Vector3(-13, 0, -5))
	_add_poi("courtyard", "Sân kiến trúc truyền thống", "Khoảng sân mô phỏng kiến trúc truyền thống để thực hành tham quan. Công trình minh họa, không khẳng định là bản số hóa của một di tích cụ thể.", Vector3(16, 0, -3))

func _build_island() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(30):
		var angle := rng.randf_range(0, TAU)
		var distance := rng.randf_range(10, 24)
		var p := Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		if p.distance_to(Vector3(0, 0, 15)) > 5:
			_tree(p, true)
	var lighthouse := Vector3(12, terrain_height(12, -6), -6)
	_box(lighthouse + Vector3(0, 2.5, 0), Vector3(2.2, 5, 2.2), Color("f2e4c9"))
	_box(lighthouse + Vector3(0, 5.2, 0), Vector3(2.8, 0.5, 2.8), Color("b65a45"))
	_box(lighthouse + Vector3(0, 5.8, 0), Vector3(1.6, 0.7, 1.6), Color("e4bc5e"))
	_box(Vector3(-10, terrain_height(-10, 9) + 1.2, 9), Vector3(5, 2.4, 3.5), Color("c69665"))
	_box(Vector3(-10, terrain_height(-10, 9) + 2.5, 9), Vector3(6, 0.35, 4.2), Color("876447"))
	var title := str(region.get("name", "Đảo"))
	_add_poi("shore", "Bờ biển · " + title, "Đi dọc bờ cát và quan sát đường bờ, cây, địa hình nổi. Đây là đảo minh họa được sinh riêng theo mã địa danh, không tái dựng đường bờ hoặc quy mô địa lý thật.", Vector3(0, 0, 23))
	_add_poi("beacon", "Điểm ngắm cảnh trên đảo", "Công trình ngắm cảnh minh họa giúp định hướng trong khu tham quan. Tên địa danh lấy từ danh mục; công trình không được khẳng định có tại vị trí thực tế.", Vector3(12, 0, -1))
	_add_poi("village", "Góc sinh hoạt ven biển", "Một khoảng dừng chân gợi nhịp sống ven biển. Bạn có thể đi bộ tự do, xoay camera và lưu lại dấu khám phá trên thiết bị.", Vector3(-10, 0, 14))

func _build_province() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var style := str(region.get("scene_style", "city"))
	_box(Vector3(0, terrain_height(0, 0) + 0.05, 0), Vector3(7, 0.12, 58), Color("d4c4a2"), false)
	for i in range(15):
		var x := rng.randf_range(12, 31) * (-1 if i % 2 == 0 else 1)
		var z := rng.randf_range(-29, 28)
		if style == "highland":
			_tree(Vector3(x, 0, z))
		else:
			var height := rng.randf_range(2.5, 6)
			_box(Vector3(x, terrain_height(x, z) + height / 2, z), Vector3(4, height, 4), Color.from_hsv(rng.randf_range(0.07, 0.16), 0.22, 0.85))
			_tree(Vector3(x + 4, 0, z + 3))
	for x in [-8, 8]:
		for z in [-22, -10, 2, 17, 28]:
			_tree(Vector3(x, 0, z))
	var title := str(region.get("name", "Điểm đến"))
	_add_poi("arrival", "Điểm đến · " + title, "Bạn đang ở khu tham quan 3D minh họa của " + title + ". Địa hình và công trình được sinh thủ tục theo mã địa danh; chưa phải bản số hóa thực địa của tỉnh hoặc thành phố.", Vector3(0, 0, 8))
	_add_poi("landscape", "Không gian cảnh quan", "Cảnh quan " + ("cao nguyên" if style == "highland" else "ven biển" if style == "coast" else "đô thị") + " được dựng theo phong cách low-poly. Di chuyển bằng joystick hoặc WASD; kéo phía phải để ngắm xung quanh.", Vector3(-5, 0, -8))
	_add_poi("outlook", "Trạm ghi dấu hành trình", "Ghi dấu khám phá để lưu chuyến đi offline. Bản mẫu dành cho trải nghiệm điều khiển và tham quan; cần dữ liệu khảo sát riêng để tái dựng địa danh thật.", Vector3(5, 0, -25))

func _tree(point: Vector3, palm: bool = false) -> void:
	point.y = terrain_height(point.x, point.z)
	_box(point + Vector3(0, 1.3, 0), Vector3(0.5, 2.6, 0.5), Color("876445"))
	var leaves := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.15 if not palm else 1.8
	mesh.bottom_radius = 1.7
	mesh.height = 2.8 if not palm else 0.6
	mesh.radial_segments = 6
	leaves.mesh = mesh
	leaves.position = point + Vector3(0, 3.2, 0)
	leaves.material_override = _material(Color("466e4b"))
	add_child(leaves)

func _add_poi(id: String, title: String, description: String, point: Vector3) -> void:
	point.y = terrain_height(point.x, point.z)
	pois.append({"id": str(region.get("id", "")) + ":" + id, "title": title, "description": description, "position": point})
	var marker := MeshInstance3D.new()
	var prism := CylinderMesh.new()
	prism.top_radius = 0.05
	prism.bottom_radius = 0.45
	prism.height = 0.9
	prism.radial_segments = 4
	marker.mesh = prism
	marker.position = point + Vector3(0, 2.2, 0)
	marker.material_override = _material(Color("f0bd54"))
	add_child(marker)
	var label := Label3D.new()
	label.text = title
	label.position = point + Vector3(0, 3.1, 0)
	label.font_size = 48
	label.pixel_size = 0.013
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = false
	label.outline_size = 8
	add_child(label)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material

func _box(point: Vector3, size: Vector3, color: Color, collidable: bool = true) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = point
	instance.material_override = _material(color)
	add_child(instance)
	if collidable:
		var body := StaticBody3D.new()
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.position = point
		body.add_child(shape)
		add_child(body)

func nearest_poi(max_distance: float = 3.7) -> Dictionary:
	if not player:
		return {}
	var nearest: Dictionary = {}
	var best := max_distance
	for poi in pois:
		var distance := Vector2(player.position.x, player.position.z).distance_to(Vector2(poi.position.x, poi.position.z))
		if distance < best:
			best = distance
			nearest = poi
	return nearest

func _physics_process(_delta: float) -> void:
	if player and is_island:
		var horizontal := Vector2(player.position.x, player.position.z)
		if horizontal.length() > 28.0:
			horizontal = horizontal.normalized() * 28.0
			player.position.x = horizontal.x
			player.position.z = horizontal.y
