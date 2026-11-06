extends SceneTree

# UI evidence for batch 0.7 (PO-14): captures the live HUD in three states —
# walking at entry, riding with the speedometer, and clean-view mode.
# Unlike paired_art_capture.gd the UI stays visible and the app keeps
# processing; riding uses the real touch pedal path.

func _initialize() -> void:
	create_timer(120).timeout.connect(func(): quit(2))
	call_deferred("run")

func out_dir() -> String:
	var dir := ProjectSettings.globalize_path("res://").path_join("../docs/screenshots07")
	DirAccess.make_dir_recursive_absolute(dir)
	return dir

func snap(dir: String, name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(dir.path_join(name))
	print("UI_CAPTURE_SHOT: ", name)

func settle(frames: int) -> void:
	for _i in range(frames):
		await physics_frame

func run() -> void:
	var dir := out_dir()
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.save_enabled = false
	app.demo_entry_button.pressed.emit()
	await settle(45)
	if not app.is_pass_demo():
		print("UI_CAPTURE_FAIL: entry")
		quit(1)
		return
	await snap(dir, "travel07-ui-idle.png")
	if not app.world.riding:
		print("UI_CAPTURE_FAIL: entry should start mounted")
		quit(1)
		return
	app.controls.gas_id = 99
	app.controls._update_drive_input()
	await settle(160)
	await snap(dir, "travel07-ui-ride.png")
	var speed: float = app.world.bike.speed
	app._toggle_clean_view()
	await settle(12)
	await snap(dir, "travel07-ui-clean.png")
	app._toggle_clean_view()
	app.controls.cancel_touches()
	app.controls.brake_id = 98
	app.controls._update_drive_input()
	for _i in range(240):
		await physics_frame
		if app.world.bike.speed <= 0.05:
			break
	app.controls.cancel_touches()
	# QA placement for the on-foot frame only (same convention as the paired
	# art captures); gameplay itself is covered by the live drive QA.
	app.world.bike.reset_to_distance(232.0, 8.0)
	await settle(30)
	app.vehicle_button.pressed.emit()
	await settle(12)
	if app.world.riding:
		print("UI_CAPTURE_FAIL: dismount for walk frame")
		quit(1)
		return
	await snap(dir, "travel07-ui-walk.png")
	print("UI_CAPTURE_PASS: idle/ride/clean/walk captured, ride speed u/s=", speed)
	app.queue_free()
	await process_frame
	quit(0)
