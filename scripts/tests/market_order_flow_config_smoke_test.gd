extends "res://scripts/tests/test_scene_tree.gd"

const MarketOrderInputConfigScript := preload("res://scripts/ui/market_order_input_config.gd")
const MarketOrderFlowConfigScript := preload("res://scripts/ui/market_order_flow_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketOrderFlowConfigScript.KEY_HANDLED == UiPayloadKeysScript.KEY_HANDLED, "handled key should use the shared UI payload key")
	_expect(MarketOrderFlowConfigScript.KEY_REQUEST == UiPayloadKeysScript.KEY_REQUEST, "request key should use the shared UI payload key")
	_expect(MarketOrderFlowConfigScript.KEY_RESULT == UiPayloadKeysScript.KEY_RESULT, "result key should use the shared UI payload key")
	_expect(MarketOrderFlowConfigScript.KEY_STATE == UiPayloadKeysScript.KEY_STATE, "state key should use the shared UI payload key")
	_expect(MarketOrderFlowConfigScript.KEY_MESSAGE == UiPayloadKeysScript.KEY_MESSAGE, "message key should use the shared UI payload key")
	_expect(MarketOrderFlowConfigScript.KEY_OK == MarketOrderInputConfigScript.KEY_OK, "ok key should share order-input config")
	_expect(MarketOrderFlowConfigScript.KEY_ERROR == MarketOrderInputConfigScript.KEY_ERROR, "error key should share order-input config")
	_expect(MarketOrderFlowConfigScript.KEY_PRICE == MarketDataKeysScript.KEY_PRICE, "price key should share market data keys")
	_expect(MarketOrderFlowConfigScript.KEY_TICKER == MarketOrderInputConfigScript.KEY_TICKER, "ticker key should share order-input config")
	_expect(MarketOrderFlowConfigScript.KEY_SIDE == MarketOrderInputConfigScript.KEY_SIDE, "side key should share order-input config")
	_expect(MarketOrderFlowConfigScript.KEY_QUANTITY == MarketOrderInputConfigScript.KEY_QUANTITY, "quantity key should share order-input config")
	_expect(MarketOrderFlowConfigScript.ERROR_GAME_NOT_STARTED == "game_not_started", "missing-game error should stay stable")
	_expect(MarketOrderFlowConfigScript.DEFAULT_QUANTITY == MarketOrderInputConfigScript.MIN_QUANTITY, "default quantity should share order-input minimum")
	_expect(not MarketOrderFlowConfigScript.DEFAULT_HANDLED, "default handled flag should stay false")
	_expect(not MarketOrderFlowConfigScript.CLOSE_REPORT_AFTER_ORDER, "orders should hide close report")
	var state := MarketOrderFlowConfigScript.post_order_state()
	_expect(state.get(MarketScreenStateConfigScript.KEY_SHOWING_CLOSE_REPORT, true) == false, "post-order state should hide close report")

	print("Market order flow config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
