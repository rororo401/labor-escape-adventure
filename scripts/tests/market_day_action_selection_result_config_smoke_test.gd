extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayActionSelectionResultConfigScript := preload("res://scripts/ui/market_day_action_selection_result_config.gd")


func _initialize() -> void:
	_expect(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED == "accepted", "accepted key should stay stable")
	_expect(MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE == "screen_state", "screen-state key should stay stable")
	_expect(MarketDayActionSelectionResultConfigScript.KEY_PANEL_STATE == "panel_state", "panel-state key should stay stable")
	_expect(MarketDayActionSelectionResultConfigScript.KEY_DISABLE_CHOICES == "disable_choices", "disable-choices key should stay stable")
	_expect(not MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED, "default accepted should stay false")
	_expect(not MarketDayActionSelectionResultConfigScript.DEFAULT_DISABLE_CHOICES, "default disable choices should stay false")

	print("Market day-action selection result config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
