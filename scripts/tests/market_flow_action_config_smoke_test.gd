extends "res://scripts/tests/test_scene_tree.gd"

const MarketFlowActionConfigScript := preload("res://scripts/ui/market_flow_action_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketFlowActionConfigScript.KEY_ACTION == UiPayloadKeysScript.KEY_ACTION, "action key should use the shared UI payload key")
	_expect(MarketFlowActionConfigScript.KEY_MESSAGE == UiPayloadKeysScript.KEY_MESSAGE, "message key should use the shared UI payload key")
	_expect(MarketFlowActionConfigScript.KEY_SCENE_PATH == "scene_path", "scene path key should stay stable")
	_expect(MarketFlowActionConfigScript.ACTION_IGNORE == "ignore", "ignore action should stay stable")
	_expect(MarketFlowActionConfigScript.ACTION_SLEEP == "sleep", "sleep action should stay stable")
	_expect(MarketFlowActionConfigScript.ACTION_COMPLETE_DAY == "complete_day", "complete-day action should stay stable")
	_expect(MarketFlowActionConfigScript.ACTION_MESSAGE == "message", "message action should stay stable")
	_expect(MarketFlowActionConfigScript.ACTION_FIRST_DAY_SCENE == "first_day_scene", "first-day-scene action should stay stable")
	_expect(MarketFlowActionConfigScript.ACTION_CHANGE_SCENE == "change_scene", "change-scene action should stay stable")
	_expect(MarketFlowActionConfigScript.EMPTY_ACTION == UiPayloadKeysScript.EMPTY_MESSAGE, "empty action should use the shared empty UI message")
	_expect(MarketFlowActionConfigScript.EMPTY_MESSAGE == UiPayloadKeysScript.EMPTY_MESSAGE, "empty message should use the shared empty UI message")
	_expect(MarketFlowActionConfigScript.EMPTY_SCENE_PATH == UiPayloadKeysScript.EMPTY_MESSAGE, "empty scene path should use the shared empty UI message")

	print("Market flow action config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
