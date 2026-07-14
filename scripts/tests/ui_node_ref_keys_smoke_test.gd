extends "res://scripts/tests/test_scene_tree.gd"

const UiNodeRefKeysScript := preload("res://scripts/ui/ui_node_ref_keys.gd")


func _initialize() -> void:
	_expect(UiNodeRefKeysScript.KEY_BACKGROUND_RECT == "background_rect", "background node-ref key should stay stable")

	print("UI node ref keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
