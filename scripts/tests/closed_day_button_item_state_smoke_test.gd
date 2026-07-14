extends "res://scripts/tests/test_scene_tree.gd"

const ClosedDayButtonItemStateConfigScript := preload("res://scripts/ui/closed_day_button_item_state_config.gd")
const ClosedDayButtonItemStateScript := preload("res://scripts/ui/closed_day_button_item_state.gd")


func _initialize() -> void:
	_verify_category_state()
	_verify_choice_state()
	_verify_selected_id_lookup()

	print("Closed-day button item state smoke test passed.")
	finish_test()


func _verify_category_state() -> void:
	var category := ClosedDayButtonItemStateScript.category({
		ClosedDayButtonItemStateConfigScript.ROW_ID: "stay_home",
		ClosedDayButtonItemStateConfigScript.ROW_NAME: "집에 있기"
	})
	_expect(String(category.get(ClosedDayButtonItemStateConfigScript.KEY_ID, "")) == "stay_home", "category state should expose id")
	_expect(String(category.get(ClosedDayButtonItemStateConfigScript.KEY_LABEL, "")) == "집에 있기", "category state should expose Korean label")

	var fallback := ClosedDayButtonItemStateScript.category({
		ClosedDayButtonItemStateConfigScript.ROW_ID: "go_out"
	})
	_expect(String(fallback.get(ClosedDayButtonItemStateConfigScript.KEY_LABEL, "")) == "go_out", "category state should fall back to id label")

	var invalid := ClosedDayButtonItemStateScript.category("broken")
	_expect(String(invalid.get(ClosedDayButtonItemStateConfigScript.KEY_ID, "bad")) == ClosedDayButtonItemStateConfigScript.EMPTY_ID, "invalid category rows should return empty id")


func _verify_choice_state() -> void:
	var choice := ClosedDayButtonItemStateScript.choice({
		ClosedDayButtonItemStateConfigScript.ROW_ID: "part_time",
		ClosedDayButtonItemStateConfigScript.ROW_NAME: "알바하기",
		ClosedDayButtonItemStateConfigScript.ROW_SUMMARY: "시드머니 보충"
	})
	_expect(String(choice.get(ClosedDayButtonItemStateConfigScript.KEY_ID, "")) == "part_time", "choice state should expose id")
	_expect(String(choice.get(ClosedDayButtonItemStateConfigScript.KEY_LABEL, "")).contains("알바하기"), "choice label should include action name")
	_expect(String(choice.get(ClosedDayButtonItemStateConfigScript.KEY_LABEL, "")).contains("시드머니 보충"), "choice label should include summary")
	_expect(String(choice.get(ClosedDayButtonItemStateConfigScript.KEY_TOOLTIP, "")) == "시드머니 보충", "choice tooltip should use summary")

	var invalid := ClosedDayButtonItemStateScript.choice(777)
	_expect(String(invalid.get(ClosedDayButtonItemStateConfigScript.KEY_LABEL, "")) == ClosedDayButtonItemStateConfigScript.CHOICE_LABEL_SEPARATOR, "invalid choice rows should keep stable multiline label")


func _verify_selected_id_lookup() -> void:
	var items := [
		{ClosedDayButtonItemStateConfigScript.ROW_ID: "stay_home", ClosedDayButtonItemStateConfigScript.ROW_NAME: "집에 있기"},
		"broken",
		{ClosedDayButtonItemStateConfigScript.ROW_ID: "go_out", ClosedDayButtonItemStateConfigScript.ROW_NAME: "외출하기"}
	]
	_expect(ClosedDayButtonItemStateScript.has_item_id(items, "go_out"), "selected id lookup should find valid row")
	_expect(not ClosedDayButtonItemStateScript.has_item_id(items, "missing"), "selected id lookup should reject missing id")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
