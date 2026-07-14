extends "res://scripts/tests/test_scene_tree.gd"

const UiMotionScript := preload("res://scripts/ui/ui_motion.gd")


func _initialize() -> void:
	_expect(is_equal_approx(UiMotionScript.duration_for(0.4, false, 0.01), 0.4), "normal motion should preserve configured duration")
	_expect(is_equal_approx(UiMotionScript.duration_for(0.4, true, 0.01), 0.01), "reduced motion should shorten decorative transitions")
	_expect(is_equal_approx(UiMotionScript.duration_for(0.02, true, 0.05), 0.02), "reduced motion should not lengthen an already short duration")
	print("UI motion smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
