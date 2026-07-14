extends "res://scripts/tests/test_scene_tree.gd"

const MarketRefreshStateConfigScript := preload("res://scripts/ui/market_refresh_state_config.gd")
const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketStatusTextConfigScript := preload("res://scripts/ui/market_status_text_config.gd")
const DisplayPayloadKeysScript := preload("res://scripts/core/display_payload_keys.gd")
const TextBlockPayloadKeysScript := preload("res://scripts/core/text_block_payload_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketRefreshStateConfigScript.KEY_MARKET_OPEN == "market_open", "market-open key should stay stable")
	_expect(MarketRefreshStateConfigScript.KEY_DATE_TEXT == DisplayPayloadKeysScript.KEY_DATE_TEXT, "date-text key should use the shared display payload key")
	_expect(MarketRefreshStateConfigScript.KEY_STATUS_TEXT == "status_text", "status-text key should stay stable")
	_expect(MarketRefreshStateConfigScript.KEY_STATUS_SNAPSHOT == "status_snapshot", "status snapshot key should stay stable")
	_expect(MarketRefreshStateConfigScript.KEY_SELECTED_STOCK == MarketDayResultStateConfigScript.KEY_SELECTED_STOCK, "selected-stock key should share day-result state config")
	_expect(MarketRefreshStateConfigScript.KEY_STOCKS == MarketDataKeysScript.KEY_STOCKS, "stocks key should share market data keys")
	_expect(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TEXT == "closed_day_text", "closed-day-text key should stay stable")
	_expect(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_MESSAGE == "closed_day_message", "closed-day-message key should stay stable")
	_expect(MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE == "completed_message", "completed-message key should stay stable")
	_expect(MarketRefreshStateConfigScript.KEY_STATUS_CASH == MarketStatusTextConfigScript.KEY_CASH, "status cash key should stay stable")
	_expect(MarketRefreshStateConfigScript.KEY_STATUS_NET_WORTH == MarketStatusTextConfigScript.KEY_NET_WORTH, "status net-worth key should stay stable")
	_expect(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TITLE == TextBlockPayloadKeysScript.KEY_TITLE, "closed-day title key should use the shared text-block key")
	_expect(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_BODY == TextBlockPayloadKeysScript.KEY_BODY, "closed-day body key should use the shared text-block key")
	_expect(MarketRefreshStateConfigScript.EMPTY_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "empty text should use the shared UI payload default")
	_expect(not MarketRefreshStateConfigScript.DEFAULT_MARKET_OPEN, "default market-open should stay false")

	print("Market refresh state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
