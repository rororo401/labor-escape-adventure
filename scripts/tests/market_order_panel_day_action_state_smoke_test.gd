extends "res://scripts/tests/test_scene_tree.gd"

const MarketOrderPanelDayActionStateConfigScript := preload("res://scripts/ui/market_order_panel_day_action_state_config.gd")
const MarketOrderPanelDayActionStateScript := preload("res://scripts/ui/market_order_panel_day_action_state.gd")


func _initialize() -> void:
	var mixed_labels := MarketOrderPanelDayActionStateScript.build(["회사 출근", 22, "집에 있기"], false, 8)
	_expect(mixed_labels.get(MarketOrderPanelDayActionStateConfigScript.KEY_LABELS, []) == ["회사 출근", "22", "집에 있기"], "day action labels should normalize to strings")
	_expect(int(mixed_labels.get(MarketOrderPanelDayActionStateConfigScript.KEY_SELECTED_INDEX, -1)) == 2, "selected index should clamp high")
	_expect(bool(mixed_labels.get(MarketOrderPanelDayActionStateConfigScript.KEY_HAS_SELECTION, false)), "non-empty labels should mark selection available")
	_expect(not bool(mixed_labels.get(MarketOrderPanelDayActionStateConfigScript.KEY_DISABLED, true)), "disabled flag should be preserved")

	var low_index := MarketOrderPanelDayActionStateScript.build(["첫번째", "두번째"], true, -4)
	_expect(int(low_index.get(MarketOrderPanelDayActionStateConfigScript.KEY_SELECTED_INDEX, -1)) == MarketOrderPanelDayActionStateConfigScript.DEFAULT_SELECTED_INDEX, "selected index should clamp low")
	_expect(bool(low_index.get(MarketOrderPanelDayActionStateConfigScript.KEY_DISABLED, false)), "disabled true should be preserved")

	var empty := MarketOrderPanelDayActionStateScript.build([], false, 3)
	_expect(empty.get(MarketOrderPanelDayActionStateConfigScript.KEY_LABELS, []).is_empty(), "empty labels should stay empty")
	_expect(int(empty.get(MarketOrderPanelDayActionStateConfigScript.KEY_SELECTED_INDEX, -1)) == MarketOrderPanelDayActionStateConfigScript.DEFAULT_SELECTED_INDEX, "empty label selected index should normalize to zero")
	_expect(not bool(empty.get(MarketOrderPanelDayActionStateConfigScript.KEY_HAS_SELECTION, true)), "empty labels should not mark selection available")

	print("Market order panel day action state smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
