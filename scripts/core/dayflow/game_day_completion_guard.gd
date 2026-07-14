class_name GameDayCompletionGuard
extends RefCounted

const DayCompletionResultScript := preload("res://scripts/core/dayflow/day_completion_result.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const KEY_ALLOWED := "allowed"
const KEY_RESULT := ResultKeysScript.KEY_RESULT


static func evaluate(
	day: Dictionary,
	day_completed: bool,
	last_day_result: Dictionary,
	status,
	first_tutorial_day: bool,
	total_held_quantity: int
) -> Dictionary:
	if day.is_empty():
		return blocked(GameStateGuardResultScript.calendar_day_missing())
	if day_completed:
		return blocked(DayCompletionResultScript.day_already_completed(last_day_result))
	if status.is_game_over():
		return blocked(GameStateGuardResultScript.game_over(status.to_dict(), status.get_game_over_reason()))
	if first_tutorial_day and total_held_quantity < 1:
		return blocked(DayCompletionResultScript.first_day_stock_required(total_held_quantity))
	return {
		KEY_ALLOWED: true,
		KEY_RESULT: {}
	}


static func blocked(result: Dictionary) -> Dictionary:
	return {
		KEY_ALLOWED: false,
		KEY_RESULT: result
	}
