extends "res://scripts/tests/test_scene_tree.gd"

const ClosedDayPanelConfigScript := preload("res://scripts/ui/closed_day_panel_config.gd")
const ClosedDayPanelScript := preload("res://scripts/ui/closed_day_panel.gd")
const MarketFlowCopyScript := preload("res://scripts/ui/market_flow_copy.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var panel = ClosedDayPanelScript.new()
	panel.build()
	root.add_child(panel)
	await process_frame

	_expect(panel.name == ClosedDayPanelConfigScript.PANEL_NAME, "panel should use configured name")
	_expect(panel.position == ClosedDayPanelConfigScript.PANEL_POSITION, "panel should use configured position")
	_expect(panel.custom_minimum_size == ClosedDayPanelConfigScript.PANEL_SIZE, "panel should use configured minimum size")
	_expect(panel.size.x >= ClosedDayPanelConfigScript.PANEL_SIZE.x and panel.size.y >= ClosedDayPanelConfigScript.PANEL_SIZE.y, "panel should not shrink below configured size")
	_expect(not panel.visible, "closed-day panel should start hidden")
	var margin := panel.get_child(0) as MarginContainer
	_expect(margin != null and margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_LEFT) == int(ClosedDayPanelConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)), "panel should use configured layout margin")
	var layout := margin.get_child(0) as VBoxContainer
	_expect(layout != null and layout.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == ClosedDayPanelConfigScript.LAYOUT_SEPARATION, "panel should use configured layout separation")

	var category_row := _helpers.find_node(panel, ClosedDayPanelConfigScript.CATEGORY_ROW_NAME) as HBoxContainer
	var choice_grid := _helpers.find_node(panel, ClosedDayPanelConfigScript.CHOICE_GRID_NAME) as GridContainer
	var flow_button := _helpers.find_node(panel, ClosedDayPanelConfigScript.FLOW_BUTTON_NAME) as Button
	_expect(category_row != null and category_row.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == ClosedDayPanelConfigScript.ROW_SEPARATION, "panel should expose configured category row")
	_expect(choice_grid != null and choice_grid.columns == ClosedDayPanelConfigScript.GRID_COLUMNS, "panel should expose configured choice grid")
	_expect(choice_grid.get_theme_constant(PanelLayoutHelpersScript.THEME_H_SEPARATION) == ClosedDayPanelConfigScript.ROW_SEPARATION, "choice grid should use configured horizontal separation")
	_expect(flow_button != null and flow_button.text == MarketFlowCopyScript.DEFAULT_READY_TEXT, "panel should render default flow text")
	_expect(flow_button.custom_minimum_size == ClosedDayPanelConfigScript.FLOW_BUTTON_SIZE, "flow button should use configured size")
	_expect(_find_label_with_text(panel, ClosedDayPanelConfigScript.DEFAULT_TITLE) != null, "panel should render configured default title")

	panel.set_day_text("토요일, 장이 열리지 않는다", "오늘은 집에 있을지 밖에 나갈지 고르자.")
	_expect(_find_label_with_text(panel, "토요일, 장이 열리지 않는다") != null, "panel should update title text")
	_expect(_find_label_with_text(panel, "오늘은 집에 있을지 밖에 나갈지 고르자.") != null, "panel should update body text")

	panel.update_flow_button(false, false, false, false, false, false, false)
	_expect(flow_button.text == MarketFlowCopyScript.ACTION_REQUIRED_TEXT, "flow button should show action-required text without selection")

	panel.update_flow_button(false, false, false, true, false, false, true)
	_expect(flow_button.text == MarketFlowCopyScript.SLEEP_TEXT, "flow button should show sleep text after completion")

	print("Closed-day panel view smoke test passed.")
	finish_test()


func _find_label_with_text(root_node: Node, text: String) -> Label:
	if root_node is Label:
		var label := root_node as Label
		if label.text == text:
			return label
	for child in root_node.get_children():
		var found := _find_label_with_text(child, text)
		if found != null:
			return found
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
