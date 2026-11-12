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
	var road = load("res://scripts/road_save.gd")
	var store = load("res://scripts/save_store.gd")
	check(road != null and store != null, "road and legacy save validators load")
	if road == null or store == null:
		quit(1)
		return
	var defaults: Dictionary = road.default_state()
	check(defaults.riding and defaults.bike_s == 5.0 and defaults.checkpoint == 0.0, "new road journey starts safely at beginning with stopped riding mode")
	for checkpoint in [230.0, 550.0]:
		var safe: Dictionary = road.default_state(checkpoint)
		check(safe.riding and safe.bike_s == checkpoint and safe.lateral == 8.0, "checkpoint defaults restore into safe layby: " + str(checkpoint))
	for invalid in [null, [], "bad", {}, {"bike_s": -1}, {"bike_s": 751.0, "lateral": 1.7, "riding": true, "checkpoint": 0.0}, {"bike_s": 10.0, "lateral": 13.0, "riding": true, "checkpoint": 0.0}, {"bike_s": "bad", "lateral": 1.7, "riding": true, "checkpoint": 0.0}, {"bike_s": 10.0, "lateral": 1.7, "riding": "yes", "checkpoint": 0.0}]:
		check(road.normalize(invalid) == defaults, "invalid optional road data resets only to safe defaults: " + str(invalid))
	check(road.normalize({"bike_s": -99, "lateral": 1, "riding": true, "checkpoint": 550}).checkpoint == 550, "valid checkpoint survives malformed vehicle position")
	var valid := {"bike_s": 550.0, "lateral": 8.0, "riding": false, "checkpoint": 550.0}
	check(road.normalize(valid) == valid, "valid road state far beyond legacy bounds retains all fields")
	for fixture_name in ["progress-v0.2.json", "progress-v0.3.json"]:
		var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/" + fixture_name))
		var decoded: Dictionary = store.decode(JSON.stringify(fixture))
		check(decoded.ok and decoded.data.region_id == fixture.region_id and decoded.data.positions == fixture.positions and decoded.data.visited == fixture.visited, "missing road field preserves old region/positions/stamps: " + fixture_name)
		check(decoded.data.road_demo == defaults, "missing road field gains safe road defaults: " + fixture_name)
		if fixture.has("onboarding"):
			var tutorial_preserved: bool = decoded.data.onboarding.status == fixture.onboarding.status and decoded.data.onboarding.step == int(fixture.onboarding.step) and is_equal_approx(decoded.data.onboarding.move_distance, fixture.onboarding.move_distance) and is_equal_approx(decoded.data.onboarding.look_radians, fixture.onboarding.look_radians)
			var preferences_preserved: bool = decoded.data.preferences.shadows == fixture.preferences.shadows and is_equal_approx(decoded.data.preferences.sensitivity, fixture.preferences.sensitivity)
			check(tutorial_preserved and preferences_preserved, "road migration preserves old tutorial and settings: " + fixture_name)
		fixture.road_demo = {"bike_s": "damaged", "checkpoint": 230}
		decoded = store.decode(JSON.stringify(fixture))
		check(decoded.ok and decoded.data.positions == fixture.positions and decoded.data.visited == fixture.visited and decoded.data.road_demo.checkpoint == 230, "malformed road field cannot reset valid core save: " + fixture_name)
		fixture.road_demo = valid
		fixture.region_id = road.REGION_ID
		fixture.visited.append(road.REGION_ID + ":viewpoint_1")
		decoded = store.decode(JSON.stringify(fixture))
		check(decoded.ok and decoded.data.road_demo == valid and decoded.data.visited.has(road.REGION_ID + ":viewpoint_1"), "road state and viewpoint stamp round-trip through core validator: " + fixture_name)
		var invalid_core: Dictionary = fixture.duplicate(true)
		invalid_core.positions.hanoi.x = 600.0
		check(not store.decode(JSON.stringify(invalid_core)).ok, "adding road support does not loosen legacy position bounds: " + fixture_name)
	var prior_exists := FileAccess.file_exists(store.SAVE_PATH)
	var prior_bytes := FileAccess.get_file_as_bytes(store.SAVE_PATH) if prior_exists else PackedByteArray()
	var progress: Dictionary = store.default_data()
	progress.region_id = road.REGION_ID
	progress.road_demo = valid
	progress.visited = [road.REGION_ID + ":viewpoint_1", road.REGION_ID + ":viewpoint_2"]
	check(store.save_data(progress), "road save writes actual local file")
	var reloaded: Dictionary = store.load_data()
	check(reloaded.ok and reloaded.data.road_demo == valid and reloaded.data.visited == progress.visited, "road local file reload preserves checkpoint, walking flag and both viewpoint stamps")
	if prior_exists:
		var restore_file := FileAccess.open(store.SAVE_PATH, FileAccess.WRITE)
		restore_file.store_buffer(prior_bytes)
		restore_file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(store.SAVE_PATH))
	print("RESULT pass/save: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
