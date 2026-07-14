extends "res://scripts/tests/test_scene_tree.gd"

const MarketFlowCopyScript := preload("res://scripts/ui/market_flow_copy.gd")
const MarketOrderPanelConfigScript := preload("res://scripts/ui/market_order_panel_config.gd")
const MarketOrderPanelScript := preload("res://scripts/ui/market_order_panel.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var panel = MarketOrderPanelScript.new()
	panel.build()
	root.add_child(panel)
	await process_frame

	_expect(panel.name == MarketOrderPanelConfigScript.PANEL_NAME, "panel name should use config")
	_expect(panel.position == MarketOrderPanelConfigScript.PANEL_POSITION, "panel position should use config")
	_expect(panel.custom_minimum_size == MarketOrderPanelConfigScript.PANEL_SIZE, "panel minimum size should use config")
	_expect(panel.size.x >= MarketOrderPanelConfigScript.PANEL_SIZE.x and panel.size.y >= MarketOrderPanelConfigScript.PANEL_SIZE.y, "panel should not shrink below configured size")
	var margin := panel.get_child(0) as MarginContainer
	_expect(margin != null and margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_LEFT) == int(MarketOrderPanelConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)), "panel should use configured layout margin")
	var layout := margin.get_child(0) as VBoxContainer
	_expect(layout != null and layout.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == MarketOrderPanelConfigScript.LAYOUT_SEPARATION, "panel should use configured layout separation")
	_expect(_find_label_with_text(panel, MarketOrderPanelConfigScript.TODAY_LABEL) != null, "today label should render")

	var buy_button := _helpers.find_node(panel, "BuyButton") as Button
	var sell_button := _helpers.find_node(panel, "SellButton") as Button
	var flow_button := _helpers.find_button_containing(panel, MarketOrderPanelConfigScript.DEFAULT_FLOW_TEXT)
	_expect(buy_button != null and buy_button.text == MarketOrderPanelConfigScript.BUY_LABEL, "buy button should render from config")
	_expect(sell_button != null and sell_button.text == MarketOrderPanelConfigScript.SELL_LABEL, "sell button should render from config")
	_expect(flow_button != null and flow_button.text == MarketOrderPanelConfigScript.DEFAULT_FLOW_TEXT, "flow button should render shared default text")

	panel.update_flow_button(false, false, false, false, false)
	_expect(flow_button.text == MarketOrderPanelConfigScript.DEFAULT_FLOW_TEXT, "missing ready text should fall back to config default")

	panel.update_flow_button(false, false, false, false, false, "회사 출근하기")
	_expect(flow_button.text == "회사 출근하기", "custom ready text should still be allowed")

	panel.update_flow_button(false, false, false, true, false, "회사 출근하기")
	_expect(flow_button.text == MarketFlowCopyScript.SLEEP_TEXT, "completed day should use shared sleep text")

	print("Market order panel view smoke test passed.")
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
