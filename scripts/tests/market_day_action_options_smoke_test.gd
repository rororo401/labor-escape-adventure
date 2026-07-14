extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayActionOptionsScript := preload("res://scripts/ui/market_day_action_options.gd")
const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")


func _initialize() -> void:
	var default_state: Dictionary = MarketDayActionOptionsScript.default_action_state({
		MarketDayActionOptionsConfigScript.FLOW_DEFAULT_ACTION: {
			MarketDayActionOptionsConfigScript.ACTION_ID: "company_work",
			MarketDayActionOptionsConfigScript.ACTION_NAME: "회사 업무"
		}
	})
	_expect(default_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, "") == "company_work", "default action should become selected action")
	_expect(default_state.get(MarketDayActionOptionsConfigScript.KEY_ACTION_IDS, []) == ["company_work"], "default action ids should contain the default id")
	_expect(default_state.get(MarketDayActionOptionsConfigScript.KEY_LABELS, []) == ["회사 업무"], "default action labels should contain the default label")

	var fallback_default: Dictionary = MarketDayActionOptionsScript.default_action_state({})
	_expect(fallback_default.get(MarketDayActionOptionsConfigScript.KEY_ACTION_IDS, []) == [MarketDayActionOptionsConfigScript.EMPTY_ID], "missing default action should keep an empty id placeholder")
	_expect(fallback_default.get(MarketDayActionOptionsConfigScript.KEY_LABELS, []) == [MarketDayActionOptionsConfigScript.DEFAULT_ACTION_LABEL], "missing default action should use fallback label")

	var choices := [
		{
			MarketDayActionOptionsConfigScript.ACTION_ID: "stay_home",
			MarketDayActionOptionsConfigScript.ACTION_NAME: "집에 있기"
		},
		{
			MarketDayActionOptionsConfigScript.ACTION_ID: "river_walk",
			MarketDayActionOptionsConfigScript.ACTION_NAME: "한강 산책하기"
		}
	]
	var choice_state: Dictionary = MarketDayActionOptionsScript.choice_action_state(choices, "river_walk")
	_expect(choice_state.get(MarketDayActionOptionsConfigScript.KEY_ACTION_IDS, []) == ["stay_home", "river_walk"], "choice state should preserve action ids")
	_expect(choice_state.get(MarketDayActionOptionsConfigScript.KEY_LABELS, []) == ["집에 있기", "한강 산책하기"], "choice state should preserve labels")
	_expect(int(choice_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_INDEX, -1)) == 1, "choice state should resolve selected index")

	var missing_choice_state: Dictionary = MarketDayActionOptionsScript.choice_action_state(choices, "missing")
	_expect(int(missing_choice_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_INDEX, -1)) == MarketDayActionOptionsConfigScript.DEFAULT_SELECTED_INDEX, "missing selected action should fall back to first index")

	var categories := [
		{MarketDayActionOptionsConfigScript.ACTION_ID: "home"},
		{MarketDayActionOptionsConfigScript.ACTION_ID: "outside"}
	]
	_expect(MarketDayActionOptionsScript.resolve_category_id(categories, "outside") == "outside", "existing category should be preserved")
	_expect(MarketDayActionOptionsScript.resolve_category_id(categories, "missing") == MarketDayActionOptionsConfigScript.EMPTY_ID, "missing category should reset to empty")

	var flow := {
		MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CATEGORIES: categories,
		MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CHOICES: choices,
		MarketDayActionOptionsConfigScript.FLOW_DEFAULT_ACTION: {
			MarketDayActionOptionsConfigScript.ACTION_ID: "company_work",
			MarketDayActionOptionsConfigScript.ACTION_NAME: "회사 업무"
		}
	}
	var empty_state: Dictionary = MarketDayActionOptionsScript.closed_day_empty_state(flow)
	_expect(empty_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, "") == "company_work", "empty closed-day state should use the default action")
	_expect(empty_state.get(MarketDayActionOptionsConfigScript.KEY_CATEGORIES, []) == [], "empty closed-day state should hide categories")
	_expect(bool(empty_state.get(MarketDayActionOptionsConfigScript.KEY_ORDER_ACTIONS_DISABLED, false)), "empty closed-day state should disable order-panel actions")

	var refresh_state: Dictionary = MarketDayActionOptionsScript.closed_day_refresh_state(flow, "outside", "river_walk", [choices[1]], true)
	_expect(refresh_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID, "") == "outside", "refresh state should preserve a valid category")
	_expect(refresh_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, "") == "river_walk", "refresh state should preserve a selected action")
	_expect(refresh_state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES, []) == [choices[1]], "refresh state should expose rendered category choices")
	_expect(int(refresh_state.get(MarketDayActionOptionsConfigScript.KEY_ACTION_SELECTED_INDEX, -1)) == 1, "refresh state should expose selected action index")
	_expect(bool(refresh_state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED, false)), "refresh state should expose disabled choice state")

	var reset_state: Dictionary = MarketDayActionOptionsScript.closed_day_refresh_state(flow, "missing", "river_walk", [choices[1]], false)
	_expect(reset_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID, "") == MarketDayActionOptionsConfigScript.EMPTY_ID, "missing category should reset category selection")
	_expect(reset_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, "") == MarketDayActionOptionsConfigScript.EMPTY_ID, "missing category should reset action selection")
	_expect(reset_state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES, []) == [], "missing category should clear rendered choices")

	var category_state: Dictionary = MarketDayActionOptionsScript.closed_day_category_state(categories, "home", [choices[0]])
	_expect(category_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID, "") == "home", "category state should set selected category")
	_expect(category_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, "") == MarketDayActionOptionsConfigScript.EMPTY_ID, "category state should clear selected action")
	_expect(category_state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES, []) == [choices[0]], "category state should expose fresh category choices")

	print("Market day action options smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
