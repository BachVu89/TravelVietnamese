class_name TravelPreferences
extends RefCounted

static func defaults() -> Dictionary:
	return {"shadows": true, "sensitivity": 1.0}

static func normalize(value: Variant) -> Dictionary:
	var preferences := defaults()
	if not value is Dictionary:
		return preferences
	if value.get("shadows") is bool:
		preferences.shadows = value.shadows
	var sensitivity = value.get("sensitivity")
	if sensitivity is float or sensitivity is int:
		for preset in [0.6, 1.0, 1.4]:
			if is_equal_approx(float(sensitivity), preset):
				preferences.sensitivity = preset
	return preferences

static func apply(world: Node3D, value: Variant) -> void:
	var preferences := normalize(value)
	if not world:
		return
	world.player.camera_sensitivity = preferences.sensitivity
	var bike = world.get("bike") if world.has_method("set_drive_input") else null
	if bike:
		bike.camera_sensitivity = preferences.sensitivity
	for light in world.find_children("*", "DirectionalLight3D", true, false):
		light.shadow_enabled = preferences.shadows
