class_name MarketRefreshPresenter
extends RefCounted

const MarketRefreshStateConfigScript := preload("res://scripts/ui/market_refresh_state_config.gd")
const MarketScreenRefreshResultConfigScript := preload("res://scripts/ui/market_screen_refresh_result_config.gd")


static func apply(
	hud,
	stock_list_panel,
	order_panel,
	closed_day_panel,
	mode_view,
	refresh_state: Dictionary,
	market_background_path: String,
	closed_day_background_path: String,
	quantity: int
) -> Dictionary:
	if hud != null:
		hud.set_date_text(String(refresh_state.get(MarketRefreshStateConfigScript.KEY_DATE_TEXT, MarketRefreshStateConfigScript.EMPTY_TEXT)))
		var status_text: Dictionary = refresh_state.get(MarketRefreshStateConfigScript.KEY_STATUS_TEXT, {})
		hud.set_status_text(
			String(status_text.get(MarketRefreshStateConfigScript.KEY_STATUS_CASH, MarketRefreshStateConfigScript.EMPTY_TEXT)),
			String(status_text.get(MarketRefreshStateConfigScript.KEY_STATUS_NET_WORTH, MarketRefreshStateConfigScript.EMPTY_TEXT))
		)
		hud.set_status_bars(Dictionary(refresh_state.get(MarketRefreshStateConfigScript.KEY_STATUS_SNAPSHOT, {})))

	var market_open := bool(refresh_state.get(MarketRefreshStateConfigScript.KEY_MARKET_OPEN, MarketRefreshStateConfigScript.DEFAULT_MARKET_OPEN))
	if mode_view != null:
		mode_view.apply_mode(market_open, market_background_path, closed_day_background_path)

	var selected_stock := Dictionary(refresh_state.get(MarketRefreshStateConfigScript.KEY_SELECTED_STOCK, {}))
	if market_open:
		if stock_list_panel != null:
			stock_list_panel.render_stocks(refresh_state.get(MarketRefreshStateConfigScript.KEY_STOCKS, []))
		if order_panel != null:
			order_panel.set_selected_stock(selected_stock, quantity)
	else:
		_apply_closed_day_panel(closed_day_panel, refresh_state)

	return {
		MarketRefreshStateConfigScript.KEY_MARKET_OPEN: market_open,
		MarketScreenRefreshResultConfigScript.KEY_SELECTED_STOCK: selected_stock,
		MarketScreenRefreshResultConfigScript.KEY_COMPLETED_MESSAGE: String(refresh_state.get(
			MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE,
			MarketRefreshStateConfigScript.EMPTY_TEXT
		))
	}


static func _apply_closed_day_panel(closed_day_panel, refresh_state: Dictionary) -> void:
	if closed_day_panel == null:
		return

	var day_text: Dictionary = refresh_state.get(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TEXT, {})
	closed_day_panel.set_day_text(
		String(day_text.get(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TITLE, MarketRefreshStateConfigScript.EMPTY_TEXT)),
		String(day_text.get(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_BODY, MarketRefreshStateConfigScript.EMPTY_TEXT))
	)
	closed_day_panel.set_message(String(refresh_state.get(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_MESSAGE, MarketRefreshStateConfigScript.EMPTY_TEXT)))
