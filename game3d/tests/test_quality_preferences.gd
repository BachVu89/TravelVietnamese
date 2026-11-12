extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)

func run() -> void:
	var preferences = load("res://scripts/preferences.gd")
	var store = load("res://scripts/save_store.gd")
	check(preferences.defaults().visual_quality == "economy", "new and legacy preferences default to economy quality")
	for profile in ["economy", "detail"]:
		var value: Dictionary = preferences.normalize({"shadows": false, "sensitivity": 1.4, "visual_quality": profile})
		check(value.visual_quality == profile and value.shadows == false and is_equal_approx(value.sensitivity, 1.4), "canonical quality preset preserves independent shadow/sensitivity: " + profile)
	for invalid in [null, false, true, 1, 0.5, "", "ultra", "DETAIL", [], {}]:
		var value: Dictionary = preferences.normalize({"shadows": false, "sensitivity": 0.6, "visual_quality": invalid})
		check(value.visual_quality == "economy" and value.shadows == false and is_equal_approx(value.sensitivity, 0.6), "invalid quality resets only quality without resetting valid settings: " + str(invalid))
	for fixture_name in ["progress-v0.2.json", "progress-v0.3.json"]:
		var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/" + fixture_name))
		var migrated: Dictionary = store.decode(JSON.stringify(fixture))
		check(migrated.ok and migrated.data.preferences.visual_quality == "economy" and migrated.data.positions == fixture.positions and migrated.data.visited == fixture.visited and migrated.data.region_id == fixture.region_id, "missing quality in real legacy fixture gains economy without resetting journey: " + fixture_name)
		if fixture.has("preferences"):
			check(migrated.data.preferences.shadows == fixture.preferences.shadows and is_equal_approx(migrated.data.preferences.sensitivity, fixture.preferences.sensitivity) and migrated.data.onboarding.status == fixture.onboarding.status, "quality migration keeps legacy shadow/camera/tutorial choices: " + fixture_name)
		fixture.preferences = {"shadows": false, "sensitivity": 1.4, "visual_quality": "broken"}
		var recovered: Dictionary = store.decode(JSON.stringify(fixture))
		check(recovered.ok and recovered.data.preferences.visual_quality == "economy" and recovered.data.preferences.shadows == false and recovered.data.positions == fixture.positions and recovered.data.visited == fixture.visited, "malformed optional quality cannot reject/reset valid legacy core: " + fixture_name)
	var prior_exists := FileAccess.file_exists(store.SAVE_PATH)
	var prior_bytes := FileAccess.get_file_as_bytes(store.SAVE_PATH) if prior_exists else PackedByteArray()
	var progress: Dictionary = store.default_data()
	progress.region_id = "mountain_pass_demo"
	progress.road_demo = {"bike_s": 550.0, "lateral": 8.0, "riding": false, "checkpoint": 550.0}
	progress.visited = ["mountain_pass_demo:viewpoint_1"]
	progress.preferences = {"shadows": false, "sensitivity": 1.4}
	var old_road: Dictionary = store.decode(JSON.stringify(progress))
	check(old_road.ok and old_road.data.preferences.visual_quality == "economy" and old_road.data.road_demo == progress.road_demo and old_road.data.visited == progress.visited, "legacy 0.4 road checkpoint/mode/stamp survive missing quality field")
	progress.preferences.visual_quality = {"bad": "value"}
	old_road = store.decode(JSON.stringify(progress))
	check(old_road.ok and old_road.data.preferences.visual_quality == "economy" and old_road.data.road_demo == progress.road_demo and old_road.data.visited == progress.visited, "malformed new quality field cannot reset existing 0.4 road progress")
	progress.preferences = {"shadows": false, "sensitivity": 0.6, "visual_quality": "detail"}
	check(store.save_data(progress), "detail quality preference writes actual local save")
	var restored: Dictionary = store.load_data()
	check(restored.ok and restored.data.preferences.visual_quality == "detail" and restored.data.preferences.shadows == false and is_equal_approx(restored.data.preferences.sensitivity, 0.6), "reload restores detail quality independently of shadows and camera sensitivity")
	progress.preferences.visual_quality = "invalid"
	check(store.save_data(progress), "invalid optional quality still permits valid core save")
	var disk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(store.SAVE_PATH))
	check(disk.preferences.visual_quality == "economy" and disk.preferences.shadows == false, "saved JSON stores canonical safe quality rather than invalid raw value")
	if prior_exists:
		var restore_file := FileAccess.open(store.SAVE_PATH, FileAccess.WRITE)
		restore_file.store_buffer(prior_bytes)
		restore_file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(store.SAVE_PATH))
	print("RESULT quality/preferences: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
