extends "res://scripts/tests/test_scene_tree.gd"

const ClosedDayPanelConfigScript := preload("res://scripts/ui/closed_day_panel_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")


func _initialize() -> void:
	_expect(ClosedDayPanelConfigScript.PANEL_NAME == "ClosedDayPanel", "panel name should stay stable")
	_expect(ClosedDayPanelConfigScript.PANEL_POSITION == Vector2(30, 226), "panel position should preserve current layout")
	_expect(ClosedDayPanelConfigScript.PANEL_SIZE == Vector2(660, 520), "panel size should preserve current layout")
	_expect(int(ClosedDayPanelConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)) == 28, "left margin should preserve current layout")
	_expect(ClosedDayPanelConfigScript.LAYOUT_SEPARATION == 18, "layout separation should preserve current layout")
	_expect(ClosedDayPanelConfigScript.ROW_SEPARATION == 12, "row separation should preserve current layout")
	_expect(ClosedDayPanelConfigScript.GRID_COLUMNS == 2, "choice grid should stay two-column")
	_expect(ClosedDayPanelConfigScript.DEFAULT_TITLE == "오늘은 장이 쉬는 날", "default title should be centralized")
	_expect(ClosedDayPanelConfigScript.FLOW_BUTTON_NAME == "ClosedDayFlowButton", "flow button name should be centralized")
	_expect(ClosedDayPanelConfigScript.BODY_LABEL_SIZE == Vector2(604, 128), "body label size should preserve current layout")
	_expect(ClosedDayPanelConfigScript.FLOW_BUTTON_SIZE == Vector2(604, 58), "flow button size should preserve current layout")
	_expect(ClosedDayPanelConfigScript.MESSAGE_LABEL_SIZE == Vector2(604, 96), "message label size should preserve current layout")
	_expect(ClosedDayPanelConfigScript.TITLE_FONT_SIZE == 30, "title font size should stay stable")
	_expect(ClosedDayPanelConfigScript.BODY_FONT_SIZE == 24, "body font size should stay stable")
	_expect(ClosedDayPanelConfigScript.BODY_COLOR == Color("#46362f"), "body label color should stay stable")

	print("Closed-day panel config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
