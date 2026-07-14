extends "res://scripts/tests/test_scene_tree.gd"

const ClearEndingStoryScript := preload("res://scripts/core/clear_ending_story.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")


func _initialize() -> void:
	var paths := ClearEndingStoryScript.cg_paths()
	var events := ClearEndingStoryScript.gallery_events()
	var steps := ClearEndingStoryScript.steps()
	_expect(paths.size() == 3, "clear ending should use three premium CGs")
	_expect(events.size() == paths.size(), "each clear ending CG should have a gallery event")
	_expect(steps.size() >= 28, "clear ending should have a substantial scenario")

	var scene_changes := 0
	for step in steps:
		var background_path := String(step.get(VnStoryKeysScript.KEY_BACKGROUND_PATH, ""))
		if background_path.is_empty():
			continue
		scene_changes += 1
		_expect(paths.has(background_path), "ending step should use a registered CG")
	_expect(scene_changes == 3, "clear ending should change CG exactly three times")

	for index in range(paths.size()):
		var path := String(paths[index])
		_expect(ResourceLoader.exists(path) or FileAccess.file_exists(path), "clear ending CG should exist: %s" % path)
		_expect(String(events[index].get(DayEventKeysScript.KEY_CG_PATH, "")) == path, "gallery event path should match ending CG")

	print("Clear ending story smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
