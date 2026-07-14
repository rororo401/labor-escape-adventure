extends "res://scripts/tests/test_scene_tree.gd"

const MarketStockRowConfigScript := preload("res://scripts/ui/market_stock_row_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketStockRowConfigScript.KEY_TICKER == MarketDataKeysScript.KEY_TICKER, "ticker key should share market data keys")
	_expect(MarketStockRowConfigScript.KEY_DISPLAY_NAME == MarketDataKeysScript.KEY_DISPLAY_NAME_KO, "display-name key should share market data keys")
	_expect(MarketStockRowConfigScript.KEY_NAME_KO == MarketDataKeysScript.KEY_NAME_KO, "Korean name key should share market data keys")
	_expect(MarketStockRowConfigScript.KEY_NAME == "name", "generic name key should stay stable")
	_expect(MarketStockRowConfigScript.KEY_OPEN == MarketDataKeysScript.KEY_OPEN, "open key should share market data keys")
	_expect(MarketStockRowConfigScript.KEY_PREVIOUS_CLOSE == MarketDataKeysScript.KEY_PREVIOUS_CLOSE, "previous-close key should share market data keys")
	_expect(MarketStockRowConfigScript.KEY_CHANGE_RATE == MarketDataKeysScript.KEY_CHANGE_RATE, "change-rate key should share market data keys")
	_expect(MarketStockRowConfigScript.KEY_HELD_QUANTITY == MarketDataKeysScript.KEY_HELD_QUANTITY, "held-quantity key should share market data keys")
	_expect(MarketStockRowConfigScript.KEY_AVG_COST == MarketDataKeysScript.KEY_AVG_COST, "average-cost key should share market data keys")
	_expect(MarketStockRowConfigScript.EMPTY_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "empty text should use the shared UI payload default")
	_expect(MarketStockRowConfigScript.DEFAULT_NUMBER == 0, "default number should stay zero")
	_expect(MarketStockRowConfigScript.DEFAULT_RATE == 0.0, "default rate should stay zero")

	print("Market stock row config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
