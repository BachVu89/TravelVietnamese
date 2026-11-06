class_name TravelRouteObjectives
extends RefCounted

const FINISH_STATION := 738.0
const STOPS := [230.0, 550.0]
const NAMES := ["Ban công mây", "Trạm nhìn thung lũng"]
const PREFIX := "mountain_pass_demo:viewpoint_"

static func evaluate(visited: Array, hud: Dictionary) -> Dictionary:
	var progress := clampf(float(hud.get("progress", 0.0)), 0, 750)
	var riding := bool(hud.get("riding", true))
	var count := 0
	var target := -1
	for i in range(2):
		if visited.has(PREFIX + str(i + 1)):
			count += 1
		elif target < 0:
			target = i
	var result := {"complete": false, "visited_count": count, "target_station": FINISH_STATION, "phase": "ride_to_finish", "text": "2/2 điểm đã ghé · Tiếp tục tới cuối tuyến", "detail": "Còn khoảng %d m trong cảnh" % maxi(0, int(FINISH_STATION - progress))}
	if target < 0:
		if progress >= FINISH_STATION:
			result.complete = true
			result.phase = "complete"
			result.text = "Hoàn thành tuyến mẫu · Đã ghé 2/2 điểm"
			result.detail = "Có thể đi lại từ đầu hoặc tiếp tục ngắm cảnh."
		elif not riding:
			result.phase = "return_to_bike"
			result.detail = "Trở lại xe để tiếp tục tới cuối tuyến."
		return result
	var station: float = STOPS[target]
	var place: String = NAMES[target]
	result.target_station = station
	if progress > station + 28:
		result.phase = "missed_stop"
		result.text = "Chưa ghé " + place
		result.detail = "Đã qua điểm dừng. Đi lại từ đầu để ghé; các dấu đã có vẫn giữ."
	elif absf(progress - station) <= 24:
		if riding:
			result.phase = "park"
			result.text = "Điểm %d/2 · %s" % [target + 1, place]
			result.detail = "Đã đỗ an toàn · Xuống xe để tham quan." if bool(hud.get("can_exit", false)) else "Rẽ vào vịnh bên phải rồi phanh để xuống xe."
		else:
			result.phase = "walk_to_poi"
			result.text = "Đi bộ tới cột mốc · " + place
			result.detail = "Đến đủ gần rồi bấm Khám phá / F để ghi dấu."
	elif not riding:
		result.phase = "return_to_bike"
		result.text = "Lên xe để tiếp tục tới " + place
		result.detail = "Trở lại gần chiếc xe đang đỗ và bấm Lên xe / E."
	else:
		result.phase = "ride_to_stop"
		result.text = "Điểm %d/2 · Lái tới %s" % [target + 1, place]
		result.detail = "Còn khoảng %d m trong cảnh · Chưa ghi dấu khi chỉ đi ngang." % maxi(0, int(station - progress))
	return result
