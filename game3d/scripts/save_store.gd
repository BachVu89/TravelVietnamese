class_name TravelSaveStore
extends RefCounted

const SAVE_PATH := "user://journey3d.json"
const VERSION := 1
const RoadSave = preload("res://scripts/road_save.gd")

static func default_data() -> Dictionary:
	return {"version": VERSION, "region_id": "hanoi", "positions": {}, "visited": [], "onboarding": preload("res://scripts/onboarding.gd").defaults(), "preferences": preload("res://scripts/preferences.gd").defaults(), "road_demo": RoadSave.default_state()}

static func decode(text: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return {"ok": false, "data": default_data(), "error": "Dữ liệu lưu không đọc được; phiên mới chưa ghi đè tệp cũ."}
	var data: Dictionary = parser.data
	if data.get("version") != VERSION or not data.get("region_id") is String or not data.get("positions") is Dictionary or not data.get("visited") is Array:
		return {"ok": false, "data": default_data(), "error": "Dữ liệu lưu không đúng định dạng."}
	if data.positions.size() > 300 or data.visited.size() > 1000:
		return {"ok": false, "data": default_data(), "error": "Dữ liệu lưu vượt giới hạn."}
	for key in data.positions:
		var position = data.positions[key]
		if not key is String or not position is Dictionary:
			return {"ok": false, "data": default_data(), "error": "Vị trí lưu không hợp lệ."}
		for field in ["x", "y", "z", "yaw", "pitch"]:
			if not position.has(field) or not (position[field] is float or position[field] is int) or not is_finite(float(position[field])):
				return {"ok": false, "data": default_data(), "error": "Tọa độ lưu không hợp lệ."}
		if absf(position.x) > 41 or absf(position.z) > 41 or position.y < -5 or position.y > 40 or position.pitch < -1.12 or position.pitch > -0.08:
			return {"ok": false, "data": default_data(), "error": "Tọa độ ngoài khu tham quan."}
	var unique: Array[String] = []
	for visited in data.visited:
		if not visited is String or visited.length() > 150:
			return {"ok": false, "data": default_data(), "error": "Dấu tham quan không hợp lệ."}
		if not unique.has(visited):
			unique.append(visited)
	data.visited = unique
	# Optional v0.3 data migrates independently; valid v0.2 journey data stays intact.
	data.onboarding = preload("res://scripts/onboarding.gd").normalize(data.get("onboarding"))
	data.preferences = preload("res://scripts/preferences.gd").normalize(data.get("preferences"))
	# The 750-unit road uses its own station/lateral coordinates; legacy position
	# validation above remains strict and unchanged for the 47 geography scenes.
	data.road_demo = RoadSave.normalize(data.get("road_demo"))
	return {"ok": true, "data": data, "error": ""}

static func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"ok": true, "data": default_data(), "error": ""}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {"ok": false, "data": default_data(), "error": "Không mở được tệp lưu trên thiết bị."}
	return decode(file.get_as_text())

static func save_data(data: Dictionary) -> bool:
	var normalized := decode(JSON.stringify(data))
	if not normalized.ok:
		return false
	var encoded := JSON.stringify(normalized.data)
	var file := FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if not file:
		return false
	file.store_string(encoded)
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".tmp"), ProjectSettings.globalize_path(SAVE_PATH)) == OK
