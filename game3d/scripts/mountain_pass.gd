class_name MountainPassWorld
extends TravelWorld

const DEMO_ID := "mountain_pass_demo"
const Route = preload("res://scripts/pass/route.gd")
var bike: PassBike
var riding := true
var paused := false
var traffic: Array[PassTraffic] = []
var checkpoint := 0.0
var visual_quality := "economy"

func build(entry: Dictionary) -> void:
	region = entry
	seed_value = 41004
	preload("res://scripts/pass/scenery.gd").build(self)
	player = TravelPlayer.new()
	add_child(player)
	if player.is_node_ready():
		_dress_walker()
	else:
		player.ready.connect(_dress_walker,CONNECT_ONE_SHOT)
	player.set_physics_process(false)
	player.hide()
	player.collision_layer = 0
	player.collision_mask = 1 | 4 | 8
	bike = PassBike.new()
	add_child(bike)
	bike.reset_to_distance(5.0)
	bike.recovery_requested.connect(return_to_start)
	for i in range(3):
		var vehicle := PassTraffic.new()
		vehicle.name = "Traffic%d" % i
		vehicle.route_distance = [130.0,390.0,690.0][i]
		vehicle.direction = -1.0
		vehicle.lane = -1.65
		vehicle.travel_speed = [7.0,8.5,6.0][i]
		vehicle.bus = i == 1
		add_child(vehicle)
		traffic.append(vehicle)
	for i in range(2):
		var p := Route.at(Route.STOPS[i],10.0)
		pois.append({"id":DEMO_ID+":viewpoint_"+str(i+1),"title":["Ban công mây", "Trạm nhìn thung lũng"][i],"description":["Ban công mây mở tầm nhìn ngang những tầng rừng phía sườn núi. Quan sát các lớp cây gần đậm màu, các dãy núi xa nhạt dần trong màn sương: đó là cách cảnh mẫu gợi chiều sâu của không gian đèo. Hãy đứng trong khu dừng có lan can, nhìn lại khúc cua và mặt đường sẫm phía sau. Đây là cảnh quan sinh thủ tục để trải nghiệm, không phải số hóa một điểm ngắm cảnh thực tại đèo Khánh Lê.", "Trạm nhìn thung lũng nằm ở chặng cao hơn của tuyến mẫu. Từ vịnh dừng, nhìn xuống sườn cây thấp và những đường sống núi nối tiếp phía xa; quay lại để thấy con đường uốn theo sườn dốc. Đi bộ giữa cột mốc và xe đã đỗ để cảm nhận sự thay đổi góc nhìn trước khi tiếp tục lên đèo. Địa hình, đường và tên điểm dừng đều là nội dung minh họa, không phải dữ liệu khảo sát hay chỉ dẫn du lịch thực địa."][i],"position":p})
		var marker := PassArt.ellipsoid(self,p+Vector3.UP*1.8,Vector3(0.6,1.0,0.6),PassArt.material("E4B84C",0.35))
		marker.name = "ViewpointMarker%d" % i
		var label := Label3D.new()
		label.text = str(pois[-1].title)
		label.position = p + Vector3.UP*3.0
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 42
		label.pixel_size = 0.014
		add_child(label)
	apply_visual_quality(visual_quality)

func _dress_walker() -> void:
	for child in player.avatar.get_children():
		player.avatar.remove_child(child)
		child.queue_free()
	PassArt.walker_model(player.avatar)

func terrain_height(_x: float, z: float) -> float:
	return Route.point(clampf(-z,0,Route.LENGTH)).y

func active_avatar() -> Node3D:
	return bike if riding else player

func set_drive_input(value: Vector2) -> void:
	bike.drive_input = Vector2(clampf(value.x,-1,1),clampf(value.y,-1,1)) if riding and not paused else Vector2.ZERO

func set_paused(value: bool) -> void:
	paused = value
	bike.paused = value
	for vehicle in traffic:
		vehicle.paused = value or vehicle.route_distance <= 1 or vehicle.route_distance >= Route.LENGTH-1
	if value:
		bike.drive_input = Vector2.ZERO
		player.move_input = Vector2.ZERO

func toggle_vehicle() -> bool:
	if paused:
		return false
	if riding:
		if bike.speed > 0.5 or not Route.in_layby(bike.position):
			return false
		riding = false
		bike.riding = false
		bike.model.get_node("Rider").hide()
		player.position = bike.position + Route.right(Route.distance_at(bike.position))*1.3 + Vector3.UP*0.2
		player.yaw = bike.rotation.y
		player.update_camera()
		player.show()
		player.collision_layer = 2
		player.set_physics_process(true)
		player.camera.current = true
	else:
		if player.position.distance_to(bike.position) > 3.0:
			return false
		riding = true
		bike.riding = true
		bike.model.get_node("Rider").show()
		player.set_physics_process(false)
		player.hide()
		player.collision_layer = 0
		bike.camera.current = true
	return true

func nearest_poi(max_distance: float = 3.7) -> Dictionary:
	return {} if riding else super.nearest_poi(max_distance)

func get_hud_state() -> Dictionary:
	var distance := Route.distance_at(active_avatar().position)
	var next := "Đích tuyến mẫu"
	for i in range(2):
		if distance < Route.STOPS[i] + 18:
			next = str(pois[i].title) + " · " + str(maxi(0,int(Route.STOPS[i]-distance))) + " m cảnh"
			break
	return {"riding":riding,"speed_kmh":bike.speed*3.6,"progress":distance,"total_length":Route.LENGTH,"next_stop":next,"can_exit":riding and bike.speed<=0.5 and Route.in_layby(bike.position),"can_mount":not riding and player.position.distance_to(bike.position)<=3.0}

func return_to_start() -> void:
	var d := Route.distance_at(active_avatar().position)
	checkpoint = 0.0
	for stop: float in Route.STOPS:
		if d >= stop:
			checkpoint = stop
	bike.reset_to_distance(maxf(5.0,checkpoint),8.0 if checkpoint>0 else 1.7)
	if not riding:
		player.position = bike.position + Route.right(checkpoint)*1.3 + Vector3.UP*0.2

func capture_road_state() -> Dictionary:
	return {"bike_s":Route.distance_at(bike.position),"lateral":Route.lateral_at(bike.position),"riding":riding,"checkpoint":checkpoint}

func restore_road_state(value: Dictionary) -> void:
	var s := clampf(float(value.get("bike_s",5)),5,Route.LENGTH-5)
	var side := clampf(float(value.get("lateral",1.7)),-3.0,12.0)
	if side>4.0 and not Route.in_layby(Route.at(s,side)):
		side = 1.7
	bike.reset_to_distance(s,side)
	checkpoint = float(value.get("checkpoint",0))
	if not bool(value.get("riding",true)) and Route.in_layby(bike.position):
		toggle_vehicle()

func _physics_process(_delta: float) -> void:
	if bike:
		for stop: float in Route.STOPS:
			if Route.in_layby(bike.position) and Route.distance_at(bike.position) >= stop and absf(Route.distance_at(bike.position)-stop)<17:
				checkpoint = stop
	if not riding and player:
		if player.position.y < terrain_height(player.position.x,player.position.z)-8:
			return_to_start()
		var d := Route.distance_at(player.position)
		var original_side := Route.lateral_at(player.position)
		var side := clampf(original_side,-3.7,Route.outer_edge(d)-0.6)
		if not is_equal_approx(side, original_side):
			var p := Route.at(d,side)
			player.position.x = p.x
			player.position.z = p.z

func apply_visual_quality(profile: String) -> void:
	visual_quality = "detail" if profile == "detail" else "economy"
	var detailed := visual_quality == "detail"
	for child in get_children():
		if child is MultiMeshInstance3D and child.get_meta("pass_decoration",false):
			var total := int(child.get_meta("detail_count",child.multimesh.instance_count))
			child.multimesh.visible_instance_count = total if detailed else maxi(1,int(total*float(child.get_meta("economy_ratio",0.58))))
			child.visibility_range_end = 340.0 if detailed else 190.0
			child.visibility_range_end_margin = 25.0
			child.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
			child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if detailed and not child.name.begins_with("Understory") else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		elif child is MeshInstance3D and child.get_meta("pass_far_mass",false):
			child.visible = detailed or int(child.get_meta("mountain_layer",0))<2
		elif child is WorldEnvironment:
			child.environment.fog_density = 0.0018 if detailed else 0.0025
	if bike and bike.camera:
		bike.camera.far = 650.0 if detailed else 440.0
	if player and player.camera:
		player.camera.far = 650.0 if detailed else 440.0

func get_visual_statistics() -> Dictionary:
	var groups := 0
	var visible_instances := 0
	var total := 0
	for child in get_children():
		if child is MultiMeshInstance3D and child.get_meta("pass_decoration",false):
			groups += 1
			total += child.multimesh.instance_count
			visible_instances += child.multimesh.visible_instance_count
	return {"profile":visual_quality,"decoration_groups":groups,"visible_instances":visible_instances,"detail_instances":total}
