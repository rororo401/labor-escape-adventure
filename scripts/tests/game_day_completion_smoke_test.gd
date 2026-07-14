extends "res://scripts/tests/test_scene_tree.gd"

const GameDayCompletionScript := preload("res://scripts/core/dayflow/game_day_completion.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")


func _initialize() -> void:
	_verify_trading_day_completion()
	_verify_empty_event_effect()
	_verify_forced_weekday_event_rows()
	_verify_forced_night_event_rows()
	print("Game day completion smoke test passed.")
	finish_test()


func _verify_trading_day_completion() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up first trading day")
	_expect(game.submit_market_order("005930", "buy", 1).get("ok", false), "game should buy one share")
	var day: Dictionary = game.calendar.get_day(game.day_index)
	var result := GameDayCompletionScript.complete(game, day, DayEventKeysScript.ACTION_COMPANY_WORK, [], true)
	_expect(result.get("ok", false), "day completion helper should return ok")
	_expect(game.day_completed, "day completion helper should mark day completed")
	var day_event := Dictionary(result.get(DayEventKeysScript.KEY_DAY_ACTION, {}).get(DayEventKeysScript.KEY_EVENT, {}))
	_expect(String(day_event.get(DayEventKeysScript.KEY_ID, "")).begins_with("company_"), "day action should resolve to a company work variant")
	_expect(String(day_event.get(DayEventKeysScript.KEY_GROUP, "")) == DayEventKeysScript.GROUP_COMPANY_WORK, "day action should keep company work group")
	_expect(ResourceLoader.exists(String(day_event.get(DayEventKeysScript.KEY_CG_PATH, ""))), "company work variant CG should exist")
	_expect(Array(day_event.get(DayEventKeysScript.KEY_DIALOGUE, [])).size() == 3, "company work variant should include three dialogue lines")
	_expect(int(result.get("market_close_report", {}).get("investment_assets", 0)) == 29320, "completion should use close valuation")
	_expect(game.status.investment_assets == 29320, "completion should sync investment assets")


func _verify_empty_event_effect() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up for empty effect")
	var before_cash: int = game.status.cash
	var effect := GameDayCompletionScript.apply_event_effect(game, {})
	_expect(effect.get("delta", {}).get("cash", -1) == 0, "empty event should have zero cash delta")
	_expect(game.status.cash == before_cash, "empty event should not mutate status")


func _verify_forced_night_event_rows() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up for forced night event")
	_expect(game.submit_market_order("005930", "buy", 1).get("ok", false), "game should buy before completion")
	var day: Dictionary = game.calendar.get_day(game.day_index)
	var result := GameDayCompletionScript.complete(game, day, DayEventKeysScript.ACTION_COMPANY_WORK, ["night_early_sleep"], false)
	var night_events: Array = result.get(DayEventKeysScript.KEY_NIGHT_EVENTS, [])
	_expect(night_events.size() == 1, "forced night event should be included")
	if night_events.is_empty():
		return
	_expect(String(Dictionary(night_events[0]).get("event", {}).get("id", "")) == "night_early_sleep", "forced night event id should be preserved")


func _verify_forced_weekday_event_rows() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up for forced weekday event")
	_expect(game.submit_market_order("005930", "buy", 1).get("ok", false), "game should buy before completion")
	var day: Dictionary = game.calendar.get_day(game.day_index)
	var result := GameDayCompletionScript.complete(game, day, DayEventKeysScript.ACTION_COMPANY_WORK, ["overtime_request"], true)
	var weekday_events: Array = result.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, [])
	_expect(weekday_events.size() == 1, "forced weekday event should be included")
	if weekday_events.is_empty():
		return
	_expect(String(Dictionary(weekday_events[0]).get("event", {}).get("id", "")) == "overtime_request", "forced weekday event id should be preserved")
	_expect(_history_has(game.event_history, "overtime_request"), "forced weekday event should be recorded in history")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _history_has(history: Array, event_id: String) -> bool:
	for row in history:
		if String(Dictionary(row).get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false
