class_name GameStateContext
extends RefCounted

const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")


static func today_context(
	day: Dictionary,
	market_context: Dictionary,
	day_flow_context: Dictionary,
	available_life_actions: Array,
	character_asset_context: Dictionary,
	status_snapshot: Dictionary,
	game_over: bool,
	game_over_reason: String,
	game_clear: bool,
	clear_reason: String
) -> Dictionary:
	if day.is_empty():
		return {}

	var is_trading_day := bool(market_context.get(
		GameStateContextKeysScript.KEY_IS_OPEN,
		day.get(GameStateContextKeysScript.KEY_IS_TRADING_DAY, false)
	))
	return {
		GameStateContextKeysScript.KEY_DATE: day.get(GameStateContextKeysScript.KEY_DATE, ""),
		GameStateContextKeysScript.KEY_WEEKDAY: day.get(GameStateContextKeysScript.KEY_WEEKDAY, ""),
		GameStateContextKeysScript.KEY_IS_TRADING_DAY: is_trading_day,
		GameStateContextKeysScript.KEY_CLOSED_REASON: market_context.get(GameStateContextKeysScript.KEY_CLOSED_REASON, day.get(GameStateContextKeysScript.KEY_REASON, "")),
		GameStateContextKeysScript.KEY_CLOSED_NAME: market_context.get(GameStateContextKeysScript.KEY_CLOSED_NAME, day.get(GameStateContextKeysScript.KEY_NAME, "")),
		GameStateContextKeysScript.KEY_DAY_MODE: day_mode(is_trading_day),
		GameStateContextKeysScript.KEY_MARKET_PHASE_AVAILABLE: is_trading_day,
		GameStateContextKeysScript.KEY_MARKET: market_context,
		GameStateContextKeysScript.KEY_DAY_FLOW: day_flow_context,
		GameStateContextKeysScript.KEY_AVAILABLE_LIFE_ACTIONS: available_life_actions,
		GameStateContextKeysScript.KEY_CHARACTER_ASSETS: character_asset_context,
		GameStateContextKeysScript.KEY_STATUS: status_snapshot,
		GameStateContextKeysScript.KEY_GAME_OVER: game_over,
		GameStateContextKeysScript.KEY_GAME_OVER_REASON: game_over_reason,
		GameStateContextKeysScript.KEY_GAME_CLEAR: game_clear,
		GameStateContextKeysScript.KEY_CLEAR_REASON: clear_reason,
		GameStateContextKeysScript.KEY_GAME_FINISHED: game_over or game_clear
	}


static func day_mode(is_trading_day: bool) -> String:
	return GameStateContextKeysScript.DAY_MODE_MARKET_AND_LIFE if is_trading_day else GameStateContextKeysScript.DAY_MODE_LIFE_ONLY


static func market_context(day: Dictionary, market_snapshot: Dictionary) -> Dictionary:
	if day.is_empty():
		return {}

	var is_trading_day := bool(day.get(GameStateContextKeysScript.KEY_IS_TRADING_DAY, false))
	var context := market_snapshot.duplicate(true)
	context[GameStateContextKeysScript.KEY_CALENDAR_DATE] = day.get(GameStateContextKeysScript.KEY_DATE, "")
	context[GameStateContextKeysScript.KEY_IS_OPEN] = is_trading_day
	context[GameStateContextKeysScript.KEY_CLOSED_REASON] = day.get(GameStateContextKeysScript.KEY_REASON, "")
	context[GameStateContextKeysScript.KEY_CLOSED_NAME] = day.get(GameStateContextKeysScript.KEY_NAME, "")
	context[GameStateContextKeysScript.KEY_PHASE] = market_phase(is_trading_day)
	return context


static func market_phase(is_trading_day: bool) -> String:
	return GameStateContextKeysScript.MARKET_PHASE_MORNING_ORDER if is_trading_day else GameStateContextKeysScript.MARKET_PHASE_CLOSED


static func day_flow_context(base_context: Dictionary, day_completed: bool, last_day_result: Dictionary) -> Dictionary:
	var context := base_context.duplicate(true)
	context[GameStateContextKeysScript.KEY_DAY_COMPLETED] = day_completed
	context[GameStateContextKeysScript.KEY_LAST_DAY_RESULT] = last_day_result.duplicate(true)
	return context


static func report_with_status(report: Dictionary, status_snapshot: Dictionary) -> Dictionary:
	var context := report.duplicate(true)
	context[GameStateContextKeysScript.KEY_STATUS] = status_snapshot.duplicate(true)
	return context
