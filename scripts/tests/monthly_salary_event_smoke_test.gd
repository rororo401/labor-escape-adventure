extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MonthlySalaryEventScript := preload("res://scripts/core/dayflow/monthly_salary_event.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")


func _initialize() -> void:
	_verify_event_rules()
	_verify_completion_applies_salary_once_per_month()
	print("Monthly salary event smoke test passed.")
	finish_test()


func _verify_event_rules() -> void:
	var before_payday := {
		DayEventKeysScript.KEY_DATE: "2016-07-22",
		DayEventKeysScript.KEY_IS_TRADING_DAY: true
	}
	_expect(MonthlySalaryEventScript.event_for_day(before_payday, []).is_empty(), "salary should not trigger before payday")

	var closed_payday := {
		DayEventKeysScript.KEY_DATE: "2016-12-25",
		DayEventKeysScript.KEY_IS_TRADING_DAY: false
	}
	_expect(MonthlySalaryEventScript.event_for_day(closed_payday, []).is_empty(), "salary should not trigger on closed days")

	var payday := {
		DayEventKeysScript.KEY_DATE: "2016-07-25",
		DayEventKeysScript.KEY_IS_TRADING_DAY: true
	}
	var event := MonthlySalaryEventScript.event_for_day(payday, [])
	_expect(not event.is_empty(), "salary should trigger on a trading day from the 25th")
	_expect(String(event.get(DayEventKeysScript.KEY_ID, "")) == "monthly_salary_2016_07", "salary event id should include year and month")
	var amount := int(Dictionary(event.get(DayEventKeysScript.KEY_EFFECTS, {})).get(PlayerStatusKeysScript.KEY_CASH_DELTA, 0))
	_expect(amount >= MonthlySalaryEventScript.MIN_SALARY, "salary amount should be at least minimum")
	_expect(amount <= MonthlySalaryEventScript.MAX_SALARY, "salary amount should be at most maximum")
	_expect(amount % MonthlySalaryEventScript.SALARY_STEP == 0, "salary amount should use the configured step")
	_expect(Array(event.get(DayEventKeysScript.KEY_DIALOGUE, [])).size() >= 3, "salary event should include dialogue")

	var history := [{DayEventKeysScript.KEY_ID: "monthly_salary_2016_07"}]
	_expect(MonthlySalaryEventScript.event_for_day(payday, history).is_empty(), "salary should not trigger twice in the same month")
	_expect(MonthlySalaryEventScript.salary_amount_for_date("2016-07-25") == MonthlySalaryEventScript.salary_amount_for_date("2016-07-29"), "same month should use the same salary amount")
	var hard_amount := MonthlySalaryEventScript.salary_amount_for_date("2016-07-25", GameDifficultyScript.HARD)
	var normal_amount := MonthlySalaryEventScript.salary_amount_for_date("2016-07-25", GameDifficultyScript.NORMAL)
	var easy_amount := MonthlySalaryEventScript.salary_amount_for_date("2016-07-25", GameDifficultyScript.EASY)
	_expect(normal_amount == roundi(hard_amount * 2.75), "normal should increase only the monthly investment amount")
	_expect(easy_amount == roundi(hard_amount * 7.0), "easy should increase only the monthly investment amount")


func _verify_completion_applies_salary_once_per_month() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-25"), "game should set up on July payday")
	var before_cash: int = game.status.cash
	var result := game.complete_today(DayEventKeysScript.ACTION_COMPANY_WORK, [], true)
	_expect(result.get(DayEventKeysScript.KEY_OK, false), "payday completion should succeed")

	var salary_row := _find_event_effect_row(result.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []), "monthly_salary_2016_07")
	_expect(not salary_row.is_empty(), "completion should include monthly salary event")
	var salary_effect := Dictionary(salary_row.get(DayEventKeysScript.KEY_EFFECT, {}))
	var salary_effect_delta := Dictionary(salary_effect.get(PlayerStatusKeysScript.KEY_DELTA, {}))
	var salary_delta := int(salary_effect_delta.get(PlayerStatusKeysScript.KEY_CASH, 0))
	_expect(salary_delta >= MonthlySalaryEventScript.MIN_SALARY, "completion salary should add at least minimum cash")
	_expect(salary_delta <= MonthlySalaryEventScript.MAX_SALARY, "completion salary should add at most maximum cash")
	_expect(game.status.cash == before_cash + salary_delta, "salary cash should be applied to player status")
	_expect(_history_has(game.event_history, "monthly_salary_2016_07"), "salary event should be recorded in history")

	var easy_game := GameStateScript.new()
	_expect(easy_game.setup("2016-07-25"), "easy salary fixture should set up")
	easy_game.difficulty = GameDifficultyScript.EASY
	var easy_before_cash: int = easy_game.status.cash
	var easy_result := easy_game.complete_today(DayEventKeysScript.ACTION_COMPANY_WORK, [], true)
	var easy_salary_row := _find_event_effect_row(easy_result.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []), "monthly_salary_2016_07")
	var easy_salary_delta := int(Dictionary(Dictionary(easy_salary_row.get(DayEventKeysScript.KEY_EFFECT, {})).get(PlayerStatusKeysScript.KEY_DELTA, {})).get(PlayerStatusKeysScript.KEY_CASH, 0))
	_expect(easy_salary_delta == roundi(salary_delta * 7.0), "day completion should apply the selected difficulty salary")
	_expect(easy_game.status.cash == easy_before_cash + easy_salary_delta, "easy salary should stay synchronized with market cash")

	var next_month_day := {
		DayEventKeysScript.KEY_DATE: "2016-07-26",
		DayEventKeysScript.KEY_IS_TRADING_DAY: true
	}
	_expect(MonthlySalaryEventScript.event_for_day(next_month_day, game.event_history).is_empty(), "recorded salary should block later same-month salary")


func _find_event_effect_row(rows: Array, event_id: String) -> Dictionary:
	for row in rows:
		var event := Dictionary(Dictionary(row).get(DayEventKeysScript.KEY_EVENT, {}))
		if String(event.get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return Dictionary(row)
	return {}


func _history_has(history: Array, event_id: String) -> bool:
	for row in history:
		if String(Dictionary(row).get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
