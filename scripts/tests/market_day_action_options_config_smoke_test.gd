extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID == "selected_action_id", "selected-action key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID == "selected_category_id", "selected-category key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.KEY_ACTION_IDS == "action_ids", "action ids key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.KEY_ACTION_LABELS == "action_labels", "action labels key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.KEY_LABELS == UiPayloadKeysScript.KEY_LABELS, "labels key should use the shared UI payload key")
	_expect(MarketDayActionOptionsConfigScript.KEY_SELECTED_INDEX == UiPayloadKeysScript.KEY_SELECTED_INDEX, "selected-index key should use the shared UI payload key")
	_expect(MarketDayActionOptionsConfigScript.KEY_ACTION_SELECTED_INDEX == "action_selected_index", "action selected-index key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.KEY_CATEGORIES == "categories", "categories key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.KEY_CHOICES == "choices", "choices key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED == "categories_disabled", "category disabled key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED == "choices_disabled", "choice disabled key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.KEY_ORDER_ACTIONS_DISABLED == "order_actions_disabled", "order-action disabled key should stay stable")
	_expect(MarketDayActionOptionsConfigScript.FLOW_DEFAULT_ACTION == DayEventKeysScript.KEY_DEFAULT_ACTION, "flow default-action key should use the shared day-event key")
	_expect(MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CATEGORIES == DayEventKeysScript.KEY_AVAILABLE_CATEGORIES, "flow categories key should use the shared day-event key")
	_expect(MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CHOICES == DayEventKeysScript.KEY_AVAILABLE_CHOICES, "flow choices key should use the shared day-event key")
	_expect(MarketDayActionOptionsConfigScript.ACTION_ID == DayEventKeysScript.KEY_ID, "action id key should use the shared day-event key")
	_expect(MarketDayActionOptionsConfigScript.ACTION_NAME == DayEventKeysScript.KEY_NAME_KO, "action name key should use the shared day-event key")
	_expect(MarketDayActionOptionsConfigScript.DEFAULT_ACTION_LABEL == "오늘 보내기", "default action label should stay stable")
	_expect(MarketDayActionOptionsConfigScript.EMPTY_ID == UiPayloadKeysScript.EMPTY_MESSAGE, "empty id should use the shared blank UI default")
	_expect(MarketDayActionOptionsConfigScript.DEFAULT_SELECTED_INDEX == 0, "default selected index should stay zero")

	print("Market day-action options config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
