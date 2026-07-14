extends "res://scripts/tests/test_scene_tree.gd"

const DayCompletionResultScript := preload("res://scripts/core/dayflow/day_completion_result.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_expect(DayCompletionResultScript.ERROR_DAY_ALREADY_COMPLETED == "day_already_completed", "completed-day error id should stay stable")
	_expect(DayCompletionResultScript.ERROR_FIRST_DAY_STOCK_REQUIRED == "first_day_stock_required", "first-day stock error id should stay stable")
	_expect(DayCompletionResultScript.ERROR_DAY_NOT_COMPLETED == "day_not_completed", "unfinished-day error id should stay stable")
	_expect(DayCompletionResultScript.KEY_RESULT == ResultKeysScript.KEY_RESULT, "completed-day result key should use the shared result key")
	_expect(DayCompletionResultScript.KEY_REQUIRED_QUANTITY == "required_quantity", "required quantity key should stay stable")
	_expect(DayCompletionResultScript.KEY_HELD_QUANTITY == MarketDataKeysScript.KEY_HELD_QUANTITY, "held quantity key should use the shared market data key")

	var missing: Dictionary = DayCompletionResultScript.calendar_day_missing()
	_expect(not missing.get("ok", true), "missing calendar day should be a failure")
	_expect(missing.get("error", "") == "calendar_day_missing", "missing calendar day error mismatch")

	var completed: Dictionary = DayCompletionResultScript.day_already_completed({
		"date": "2016-07-01"
	})
	_expect(completed.get("error", "") == DayCompletionResultScript.ERROR_DAY_ALREADY_COMPLETED, "completed day error mismatch")
	_expect(completed.get(DayCompletionResultScript.KEY_RESULT, {}).get("date", "") == "2016-07-01", "completed day should keep the last result")

	var blocked_game_over: Dictionary = DayCompletionResultScript.game_over({
		"cash": 0
	}, "cash_zero")
	_expect(blocked_game_over.get("error", "") == "game_over", "game-over error mismatch")
	_expect(blocked_game_over.get("game_over_reason", "") == "cash_zero", "game-over reason should be preserved")

	var blocked_game_clear: Dictionary = DayCompletionResultScript.game_clear({
		"cash": 1000000000
	}, "target_net_worth")
	_expect(blocked_game_clear.get("error", "") == "game_clear", "game-clear error mismatch")
	_expect(blocked_game_clear.get("clear_reason", "") == "target_net_worth", "clear reason should be preserved")

	var stock_required: Dictionary = DayCompletionResultScript.first_day_stock_required(0)
	_expect(stock_required.get("error", "") == DayCompletionResultScript.ERROR_FIRST_DAY_STOCK_REQUIRED, "first-day stock error mismatch")
	_expect(stock_required.get(DayCompletionResultScript.KEY_REQUIRED_QUANTITY, 0) == 1, "first-day stock requirement should default to one share")
	_expect(stock_required.get(DayCompletionResultScript.KEY_HELD_QUANTITY, -1) == 0, "first-day stock requirement should preserve held quantity")

	_expect(DayCompletionResultScript.day_not_completed().get("error", "") == DayCompletionResultScript.ERROR_DAY_NOT_COMPLETED, "unfinished-day error mismatch")

	var status := {
		PlayerStatusKeysScript.KEY_CASH: 1000,
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: 200,
		PlayerStatusKeysScript.KEY_HEALTH: 80,
		PlayerStatusKeysScript.KEY_MOOD: 55,
		PlayerStatusKeysScript.KEY_FATIGUE: 20
	}
	var empty_effect: Dictionary = DayCompletionResultScript.empty_effect(status)
	_expect(empty_effect.get(PlayerStatusKeysScript.KEY_BEFORE, {}).get(PlayerStatusKeysScript.KEY_CASH, 0) == 1000, "empty effect should keep the before status")
	_expect(empty_effect.get(PlayerStatusKeysScript.KEY_AFTER, {}).get(PlayerStatusKeysScript.KEY_HEALTH, 0) == 80, "empty effect should keep the after status")
	_expect(empty_effect.get(PlayerStatusKeysScript.KEY_DELTA, {}).get(PlayerStatusKeysScript.KEY_MOOD, -1) == 0, "empty effect should zero mood delta")

	status[PlayerStatusKeysScript.KEY_CASH] = 0
	_expect(empty_effect.get(PlayerStatusKeysScript.KEY_BEFORE, {}).get(PlayerStatusKeysScript.KEY_CASH, 0) == 1000, "empty effect should duplicate status snapshots")

	var event := {
		DayEventKeysScript.KEY_ID: DayEventKeysScript.ACTION_NAP,
		"name_ko": "낮잠자기"
	}
	var row: Dictionary = DayCompletionResultScript.event_effect_row(event, empty_effect)
	_expect(row.get("event", {}).get(DayEventKeysScript.KEY_ID, "") == DayEventKeysScript.ACTION_NAP, "event effect row should keep the event")
	_expect(row.get("effect", {}).get(PlayerStatusKeysScript.KEY_DELTA, {}).get(PlayerStatusKeysScript.KEY_FATIGUE, -1) == 0, "event effect row should keep the effect")

	var payload: Dictionary = DayCompletionResultScript.payload(
		{
			"date": "2016-07-02",
			"weekday": "Saturday",
			"is_trading_day": false
		},
		event,
		empty_effect,
		[row],
		[row],
		{
			PlayerStatusKeysScript.KEY_DELTA: {
				PlayerStatusKeysScript.KEY_FATIGUE: 3
			}
		},
		{
			"net_worth": 1200
		},
		{
			PlayerStatusKeysScript.KEY_CASH: 1000,
			PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: 200
		},
		false,
		"",
		false,
		""
	)
	_expect(payload.get("ok", false), "day completion payload should be ok")
	_expect(payload.get("date", "") == "2016-07-02", "day completion payload should keep the date")
	_expect(not payload.get("market", {}).get("is_open", true), "closed-day payload should mark the market closed")
	_expect(payload.get(DayEventKeysScript.KEY_DAY_ACTION, {}).get("event", {}).get(DayEventKeysScript.KEY_ID, "") == DayEventKeysScript.ACTION_NAP, "payload should wrap the day action event")
	_expect(Array(payload.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, [])).size() == 1, "payload should keep weekday event rows")
	_expect(Array(payload.get(DayEventKeysScript.KEY_NIGHT_EVENTS, [])).size() == 1, "payload should keep night event rows")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_LEVERAGE_BONUS_EFFECT, {})).is_empty(), "ordinary payload should default to no leverage bonus")
	_expect(not payload.get("game_finished", true), "unfinished payload should keep game_finished false")
	_expect(payload.get("sleep_required", false), "unfinished payload should require sleep")

	var clear_payload: Dictionary = DayCompletionResultScript.payload(
		{
			"is_trading_day": true
		},
		{},
		empty_effect,
		[],
		[],
		{},
		{},
		{},
		false,
		"",
		true,
		"target_net_worth"
	)
	_expect(clear_payload.get("game_finished", false), "clear payload should finish the game")
	_expect(not clear_payload.get("sleep_required", true), "clear payload should not require sleep")
	_expect(clear_payload.get("clear_reason", "") == "target_net_worth", "clear payload should keep the clear reason")

	var bad_payload: Dictionary = DayCompletionResultScript.payload(
		{"is_trading_day": true},
		{},
		empty_effect,
		[],
		[],
		{},
		{},
		{},
		true,
		"final_bad_ending",
		false,
		"",
		{
			PlayerStatusKeysScript.KEY_ENDING_ROUTE: "bad_ending_04_almost_free",
			PlayerStatusKeysScript.KEY_ENDING_TIER: 4
		}
	)
	_expect(bad_payload.get("game_finished", false), "bad ending payload should finish the game")
	_expect(bad_payload.get("ending_route", "") == "bad_ending_04_almost_free", "bad ending payload should preserve route")

	print("Day completion result smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
