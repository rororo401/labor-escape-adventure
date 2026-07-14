extends "res://scripts/tests/test_scene_tree.gd"

const MarketStockListPanelConfigScript := preload("res://scripts/ui/market_stock_list_panel_config.gd")
const MarketStockListPanelScript := preload("res://scripts/ui/market_stock_list_panel.gd")
const MarketStockRowConfigScript := preload("res://scripts/ui/market_stock_row_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")

var _selected_ticker := ""


func _initialize() -> void:
	var panel = MarketStockListPanelScript.new()
	panel.build()
	panel.stock_selected.connect(func(ticker: String) -> void:
		_selected_ticker = ticker
	)
	root.add_child(panel)
	await process_frame

	_expect(panel.name == MarketStockListPanelConfigScript.PANEL_NAME, "stock-list panel should use configured node name")
	_expect(panel.position == MarketStockListPanelConfigScript.PANEL_POSITION, "stock-list panel should use configured position")
	_expect(panel.custom_minimum_size == MarketStockListPanelConfigScript.PANEL_SIZE, "stock-list panel should use configured minimum size")
	_expect(panel.size.x >= MarketStockListPanelConfigScript.PANEL_SIZE.x and panel.size.y >= MarketStockListPanelConfigScript.PANEL_SIZE.y, "stock-list panel should not shrink below configured size")
	var margin := panel.get_child(0) as MarginContainer
	_expect(margin != null and margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_LEFT) == MarketStockListPanelConfigScript.PANEL_MARGIN_LEFT, "stock-list panel should use configured layout margin")
	var layout := margin.get_child(0) as VBoxContainer
	_expect(layout != null and layout.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == MarketStockListPanelConfigScript.LAYOUT_SEPARATION, "stock-list panel should use configured layout separation")

	var title := _find_label_with_text(panel, MarketStockListPanelConfigScript.TITLE_TEXT)
	_expect(title != null, "stock-list panel should create configured title")
	var header := _find_grid_with_size(panel, MarketStockListPanelConfigScript.HEADER_SIZE)
	_expect(header != null, "stock-list panel should create configured header grid")
	_expect(header.get_child_count() == MarketStockListPanelConfigScript.HEADER_LABELS.size(), "header should create configured columns")
	_expect(header.get_theme_constant(PanelLayoutHelpersScript.THEME_H_SEPARATION) == MarketStockListPanelConfigScript.HEADER_SEPARATION, "header should use configured separation")

	var rows: Array[Dictionary] = []
	for index in 12:
		rows.append({
			MarketStockRowConfigScript.KEY_TICKER: "T%02d" % index,
			MarketStockRowConfigScript.KEY_NAME: "테스트%02d" % index,
			MarketStockRowConfigScript.KEY_OPEN: 1000 + index,
			MarketStockRowConfigScript.KEY_CHANGE_RATE: 0.1 * float(index),
			MarketStockRowConfigScript.KEY_HELD_QUANTITY: index
		})
	panel.render_stocks(rows)
	await process_frame

	var row_buttons := _find_stock_buttons(panel)
	_expect(row_buttons.size() == MarketStockListPanelConfigScript.DEFAULT_RENDER_LIMIT, "stock-list panel should apply default render limit")
	var first_button := row_buttons[0] as Button
	_expect(first_button.custom_minimum_size.x > 0.0, "stock row should keep a stable button size")
	var columns := first_button.get_node_or_null("Columns") as GridContainer
	_expect(columns != null, "stock row should create a columns grid")
	_expect(columns.position == MarketStockListPanelConfigScript.ROW_GRID_POSITION, "stock row columns should use configured position")
	_expect(columns.size == MarketStockListPanelConfigScript.ROW_GRID_SIZE, "stock row columns should use configured size")
	_expect(columns.get_theme_constant(PanelLayoutHelpersScript.THEME_H_SEPARATION) == MarketStockListPanelConfigScript.ROW_GRID_SEPARATION, "stock row columns should use configured separation")

	first_button.emit_signal("pressed")
	_expect(_selected_ticker == "T00", "stock-list panel should emit selected ticker")

	panel.render_stocks(rows, 3)
	await process_frame
	_expect(_find_stock_buttons(panel).size() == 3, "stock-list panel should honor explicit render limit")

	print("Market stock list panel smoke test passed.")
	finish_test()


func _find_label_with_text(node: Node, text: String) -> Label:
	if node is Label and node.text == text:
		return node
	for child in node.get_children():
		var found := _find_label_with_text(child, text)
		if found != null:
			return found
	return null


func _find_grid_with_size(node: Node, size: Vector2) -> GridContainer:
	if node is GridContainer and node.custom_minimum_size == size:
		return node
	for child in node.get_children():
		var found := _find_grid_with_size(child, size)
		if found != null:
			return found
	return null


func _find_stock_buttons(node: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	_collect_stock_buttons(node, buttons)
	return buttons


func _collect_stock_buttons(node: Node, buttons: Array[Button]) -> void:
	if node is Button and node.name.begins_with("Stock_"):
		buttons.append(node)
	for child in node.get_children():
		_collect_stock_buttons(child, buttons)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
