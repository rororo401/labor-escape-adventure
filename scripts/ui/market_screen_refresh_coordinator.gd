class_name MarketScreenRefreshCoordinator
extends RefCounted

const MarketRefreshPresenterScript := preload("res://scripts/ui/market_refresh_presenter.gd")
const MarketRefreshStateScript := preload("res://scripts/ui/market_refresh_state.gd")
const MarketScreenRefreshResultConfigScript := preload("res://scripts/ui/market_screen_refresh_result_config.gd")


static func refresh(
	game,
	runtime_state,
	hud,
	stock_list_panel,
	order_panel,
	closed_day_panel,
	mode_view,
	market_background_path: String,
	closed_day_background_path: String
) -> Dictionary:
	var market_context := {}
	if game != null:
		market_context = game.get_market_context()

	var selected_stock := {} if runtime_state == null else Dictionary(runtime_state.selected_stock)
	var showing_close_report := false if runtime_state == null else bool(runtime_state.showing_close_report)
	var quantity := 1 if runtime_state == null else int(runtime_state.quantity)
	var refresh_state := MarketRefreshStateScript.build(game, market_context, selected_stock, showing_close_report)
	var presentation := MarketRefreshPresenterScript.apply(
		hud,
		stock_list_panel,
		order_panel,
		closed_day_panel,
		mode_view,
		refresh_state,
		market_background_path,
		closed_day_background_path,
		quantity
	)
	var resolved_stock := Dictionary(presentation.get(MarketScreenRefreshResultConfigScript.KEY_SELECTED_STOCK, {}))
	if runtime_state != null:
		runtime_state.selected_stock = resolved_stock

	return {
		MarketScreenRefreshResultConfigScript.KEY_MARKET_CONTEXT: market_context,
		MarketScreenRefreshResultConfigScript.KEY_PRESENTATION: presentation,
		MarketScreenRefreshResultConfigScript.KEY_SELECTED_STOCK: resolved_stock,
		MarketScreenRefreshResultConfigScript.KEY_COMPLETED_MESSAGE: String(presentation.get(
			MarketScreenRefreshResultConfigScript.KEY_COMPLETED_MESSAGE,
			MarketScreenRefreshResultConfigScript.EMPTY_MESSAGE
		))
	}
