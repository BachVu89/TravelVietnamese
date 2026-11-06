class_name TravelRoadSave
extends RefCounted

# A scene sample, never a 48th geographic registry entry.
const REGION_ID := "mountain_pass_demo"
const MAX_DISTANCE := 750.0
const CHECKPOINTS := [0.0, 230.0, 550.0]

static func default_state(checkpoint: float = 0.0) -> Dictionary:
	var safe_checkpoint := checkpoint if checkpoint in CHECKPOINTS else 0.0
	return {"bike_s": maxf(5.0, safe_checkpoint), "lateral": 8.0 if safe_checkpoint > 0 else 1.7, "riding": true, "checkpoint": safe_checkpoint}

static func normalize(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return default_state()
	var checkpoint := 0.0
	if _finite_number(value.get("checkpoint")) and float(value.checkpoint) in CHECKPOINTS:
		checkpoint = float(value.checkpoint)
	var fallback := default_state(checkpoint)
	for key in ["bike_s", "lateral", "checkpoint"]:
		if not _finite_number(value.get(key)):
			return fallback
	if not value.get("riding") is bool or float(value.checkpoint) not in CHECKPOINTS:
		return fallback
	var distance := float(value.bike_s)
	var lateral := float(value.lateral)
	if distance < 0.0 or distance > MAX_DISTANCE or lateral < -3.0 or lateral > 12.0:
		return fallback
	return {"bike_s": distance, "lateral": lateral, "riding": bool(value.riding), "checkpoint": checkpoint}

static func _finite_number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))
