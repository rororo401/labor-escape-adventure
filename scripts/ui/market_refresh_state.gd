class_name MarketRefreshState
extends RefCounted

const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const GameDateFormatterScript := preload("res://scripts/core/game_date_formatter.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketRefreshStateConfigScript := preload("res://scripts/ui/market_refresh_state_config.gd")
const MarketReportStateScript := preload("res://scripts/ui/market_report_state.gd")
const MarketStockSelectionScript := preload("res://scripts/ui/market_stock_selection.gd")


static func build(game, market_context: Dictionary, selected_stock: Dictionary, showing_close_report: bool) -> Dictionary:
	if game == null:
		return {
			MarketRefreshStateConfigScript.KEY_MARKET_OPEN: MarketRefreshStateConfigScript.DEFAULT_MARKET_OPEN,
			MarketRefreshStateConfigScript.KEY_DATE_TEXT: MarketRefreshStateConfigScript.EMPTY_TEXT,
			MarketRefreshStateConfigScript.KEY_STATUS_TEXT: MarketReportStateScript.status_texts(null, market_context, showing_close_report),
			MarketRefreshStateConfigScript.KEY_STATUS_SNAPSHOT: {},
			MarketRefreshStateConfigScript.KEY_SELECTED_STOCK: {},
			MarketRefreshStateConfigScript.KEY_STOCKS: [],
			MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TEXT: MarketDayFlowTextScript.closed_day_text(market_context),
			MarketRefreshStateConfigScript.KEY_CLOSED_DAY_MESSAGE: MarketRefreshStateConfigScript.EMPTY_TEXT,
			MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE: MarketRefreshStateConfigScript.EMPTY_TEXT
		}

	var today: Dictionary = game.get_today_context()
	var market_open := bool(market_context.get(GameStateContextKeysScript.KEY_IS_OPEN, false))
	var stocks: Array = market_context.get(MarketDataKeysScript.KEY_STOCKS, [])
	var resolved_stock := MarketStockSelectionScript.resolve_after_refresh(stocks, selected_stock) if market_open else {}
	return {
		MarketRefreshStateConfigScript.KEY_MARKET_OPEN: market_open,
		MarketRefreshStateConfigScript.KEY_DATE_TEXT: GameDateFormatterScript.market_phase_label(today, game.day_completed),
		MarketRefreshStateConfigScript.KEY_STATUS_TEXT: MarketReportStateScript.status_texts(game, market_context, showing_close_report),
		MarketRefreshStateConfigScript.KEY_STATUS_SNAPSHOT: game.status.to_dict(),
		MarketRefreshStateConfigScript.KEY_SELECTED_STOCK: resolved_stock,
		MarketRefreshStateConfigScript.KEY_STOCKS: stocks,
		MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TEXT: MarketDayFlowTextScript.closed_day_text(market_context),
		MarketRefreshStateConfigScript.KEY_CLOSED_DAY_MESSAGE: MarketRefreshStateConfigScript.EMPTY_TEXT if not game.day_completed else MarketDayFlowTextScript.format_day_result(game.last_day_result),
		MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE: MarketReportStateScript.completed_day_message(game)
	}
