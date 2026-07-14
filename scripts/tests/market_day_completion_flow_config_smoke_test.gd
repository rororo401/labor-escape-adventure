extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayCompletionFlowConfigScript := preload("res://scripts/ui/market_day_completion_flow_config.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketDayCompletionFlowConfigScript.KEY_OK == ResultKeysScript.KEY_OK, "ok key should use the shared result key")
	_expect(MarketDayCompletionFlowConfigScript.KEY_RESULT == UiPayloadKeysScript.KEY_RESULT, "result key should use the shared UI payload key")
	_expect(MarketDayCompletionFlowConfigScript.KEY_STATE == UiPayloadKeysScript.KEY_STATE, "state key should use the shared UI payload key")
	_expect(MarketDayCompletionFlowConfigScript.KEY_DAY_ACTION == DayEventKeysScript.KEY_DAY_ACTION, "day action key should use the shared day-event key")
	_expect(MarketDayCompletionFlowConfigScript.KEY_EVENT == DayEventKeysScript.KEY_EVENT, "event key should use the shared day-event key")
	_expect(MarketDayCompletionFlowConfigScript.KEY_SHOULD_PLAY_DAY_EVENT == "should_play_day_event", "event flag key should stay stable")
	_expect(MarketDayCompletionFlowConfigScript.KEY_PLAYBACK_EVENTS == "playback_events", "playback-events key should stay stable")
	_expect(MarketDayCompletionFlowConfigScript.KEY_ERROR == ResultKeysScript.KEY_ERROR, "error key should use the shared result key")
	_expect(MarketDayCompletionFlowConfigScript.DEFAULT_MISSING_GAME_ERROR == "game_not_started", "missing-game error should stay stable")

	print("Market day completion flow config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
