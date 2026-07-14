extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenRefreshResultConfigScript := preload("res://scripts/ui/market_screen_refresh_result_config.gd")
const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketRefreshStateConfigScript := preload("res://scripts/ui/market_refresh_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketScreenRefreshResultConfigScript.KEY_MARKET_CONTEXT == "market_context", "market-context key should stay stable")
	_expect(MarketScreenRefreshResultConfigScript.KEY_PRESENTATION == "presentation", "presentation key should stay stable")
	_expect(MarketScreenRefreshResultConfigScript.KEY_SELECTED_STOCK == MarketDayResultStateConfigScript.KEY_SELECTED_STOCK, "selected-stock key should share day-result state config")
	_expect(MarketScreenRefreshResultConfigScript.KEY_COMPLETED_MESSAGE == MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE, "completed-message key should share refresh state config")
	_expect(MarketScreenRefreshResultConfigScript.EMPTY_MESSAGE == UiPayloadKeysScript.EMPTY_MESSAGE, "empty message should use the shared UI payload default")

	print("Market screen refresh result config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
