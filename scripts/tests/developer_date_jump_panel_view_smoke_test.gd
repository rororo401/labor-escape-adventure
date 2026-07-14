extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperDateJumpPanelConfigScript := preload("res://scripts/dev/developer_date_jump_panel_config.gd")
const DeveloperDateJumpPanelScript := preload("res://scripts/dev/developer_date_jump_panel.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()
var _standing_requested := false
var _result_popup_requested := false
var _jumped_dates: Array[String] = []


func _initialize() -> void:
	var panel := DeveloperDateJumpPanelScript.new()
	root.add_child(panel)
	panel.build("2016-07-03")
	panel.standing_calibrator_requested.connect(func() -> void:
		_standing_requested = true
	)
	panel.result_popup_calibrator_requested.connect(func() -> void:
		_result_popup_requested = true
	)
	panel.date_jump_requested.connect(func(date: String) -> void:
		_jumped_dates.append(date)
	)
	await process_frame

	_expect(panel.name == DeveloperDateJumpPanelConfigScript.PANEL_NAME, "panel should use configured name")
	_expect(panel.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == DeveloperDateJumpPanelConfigScript.PANEL_SEPARATION, "panel should use configured separation")

	var standing_button := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.STANDING_BUTTON_NAME) as Button
	var result_popup_button := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.RESULT_POPUP_BUTTON_NAME) as Button
	var friday_button := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_BUTTON_NAME) as Button
	var saturday_button := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_BUTTON_NAME) as Button
	var baseline := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.BASELINE_LABEL_NAME) as Label
	var date_row := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.DATE_ROW_NAME) as HBoxContainer
	var input := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.DATE_INPUT_NAME) as LineEdit
	var jump_button := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.DATE_BUTTON_NAME) as Button
	_expect(standing_button != null and standing_button.text == DeveloperDateJumpPanelConfigScript.STANDING_BUTTON_TEXT, "standing button should use configured text")
	_expect(result_popup_button != null and result_popup_button.text == DeveloperDateJumpPanelConfigScript.RESULT_POPUP_BUTTON_TEXT, "result-popup button should use configured text")
	_expect(friday_button != null and friday_button.text == DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_BUTTON_TEXT, "Friday button should use configured text")
	_expect(saturday_button != null and saturday_button.text == DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_BUTTON_TEXT, "Saturday button should use configured text")
	_expect(baseline != null and baseline.text == DeveloperDateJumpPanelConfigScript.BASELINE_TEXT, "baseline should use configured copy")
	_expect(baseline.custom_minimum_size == DeveloperDateJumpPanelConfigScript.BASELINE_LABEL_SIZE, "baseline should use configured size")
	_expect(date_row != null and date_row.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == DeveloperDateJumpPanelConfigScript.DATE_ROW_SEPARATION, "date row should use configured separation")
	_expect(input != null and input.text == "2016-07-03", "input should use provided date")
	_expect(input.placeholder_text == DeveloperDateJumpPanelConfigScript.DATE_PLACEHOLDER, "input should use configured placeholder")
	_expect(input.custom_minimum_size == DeveloperDateJumpPanelConfigScript.DATE_INPUT_SIZE, "input should use configured size")
	_expect(jump_button != null and jump_button.text == DeveloperDateJumpPanelConfigScript.DATE_BUTTON_TEXT, "jump button should use configured text")

	standing_button.pressed.emit()
	result_popup_button.pressed.emit()
	friday_button.pressed.emit()
	saturday_button.pressed.emit()
	input.text = "2016-07-04"
	jump_button.pressed.emit()
	_expect(_standing_requested, "standing button should emit standing request")
	_expect(_result_popup_requested, "result-popup button should emit result-popup request")
	_expect(_jumped_dates == [
		DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_DATE,
		DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_DATE,
		"2016-07-04"
	], "jump buttons should emit configured and input dates")

	print("Developer date jump panel view smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
