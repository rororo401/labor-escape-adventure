extends "res://scripts/tests/test_scene_tree.gd"

const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_expect(GameDayProgressKeysScript.KEY_OK == ResultKeysScript.KEY_OK, "sleep progress ok key should use the shared result key")
	_expect(GameDayProgressKeysScript.KEY_ERROR == ResultKeysScript.KEY_ERROR, "sleep progress error key should use the shared result key")
	_expect(GameDayProgressKeysScript.KEY_FROM_DATE == "from_date", "sleep progress from-date key should stay stable")
	_expect(GameDayProgressKeysScript.KEY_TO_DATE == "to_date", "sleep progress to-date key should stay stable")
	_expect(GameDayProgressKeysScript.KEY_TO_WEEKDAY == "to_weekday", "sleep progress to-weekday key should stay stable")
	_expect(GameDayProgressKeysScript.KEY_TODAY == "today", "sleep progress today context key should stay stable")
	_expect(GameDayProgressKeysScript.KEY_PREVIOUS_DAY_RESULT == "previous_day_result", "sleep progress previous-day result key should stay stable")

	print("Game day progress keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
