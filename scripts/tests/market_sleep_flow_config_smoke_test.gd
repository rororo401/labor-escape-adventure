extends "res://scripts/tests/test_scene_tree.gd"

const MarketSleepFlowConfigScript := preload("res://scripts/ui/market_sleep_flow_config.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketSleepFlowConfigScript.KEY_OK == ResultKeysScript.KEY_OK, "sleep flow ok key should use the shared result key")
	_expect(MarketSleepFlowConfigScript.KEY_START_STATE == "start_state", "sleep flow start-state key should stay stable")
	_expect(MarketSleepFlowConfigScript.KEY_ERROR_STATE == "error_state", "sleep flow error-state key should stay stable")
	_expect(MarketSleepFlowConfigScript.KEY_TRANSITION_STATE == "transition_state", "sleep flow transition-state key should stay stable")
	_expect(MarketSleepFlowConfigScript.KEY_RESULT == UiPayloadKeysScript.KEY_RESULT, "sleep flow result key should use the shared UI payload key")
	_expect(MarketSleepFlowConfigScript.CALLBACK_APPLY_STATE == "apply_state", "apply-state callback key should stay stable")
	_expect(MarketSleepFlowConfigScript.CALLBACK_SET_MESSAGE == "set_message", "set-message callback key should stay stable")
	_expect(MarketSleepFlowConfigScript.CALLBACK_REFRESH_FLOW_CONTROLS == "refresh_flow_controls", "refresh-flow callback key should stay stable")
	_expect(MarketSleepFlowConfigScript.CALLBACK_REFRESH_MARKET == "refresh_market", "refresh-market callback key should stay stable")
	_expect(MarketSleepFlowConfigScript.CALLBACK_MARKET_REVEAL_READY == "market_reveal_ready", "market-reveal callback key should stay stable")
	_expect(MarketSleepFlowConfigScript.DEFAULT_MISSING_GAME_ERROR == "game_not_started", "missing-game error should stay stable")

	var callbacks := MarketSleepFlowConfigScript.screen_callbacks(_noop, _noop, _noop, _noop, _noop)
	_expect(callbacks.has(MarketSleepFlowConfigScript.CALLBACK_APPLY_STATE), "screen callbacks should include apply-state callback")
	_expect(callbacks.has(MarketSleepFlowConfigScript.CALLBACK_SET_MESSAGE), "screen callbacks should include set-message callback")
	_expect(callbacks.has(MarketSleepFlowConfigScript.CALLBACK_REFRESH_FLOW_CONTROLS), "screen callbacks should include flow-controls refresh callback")
	_expect(callbacks.has(MarketSleepFlowConfigScript.CALLBACK_REFRESH_MARKET), "screen callbacks should include market refresh callback")
	_expect(Callable(callbacks.get(MarketSleepFlowConfigScript.CALLBACK_REFRESH_MARKET, Callable())).is_valid(), "screen callbacks should store valid callables")
	_expect(callbacks.has(MarketSleepFlowConfigScript.CALLBACK_MARKET_REVEAL_READY), "screen callbacks should include market reveal callback")
	_expect(Callable(callbacks.get(MarketSleepFlowConfigScript.CALLBACK_MARKET_REVEAL_READY, Callable())).is_valid(), "screen callbacks should store a valid market reveal callback")

	var start_state := {"is_sleep_sequence": true}
	var error_state := {"is_sleep_sequence": false, "message": "error"}
	var error_payload := MarketSleepFlowConfigScript.sleep_error_result(start_state, error_state)
	_expect(not bool(error_payload.get(MarketSleepFlowConfigScript.KEY_OK, true)), "sleep error payload should fail")
	_expect(error_payload.get(MarketSleepFlowConfigScript.KEY_START_STATE, {}) == start_state, "sleep error payload should keep start state")
	_expect(error_payload.get(MarketSleepFlowConfigScript.KEY_ERROR_STATE, {}) == error_state, "sleep error payload should keep error state")
	_expect(not error_payload.has(MarketSleepFlowConfigScript.KEY_RESULT), "sleep error payload should omit empty result")

	var backend_result := {"to_date": "2016-07-02"}
	var backend_error_payload := MarketSleepFlowConfigScript.sleep_error_result(start_state, error_state, backend_result)
	_expect(backend_error_payload.get(MarketSleepFlowConfigScript.KEY_RESULT, {}) == backend_result, "sleep backend error payload should keep result")

	var transition_state := {"is_sleep_sequence": true, "message": ""}
	var transition_payload := MarketSleepFlowConfigScript.sleep_transition_result(start_state, transition_state, backend_result)
	_expect(bool(transition_payload.get(MarketSleepFlowConfigScript.KEY_OK, false)), "sleep transition payload should succeed")
	_expect(transition_payload.get(MarketSleepFlowConfigScript.KEY_START_STATE, {}) == start_state, "sleep transition payload should keep start state")
	_expect(transition_payload.get(MarketSleepFlowConfigScript.KEY_TRANSITION_STATE, {}) == transition_state, "sleep transition payload should keep transition state")
	_expect(transition_payload.get(MarketSleepFlowConfigScript.KEY_RESULT, {}) == backend_result, "sleep transition payload should keep backend result")

	print("Market sleep flow config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _noop(_value = null) -> void:
	pass
