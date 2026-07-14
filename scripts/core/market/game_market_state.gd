class_name GameMarketState
extends RefCounted

const GameStateContextScript := preload("res://scripts/core/game_state_context.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const GameEndingScript := preload("res://scripts/core/game_ending.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventRuleResolverScript := preload("res://scripts/core/dayflow/day_event_rule_resolver.gd")

const SUMMER_VACATION_CLOSED_REASON := "summer_vacation"
const SUMMER_VACATION_CLOSED_NAME := "여름휴가"


static func get_market_context(game, limit: int = 30) -> Dictionary:
	var day: Dictionary = game.calendar.get_day(game.day_index)
	if day.is_empty():
		return {}

	var date := pricing_date_for_day(game, day)
	var previous_trading_date := previous_trading_date(game)
	var snapshot: Dictionary = game.market.get_market_snapshot(date, previous_trading_date, limit)
	var context := GameStateContextScript.market_context(_market_day_for_context(game, day), snapshot)
	context[DayEventKeysScript.KEY_MARKET_FIXED_EVENT] = (
		game.day_events.get_market_fixed_event(day) if _is_market_open_for_day(game, day) else {}
	)
	return context


static func submit_market_order(game, ticker: String, side: String, quantity: int) -> Dictionary:
	var day: Dictionary = game.calendar.get_day(game.day_index)
	if day.is_empty():
		return GameStateGuardResultScript.calendar_day_missing()

	if game.status.is_game_over():
		return GameStateGuardResultScript.game_over(GameEndingScript.status_snapshot(game), game.status.get_game_over_reason())
	if GameEndingScript.is_game_clear(game):
		return GameStateGuardResultScript.game_clear(GameEndingScript.status_snapshot(game), GameEndingScript.clear_reason(game))
	if GameEndingScript.is_final_bad_ending(game):
		return GameStateGuardResultScript.game_over(GameEndingScript.status_snapshot(game), GameEndingScript.game_over_reason(game), GameEndingScript.active_ending_state(game))

	var result: Dictionary = game.market.submit_order(
		String(day.get(MarketDataKeysScript.KEY_DATE, "")),
		_is_market_open_for_day(game, day),
		ticker,
		side,
		quantity
	)
	if bool(result.get(MarketDataKeysScript.KEY_OK, false)):
		sync_status_from_market(game, pricing_date_for_day(game, day))
	result[MarketDataKeysScript.KEY_STATUS] = GameEndingScript.status_snapshot(game)
	return result


static func get_market_close_report(game) -> Dictionary:
	var day: Dictionary = game.calendar.get_day(game.day_index)
	if day.is_empty():
		return {}

	var report: Dictionary = game.market.get_close_report(pricing_date_for_day(game, day))
	sync_status_from_report(game, report)
	return GameStateContextScript.report_with_status(report, GameEndingScript.status_snapshot(game))


static func get_market_open_report(game) -> Dictionary:
	var day: Dictionary = game.calendar.get_day(game.day_index)
	if day.is_empty():
		return {}

	var report: Dictionary = game.market.get_open_report(pricing_date_for_day(game, day))
	return GameStateContextScript.report_with_status(report, GameEndingScript.status_snapshot(game))


static func current_phase_report(game) -> Dictionary:
	var day: Dictionary = game.calendar.get_day(game.day_index)
	if day.is_empty():
		return {}
	if bool(game.day_completed):
		return game.market.get_close_report(pricing_date_for_day(game, day))
	return game.market.get_open_report(pricing_date_for_day(game, day))


static func sync_status_from_market(game, date: String) -> void:
	var report: Dictionary = game.market.get_open_report(date)
	sync_status_from_report(game, report)


static func sync_status_from_report(game, report: Dictionary) -> void:
	game.status.cash = int(report.get(MarketDataKeysScript.KEY_CASH, game.status.cash))
	game.status.investment_assets = int(report.get(MarketDataKeysScript.KEY_INVESTMENT_ASSETS, game.status.investment_assets))


static func previous_trading_date(game) -> String:
	for index in range(game.day_index - 1, -1, -1):
		var day: Dictionary = game.calendar.get_day(index)
		if _is_market_open_for_day(game, day):
			return String(day.get(MarketDataKeysScript.KEY_DATE, ""))
	return ""


static func pricing_date_for_day(game, day: Dictionary) -> String:
	if _is_market_open_for_day(game, day):
		return String(day.get(MarketDataKeysScript.KEY_DATE, ""))
	return previous_trading_date(game)


static func _is_market_open_for_day(game, day: Dictionary) -> bool:
	return bool(day.get(MarketDataKeysScript.KEY_IS_TRADING_DAY, false)) and not DayEventRuleResolverScript.is_summer_vacation(game.day_events.rules, day)


static func _market_day_for_context(game, day: Dictionary) -> Dictionary:
	if not DayEventRuleResolverScript.is_summer_vacation(game.day_events.rules, day):
		return day
	var market_day := day.duplicate(true)
	market_day[MarketDataKeysScript.KEY_IS_TRADING_DAY] = false
	market_day[DayEventKeysScript.KEY_REASON] = SUMMER_VACATION_CLOSED_REASON
	market_day[DayEventKeysScript.KEY_NAME] = SUMMER_VACATION_CLOSED_NAME
	return market_day
