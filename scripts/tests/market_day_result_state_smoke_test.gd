extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketDayResultStateScript := preload("res://scripts/ui/market_day_result_state.gd")


func _initialize() -> void:
	var result := {
		"day_action": {
			"event": {
				"name_ko": "회사 업무"
			}
		},
		"night_events": [],
		"market_close_report": {
			"unrealized_profit": 1200,
			"net_worth": 1000000000
		}
	}
	var success_state: Dictionary = MarketDayResultStateScript.completion_success_state(result)
	_expect(not bool(success_state.get(MarketDayResultStateConfigScript.KEY_IS_COMPLETING_DAY, true)), "completion success should clear completing flag")
	_expect(bool(success_state.get(MarketDayResultStateConfigScript.KEY_SHOWING_CLOSE_REPORT, false)), "completion success should show close report")
	_expect(String(success_state.get(MarketDayResultStateConfigScript.KEY_MESSAGE, "")).contains("회사 업무 완료"), "completion success should format result message")

	var error_state: Dictionary = MarketDayResultStateScript.completion_error_state("first_day_stock_required")
	_expect(not bool(error_state.get(MarketDayResultStateConfigScript.KEY_IS_COMPLETING_DAY, true)), "completion error should clear completing flag")
	_expect(not bool(error_state.get(MarketDayResultStateConfigScript.KEY_CHOICE_BUTTONS_DISABLED, true)), "completion error should re-enable choices")
	_expect(String(error_state.get(MarketDayResultStateConfigScript.KEY_MESSAGE, "")).contains("최소 1주"), "completion error should format flow error message")

	var sleep_start: Dictionary = MarketDayResultStateScript.sleep_start_state()
	_expect(bool(sleep_start.get(MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE, false)), "sleep start should set sleep sequence flag")

	var sleep_error: Dictionary = MarketDayResultStateScript.sleep_error_state("day_not_completed")
	_expect(not bool(sleep_error.get(MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE, true)), "sleep error should clear sleep flag")
	_expect(String(sleep_error.get(MarketDayResultStateConfigScript.KEY_MESSAGE, "")).contains("아직 잠들기"), "sleep error should format sleep error message")

	var after_sleep: Dictionary = MarketDayResultStateScript.after_sleep_transition_state()
	_expect(bool(after_sleep.get(MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE, false)), "after sleep transition should keep sleep sequence active until morning briefing finishes")
	_expect(not bool(after_sleep.get(MarketDayResultStateConfigScript.KEY_SHOWING_CLOSE_REPORT, true)), "after sleep should hide close report")
	_expect(Dictionary(after_sleep.get(MarketDayResultStateConfigScript.KEY_SELECTED_STOCK, {"bad": true})).is_empty(), "after sleep should clear selected stock")
	_expect(String(after_sleep.get(MarketDayResultStateConfigScript.KEY_SELECTED_DAY_ACTION_ID, "bad")).is_empty(), "after sleep should clear selected day action")
	_expect(String(after_sleep.get(MarketDayResultStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID, "bad")).is_empty(), "after sleep should clear selected category")
	_expect(String(after_sleep.get(MarketDayResultStateConfigScript.KEY_MESSAGE, "bad")).is_empty(), "after sleep should clear flow message")

	var after_morning: Dictionary = MarketDayResultStateScript.after_sleep_morning_state()
	_expect(not bool(after_morning.get(MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE, true)), "after morning should clear sleep sequence flag")

	print("Market day result state smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
