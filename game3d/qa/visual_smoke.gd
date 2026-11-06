extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func settle(frames: int = 25) -> void:
	for _i in range(frames):
		await physics_frame
	await process_frame
	await RenderingServer.frame_post_draw

func capture(label: String) -> void:
	root.get_texture().get_image().save_png("/tmp/travel3d-" + label + ".png")

func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.save_enabled = false
	app.enter_region("hanoi", false)
	await settle()
	capture("hanoi")
	var before: Vector3 = app.world.player.position
	app.controls.movement = Vector2(0.8, -0.4)
	await settle(50)
	app.controls.movement = Vector2.ZERO
	assert(app.world.player.position.distance_to(before) > 1.0, "Character failed to move")
	app.open_menu()
	await settle(5)
	assert(app.menu_list.get_child_count() == app.catalog.size(), "Menu/catalog mismatch")
	capture("menu")
	app._show_licenses()
	await settle(5)
	assert(app.license_dialog.size.x <= root.size.x and app.license_dialog.size.y <= root.size.y, "License dialog exceeds viewport")
	capture("licenses")
	app.license_dialog.hide()
	app.enter_region("island_phu_quoc", false)
	await settle()
	capture("island")
	var poi: Dictionary = app.world.pois[0]
	app.world.player.position = poi.position + Vector3(0, 0.5, 1.8)
	await settle(10)
	assert(app.interact(), "Proximity interaction failed")
	await settle(5)
	capture("island-poi")
	app.description_dialog.hide()
	app.enter_region("province_15", false)
	await settle()
	capture("highland")
	print("VISUAL_SMOKE_PASS: rendered Hanoi, 47-entry menu, license dialog, island, POI, highland; player movement >1m")
	app.queue_free()
	await process_frame
	quit(0)
