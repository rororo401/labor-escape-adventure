extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")
const MarketDayActionSelectionScript := preload("res://scripts/ui/market_day_action_selection.gd")
const MarketDayActionSelectionResultConfigScript := preload("res://scripts/ui/market_day_action_selection_result_config.gd")
const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var empty_state: Dictionary = MarketDayActionSelectionScript.refresh_state(null, "", "", false)
	_expect(empty_state.is_empty(), "null game should return an empty refresh state")

	var game := GameStateScript.new()
	var closed_date := _helpers.find_closed_date_with_choice(game, "go_out", "part_time", "2016-07-02")
	_expect(game.setup(closed_date), "game should set up a closed day")

	var initial_state: Dictionary = MarketDayActionSelectionScript.refresh_state(game, "", "", false)
	_expect(not Array(initial_state.get(MarketDayActionOptionsConfigScript.KEY_CATEGORIES, [])).is_empty(), "closed day should expose action categories")
	_expect(Array(initial_state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES, [])).is_empty(), "closed day should wait for a category before rendering choices")
	_expect(String(initial_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID, "")).is_empty(), "initial closed-day category should be empty")

	var category_state: Dictionary = MarketDayActionSelectionScript.category_state(game, "go_out")
	var category_choices: Array = category_state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES, [])
	_expect(not category_choices.is_empty(), "selected closed-day category should expose choices")
	_expect(category_choices.size() <= 4, "category choices should be limited for the compact UI")
	var selected_action_id := String(Dictionary(category_choices[0]).get(MarketDayActionOptionsConfigScript.ACTION_ID, ""))

	var selected_category := MarketDayActionSelectionScript.category_selected(game, "go_out")
	_expect(bool(selected_category.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, false)), "category selection should be accepted on unfinished closed days")
	_expect(String(selected_category.get(MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE, {}).get(MarketScreenStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID, "")) == "go_out", "category selection should patch selected category")
	_expect(String(selected_category.get(MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE, {}).get(MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID, "bad")).is_empty(), "category selection should clear selected action")
	_expect(not Dictionary(selected_category.get(MarketDayActionSelectionResultConfigScript.KEY_PANEL_STATE, {})).is_empty(), "category selection should include panel state")

	var selected_state: Dictionary = MarketDayActionSelectionScript.refresh_state(game, "go_out", selected_action_id, false)
	_expect(String(selected_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID, "")) == "go_out", "refresh should preserve a valid selected category")
	_expect(String(selected_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, "")) == selected_action_id, "refresh should preserve a valid selected action")
	_expect(not bool(selected_state.get(MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED, true)), "idle refresh should keep categories enabled")
	_expect(not bool(selected_state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED, true)), "idle refresh should keep choices enabled")

	var selected_action := MarketDayActionSelectionScript.action_selected(game, false, selected_action_id)
	_expect(bool(selected_action.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, false)), "action selection should be accepted on unfinished closed days")
	_expect(String(selected_action.get(MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE, {}).get(MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID, "")) == selected_action_id, "action selection should patch selected action")
	_expect(String(selected_action.get(MarketDayResultStateConfigScript.KEY_MESSAGE, "")).contains("로 하루를 보내기로 했다"), "action selection should expose a selection message")

	var start_action := MarketDayActionSelectionScript.action_start(game, false, selected_action_id)
	_expect(bool(start_action.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, false)), "action start should be accepted with a selected action")
	_expect(bool(start_action.get(MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE, {}).get(MarketScreenStateConfigScript.KEY_IS_COMPLETING_DAY, false)), "action start should enter completing state")
	_expect(bool(start_action.get(MarketDayActionSelectionResultConfigScript.KEY_DISABLE_CHOICES, false)), "action start should request choice button disabling")

	_expect(not bool(MarketDayActionSelectionScript.action_selected(game, true, selected_action_id).get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, true)), "action selection should be blocked while completing")
	_expect(not bool(MarketDayActionSelectionScript.action_start(game, false, "").get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, true)), "empty action start should be blocked")

	var disabled_state: Dictionary = MarketDayActionSelectionScript.refresh_state(game, "go_out", selected_action_id, true)
	_expect(bool(disabled_state.get(MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED, false)), "disabled refresh should disable categories")
	_expect(bool(disabled_state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED, false)), "disabled refresh should disable choices")

	var invalid_category_state: Dictionary = MarketDayActionSelectionScript.refresh_state(game, "missing", selected_action_id, false)
	_expect(String(invalid_category_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID, "bad")).is_empty(), "invalid category should be cleared")
	_expect(Array(invalid_category_state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES, [])).is_empty(), "invalid category should not render stale choices")

	var action_ids: Array[String] = ["cleaning", "part_time"]
	_expect(
		MarketDayActionSelectionScript.selected_action_from_index(action_ids, 1, "cleaning") == "part_time",
		"valid action index should select the matching action id"
	)
	_expect(
		MarketDayActionSelectionScript.selected_action_from_index(action_ids, 7, "cleaning") == "cleaning",
		"invalid action index should preserve the current action id"
	)

	print("Market day action selection smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
