extends "res://scripts/tests/test_scene_tree.gd"

const MarketOrderInputConfigScript := preload("res://scripts/ui/market_order_input_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_expect(MarketOrderInputConfigScript.MIN_QUANTITY == 1, "minimum quantity should stay stable")
	_expect(MarketOrderInputConfigScript.MAX_QUANTITY == 999, "maximum quantity should stay stable")
	_expect(MarketOrderInputConfigScript.KEY_OK == ResultKeysScript.KEY_OK, "ok key should use the shared result key")
	_expect(MarketOrderInputConfigScript.KEY_ERROR == ResultKeysScript.KEY_ERROR, "error key should use the shared result key")
	_expect(MarketOrderInputConfigScript.KEY_TICKER == MarketDataKeysScript.KEY_TICKER, "ticker key should share market data keys")
	_expect(MarketOrderInputConfigScript.KEY_SIDE == MarketDataKeysScript.KEY_SIDE, "side key should share market data keys")
	_expect(MarketOrderInputConfigScript.KEY_QUANTITY == MarketDataKeysScript.KEY_QUANTITY, "quantity key should share market data keys")
	_expect(MarketOrderInputConfigScript.ERROR_STOCK_NOT_SELECTED == "stock_not_selected", "missing-stock error should stay stable")

	print("Market order input config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
