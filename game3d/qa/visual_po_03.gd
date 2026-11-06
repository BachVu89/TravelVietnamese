extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func settle(frames: int = 20) -> void:
	for _i in range(frames):
		await physics_frame
	await process_frame
	await RenderingServer.frame_post_draw

func capture(label: String) -> void:
	root.get_texture().get_image().save_png("/tmp/travel03-" + label + ".png")

func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.save_enabled = false
	app.enter_region("hanoi", false)
	app.replay_tutorial()
	await settle()
	assert(app.onboarding.data.step == 0)
	assert(not app.waypoint_target.is_empty())
	capture("onboarding")
	app.controls.movement = Vector2(1, 0)
	await settle(40)
	app.controls.cancel_touches()
	assert(app.onboarding.data.step == 1, "Actual walk did not advance tutorial")
	app.world.player.look(Vector2(100, 0))
	await settle()
	assert(app.onboarding.data.step == 2, "Actual camera change did not advance tutorial")
	capture("waypoint")
	var poi: Dictionary = app.world.pois[0]
	app.world.player.position = poi.position + Vector3(0, 0.5, 1.8)
	await settle()
	assert(app.interact())
	assert(app.onboarding.data.status == "completed")
	app.description_dialog.hide()
	await settle()
	assert(app.waypoint_target.id != poi.id)
	app.open_settings()
	await settle()
	assert(app.settings_dialog.size.x <= root.size.x and app.settings_dialog.size.y <= root.size.y, "Settings exceeds viewport")
	assert(app.settings_dialog.get_ok_button().get_global_rect().end.y <= app.settings_dialog.size.y, "Settings return button is outside dialog")
	app.shadow_toggle.button_pressed = false
	app.sensitivity_option.select(2)
	app.sensitivity_option.item_selected.emit(2)
	await settle()
	assert(app.state.preferences.shadows == false)
	assert(is_equal_approx(app.world.player.camera_sensitivity, 1.4))
	capture("settings")
	app.settings_dialog.hide()
	app.enter_region("island_phu_quoc", false)
	await settle()
	for node in app.world.get_children():
		if node is DirectionalLight3D:
			assert(not node.shadow_enabled)
	capture("island")
	app.open_menu()
	await settle()
	capture("menu")
	print("PO03_VISUAL_PASS: real move/look/interact onboarding; next POI; settings UI live; island shadow setting retained; menu")
	app.queue_free()
	await process_frame
	quit(0)
