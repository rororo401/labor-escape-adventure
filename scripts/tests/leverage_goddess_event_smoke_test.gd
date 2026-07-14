extends "res://scripts/tests/test_scene_tree.gd"

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const LeverageGoddessEventScript := preload("res://scripts/core/dayflow/leverage_goddess_event.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")


func _initialize() -> void:
	_verify_trigger_rules_and_duration()
	_verify_completion_triggers_once()
	_verify_active_blessing_doubles_positive_market_profit()
	_verify_salary_is_not_doubled()
	print("Leverage goddess event smoke test passed.")
	finish_test()


func _verify_trigger_rules_and_duration() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-04", "leverage-rules"), "leverage rule fixture should set up")
	_set_cash(game, 3000000)
	_expect(not LeverageGoddessEventScript.can_trigger(game), "hard mode should never offer the leverage goddess")
	game.difficulty = GameDifficultyScript.EASY
	_expect(LeverageGoddessEventScript.can_trigger(game), "easy mode should trigger at three million won")
	var event := LeverageGoddessEventScript.event()
	_expect(String(event.get(DayEventKeysScript.KEY_ID, "")) == LeverageGoddessEventScript.EVENT_ID, "leverage event should have a stable id")
	_expect(FileAccess.file_exists(String(event.get(DayEventKeysScript.KEY_CG_PATH, ""))), "leverage event CG should exist")
	var dialogue_text := " ".join(PackedStringArray(event.get(DayEventKeysScript.KEY_DIALOGUE, [])))
	_expect(not dialogue_text.contains("365"), "dialogue should not reveal the exact duration")

	var trigger_day := game.day_index
	LeverageGoddessEventScript.trigger(game)
	_expect(game.leverage_goddess_used, "trigger should consume the once-per-run event")
	_expect(game.leverage_blessing_start_day_index == trigger_day + 1, "blessing should begin on the next day")
	_expect(game.leverage_blessing_end_day_index - game.leverage_blessing_start_day_index == 365, "internal blessing duration should be exactly 365 calendar days")
	_expect(not LeverageGoddessEventScript.is_blessing_active(game), "trigger day should not retroactively receive profit")
	game.day_index = game.leverage_blessing_start_day_index
	_expect(LeverageGoddessEventScript.is_blessing_active(game), "blessing should be active from its start day")
	game.difficulty = GameDifficultyScript.HARD
	_expect(not LeverageGoddessEventScript.is_blessing_active(game), "other difficulties should never activate the blessing")
	game.difficulty = GameDifficultyScript.EASY
	game.day_index = game.leverage_blessing_end_day_index - 1
	_expect(LeverageGoddessEventScript.is_blessing_active(game), "blessing should include its final day")
	game.day_index = game.leverage_blessing_end_day_index
	_expect(not LeverageGoddessEventScript.is_blessing_active(game), "blessing should expire after 365 days")
	_expect(not LeverageGoddessEventScript.can_trigger(game), "expired blessing should not summon the goddess twice")
	_expect(LeverageGoddessEventScript.profit_bonus(3300000, 3000000, 100000) == 200000, "external cash gains should not be doubled")
	_expect(LeverageGoddessEventScript.profit_bonus(2800000, 3000000, 0) == 0, "losses should not receive a bonus")


func _verify_completion_triggers_once() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-04", "leverage-trigger"), "leverage trigger fixture should set up")
	game.difficulty = GameDifficultyScript.EASY
	_set_cash(game, 2500000)
	var result := game.complete_today(DayEventKeysScript.ACTION_COMPANY_WORK, [], true)
	_expect(result.get(DayEventKeysScript.KEY_OK, false), "low-asset easy day should complete")
	_expect(_has_night_event(result, LeverageGoddessEventScript.EVENT_ID), "low-asset easy completion should add the goddess event")
	_expect(game.leverage_goddess_used, "completion should persist the once-only flag")
	_expect(_history_count(game.event_history, LeverageGoddessEventScript.EVENT_ID) == 1, "goddess should be recorded once in event history")


func _verify_active_blessing_doubles_positive_market_profit() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-04", "leverage-profit"), "leverage profit fixture should set up")
	game.difficulty = GameDifficultyScript.EASY
	_expect(game.submit_market_order("005930", "buy", 1).get(DayEventKeysScript.KEY_OK, false), "profit fixture should buy one share")
	game.leverage_goddess_used = true
	game.leverage_blessing_start_day_index = game.day_index
	game.leverage_blessing_end_day_index = game.day_index + 365
	game.leverage_reference_net_worth = int(game.market.get_open_report("2016-07-04").get(PlayerStatusKeysScript.KEY_NET_WORTH, 0))
	var result := game.complete_today(DayEventKeysScript.ACTION_COMPANY_WORK, [], true)
	var bonus_effect: Dictionary = result.get(DayEventKeysScript.KEY_LEVERAGE_BONUS_EFFECT, {})
	var bonus_delta: Dictionary = bonus_effect.get(PlayerStatusKeysScript.KEY_DELTA, {})
	_expect(int(bonus_delta.get(PlayerStatusKeysScript.KEY_CASH, 0)) == 41, "positive Samsung intraday gain should be credited once more")
	_expect(game.leverage_reference_net_worth == game.status.get_net_worth(), "blessing reference should advance after each completed day")


func _verify_salary_is_not_doubled() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-25", "leverage-salary"), "salary exclusion fixture should set up")
	game.difficulty = GameDifficultyScript.EASY
	game.leverage_goddess_used = true
	game.leverage_blessing_start_day_index = game.day_index
	game.leverage_blessing_end_day_index = game.day_index + 365
	game.leverage_reference_net_worth = game.status.get_net_worth()
	var result := game.complete_today(DayEventKeysScript.ACTION_COMPANY_WORK, [], true)
	var bonus_effect: Dictionary = result.get(DayEventKeysScript.KEY_LEVERAGE_BONUS_EFFECT, {})
	var bonus_delta: Dictionary = bonus_effect.get(PlayerStatusKeysScript.KEY_DELTA, {})
	_expect(int(bonus_delta.get(PlayerStatusKeysScript.KEY_CASH, 0)) == 0, "monthly salary and work cash effects should not receive leverage bonus")


func _set_cash(game, cash: int) -> void:
	game.status.cash = cash
	game.market.set_cash_balance(cash)
	game.refresh_status_from_current_phase()


func _has_night_event(result: Dictionary, event_id: String) -> bool:
	for row in result.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []):
		var event := Dictionary(Dictionary(row).get(DayEventKeysScript.KEY_EVENT, {}))
		if String(event.get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false


func _history_count(history: Array, event_id: String) -> int:
	var count := 0
	for row in history:
		if String(Dictionary(row).get(DayEventKeysScript.KEY_ID, "")) == event_id:
			count += 1
	return count


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
