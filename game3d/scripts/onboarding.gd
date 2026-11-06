class_name TravelOnboarding
extends RefCounted

signal changed
const MOVE_THRESHOLD := 2.0
const LOOK_THRESHOLD := 0.25
var data: Dictionary = defaults()

static func defaults() -> Dictionary:
	return {"step": 0, "status": "active", "move_distance": 0.0, "look_radians": 0.0}

static func normalize(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return defaults()
	var step = value.get("step", 0)
	var status = value.get("status", "active")
	var distance = value.get("move_distance", 0.0)
	var look = value.get("look_radians", 0.0)
	if not (step is int or step is float) or not is_finite(float(step)) or float(step) != floorf(float(step)) or step < 0 or step > 3:
		return defaults()
	if status not in ["active", "completed", "skipped"]:
		return defaults()
	if (status == "active" and step == 3) or (status != "active" and step != 3):
		return defaults()
	if not (distance is float or distance is int) or not is_finite(float(distance)) or distance < 0 or not (look is float or look is int) or not is_finite(float(look)) or look < 0:
		return defaults()
	return {"step": int(step), "status": str(status), "move_distance": minf(float(distance), MOVE_THRESHOLD), "look_radians": minf(float(look), LOOK_THRESHOLD)}

func init_from(value: Variant) -> void:
	data = normalize(value)

func record_move(distance: float) -> void:
	if data.status != "active" or data.step != 0 or not is_finite(distance) or distance <= 0:
		return
	data.move_distance = minf(MOVE_THRESHOLD, float(data.move_distance) + distance)
	if data.move_distance >= MOVE_THRESHOLD:
		data.step = 1
	changed.emit()

func record_look(radians: float) -> void:
	if data.status != "active" or data.step != 1 or not is_finite(radians) or radians <= 0:
		return
	data.look_radians = minf(LOOK_THRESHOLD, float(data.look_radians) + radians)
	if data.look_radians >= LOOK_THRESHOLD:
		data.step = 2
	changed.emit()

func record_interaction() -> void:
	if data.status != "active" or data.step != 2:
		return
	data.step = 3
	data.status = "completed"
	changed.emit()

func skip() -> void:
	data.step = 3
	data.status = "skipped"
	changed.emit()

func replay() -> void:
	data = defaults()
	changed.emit()
