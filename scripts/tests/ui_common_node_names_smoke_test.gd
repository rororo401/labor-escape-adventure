extends "res://scripts/tests/test_scene_tree.gd"

const UiCommonNodeNamesScript := preload("res://scripts/ui/ui_common_node_names.gd")


func _initialize() -> void:
	_expect(UiCommonNodeNamesScript.DATE_LABEL_NAME == "DateLabel", "date label node name should stay stable")

	print("UI common node names smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
