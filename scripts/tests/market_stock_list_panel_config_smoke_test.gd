extends "res://scripts/tests/test_scene_tree.gd"

const MarketStockListPanelConfigScript := preload("res://scripts/ui/market_stock_list_panel_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")


func _initialize() -> void:
	_expect(MarketStockListPanelConfigScript.PANEL_NAME == "StockListPanel", "stock-list panel name should stay stable")
	_expect(MarketStockListPanelConfigScript.PANEL_POSITION == Vector2(22, 194), "stock-list panel position should stay stable")
	_expect(MarketStockListPanelConfigScript.PANEL_SIZE == Vector2(676, 455), "stock-list panel size should stay stable")
	_expect(int(MarketStockListPanelConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)) == MarketStockListPanelConfigScript.PANEL_MARGIN_LEFT, "stock-list panel margin dictionary should mirror left margin")
	_expect(int(MarketStockListPanelConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_BOTTOM, 0)) == MarketStockListPanelConfigScript.PANEL_MARGIN_BOTTOM, "stock-list panel margin dictionary should mirror bottom margin")
	_expect(MarketStockListPanelConfigScript.TITLE_TEXT == "오늘의 종목", "stock-list title should stay stable")
	_expect(MarketStockListPanelConfigScript.SCROLL_SIZE == Vector2(644, 336), "stock-list scroll size should stay stable")
	_expect(MarketStockListPanelConfigScript.HEADER_LABELS == ["종목", "시가", "등락", "보유"], "header labels should stay stable")
	_expect(MarketStockListPanelConfigScript.STOCK_COL_WIDTHS == [188.0, 152.0, 118.0, 102.0], "stock column widths should stay stable")
	_expect(MarketStockListPanelConfigScript.ROW_GRID_POSITION == Vector2(16, 10), "row grid position should stay stable")
	_expect(MarketStockListPanelConfigScript.DEFAULT_RENDER_LIMIT == 10, "default render limit should stay stable")

	print("Market stock list panel config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
