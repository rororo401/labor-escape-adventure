class_name MarketReportState
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")


static func should_use_close_report(game, showing_close_report: bool) -> bool:
	return showing_close_report or (game != null and bool(game.day_completed))


static func valuation_report(game, showing_close_report: bool) -> Dictionary:
	if game == null:
		return {}
	if should_use_close_report(game, showing_close_report):
		return game.get_market_close_report()
	return game.get_market_open_report()


static func status_texts(game, market_context: Dictionary, showing_close_report: bool) -> Dictionary:
	return MarketDayFlowTextScript.status_texts(
		Dictionary(market_context.get(MarketDataKeysScript.KEY_PORTFOLIO, {})),
		valuation_report(game, showing_close_report)
	)


static func completed_day_message(game) -> String:
	if game == null or not bool(game.day_completed) or Dictionary(game.last_day_result).is_empty():
		return ""
	return MarketDayFlowTextScript.format_day_result(Dictionary(game.last_day_result))
