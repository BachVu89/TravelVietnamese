extends Node3D

const WorldScript = preload("res://scripts/world.gd")
const ControlsScript = preload("res://scripts/touch_controls.gd")
const SaveStore = preload("res://scripts/save_store.gd")
const OnboardingScript = preload("res://scripts/onboarding.gd")
const Navigation = preload("res://scripts/navigation.gd")
const Preferences = preload("res://scripts/preferences.gd")
const PassWorldScript = preload("res://scripts/mountain_pass.gd")
const RoadSave = preload("res://scripts/road_save.gd")
const RouteObjectives = preload("res://scripts/route_objectives.gd")
const PerformanceMeter = preload("res://scripts/performance.gd")
var onboarding = OnboardingScript.new()
var navigation_label: Label
var tutorial_label: Label
var tutorial_row: HBoxContainer
var waypoint_target: Dictionary = {}
var settings_dialog: AcceptDialog
var shadow_toggle: CheckButton
var sensitivity_option: OptionButton
var quality_option: OptionButton
var route_objective: Dictionary = {}
var route_objective_label: Label
var demo_entry_button: Button
var catalog: Array[Dictionary] = []
var world: TravelWorld
var controls: TravelTouchControls
var state: Dictionary
var ui: Control
var heading: Label
var status: Label
var hint: Label
var interact_button: Button
var menu: PanelContainer
var menu_list: VBoxContainer
var search: LineEdit
var license_dialog: AcceptDialog
var description_dialog: AcceptDialog
var current_poi: Dictionary = {}
var autosave_time := 0.0
var save_enabled := true
var vehicle_button: Button
var reset_button: Button
var guidance_note: Label
var footer_background: Panel
var footer_container: VBoxContainer
var drive_hint: Label
var application_suspended := false
var performance_meter = PerformanceMeter.new()
var adaptive_detail := 0
var adaptive_cooldown := 2.5

func _ready() -> void:
	# Keep a steady frame budget on phones instead of letting the GPU run hot and
	# then throttling; desktop stays uncapped for normal windowed play.
	if OS.has_feature("mobile"):
		Engine.max_fps = 60
	_load_catalog()
	var loaded := SaveStore.load_data()
	state = loaded.data
	onboarding.init_from(state.onboarding)
	onboarding.changed.connect(_on_tutorial_changed)
	_build_ui()
	_on_tutorial_changed()
	if not loaded.ok:
		status.text = loaded.error + " Bấm Lưu để bắt đầu ghi phiên mới."
		save_enabled = false
	var entry := catalog[0]
	for candidate in catalog:
		if candidate.id == state.region_id:
			entry = candidate
			break
	enter_region(RoadSave.REGION_ID if state.region_id == RoadSave.REGION_ID else str(entry.id), false)

func _load_catalog() -> void:
	var path := "res://data/geography/regions.json"
	if FileAccess.file_exists(path):
		var data = JSON.parse_string(FileAccess.get_file_as_string(path))
		var entries = data if data is Array else data.get("regions", []) if data is Dictionary else []
		for entry in entries:
			if entry is Dictionary and entry.get("id") is String and entry.get("name") is String:
				catalog.append(entry)
	if catalog.is_empty():
		catalog.append({"id": "hanoi", "name": "Hà Nội", "type": "province", "scene_style": "city", "detail_level": "prototype"})

func enter_region(id: String, save_previous: bool = true) -> bool:
	var selected: Dictionary = {}
	if id == RoadSave.REGION_ID:
		selected = {"id": RoadSave.REGION_ID, "name": "Đèo mây · Tuyến lái thử", "type": "sample", "scene_style": "mountain_pass"}
	for entry in catalog:
		if entry.id == id:
			selected = entry
			break
	if selected.is_empty():
		return false
	if world and save_previous:
		capture_position()
	if world:
		remove_child(world)
		world.queue_free()
	world = PassWorldScript.new() if id == RoadSave.REGION_ID else WorldScript.new()
	add_child(world)
	world.build(selected)
	adaptive_detail = 0
	adaptive_cooldown = 2.5
	performance_meter.reset()
	Preferences.apply(world, state.preferences)
	world.player.traveled.connect(_on_player_traveled)
	world.player.looked.connect(_on_player_looked)
	state.region_id = id
	if is_pass_demo():
		world.call("restore_road_state", RoadSave.normalize(state.get("road_demo")))
	elif state.positions.has(id):
		var position: Dictionary = state.positions[id]
		world.player.position = Vector3(position.x, maxf(position.y, world.terrain_height(position.x, position.z) + 0.1), position.z)
		world.player.yaw = position.yaw
		world.player.pitch = position.pitch
		world.player.update_camera()
	if is_instance_valid(heading):
		heading.text = "ĐÈO MÂY · TUYẾN MẪU 750 m" if is_pass_demo() else str(selected.name) + "  ·  " + ("KHU MẪU HÀ NỘI" if str(id).to_lower().replace("-", "").replace("_", "") in ["hanoi", "01"] else "CẢNH MINH HỌA 3D")
	close_menu()
	_on_tutorial_changed()
	if save_previous and save_enabled:
		save_now()
	return true

func capture_position() -> void:
	if not world or not world.player:
		return
	if is_pass_demo():
		state.road_demo = RoadSave.normalize(world.call("capture_road_state"))
		return
	var p := world.player.position
	state.positions[state.region_id] = {"x": clampf(p.x, -41, 41), "y": clampf(p.y, -5, 40), "z": clampf(p.z, -41, 41), "yaw": world.player.yaw, "pitch": world.player.pitch}

func save_now() -> bool:
	capture_position()
	var success := SaveStore.save_data(state)
	status.text = "Đã lưu offline trên thiết bị · " + str(state.visited.size()) + " dấu khám phá" if success else "Chưa lưu được. Hãy thử lại trước khi thoát."
	return success

func _process(delta: float) -> void:
	if not world:
		return
	var paused := _is_modal_open() or application_suspended
	var pass_active := is_pass_demo()
	var road_hud: Dictionary = world.call("get_hud_state") if pass_active else {}
	var riding := pass_active and bool(road_hud.get("riding", false))
	controls.set_drive_mode(riding)
	controls.enabled = not paused
	if pass_active:
		world.call("set_paused", paused)
	if paused:
		world.player.move_input = Vector2.ZERO
		controls.cancel_touches()
		if pass_active:
			world.call("set_drive_input", Vector2.ZERO)
	else:
		var keyboard := Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
		if riding:
			world.player.move_input = Vector2.ZERO
			var pedal := controls.drive_input.y
			if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN) or pedal < 0:
				pedal = -1.0
			elif Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
				pedal = 1.0
			world.call("set_drive_input", Vector2(clampf(keyboard.x + controls.movement.x, -1, 1), pedal))
		else:
			world.player.move_input = (keyboard + controls.movement).limit_length(1.0)
	var origin: Vector3 = world.call("active_avatar").position if pass_active else world.player.position
	waypoint_target = Navigation.next_target(world.pois, state.visited, origin, world.player.yaw)
	if riding:
		_set_text(navigation_label, "%d km/h · %d / %d m cảnh" % [int(road_hud.speed_kmh), int(road_hud.progress), int(road_hud.total_length)])
		_set_text(guidance_note, "Tuyến đèo minh họa · Khoảng cách trong cảnh")
	elif waypoint_target.is_empty():
		_set_text(navigation_label, "Đã khám phá " + str(_current_visit_count()) + "/" + str(world.pois.size()) + " điểm trong cảnh")
	else:
		var arrows := {"trước": "↑", "phải": "→", "sau": "↓", "trái": "←"}
		_set_text(navigation_label, str(arrows[waypoint_target.bearing]) + " " + str(waypoint_target.title) + " · ≈" + str(int(round(waypoint_target.distance))) + " m · Phía " + str(waypoint_target.bearing))
	if not riding:
		_set_text(guidance_note, "Khoảng cách thẳng trong cảnh minh họa · Hướng theo camera")
	route_objective_label.visible = pass_active
	if pass_active:
		route_objective = RouteObjectives.evaluate(state.visited, road_hud)
		_set_text(route_objective_label, str(route_objective.text) + "\n" + str(route_objective.detail))
	drive_hint.visible = riding
	footer_background.visible = not riding
	footer_container.visible = not riding
	vehicle_button.visible = pass_active and not paused
	_set_text(demo_entry_button, "Đi lại từ đầu" if pass_active else "Chơi đèo mẫu")
	_set_text(reset_button, "Về điểm dừng" if pass_active else "Về lối vào")
	if pass_active:
		var right_edge := 790 if riding else 630
		if int(vehicle_button.offset_right) != right_edge:
			vehicle_button.offset_right = right_edge
		_set_text(vehicle_button, "Xuống xe · E" if riding and road_hud.can_exit else "Phanh và vào vịnh dừng để xuống xe" if riding else "Lên xe · E" if road_hud.can_mount else "Đến gần xe để lên xe")
		vehicle_button.disabled = not bool(road_hud.can_exit if riding else road_hud.can_mount)
	controls.blocked_rectangles.clear()
	if vehicle_button.visible:
		controls.blocked_rectangles.append(vehicle_button.get_global_rect())
	if interact_button.visible:
		controls.blocked_rectangles.append(interact_button.get_global_rect())
	current_poi = world.nearest_poi()
	interact_button.visible = not current_poi.is_empty() and not paused
	if not current_poi.is_empty():
		_set_text(interact_button, ("✓ Xem lại · " if state.visited.has(current_poi.id) else "Khám phá · ") + str(current_poi.title))
	_set_text(hint, "Đi gần cột mốc vàng để tham quan  ·  " + str(_current_visit_count()) + "/" + str(world.pois.size()) + " dấu tại đây")
	autosave_time += delta
	if autosave_time > 5 and save_enabled:
		autosave_time = 0
		save_now()
	_report_frame_time(delta, paused)

## Label text shaping and layout are comparatively expensive, so only assign a
## string when it actually changes. HUD values update at full speed but repeated
## identical frames cost nothing.
func _set_text(target, value: String) -> void:
	if target.text != value:
		target.text = value

## If measured frame rate stays under target, remove decorative detail in two
## steps. This is intentionally one-way per scene so quality cannot oscillate.
func _report_frame_time(delta: float, paused: bool) -> void:
	if paused or not world or not world.has_method("set_adaptive_detail"):
		return
	adaptive_cooldown = maxf(0.0, adaptive_cooldown - delta)
	if adaptive_detail >= 2 or adaptive_cooldown > 0.0:
		return
	if performance_meter.sample(delta):
		adaptive_detail += 1
		adaptive_cooldown = 4.0
		world.call("set_adaptive_detail", adaptive_detail)

func _current_visit_count() -> int:
	var count := 0
	for poi in world.pois:
		if state.visited.has(poi.id):
			count += 1
	return count

func is_pass_demo() -> bool:
	return world != null and str(world.region.get("id", "")) == RoadSave.REGION_ID

func start_pass_demo() -> bool:
	return enter_region(RoadSave.REGION_ID)

func replay_pass_route() -> bool:
	# Reset this ride's position, not its stamps, settings or geographic progress.
	state.road_demo = RoadSave.default_state()
	var entered := enter_region(RoadSave.REGION_ID, false)
	if entered and save_enabled:
		save_now()
	return entered

func toggle_pass_vehicle() -> bool:
	if not is_pass_demo() or _is_modal_open() or application_suspended:
		return false
	controls.cancel_touches()
	var changed: bool = world.call("toggle_vehicle")
	if changed and save_enabled:
		save_now()
	return changed

func return_to_entry() -> void:
	if not world:
		return
	controls.cancel_touches()
	if is_pass_demo():
		world.call("return_to_start")
	else:
		world.player.position = Vector3(0, world.terrain_height(0, 15) + 0.4, 15)
		world.player.velocity = Vector3.ZERO
	if save_enabled:
		save_now()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_E and toggle_pass_vehicle():
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_F and not _is_modal_open() and not application_suspended and interact():
			get_viewport().set_input_as_handled()

func interact() -> bool:
	var poi := world.nearest_poi()
	if poi.is_empty():
		return false
	if not state.visited.has(poi.id):
		state.visited.append(poi.id)
	onboarding.record_interaction()
	description_dialog.title = poi.title
	description_dialog.dialog_text = poi.description + "\n\nĐã ghi một dấu khám phá trong nhật ký offline."
	description_dialog.popup_centered(Vector2i(620, 270))
	controls.cancel_touches()
	if save_enabled:
		save_now()
	return true

func open_menu() -> void:
	menu.show()
	controls.enabled = false
	controls.cancel_touches()
	_refresh_menu()

func close_menu() -> void:
	if is_instance_valid(menu):
		menu.hide()
	if is_instance_valid(controls):
		controls.cancel_touches()
		controls.enabled = true

func _refresh_menu(_text: String = "") -> void:
	for child in menu_list.get_children():
		menu_list.remove_child(child)
		child.queue_free()
	var query := search.text.strip_edges().to_lower()
	for entry in catalog:
		if not query.is_empty() and not str(entry.name).to_lower().contains(query):
			continue
		var button := Button.new()
		var kind := "ĐẢO / QUẦN ĐẢO" if str(entry.get("type", "")) == "island" else "TỈNH / THÀNH"
		button.text = str(entry.name) + "   ·   " + kind + "   → Vào cảnh 3D"
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size.y = 46
		button.pressed.connect(enter_region.bind(str(entry.id)))
		menu_list.add_child(button)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui)
	var theme := Theme.new()
	theme.default_font_size = 18
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color("214c3f")
	button_style.set_corner_radius_all(9)
	button_style.content_margin_left = 15
	button_style.content_margin_right = 15
	button_style.content_margin_top = 9
	button_style.content_margin_bottom = 9
	theme.set_stylebox("normal", "Button", button_style)
	var hover := button_style.duplicate()
	hover.bg_color = Color("3b6a52")
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", hover)
	theme.set_color("font_color", "Button", Color("fff4df"))
	ui.theme = theme
	controls = ControlsScript.new()
	ui.add_child(controls)
	controls.camera_drag.connect(func(motion: Vector2):
		if world and not _is_modal_open():
			if is_pass_demo() and bool(world.get("riding")):
				var bike = world.get("bike")
				bike.look(motion)
			else:
				world.player.look(motion))
	var bar := PanelContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bar.offset_left = 18
	bar.offset_top = 16
	bar.offset_right = -18
	bar.offset_bottom = 98
	bar.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.17, 0.14, 0.92)))
	ui.add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	bar.add_child(row)
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(names)
	heading = Label.new()
	heading.add_theme_font_size_override("font_size", 23)
	names.add_child(heading)
	var subtitle := Label.new()
	subtitle.text = "DỌC MIỀN VIỆT 3D · 0.6 · OFFLINE"
	subtitle.add_theme_font_size_override("font_size", 14)
	names.add_child(subtitle)
	demo_entry_button = Button.new()
	demo_entry_button.text = "Chơi đèo mẫu"
	demo_entry_button.pressed.connect(func():
		if is_pass_demo():
			replay_pass_route()
		else:
			start_pass_demo())
	row.add_child(demo_entry_button)
	var map_button := Button.new()
	map_button.text = "Đổi địa điểm"
	map_button.pressed.connect(open_menu)
	row.add_child(map_button)
	var save_button := Button.new()
	save_button.text = "Lưu"
	save_button.pressed.connect(func():
		save_enabled = true
		save_now())
	row.add_child(save_button)
	reset_button = Button.new()
	reset_button.text = "Về lối vào"
	reset_button.pressed.connect(return_to_entry)
	row.add_child(reset_button)
	_build_guidance_ui()
	footer_background = Panel.new()
	footer_background.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer_background.offset_left = 208
	footer_background.offset_right = -16
	footer_background.offset_top = -102
	footer_background.offset_bottom = -7
	footer_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer_background.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.17, 0.14, 0.85)))
	ui.add_child(footer_background)
	var footer := VBoxContainer.new()
	footer_container = footer
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 220
	footer.offset_right = -25
	footer.offset_top = -94
	footer.offset_bottom = -14
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(footer)
	hint = Label.new()
	hint.add_theme_font_size_override("font_size", 17)
	hint.add_theme_color_override("font_shadow_color", Color.BLACK)
	hint.add_theme_constant_override("shadow_offset_x", 1)
	hint.add_theme_constant_override("shadow_offset_y", 2)
	footer.add_child(hint)
	status = Label.new()
	status.text = "Chưa có thay đổi · Lưu offline tự động mỗi 5 giây"
	status.add_theme_font_size_override("font_size", 13)
	footer.add_child(status)
	var instructions := Label.new()
	instructions.text = "Joystick / WASD: đi bộ · Kéo phải / chuột phải: camera · F: khám phá"
	instructions.add_theme_font_size_override("font_size", 13)
	footer.add_child(instructions)
	interact_button = Button.new()
	interact_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	interact_button.offset_left = -610
	interact_button.offset_right = -24
	interact_button.offset_top = -158
	interact_button.offset_bottom = -106
	interact_button.pressed.connect(interact)
	interact_button.hide()
	ui.add_child(interact_button)
	vehicle_button = Button.new()
	vehicle_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	vehicle_button.offset_left = 270
	vehicle_button.offset_right = 790
	vehicle_button.offset_top = -152
	vehicle_button.offset_bottom = -102
	vehicle_button.add_theme_font_size_override("font_size", 16)
	vehicle_button.pressed.connect(toggle_pass_vehicle)
	vehicle_button.hide()
	ui.add_child(vehicle_button)
	menu = PanelContainer.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.offset_left = 120
	menu.offset_right = -120
	menu.offset_top = 112
	menu.offset_bottom = -40
	menu.add_theme_stylebox_override("panel", _panel_style(Color("173f35")))
	ui.add_child(menu)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	menu.add_child(column)
	var title := Label.new()
	title.text = "34 tỉnh/thành + 13 vùng đảo · Nội dung đang phát triển"
	title.add_theme_font_size_override("font_size", 25)
	column.add_child(title)
	var disclaimer := Label.new()
	disclaimer.text = "Mỗi địa danh vào được cảnh 3D minh họa riêng. Chưa số hóa địa hình / công trình thực địa.\nĐảo có địa hình nổi, bờ cát và điểm tham quan; không khẳng định đường bờ hay tỷ lệ thực."
	disclaimer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	disclaimer.add_theme_font_size_override("font_size", 14)
	column.add_child(disclaimer)
	var demo_button := Button.new()
	demo_button.text = "▶ LÁI XE TRÊN ĐÈO MÂY · Tuyến mẫu 750 m"
	demo_button.custom_minimum_size.y = 48
	demo_button.pressed.connect(enter_region.bind(RoadSave.REGION_ID))
	column.add_child(demo_button)
	search = LineEdit.new()
	search.placeholder_text = "Tìm tên tỉnh, thành phố hoặc đảo…"
	search.text_changed.connect(_refresh_menu)
	column.add_child(search)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	menu_list = VBoxContainer.new()
	menu_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(menu_list)
	var settings_button := Button.new()
	settings_button.text = "Cài đặt · Bóng đổ và camera"
	settings_button.pressed.connect(open_settings)
	column.add_child(settings_button)
	var replay_button := Button.new()
	replay_button.text = "Xem lại hướng dẫn điều khiển"
	replay_button.pressed.connect(replay_tutorial)
	column.add_child(replay_button)
	var licenses_button := Button.new()
	licenses_button.text = "Giấy phép & nguồn dữ liệu"
	licenses_button.pressed.connect(_show_licenses)
	column.add_child(licenses_button)
	var close := Button.new()
	close.text = "Trở lại tham quan"
	close.pressed.connect(close_menu)
	column.add_child(close)
	menu.hide()
	description_dialog = AcceptDialog.new()
	description_dialog.exclusive = true
	description_dialog.min_size = Vector2i(580, 260)
	description_dialog.ok_button_text = "Tiếp tục đi bộ"
	ui.add_child(description_dialog)

func _is_modal_open() -> bool:
	return (is_instance_valid(menu) and menu.visible) or (is_instance_valid(description_dialog) and description_dialog.visible) or (is_instance_valid(license_dialog) and license_dialog.visible) or (is_instance_valid(settings_dialog) and settings_dialog.visible)

func _on_player_traveled(distance: float) -> void:
	if not _is_modal_open():
		onboarding.record_move(distance)

func _on_player_looked(radians: float) -> void:
	if not _is_modal_open():
		onboarding.record_look(radians)

func _on_tutorial_changed() -> void:
	var previous: Dictionary = state.get("onboarding", {})
	var checkpoint: bool = previous.get("step") != onboarding.data.step or previous.get("status") != onboarding.data.status
	state.onboarding = onboarding.data.duplicate(true)
	if checkpoint and world and save_enabled:
		save_now()
	if not is_instance_valid(tutorial_row):
		return
	tutorial_row.visible = onboarding.data.status == "active" and not is_pass_demo()
	var instructions := ["1/3 · Kéo cần trái / WASD để đi bộ 2 m", "2/3 · Kéo phía phải / chuột phải để xoay camera", "3/3 · Đến cột mốc vàng, chọn Khám phá / Xem lại"]
	if onboarding.data.step < instructions.size():
		tutorial_label.text = instructions[onboarding.data.step]

func skip_tutorial() -> void:
	onboarding.skip()
	if save_enabled:
		save_now()

func replay_tutorial() -> void:
	onboarding.replay()
	close_menu()
	if save_enabled:
		save_now()

func _build_guidance_ui() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 110)
	panel.custom_minimum_size = Vector2(620, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.17, 0.14, 0.86)))
	ui.add_child(panel)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(column)
	navigation_label = Label.new()
	navigation_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	navigation_label.add_theme_font_size_override("font_size", 18)
	column.add_child(navigation_label)
	guidance_note = Label.new()
	guidance_note.text = "Khoảng cách thẳng trong cảnh minh họa · Hướng theo camera"
	guidance_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guidance_note.add_theme_font_size_override("font_size", 12)
	column.add_child(guidance_note)
	route_objective_label = Label.new()
	route_objective_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	route_objective_label.custom_minimum_size.x = 580
	route_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_objective_label.add_theme_font_size_override("font_size", 15)
	route_objective_label.hide()
	column.add_child(route_objective_label)
	drive_hint = Label.new()
	drive_hint.text = "A/D: lái · W: ga · S: phanh · E: lên/xuống xe tại vịnh dừng"
	drive_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drive_hint.add_theme_font_size_override("font_size", 13)
	drive_hint.hide()
	column.add_child(drive_hint)
	tutorial_row = HBoxContainer.new()
	tutorial_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(tutorial_row)
	tutorial_label = Label.new()
	tutorial_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tutorial_label.add_theme_font_size_override("font_size", 16)
	tutorial_row.add_child(tutorial_label)
	var skip_button := Button.new()
	skip_button.text = "Bỏ qua"
	skip_button.custom_minimum_size.y = 44
	skip_button.pressed.connect(skip_tutorial)
	tutorial_row.add_child(skip_button)

func open_settings() -> void:
	controls.cancel_touches()
	controls.enabled = false
	if not is_instance_valid(settings_dialog):
		settings_dialog = AcceptDialog.new()
		settings_dialog.title = "Cài đặt trải nghiệm"
		settings_dialog.ok_button_text = "Trở lại"
		settings_dialog.exclusive = true
		ui.add_child(settings_dialog)
		var column := VBoxContainer.new()
		column.custom_minimum_size = Vector2(520, 340)
		column.add_theme_constant_override("separation", 16)
		settings_dialog.add_child(column)
		shadow_toggle = CheckButton.new()
		shadow_toggle.text = "Bóng đổ 3D"
		shadow_toggle.custom_minimum_size.y = 44
		shadow_toggle.toggled.connect(func(enabled: bool):
			var next: Dictionary = state.preferences.duplicate()
			next.shadows = enabled
			apply_preferences(next))
		column.add_child(shadow_toggle)
		var label := Label.new()
		label.text = "Độ nhạy camera"
		column.add_child(label)
		sensitivity_option = OptionButton.new()
		sensitivity_option.custom_minimum_size.y = 48
		for title in ["Thấp · 0.6×", "Chuẩn · 1×", "Cao · 1.4×"]:
			sensitivity_option.add_item(title)
		sensitivity_option.item_selected.connect(func(index: int):
			var next: Dictionary = state.preferences.duplicate()
			next.sensitivity = [0.6, 1.0, 1.4][index]
			apply_preferences(next))
		column.add_child(sensitivity_option)
		var quality_label := Label.new()
		quality_label.text = "Chi tiết cảnh (bóng đổ dùng lựa chọn riêng)"
		quality_label.add_theme_font_size_override("font_size", 16)
		column.add_child(quality_label)
		quality_option = OptionButton.new()
		quality_option.custom_minimum_size.y = 48
		quality_option.add_item("Tiết kiệm · Ít cây bụi và chi tiết xa")
		quality_option.add_item("Chi tiết · Nhiều lớp cảnh hơn")
		quality_option.item_selected.connect(func(index: int):
			var next: Dictionary = state.preferences.duplicate()
			next.visual_quality = "detail" if index == 1 else "economy"
			apply_preferences(next))
		column.add_child(quality_option)
		var note := Label.new()
		note.text = "Áp dụng ngay và lưu trên thiết bị.\nTắt bóng đổ khi muốn giảm chi tiết đồ họa."
		note.add_theme_font_size_override("font_size", 14)
		column.add_child(note)
	shadow_toggle.set_pressed_no_signal(state.preferences.shadows)
	sensitivity_option.select([0.6, 1.0, 1.4].find(state.preferences.sensitivity))
	quality_option.select(1 if state.preferences.visual_quality == "detail" else 0)
	settings_dialog.popup_centered(Vector2i(600, 480))

func apply_preferences(preferences: Variant) -> void:
	state.preferences = Preferences.normalize(preferences)
	Preferences.apply(world, state.preferences)
	if save_enabled:
		save_now()

func _show_licenses() -> void:
	controls.cancel_touches()
	if not is_instance_valid(license_dialog):
		license_dialog = AcceptDialog.new()
		license_dialog.title = "Giấy phép & nguồn dữ liệu · Offline"
		license_dialog.exclusive = true
		license_dialog.ok_button_text = "Đóng"
		ui.add_child(license_dialog)
		var text := TextEdit.new()
		text.text = preload("res://scripts/licenses.gd").full_text()
		text.editable = false
		text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		text.custom_minimum_size = Vector2(700, 360)
		text.add_theme_font_size_override("font_size", 15)
		license_dialog.add_child(text)
	license_dialog.popup_centered(Vector2i(800, 460))

func _panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(12)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_CLOSE_REQUEST:
		application_suspended = true
		if state and world and save_enabled:
			save_now()
		if controls:
			controls.cancel_touches()
		if is_pass_demo():
			world.call("set_paused", true)
	elif what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		application_suspended = false
