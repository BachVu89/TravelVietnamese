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
	var tutorial_script = load("res://scripts/onboarding.gd")
	var navigation = load("res://scripts/navigation.gd")
	var preferences = load("res://scripts/preferences.gd")
	var store = load("res://scripts/save_store.gd")
	check(tutorial_script != null and navigation != null and preferences != null and store != null, "batch 0.3 rule scripts load")
	if tutorial_script == null or navigation == null or preferences == null or store == null:
		quit(1)
		return
	var tutorial = tutorial_script.new()
	tutorial.init_from(tutorial_script.defaults())
	check(tutorial.data.step == 0 and tutorial.data.status == "active", "new tutorial begins with movement step")
	tutorial.record_look(1.0)
	tutorial.record_interaction()
	check(tutorial.data.step == 0, "early camera/POI actions cannot skip movement step")
	tutorial.record_move(-10.0)
	check(tutorial.data.step == 0 and tutorial.data.move_distance >= 0.0, "negative movement distance cannot complete tutorial")
	tutorial.record_move(0.75)
	tutorial.record_move(1.24)
	check(tutorial.data.step == 0, "movement below 2 m does not advance")
	tutorial.record_move(0.02)
	check(tutorial.data.step == 1 and tutorial.data.status == "active", "actual movement reaching 2 m advances to look step")
	tutorial.record_interaction()
	tutorial.record_move(100.0)
	check(tutorial.data.step == 1, "later movement and early interaction cannot skip look step")
	tutorial.record_look(0.1)
	tutorial.record_look(0.14)
	check(tutorial.data.step == 1, "look accumulation below 0.25 rad does not advance")
	tutorial.record_look(0.02)
	check(tutorial.data.step == 2, "look input accumulation reaching threshold advances to interaction")
	tutorial.record_interaction()
	check(tutorial.data.step == 3 and tutorial.data.status == "completed", "successful final interaction completes tutorial")
	tutorial.replay()
	check(tutorial.data.step == 0 and tutorial.data.status == "active" and is_zero_approx(tutorial.data.move_distance) and is_zero_approx(tutorial.data.look_radians), "replay resets only tutorial counters/status")
	tutorial.skip()
	check(tutorial.data.status == "skipped", "skip remains distinct from completed")
	tutorial.record_move(100.0)
	tutorial.record_look(100.0)
	tutorial.record_interaction()
	check(tutorial.data.status == "skipped", "skipped tutorial does not later become completed through gameplay events")
	var resumed = tutorial_script.new()
	resumed.init_from({"step": 1, "status": "active", "move_distance": 2.5, "look_radians": 0.1})
	resumed.record_look(0.16)
	check(resumed.data.step == 2, "saved partial look step resumes accumulated progress")

	var pois: Array = [
		{"id": "far", "title": "Far", "position": Vector3(0, 0, -20)},
		{"id": "near", "title": "Near", "position": Vector3(0, 20, -3)},
		{"id": "right", "title": "Right", "position": Vector3(10, 0, 0)}]
	var next: Dictionary = navigation.next_target(pois, [], Vector3.ZERO, 0.0)
	check(next.get("id") == "near" and is_equal_approx(float(next.get("distance", -1)), 3.0), "navigation chooses closest unvisited using planar distance, not height")
	check(next.get("bearing") == "trước", "forward target is relative to camera yaw zero")
	next = navigation.next_target(pois, ["near"], Vector3.ZERO, 0.0)
	check(next.get("id") == "right" and next.get("bearing") == "phải", "visited target excluded and right bearing computed")
	next = navigation.next_target(pois, ["near", "right"], Vector3.ZERO, PI)
	check(next.get("id") == "far" and next.get("bearing") == "sau", "rotating camera updates relative bearing")
	var left: Array = [{"id": "left", "title": "Left", "position": Vector3(-5, 0, 0)}]
	check(navigation.next_target(left, [], Vector3.ZERO, 0.0).get("bearing") == "trái", "left target bearing is correct")
	check(navigation.next_target(left, [], Vector3.ZERO, PI / 2).get("bearing") == "trước", "camera yaw changes which world axis is forward")
	check(navigation.next_target(pois, ["near", "right", "far"], Vector3.ZERO, 0.0).is_empty(), "all visited produces no next destination")
	check(navigation.next_target([], [], Vector3.ZERO, 0.0).is_empty(), "empty scene POI list is safe")
	check(navigation.next_target(pois, [], Vector3(0, 0, -19), 0.0).get("id") == "far", "moving player changes nearest target")

	var defaults: Dictionary = preferences.defaults()
	check(defaults.shadows == true and is_equal_approx(defaults.sensitivity, 1.0), "preferences default to shadows on and normal sensitivity")
	for sensitivity in [0.6, 1.0, 1.4]:
		var result: Dictionary = preferences.normalize({"shadows": false, "sensitivity": sensitivity})
		check(result.shadows == false and is_equal_approx(result.sensitivity, sensitivity), "supported sensitivity preset survives normalization: " + str(sensitivity))
	for invalid in [null, "invalid", [], {"shadows": "false", "sensitivity": "fast"}, {"shadows": 0, "sensitivity": -1.0}]:
		check(preferences.normalize(invalid) == defaults, "invalid optional preferences normalize safely: " + str(invalid))
	var legacy_text := FileAccess.get_file_as_string("res://tests/fixtures/progress-v0.2.json")
	var legacy: Dictionary = JSON.parse_string(legacy_text)
	var migrated: Dictionary = store.decode(legacy_text)
	check(migrated.ok and migrated.data.region_id == legacy.region_id and migrated.data.positions == legacy.positions and migrated.data.visited == legacy.visited, "real 0.2 fixture migrates without losing current region, positions, camera or visited")
	check(migrated.data.get("preferences") == defaults and migrated.data.get("onboarding", {}).get("step") == 0 and migrated.data.get("onboarding", {}).get("status") == "active", "legacy save gains default preferences and first-run tutorial")
	var damaged_optional: Dictionary = legacy.duplicate(true)
	damaged_optional.preferences = {"shadows": "bad", "sensitivity": "bad"}
	damaged_optional.onboarding = {"step": -50, "status": "nonsense"}
	var normalized: Dictionary = store.decode(JSON.stringify(damaged_optional))
	check(normalized.ok and normalized.data.positions == legacy.positions and normalized.data.visited == legacy.visited, "malformed optional fields do not reject or reset valid old progress")
	check(normalized.data.preferences == defaults and normalized.data.onboarding.status == "active" and normalized.data.onboarding.step == 0, "malformed optional fields get safe defaults")
	print("RESULT batch03/rules: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
