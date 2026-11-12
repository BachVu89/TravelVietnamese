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
	var objectives = load("res://scripts/route_objectives.gd")
	var visited: Array = []
	var goal: Dictionary = objectives.evaluate(visited, {"progress": 5.0, "riding": true, "can_exit": false})
	check(goal.phase == "ride_to_stop" and goal.target_station == 230.0 and goal.visited_count == 0 and not goal.complete, "fresh ride targets first stop without awarding progress")
	goal = objectives.evaluate(visited, {"progress": 230.0, "riding": true, "can_exit": false})
	check(goal.phase == "park" and not goal.detail.contains("Đã đỗ an toàn"), "near stop while moving/outside parking guard tells player to park first")
	goal = objectives.evaluate(visited, {"progress": 230.0, "riding": true, "can_exit": true})
	check(goal.phase == "park" and goal.detail.contains("Đã đỗ an toàn"), "safe stop guard enables dismount guidance")
	goal = objectives.evaluate(visited, {"progress": 230.0, "riding": false})
	check(goal.phase == "walk_to_poi" and goal.target_station == 230.0 and goal.visited_count == 0, "walking near first stop targets its POI without pretending it is stamped")
	check(visited.is_empty(), "evaluating nearby walking goal never mutates visited progress")
	goal = objectives.evaluate(visited, {"progress": 500.0, "riding": true})
	check(goal.phase == "missed_stop" and goal.target_station == 230.0 and not goal.complete, "passing an unvisited first stop cannot silently advance to second or finish")
	visited = ["mountain_pass_demo:viewpoint_2"]
	goal = objectives.evaluate(visited, {"progress": 550.0, "riding": true})
	check(goal.visited_count == 1 and goal.target_station == 230.0 and goal.phase == "missed_stop", "visiting second stop first still targets missing first stop")
	visited = ["mountain_pass_demo:viewpoint_1"]
	goal = objectives.evaluate(visited, {"progress": 230.0, "riding": false})
	check(goal.phase == "return_to_bike" and goal.target_station == 550.0 and goal.visited_count == 1, "first POI stamp while walking directs player back to bike for second stop")
	goal = objectives.evaluate(visited, {"progress": 240.0, "riding": true})
	check(goal.phase == "ride_to_stop" and goal.target_station == 550.0, "remount after first stamp targets second stop without repeating first")
	goal = objectives.evaluate(visited, {"progress": 550.0, "riding": true, "can_exit": false})
	check(goal.phase == "park" and goal.target_station == 550.0 and not goal.complete, "second stop requires parking guard independently")
	goal = objectives.evaluate(visited, {"progress": 550.0, "riding": false})
	check(goal.phase == "walk_to_poi" and goal.target_station == 550.0, "walking at second stop guides actual second POI interaction")
	visited = ["mountain_pass_demo:viewpoint_1", "mountain_pass_demo:viewpoint_2"]
	goal = objectives.evaluate(visited, {"progress": 550.0, "riding": false})
	check(goal.phase == "return_to_bike" and goal.visited_count == 2 and not goal.complete, "both stamps while walking still require continuing toward finish")
	goal = objectives.evaluate(visited, {"progress": 550.0, "riding": true})
	check(goal.phase == "ride_to_finish" and not goal.complete, "both stamps and remount unlock finish objective")
	goal = objectives.evaluate(visited, {"progress": objectives.FINISH_STATION - 0.1, "riding": true})
	check(not goal.complete, "finish does not complete before configured station threshold")
	goal = objectives.evaluate(visited, {"progress": objectives.FINISH_STATION, "riding": true})
	check(goal.complete and goal.phase == "complete" and goal.text.contains("tuyến mẫu"), "two stamps plus finish station completes only this illustrative route")
	for incomplete in [[], ["mountain_pass_demo:viewpoint_1"], ["mountain_pass_demo:viewpoint_2"], ["hanoi:lake"]]:
		check(not objectives.evaluate(incomplete, {"progress": 750.0, "riding": true}).complete, "reaching end alone cannot replace required two road stamps: " + str(incomplete))
	goal = objectives.evaluate(visited, {"progress": 5.0, "riding": true})
	check(goal.phase == "ride_to_finish" and goal.visited_count == 2 and not goal.complete, "replay at start keeps both visited stamps and does not invent unvisited stops")
	print("RESULT route/objectives: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
