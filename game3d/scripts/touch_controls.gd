class_name TravelTouchControls
extends Control

signal camera_drag(delta: Vector2)
var joystick_id := -1
var camera_id := -1
var joystick_origin := Vector2.ZERO
var joystick_tip := Vector2.ZERO
var movement := Vector2.ZERO
var enabled := true
var mouse_look := false
var drive_mode := false
var drive_input := Vector2.ZERO
var gas_id := -1
var brake_id := -1
var blocked_rectangles: Array[Rect2] = []
const RADIUS := 68.0
const DEADZONE := 0.14

func set_drive_mode(value: bool) -> void:
	if drive_mode != value:
		cancel_touches()
		drive_mode = value
		queue_redraw()

## Touch targets scale with the screen so thumbs keep the same physical size on
## small phones and tablets instead of shrinking with the 1280x720 layout.
func joystick_radius() -> float:
	return clampf(minf(size.x, size.y) * 0.105, 54.0, 78.0)

func pedal_radius() -> float:
	return clampf(minf(size.x, size.y) * 0.075, 44.0, 56.0)

func gas_center() -> Vector2:
	var margin := maxf(86.0, minf(size.x, size.y) * 0.12)
	return Vector2(size.x - margin, size.y - maxf(106.0, minf(size.x, size.y) * 0.15))

func brake_center() -> Vector2:
	var spacing := maxf(124.0, minf(size.x, size.y) * 0.17)
	return gas_center() + Vector2(-spacing, 0)

func _update_drive_input() -> void:
	drive_input = Vector2(movement.x, -1.0 if brake_id >= 0 else 1.0 if gas_id >= 0 else 0.0)

func _blocked(point: Vector2) -> bool:
	for rect in blocked_rectangles:
		if rect.has_point(point):
			return true
	return false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func cancel_touches() -> void:
	joystick_id = -1
	camera_id = -1
	movement = Vector2.ZERO
	mouse_look = false
	gas_id = -1
	brake_id = -1
	drive_input = Vector2.ZERO
	queue_redraw()

func _input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventScreenTouch:
		if not event.pressed:
			if event.index == gas_id:
				gas_id = -1
			if event.index == brake_id:
				brake_id = -1
			if event.index == joystick_id:
				joystick_id = -1
				movement = Vector2.ZERO
			if event.index == camera_id:
				camera_id = -1
		elif _blocked(event.position):
			return
		elif drive_mode and event.position.distance_to(gas_center()) < pedal_radius() + 12.0 and gas_id == -1:
			gas_id = event.index
		elif drive_mode and event.position.distance_to(brake_center()) < pedal_radius() + 12.0 and brake_id == -1:
			brake_id = event.index
		elif event.position.y > size.y * 0.45 and event.position.x < size.x * 0.38 and joystick_id == -1:
			joystick_id = event.index
			joystick_origin = event.position
			joystick_tip = event.position
		elif event.position.x > size.x * 0.44 and event.position.y > 130 and event.position.y < size.y - 110 and camera_id == -1:
			camera_id = event.index
		_update_drive_input()
		queue_redraw()
	elif event is InputEventScreenDrag:
		if event.index == joystick_id:
			var raw: Vector2 = (event.position - joystick_origin) / joystick_radius()
			# Ignore tiny thumb jitter instead of letting it steer the bike, then
			# rescale so full deflection is still reachable.
			var magnitude: float = raw.length()
			if magnitude <= DEADZONE:
				movement = Vector2.ZERO
			else:
				movement = raw.normalized() * minf((magnitude - DEADZONE) / (1.0 - DEADZONE), 1.0)
			joystick_tip = joystick_origin + movement * joystick_radius()
			_update_drive_input()
			queue_redraw()
		elif event.index == camera_id:
			camera_drag.emit(event.relative)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		mouse_look = event.pressed
	elif event is InputEventMouseMotion and mouse_look:
		camera_drag.emit(event.relative)

func _draw() -> void:
	if not enabled:
		return
	var radius := joystick_radius()
	var center := joystick_origin if joystick_id >= 0 else Vector2(115, size.y - 120)
	var tip := joystick_tip if joystick_id >= 0 else center
	draw_circle(center, radius, Color(0.08, 0.22, 0.18, 0.35))
	draw_arc(center, radius, 0, TAU, 48, Color(1, 0.97, 0.88, 0.8), 2)
	draw_circle(tip, radius * 0.41, Color(0.92, 0.72, 0.35, 0.85))
	if drive_mode:
		var font := ThemeDB.fallback_font
		var pedal := pedal_radius()
		for button: Dictionary in [{"center": gas_center(), "label": "GA", "pressed": gas_id >= 0}, {"center": brake_center(), "label": "PHANH", "pressed": brake_id >= 0}]:
			var color := Color(0.11, 0.27, 0.23, 0.9) if button.pressed else Color(0.08, 0.18, 0.17, 0.65)
			draw_circle(button.center, pedal, color)
			draw_arc(button.center, pedal, 0, TAU, 40, Color("e9d8b1"), 2)
			var label_size := font.get_string_size(button.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 19)
			draw_string(font, button.center + Vector2(-label_size.x / 2, 7), button.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("fff8ed"))
