extends "res://scripts/tests/test_scene_tree.gd"

const ClosedDayButtonListConfigScript := preload("res://scripts/ui/closed_day_button_list_config.gd")


func _initialize() -> void:
	_expect(ClosedDayButtonListConfigScript.CATEGORY_BUTTON_SIZE == Vector2(296, 54), "category button size should stay stable")
	_expect(ClosedDayButtonListConfigScript.CATEGORY_BUTTON_FONT_SIZE == 22, "category button font size should stay stable")
	_expect(ClosedDayButtonListConfigScript.CHOICE_BUTTON_SIZE == Vector2(296, 92), "choice button size should stay stable")
	_expect(ClosedDayButtonListConfigScript.CHOICE_BUTTON_FONT_SIZE == 19, "choice button font size should stay stable")
	_expect(ClosedDayButtonListConfigScript.SELECTED_NORMAL_COLOR == Color("#42656a"), "selected normal color should stay stable")
	_expect(ClosedDayButtonListConfigScript.SELECTED_TEXT_COLOR == Color("#ffffff"), "selected text color should stay stable")
	_expect(ClosedDayButtonListConfigScript.NORMAL_COLOR == Color("#fff8eddd"), "normal color should stay stable")
	_expect(ClosedDayButtonListConfigScript.TEXT_COLOR == Color("#46362f"), "normal text color should stay stable")

	print("Closed-day button list config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
