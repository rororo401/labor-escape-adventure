extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketScreenStateConfigScript.KEY_IS_SLEEP_SEQUENCE == MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE, "sleep key should share day-result state config")
	_expect(MarketScreenStateConfigScript.KEY_IS_COMPLETING_DAY == MarketDayResultStateConfigScript.KEY_IS_COMPLETING_DAY, "completing key should share day-result state config")
	_expect(MarketScreenStateConfigScript.KEY_SHOWING_CLOSE_REPORT == MarketDayResultStateConfigScript.KEY_SHOWING_CLOSE_REPORT, "close-report key should share day-result state config")
	_expect(MarketScreenStateConfigScript.KEY_SELECTED_STOCK == MarketDayResultStateConfigScript.KEY_SELECTED_STOCK, "selected-stock key should share day-result state config")
	_expect(MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID == MarketDayResultStateConfigScript.KEY_SELECTED_DAY_ACTION_ID, "selected action key should share day-result state config")
	_expect(MarketScreenStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID == MarketDayResultStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID, "selected category key should share day-result state config")
	_expect(MarketScreenStateConfigScript.KEY_QUANTITY == MarketDataKeysScript.KEY_QUANTITY, "quantity key should use the shared market data key")
	_expect(MarketScreenStateConfigScript.DEFAULT_SELECTED_STOCK.is_empty(), "default selected stock should be empty")
	_expect(MarketScreenStateConfigScript.DEFAULT_SELECTED_DAY_ACTION_ID == UiPayloadKeysScript.EMPTY_MESSAGE, "default action id should use the shared empty UI message")
	_expect(MarketScreenStateConfigScript.DEFAULT_SELECTED_CLOSED_DAY_CATEGORY_ID == UiPayloadKeysScript.EMPTY_MESSAGE, "default category id should use the shared empty UI message")
	_expect(MarketScreenStateConfigScript.DEFAULT_QUANTITY == 1, "default quantity should stay stable")
	_expect(not MarketScreenStateConfigScript.DEFAULT_FLAG, "default flags should be false")
	_expect(MarketScreenStateConfigScript.KNOWN_KEYS.has(MarketScreenStateConfigScript.KEY_QUANTITY), "known keys should include quantity")
	_expect(MarketScreenStateConfigScript.KNOWN_KEYS.has(MarketScreenStateConfigScript.KEY_SELECTED_STOCK), "known keys should include selected stock")

	print("Market screen state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
