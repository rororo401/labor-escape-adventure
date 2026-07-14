extends "res://scripts/tests/test_scene_tree.gd"

const ClosedDayButtonListConfigScript := preload("res://scripts/ui/closed_day_button_list_config.gd")
const ClosedDayButtonListScript := preload("res://scripts/ui/closed_day_button_list.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")

var _selected_id := ""


func _initialize() -> void:
	_verify_category_rendering()
	_verify_choice_rendering()

	print("Closed-day button list smoke test passed.")
	finish_test()


func _verify_category_rendering() -> void:
	var list = ClosedDayButtonListScript.new()
	var row := HBoxContainer.new()
	root.add_child(row)

	var selected_exists := list.render_categories(
		row,
		[
			{"id": "stay_home", "name_ko": "집에 있기"},
			{"id": "go_out", "name_ko": "외출하기"}
		],
		"go_out",
		false,
		_on_item_selected
	)

	_expect(selected_exists, "category renderer should report existing selection")
	_expect(row.get_child_count() == 2, "category renderer should create category buttons")
	_expect(row.get_child(1) is Button, "category renderer should create button nodes")
	var normal_button := row.get_child(0) as Button
	var selected_button := row.get_child(1) as Button
	_expect(not selected_button.disabled, "category renderer should apply enabled state")
	_expect(selected_button.custom_minimum_size == ClosedDayButtonListConfigScript.CATEGORY_BUTTON_SIZE, "category renderer should use configured button size")
	_expect(selected_button.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == ClosedDayButtonListConfigScript.CATEGORY_BUTTON_FONT_SIZE, "category renderer should use configured font size")
	_expect(selected_button.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == ClosedDayButtonListConfigScript.SELECTED_TEXT_COLOR, "selected category should use configured selected text color")
	_expect(normal_button.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == ClosedDayButtonListConfigScript.TEXT_COLOR, "unselected category should use configured text color")

	normal_button.emit_signal("pressed")
	_expect(_selected_id == "stay_home", "category button should invoke callback with id")
	list.set_disabled(true)
	_expect((row.get_child(0) as Button).disabled, "category renderer should update disabled state")

	row.queue_free()


func _verify_choice_rendering() -> void:
	var list = ClosedDayButtonListScript.new()
	var grid := GridContainer.new()
	root.add_child(grid)

	list.render_choices(
		grid,
		[
			{"id": "part_time", "name_ko": "알바하기", "summary_ko": "시드머니 보충"},
			{"id": "river_walk", "name_ko": "한강 산책", "summary_ko": "기분 전환"}
		],
		"part_time",
		false,
		_on_item_selected
	)

	_expect(grid.get_child_count() == 2, "choice renderer should create choice buttons")
	var first_button := grid.get_child(0) as Button
	_expect(first_button.text.contains("알바하기"), "choice button should include action name")
	_expect(first_button.tooltip_text == "시드머니 보충", "choice button should expose summary as tooltip")
	_expect(first_button.custom_minimum_size == ClosedDayButtonListConfigScript.CHOICE_BUTTON_SIZE, "choice renderer should use configured button size")
	_expect(first_button.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == ClosedDayButtonListConfigScript.CHOICE_BUTTON_FONT_SIZE, "choice renderer should use configured font size")
	_expect(first_button.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == ClosedDayButtonListConfigScript.SELECTED_TEXT_COLOR, "selected choice should use configured selected text color")

	(grid.get_child(1) as Button).emit_signal("pressed")
	_expect(_selected_id == "river_walk", "choice button should invoke callback with id")

	list.render_choices(grid, [], "", true, _on_item_selected)
	_expect(grid.get_child_count() == 0, "choice renderer should clear old choices")

	grid.queue_free()


func _on_item_selected(item_id: String) -> void:
	_selected_id = item_id


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
