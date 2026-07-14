extends "res://scripts/tests/test_scene_tree.gd"

const MarketOrderPanelStockStateConfigScript := preload("res://scripts/ui/market_order_panel_stock_state_config.gd")
const MarketOrderPanelStockStateScript := preload("res://scripts/ui/market_order_panel_stock_state.gd")


func _initialize() -> void:
	_verify_empty_stock_texts()
	_verify_selected_stock_texts()

	print("Market order panel stock state smoke test passed.")
	finish_test()


func _verify_empty_stock_texts() -> void:
	var state := MarketOrderPanelStockStateScript.selected_stock_texts({}, 3)
	_expect(String(state.get(MarketOrderPanelStockStateConfigScript.KEY_NAME, "")) == MarketOrderPanelStockStateConfigScript.EMPTY_STOCK_NAME, "empty stock should show placeholder")
	_expect(String(state.get(MarketOrderPanelStockStateConfigScript.KEY_PRICE, "")) == MarketOrderPanelStockStateConfigScript.EMPTY_TEXT, "empty stock should clear price text")
	_expect(String(state.get(MarketOrderPanelStockStateConfigScript.KEY_HOLDING, "")) == MarketOrderPanelStockStateConfigScript.EMPTY_TEXT, "empty stock should clear holding text")
	_expect(String(state.get(MarketOrderPanelStockStateConfigScript.KEY_QUANTITY, "")) == "3주", "empty stock should still show order quantity")


func _verify_selected_stock_texts() -> void:
	var state := MarketOrderPanelStockStateScript.selected_stock_texts({
		"ticker": "AAA",
		"name_ko": "새벽전자",
		"open": 12345,
		"change_rate": 1.25,
		"held_quantity": 4,
		"avg_cost": 12000
	}, 2)

	_expect(String(state.get(MarketOrderPanelStockStateConfigScript.KEY_NAME, "")).contains("새벽전자"), "selected stock should include display name")
	_expect(String(state.get(MarketOrderPanelStockStateConfigScript.KEY_PRICE, "")).contains("12,345원"), "selected stock should include formatted price")
	_expect(String(state.get(MarketOrderPanelStockStateConfigScript.KEY_PRICE, "")).contains("+1.25%"), "selected stock should include formatted change rate")
	_expect(String(state.get(MarketOrderPanelStockStateConfigScript.KEY_HOLDING, "")) == "보유 4주  평균 12,000원", "selected stock should include holding line")
	_expect(String(state.get(MarketOrderPanelStockStateConfigScript.KEY_QUANTITY, "")) == "2주", "selected stock should include order quantity")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
