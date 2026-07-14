class_name GameDayProgress
extends RefCounted

const DayCompletionResultScript := preload("res://scripts/core/dayflow/day_completion_result.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const GameEndingScript := preload("res://scripts/core/game_ending.gd")


static func sleep_to_next_day(game) -> Dictionary:
	if not bool(game.day_completed):
		return DayCompletionResultScript.day_not_completed()
	if game.status.is_game_over():
		return GameStateGuardResultScript.game_over(GameEndingScript.status_snapshot(game), game.status.get_game_over_reason())
	if GameEndingScript.is_game_clear(game):
		return GameStateGuardResultScript.game_clear(GameEndingScript.status_snapshot(game), GameEndingScript.clear_reason(game), GameEndingScript.active_ending_state(game))
	if GameEndingScript.is_final_bad_ending(game):
		return GameStateGuardResultScript.game_over(GameEndingScript.status_snapshot(game), GameEndingScript.game_over_reason(game), GameEndingScript.active_ending_state(game))

	var from_day: Dictionary = game.calendar.get_day(game.day_index)
	var previous_day_result := Dictionary(game.last_day_result).duplicate(true)
	advance_day(game)
	game.day_completed = false
	game.last_day_result = {}
	var to_day: Dictionary = game.calendar.get_day(game.day_index)
	return {
		GameDayProgressKeysScript.KEY_OK: true,
		GameDayProgressKeysScript.KEY_FROM_DATE: from_day.get(DayEventKeysScript.KEY_DATE, ""),
		GameDayProgressKeysScript.KEY_TO_DATE: to_day.get(DayEventKeysScript.KEY_DATE, ""),
		GameDayProgressKeysScript.KEY_TO_WEEKDAY: to_day.get(DayEventKeysScript.KEY_WEEKDAY, ""),
		GameDayProgressKeysScript.KEY_TODAY: game.get_today_context(),
		GameDayProgressKeysScript.KEY_PREVIOUS_DAY_RESULT: previous_day_result
	}


static func advance_day(game) -> void:
	game.day_index = mini(game.day_index + 1, game.calendar.count() - 1)
	game.completed_days += 1
