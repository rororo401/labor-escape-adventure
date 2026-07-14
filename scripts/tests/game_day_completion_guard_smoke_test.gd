extends "res://scripts/tests/test_scene_tree.gd"

const GameDayCompletionGuardScript := preload("res://scripts/core/dayflow/game_day_completion_guard.gd")
const DayCompletionResultScript := preload("res://scripts/core/dayflow/day_completion_result.gd")
const PlayerStatusScript := preload("res://scripts/core/player_status.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_expect(GameDayCompletionGuardScript.KEY_ALLOWED == "allowed", "guard allowed key should stay stable")
	_expect(GameDayCompletionGuardScript.KEY_RESULT == ResultKeysScript.KEY_RESULT, "guard result key should use the shared result key")

	_verify_missing_day_guard()
	_verify_completed_day_guard()
	_verify_game_over_and_clear_guards()
	_verify_first_tutorial_stock_guard()
	_verify_allowed_day()

	print("Game day completion guard smoke test passed.")
	finish_test()


func _verify_missing_day_guard() -> void:
	var status = PlayerStatusScript.new()
	var guard := GameDayCompletionGuardScript.evaluate({}, false, {}, status, false, 0)
	_expect(not bool(guard.get(GameDayCompletionGuardScript.KEY_ALLOWED, true)), "missing day should block completion")
	_expect(String(guard.get(GameDayCompletionGuardScript.KEY_RESULT, {}).get("error", "")) == "calendar_day_missing", "missing day should return calendar error")


func _verify_completed_day_guard() -> void:
	var status = PlayerStatusScript.new()
	var guard := GameDayCompletionGuardScript.evaluate({"date": "2016-07-01"}, true, {"date": "2016-07-01"}, status, false, 0)
	_expect(not bool(guard.get(GameDayCompletionGuardScript.KEY_ALLOWED, true)), "already completed day should block completion")
	_expect(String(guard.get(GameDayCompletionGuardScript.KEY_RESULT, {}).get("error", "")) == "day_already_completed", "completed day should return completed error")
	_expect(String(guard.get(GameDayCompletionGuardScript.KEY_RESULT, {}).get(DayCompletionResultScript.KEY_RESULT, {}).get("date", "")) == "2016-07-01", "completed day should keep last result")


func _verify_game_over_and_clear_guards() -> void:
	var cash_zero = PlayerStatusScript.new()
	cash_zero.cash = 0
	var over_guard := GameDayCompletionGuardScript.evaluate({"date": "2016-07-01"}, false, {}, cash_zero, false, 0)
	_expect(not bool(over_guard.get(GameDayCompletionGuardScript.KEY_ALLOWED, true)), "game over should block completion")
	_expect(String(over_guard.get(GameDayCompletionGuardScript.KEY_RESULT, {}).get("error", "")) == "game_over", "game over should return game_over error")
	_expect(String(over_guard.get(GameDayCompletionGuardScript.KEY_RESULT, {}).get("game_over_reason", "")) == "cash_zero", "game over should include reason")

	var clear = PlayerStatusScript.new()
	clear.cash = PlayerStatusScript.TARGET_NET_WORTH
	var clear_guard := GameDayCompletionGuardScript.evaluate({"date": "2016-07-01"}, false, {}, clear, false, 0)
	_expect(bool(clear_guard.get(GameDayCompletionGuardScript.KEY_ALLOWED, false)), "target reached before the final day should not block completion")
	_expect(Dictionary(clear_guard.get(GameDayCompletionGuardScript.KEY_RESULT, {})).is_empty(), "target-reached guard should return empty result before final ending")


func _verify_first_tutorial_stock_guard() -> void:
	var status = PlayerStatusScript.new()
	var blocked := GameDayCompletionGuardScript.evaluate({"date": "2016-07-01"}, false, {}, status, true, 0)
	_expect(not bool(blocked.get(GameDayCompletionGuardScript.KEY_ALLOWED, true)), "first tutorial day should block without stock")
	_expect(String(blocked.get(GameDayCompletionGuardScript.KEY_RESULT, {}).get("error", "")) == "first_day_stock_required", "first tutorial day should require stock")
	_expect(int(blocked.get(GameDayCompletionGuardScript.KEY_RESULT, {}).get(DayCompletionResultScript.KEY_HELD_QUANTITY, -1)) == 0, "first tutorial guard should preserve held quantity")

	var allowed := GameDayCompletionGuardScript.evaluate({"date": "2016-07-01"}, false, {}, status, true, 1)
	_expect(bool(allowed.get(GameDayCompletionGuardScript.KEY_ALLOWED, false)), "first tutorial day should allow one held share")


func _verify_allowed_day() -> void:
	var status = PlayerStatusScript.new()
	var guard := GameDayCompletionGuardScript.evaluate({"date": "2016-07-02"}, false, {}, status, false, 0)
	_expect(bool(guard.get(GameDayCompletionGuardScript.KEY_ALLOWED, false)), "normal healthy day should allow completion")
	_expect(guard.get(GameDayCompletionGuardScript.KEY_RESULT, {}).is_empty(), "allowed guard should return empty result")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
