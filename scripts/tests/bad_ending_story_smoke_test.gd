extends "res://scripts/tests/test_scene_tree.gd"

const BadEndingStoryScript := preload("res://scripts/core/bad_ending_story.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameEndingScript := preload("res://scripts/core/game_ending.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")


func _initialize() -> void:
	var routes := [
		GameEndingScript.BAD_ENDING_01_ROUTE,
		GameEndingScript.BAD_ENDING_02_ROUTE,
		GameEndingScript.BAD_ENDING_03_ROUTE,
		GameEndingScript.BAD_ENDING_04_ROUTE,
		GameEndingScript.BAD_ENDING_05_ROUTE
	]
	var paths: Array[String] = []
	var summaries: Array[String] = []
	for route in routes:
		_expect(BadEndingStoryScript.has_route(route), "bad ending route should be supported: %s" % route)
		var path := BadEndingStoryScript.cg_path(route)
		_expect(not path.is_empty(), "bad ending should have a CG path: %s" % route)
		_expect(ResourceLoader.exists(path) or FileAccess.file_exists(path), "bad ending CG should exist: %s" % path)
		var texture := load(path) as Texture2D
		_expect(texture != null, "bad ending CG should load as a texture: %s" % path)
		if texture != null:
			_expect(texture.get_width() == 720, "bad ending CG should be 720px wide: %s" % path)
			_expect(texture.get_height() == 1280, "bad ending CG should be 1280px tall: %s" % path)
		paths.append(path)
		var steps := BadEndingStoryScript.steps(route)
		_expect(steps.size() >= 10, "bad ending should have a substantial epilogue: %s" % route)
		_expect(String(steps[0].get(VnStoryKeysScript.KEY_BACKGROUND_PATH, "")) == path, "first step should show route CG: %s" % route)
		for step in steps:
			_expect(not String(step.get(VnStoryKeysScript.KEY_TEXT, "")).is_empty(), "bad ending lines should not be empty: %s" % route)
		var gallery_event := BadEndingStoryScript.gallery_event(route)
		_expect(String(gallery_event.get(DayEventKeysScript.KEY_ID, "")) == route, "gallery event id should match route")
		_expect(String(gallery_event.get(DayEventKeysScript.KEY_CG_PATH, "")) == path, "gallery event should use route CG")
		var summary := BadEndingStoryScript.summary_body(route, "123,456,789원")
		_expect(summary.contains("123,456,789원"), "route summary should include final net worth: %s" % route)
		summaries.append(summary)

	_expect(_unique_count(paths) == routes.size(), "all bad ending routes should have distinct CGs")
	_expect(_unique_count(summaries) == routes.size(), "all bad ending routes should have distinct summaries")
	_expect(BadEndingStoryScript.gallery_events().size() == routes.size(), "gallery catalog should include all bad endings")
	print("Bad ending story smoke test passed.")
	finish_test()


func _unique_count(values: Array[String]) -> int:
	var unique := {}
	for value in values:
		unique[value] = true
	return unique.size()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
