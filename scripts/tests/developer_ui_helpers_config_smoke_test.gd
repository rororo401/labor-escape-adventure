extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperUiHelpersConfigScript := preload("res://scripts/dev/developer_ui_helpers_config.gd")


func _initialize() -> void:
	_expect(DeveloperUiHelpersConfigScript.MENU_BUTTON_SIZE == Vector2(572, 58), "menu button size should stay stable")
	_expect(DeveloperUiHelpersConfigScript.MENU_BUTTON_FONT_SIZE == 23, "menu button font size should stay stable")
	_expect(DeveloperUiHelpersConfigScript.COMPACT_BUTTON_SIZE == Vector2(202, 54), "compact button size should stay stable")
	_expect(DeveloperUiHelpersConfigScript.TOOL_BUTTON_DEFAULT_SIZE == Vector2(58, 42), "tool button default size should stay stable")
	_expect(DeveloperUiHelpersConfigScript.BUTTON_TEXT_COLOR == Color("#fffdf7"), "button text color should stay stable")
	_expect(DeveloperUiHelpersConfigScript.BUTTON_NORMAL_COLOR == Color("#42656a"), "button normal color should stay stable")
	_expect(DeveloperUiHelpersConfigScript.LINE_EDIT_FONT_SIZE == 22, "line edit font size should stay stable")
	_expect(DeveloperUiHelpersConfigScript.LINE_EDIT_TEXT_COLOR == Color("#33231e"), "line edit text color should stay stable")
	_expect(DeveloperUiHelpersConfigScript.PANEL_RADIUS == 8, "panel radius should stay stable")
	_expect(DeveloperUiHelpersConfigScript.BUTTON_CONTENT_MARGIN_X == 18, "button content margin should stay stable")

	print("Developer UI helpers config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
