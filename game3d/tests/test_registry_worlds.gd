extends SceneTree

const EXPECTED_PROVINCE_CODES := ["01", "04", "08", "11", "12", "14", "15", "19", "20", "22", "24", "25", "31", "33", "37", "38", "40", "42", "44", "46", "48", "51", "52", "56", "66", "68", "75", "79", "80", "82", "86", "91", "92", "96"]
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
	var entries = JSON.parse_string(FileAccess.get_file_as_string("res://data/geography/regions.json"))
	check(entries is Array and entries.size() == 47, "registry contains selected 47 destinations")
	if not entries is Array:
		quit(1)
		return
	var ids := {}
	var province_codes: Array[String] = []
	var province_names := {}
	var islands := 0
	for entry in entries:
		var valid: bool = entry is Dictionary
		for key in ["id", "name", "type", "region", "scene_style", "detail_level", "source_id", "coverage_note"]:
			valid = valid and entry.get(key) is String and not str(entry.get(key)).is_empty()
		valid = valid and entry.get("type") in ["province", "island"] and entry.has("lat") and entry.has("lon")
		check(valid, "required metadata: " + str(entry.get("id", "invalid")))
		check(not ids.has(entry.id), "unique destination ID: " + str(entry.id))
		ids[entry.id] = true
		if entry.type == "province":
			province_codes.append(entry.code)
			province_names[entry.name] = true
		else:
			islands += 1
	province_codes.sort()
	check(province_codes == EXPECTED_PROVINCE_CODES and province_names.size() == 34, "all 34 distinct province codes and names are present")
	check(islands == 13, "selected dataset has 13 named island areas, without completeness claim")
	for entry in entries:
		if entry.type == "island":
			check(ids.has(entry.parent_province_id), "island parent exists: " + entry.id)
	var sources = JSON.parse_string(FileAccess.get_file_as_string("res://data/geography/sources.json"))
	check(sources.coverage.all_vietnam_islands_verified == false, "coverage explicitly does not certify all Vietnamese islands")
	check(sources.coverage.coordinates_included == false and sources.coverage.boundary_geometry_included == false, "coverage distinguishes illustrative geometry from surveyed geography")
	var world_script = load("res://scripts/world.gd")
	check(world_script != null, "world generator script loads")
	if world_script == null:
		quit(1)
		return
	for entry in entries:
		var world = world_script.new()
		root.add_child(world)
		world.build(entry)
		for i in 30:
			await physics_frame
		var label: String = entry.id
		check(world.region.id == entry.id and world.player is CharacterBody3D, "enter playable 3D scene: " + label)
		check(world.get_node_or_null("Terrain") is MeshInstance3D and world.get_node("Terrain").mesh != null, "scene has generated terrain mesh: " + label)
		check(world.get_node_or_null("TerrainCollision") is StaticBody3D, "scene has solid terrain physics: " + label)
		check(world.player.is_on_floor() and world.player.position.is_finite(), "spawn settles safely on terrain: " + label)
		check(world.is_island == (entry.type == "island"), "correct province/island scene type: " + label)
		check(world.pois.size() >= 3, "scene exposes at least three visitable POIs: " + label)
		var poi_ids := {}
		var all_reachable := true
		for poi in world.pois:
			all_reachable = all_reachable and not poi_ids.has(poi.id) and poi.position.is_finite()
			poi_ids[poi.id] = true
			world.player.position = poi.position + Vector3(0, 0.1, 0)
			var nearest: Dictionary = world.nearest_poi()
			all_reachable = all_reachable and nearest.get("id", "") == poi.id
		check(all_reachable, "POIs have unique IDs and work when player is within range: " + label)
		world.player.position = Vector3(36, 2, 36)
		check(world.nearest_poi().is_empty(), "distant player cannot interact with a POI: " + label)
		if world.is_island:
			world.player.position = Vector3(40, 2, 0)
			world._physics_process(1.0 / 60.0)
			check(Vector2(world.player.position.x, world.player.position.z).length() <= 28.01, "island boundary keeps player in walkable area: " + label)
		world.queue_free()
		await process_frame
	print("RESULT registry/worlds: %d checks, %d failures; 34 provinces and 13 selected island areas instantiated" % [checks, failures])
	quit(1 if failures else 0)
