class_name DayCompletionResult
extends RefCounted

const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const ERROR_DAY_ALREADY_COMPLETED := "day_already_completed"
const ERROR_FIRST_DAY_STOCK_REQUIRED := "first_day_stock_required"
const ERROR_DAY_NOT_COMPLETED := "day_not_completed"
const KEY_RESULT := ResultKeysScript.KEY_RESULT
const KEY_REQUIRED_QUANTITY := "required_quantity"
const KEY_HELD_QUANTITY := MarketDataKeysScript.KEY_HELD_QUANTITY


static func error(error_id: String, extra: Dictionary = {}) -> Dictionary:
	return GameStateGuardResultScript.error(error_id, extra)


static func calendar_day_missing() -> Dictionary:
	return GameStateGuardResultScript.calendar_day_missing()


static func day_already_completed(last_day_result: Dictionary) -> Dictionary:
	return error(ERROR_DAY_ALREADY_COMPLETED, {
		KEY_RESULT: last_day_result
	})


static func game_over(status_snapshot: Dictionary, reason: String) -> Dictionary:
	return GameStateGuardResultScript.game_over(status_snapshot, reason)


static func game_clear(status_snapshot: Dictionary, reason: String) -> Dictionary:
	return GameStateGuardResultScript.game_clear(status_snapshot, reason)


static func first_day_stock_required(held_quantity: int, required_quantity: int = 1) -> Dictionary:
	return error(ERROR_FIRST_DAY_STOCK_REQUIRED, {
		KEY_REQUIRED_QUANTITY: required_quantity,
		KEY_HELD_QUANTITY: held_quantity
	})


static func day_not_completed() -> Dictionary:
	return error(ERROR_DAY_NOT_COMPLETED)


static func empty_effect(status_snapshot: Dictionary) -> Dictionary:
	return {
		PlayerStatusKeysScript.KEY_BEFORE: status_snapshot.duplicate(true),
		PlayerStatusKeysScript.KEY_AFTER: status_snapshot.duplicate(true),
		PlayerStatusKeysScript.KEY_DELTA: {
			PlayerStatusKeysScript.KEY_CASH: 0,
			PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: 0,
			PlayerStatusKeysScript.KEY_HEALTH: 0,
			PlayerStatusKeysScript.KEY_MOOD: 0,
			PlayerStatusKeysScript.KEY_FATIGUE: 0
		}
	}


static func event_effect_row(event: Dictionary, effect: Dictionary) -> Dictionary:
	return {
		DayEventKeysScript.KEY_EVENT: event,
		DayEventKeysScript.KEY_EFFECT: effect
	}


static func payload(
	day: Dictionary,
	day_action: Dictionary,
	day_effect: Dictionary,
	weekday_effects: Array,
	night_effects: Array,
	end_of_day_effect: Dictionary,
	close_report: Dictionary,
	status_snapshot: Dictionary,
	game_over: bool,
	game_over_reason: String,
	game_clear: bool,
	clear_reason: String,
	ending_state: Dictionary = {},
	market_fixed_effect: Dictionary = {},
	leverage_bonus_effect: Dictionary = {}
) -> Dictionary:
	var is_trading_day := bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false))
	var result := {
		DayEventKeysScript.KEY_OK: true,
		DayEventKeysScript.KEY_DATE: day.get(DayEventKeysScript.KEY_DATE, ""),
		DayEventKeysScript.KEY_WEEKDAY: day.get(DayEventKeysScript.KEY_WEEKDAY, ""),
		DayEventKeysScript.KEY_IS_TRADING_DAY: is_trading_day,
		DayEventKeysScript.KEY_MARKET: {
			DayEventKeysScript.KEY_IS_OPEN: is_trading_day,
			DayEventKeysScript.KEY_PHASE_AVAILABLE: is_trading_day
		},
		DayEventKeysScript.KEY_DAY_ACTION: event_effect_row(day_action, day_effect),
		DayEventKeysScript.KEY_WEEKDAY_EVENTS: weekday_effects,
		DayEventKeysScript.KEY_NIGHT_EVENTS: night_effects,
		DayEventKeysScript.KEY_MARKET_FIXED_EFFECT: market_fixed_effect,
		DayEventKeysScript.KEY_LEVERAGE_BONUS_EFFECT: leverage_bonus_effect,
		DayEventKeysScript.KEY_END_OF_DAY_EFFECT: end_of_day_effect,
		DayEventKeysScript.KEY_MARKET_CLOSE_REPORT: close_report,
		DayEventKeysScript.KEY_STATUS: status_snapshot,
		PlayerStatusKeysScript.KEY_GAME_OVER: game_over,
		PlayerStatusKeysScript.KEY_GAME_OVER_REASON: game_over_reason,
		PlayerStatusKeysScript.KEY_GAME_CLEAR: game_clear,
		PlayerStatusKeysScript.KEY_CLEAR_REASON: clear_reason,
		DayEventKeysScript.KEY_GAME_FINISHED: game_over or game_clear,
		DayEventKeysScript.KEY_SLEEP_REQUIRED: not game_over and not game_clear
	}
	result.merge(ending_state, true)
	return result
