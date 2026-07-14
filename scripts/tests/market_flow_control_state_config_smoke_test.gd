extends "res://scripts/tests/test_scene_tree.gd"

const MarketFlowControlStateConfigScript := preload("res://scripts/ui/market_flow_control_state_config.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketFlowControlStateConfigScript.KEY_CAN_TRADE == "can_trade", "can-trade key should stay stable")
	_expect(MarketFlowControlStateConfigScript.KEY_ORDER_FLOW == "order_flow", "order-flow key should stay stable")
	_expect(MarketFlowControlStateConfigScript.KEY_CLOSED_FLOW == "closed_flow", "closed-flow key should stay stable")
	_expect(MarketFlowControlStateConfigScript.KEY_GAME_FINISHED == GameStateContextKeysScript.KEY_GAME_FINISHED, "game-finished key should share game-state context")
	_expect(MarketFlowControlStateConfigScript.KEY_GAME_CLEAR == GameStateContextKeysScript.KEY_GAME_CLEAR, "game-clear key should share game-state context")
	_expect(MarketFlowControlStateConfigScript.KEY_GAME_OVER == GameStateContextKeysScript.KEY_GAME_OVER, "game-over key should share game-state context")
	_expect(MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED == GameStateContextKeysScript.KEY_DAY_COMPLETED, "day-completed key should share game-state context")
	_expect(MarketFlowControlStateConfigScript.KEY_SLEEP_SEQUENCE == "sleep_sequence", "sleep-sequence key should stay stable")
	_expect(MarketFlowControlStateConfigScript.KEY_READY_TEXT == "ready_text", "ready-text key should stay stable")
	_expect(MarketFlowControlStateConfigScript.KEY_COMPLETING_DAY == "completing_day", "completing-day key should stay stable")
	_expect(MarketFlowControlStateConfigScript.KEY_HAS_SELECTION == UiPayloadKeysScript.KEY_HAS_SELECTION, "has-selection key should use the shared UI payload key")
	_expect(not MarketFlowControlStateConfigScript.DEFAULT_CAN_TRADE, "default can-trade should stay false")
	_expect(not MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG, "default flow flag should stay false")
	_expect(MarketFlowControlStateConfigScript.DEFAULT_READY_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "default ready text should use the shared blank UI default")
	_expect(not MarketFlowControlStateConfigScript.DEFAULT_HAS_SELECTION, "default has-selection should stay false")

	print("Market flow control state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
