extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketDayResultStateConfigScript.KEY_IS_COMPLETING_DAY == "is_completing_day", "completing flag key should stay stable")
	_expect(MarketDayResultStateConfigScript.KEY_SHOWING_CLOSE_REPORT == "showing_close_report", "close-report flag key should stay stable")
	_expect(MarketDayResultStateConfigScript.KEY_CHOICE_BUTTONS_DISABLED == "choice_buttons_disabled", "choice-disabled key should stay stable")
	_expect(MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE == "is_sleep_sequence", "sleep-sequence key should stay stable")
	_expect(MarketDayResultStateConfigScript.KEY_SELECTED_STOCK == "selected_stock", "selected-stock key should stay stable")
	_expect(MarketDayResultStateConfigScript.KEY_SELECTED_DAY_ACTION_ID == "selected_day_action_id", "selected action key should stay stable")
	_expect(MarketDayResultStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID == "selected_closed_day_category_id", "selected category key should stay stable")
	_expect(MarketDayResultStateConfigScript.KEY_MESSAGE == UiPayloadKeysScript.KEY_MESSAGE, "message key should use the shared UI payload key")
	_expect(MarketDayResultStateConfigScript.CLEAR_MESSAGE == UiPayloadKeysScript.EMPTY_MESSAGE, "clear message value should use the shared empty UI message")
	_expect(MarketDayResultStateConfigScript.CLEAR_DAY_ACTION_ID == "", "clear day-action value should stay blank")
	_expect(MarketDayResultStateConfigScript.CLEAR_CLOSED_DAY_CATEGORY_ID == "", "clear category value should stay blank")

	print("Market day result state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
