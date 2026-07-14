extends "res://scripts/tests/test_scene_tree.gd"

const GameDayProgressScript := preload("res://scripts/core/dayflow/game_day_progress.gd")
const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")


func _initialize() -> void:
	_verify_unfinished_day_blocks_sleep()
	_verify_completed_day_advances()
	_verify_target_reached_before_final_day_advances()
	_verify_final_clear_blocks_sleep()
	_verify_final_bad_ending_blocks_sleep()
	print("Game day progress smoke test passed.")
	finish_test()


func _verify_unfinished_day_blocks_sleep() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up")
	var result := GameDayProgressScript.sleep_to_next_day(game)
	_expect(not result.get(GameDayProgressKeysScript.KEY_OK, true), "unfinished day should not sleep")
	_expect(result.get(GameDayProgressKeysScript.KEY_ERROR, "") == "day_not_completed", "unfinished day should return day_not_completed")
	_expect(game.day_index == 0, "blocked sleep should not advance day")


func _verify_completed_day_advances() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up completed-day test")
	_expect(game.submit_market_order("005930", "buy", 1).get("ok", false), "game should buy one share")
	_expect(game.complete_today("company_work", [], true).get("ok", false), "game should complete first day")
	var result := GameDayProgressScript.sleep_to_next_day(game)
	_expect(result.get(GameDayProgressKeysScript.KEY_OK, false), "completed day should sleep")
	_expect(result.get(GameDayProgressKeysScript.KEY_FROM_DATE, "") == "2016-07-01", "sleep should preserve from date")
	_expect(result.get(GameDayProgressKeysScript.KEY_TO_DATE, "") == "2016-07-02", "sleep should advance to Saturday")
	var previous_result := Dictionary(result.get(GameDayProgressKeysScript.KEY_PREVIOUS_DAY_RESULT, {}))
	_expect(previous_result.get(DayEventKeysScript.KEY_DATE, "") == "2016-07-01", "sleep should preserve previous day result for morning context")
	_expect(game.day_index == 1, "sleep should advance day index")
	_expect(game.completed_days == 1, "sleep should increment completed days")
	_expect(not game.day_completed, "sleep should reset day completion flag")
	_expect(game.last_day_result.is_empty(), "sleep should clear last day result")
	_expect(Dictionary(result.get(GameDayProgressKeysScript.KEY_TODAY, {})).get("date", "") == "2016-07-02", "sleep should return next-day context")


func _verify_target_reached_before_final_day_advances() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-04"), "game should set up target-reached sleep test")
	game.status.cash = 1000000000
	game.day_completed = true
	var result := GameDayProgressScript.sleep_to_next_day(game)
	_expect(result.get(GameDayProgressKeysScript.KEY_OK, false), "target reached before final day should still sleep")
	_expect(result.get(GameDayProgressKeysScript.KEY_TO_DATE, "") == "2016-07-05", "target-reached run should keep advancing before final day")


func _verify_final_clear_blocks_sleep() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2026-06-30"), "game should set up final clear test")
	game.status.cash = 1000000000
	game.day_completed = true
	var result := GameDayProgressScript.sleep_to_next_day(game)
	_expect(not result.get(GameDayProgressKeysScript.KEY_OK, true), "clear game should not sleep")
	_expect(result.get(GameDayProgressKeysScript.KEY_ERROR, "") == "game_clear", "clear game should return game_clear")


func _verify_final_bad_ending_blocks_sleep() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2026-06-30"), "game should set up final bad-ending test")
	game.status.cash = 500000000
	game.day_completed = true
	var result := GameDayProgressScript.sleep_to_next_day(game)
	_expect(not result.get(GameDayProgressKeysScript.KEY_OK, true), "final bad ending should not sleep")
	_expect(result.get(GameDayProgressKeysScript.KEY_ERROR, "") == "game_over", "final bad ending should return game_over")
	_expect(result.get("game_over_reason", "") == "final_bad_ending", "final bad ending should preserve ending reason")
	_expect(result.get("ending_route", "") == "bad_ending_05_near_miss", "final bad ending should include asset route")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
