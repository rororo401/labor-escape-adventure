extends "res://scripts/tests/test_scene_tree.gd"

const MarketOrderPanelDayActionStateConfigScript := preload("res://scripts/ui/market_order_panel_day_action_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketOrderPanelDayActionStateConfigScript.KEY_LABELS == UiPayloadKeysScript.KEY_LABELS, "labels key should use the shared UI payload key")
	_expect(MarketOrderPanelDayActionStateConfigScript.KEY_DISABLED == UiPayloadKeysScript.KEY_DISABLED, "disabled key should use the shared UI payload key")
	_expect(MarketOrderPanelDayActionStateConfigScript.KEY_SELECTED_INDEX == UiPayloadKeysScript.KEY_SELECTED_INDEX, "selected-index key should use the shared UI payload key")
	_expect(MarketOrderPanelDayActionStateConfigScript.KEY_HAS_SELECTION == UiPayloadKeysScript.KEY_HAS_SELECTION, "has-selection key should use the shared UI payload key")
	_expect(MarketOrderPanelDayActionStateConfigScript.DEFAULT_SELECTED_INDEX == 0, "default selected index should stay zero")

	print("Market order panel day action state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
