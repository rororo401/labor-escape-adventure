extends "res://scripts/tests/test_scene_tree.gd"

const MarketOrderPanelStockStateConfigScript := preload("res://scripts/ui/market_order_panel_stock_state_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketStockRowConfigScript := preload("res://scripts/ui/market_stock_row_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketOrderPanelStockStateConfigScript.KEY_NAME == MarketStockRowConfigScript.KEY_NAME, "selected stock name key should reuse the stock-row name key")
	_expect(MarketOrderPanelStockStateConfigScript.KEY_PRICE == MarketDataKeysScript.KEY_PRICE, "price key should share market data keys")
	_expect(MarketOrderPanelStockStateConfigScript.KEY_HOLDING == "holding", "holding key should stay stable")
	_expect(MarketOrderPanelStockStateConfigScript.KEY_QUANTITY == MarketDataKeysScript.KEY_QUANTITY, "quantity key should share market data keys")
	_expect(MarketOrderPanelStockStateConfigScript.EMPTY_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "empty text should use the shared UI payload default")
	_expect(MarketOrderPanelStockStateConfigScript.EMPTY_STOCK_NAME == "선택 종목 없음", "empty stock name should stay stable")

	print("Market order panel stock state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
