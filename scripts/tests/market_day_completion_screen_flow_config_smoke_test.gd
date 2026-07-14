extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayCompletionScreenFlowConfigScript := preload("res://scripts/ui/market_day_completion_screen_flow_config.gd")
const MarketDayCompletionScreenFlowScript := preload("res://scripts/ui/market_day_completion_screen_flow.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketDayCompletionScreenFlowConfigScript.EVENT_MODE_AWAIT == "await", "await event mode should stay stable")
	_expect(MarketDayCompletionScreenFlowConfigScript.EVENT_MODE_CALLBACK == "callback", "callback event mode should stay stable")
	_expect(MarketDayCompletionScreenFlowConfigScript.KEY_ACTION == UiPayloadKeysScript.KEY_ACTION, "step action key should use the shared UI payload key")
	_expect(MarketDayCompletionScreenFlowConfigScript.KEY_STATE == UiPayloadKeysScript.KEY_STATE, "step state key should use the shared UI payload key")
	_expect(MarketDayCompletionScreenFlowConfigScript.KEY_RESULT == UiPayloadKeysScript.KEY_RESULT, "step result key should use the shared UI payload key")
	_expect(MarketDayCompletionScreenFlowConfigScript.KEY_DAY_ACTION == DayEventKeysScript.KEY_DAY_ACTION, "step day-action key should use the shared day-event key")
	_expect(MarketDayCompletionScreenFlowConfigScript.KEY_PLAYBACK_EVENTS == "playback_events", "step playback-events key should stay stable")
	_expect(MarketDayCompletionScreenFlowConfigScript.ACTION_ERROR == "error", "error step action should stay stable")
	_expect(MarketDayCompletionScreenFlowConfigScript.ACTION_FINISH == "finish", "finish step action should stay stable")
	_expect(MarketDayCompletionScreenFlowConfigScript.ACTION_PLAY_EVENT == "play_event", "event step action should stay stable")
	_expect(MarketDayCompletionScreenFlowScript.EVENT_MODE_AWAIT == MarketDayCompletionScreenFlowConfigScript.EVENT_MODE_AWAIT, "screen flow should keep await mode alias")
	_expect(MarketDayCompletionScreenFlowScript.EVENT_MODE_CALLBACK == MarketDayCompletionScreenFlowConfigScript.EVENT_MODE_CALLBACK, "screen flow should keep callback mode alias")
	_expect(MarketDayCompletionScreenFlowConfigScript.CALLBACK_APPLY_ERROR == "apply_error", "apply-error callback key should stay stable")
	_expect(MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH == "finish", "finish callback key should stay stable")
	_expect(MarketDayCompletionScreenFlowConfigScript.CALLBACK_UPDATE_CLOSED_DAY_CHOICES == "update_closed_day_choices", "choice-update callback key should stay stable")
	_expect(MarketDayCompletionScreenFlowConfigScript.DEFAULT_UPDATE_CLOSED_DAY_CHOICES, "choice updates should be enabled by default")

	print("Market day completion screen flow config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
