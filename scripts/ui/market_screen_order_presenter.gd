class_name MarketScreenOrderPresenter
extends RefCounted

const MarketOrderFlowScript := preload("res://scripts/ui/market_order_flow.gd")
const MarketOrderFlowConfigScript := preload("res://scripts/ui/market_order_flow_config.gd")
const MarketScreenPanelFeedbackScript := preload("res://scripts/ui/market_screen_panel_feedback.gd")


static func submit_order(
	selected_stock: Dictionary,
	quantity: int,
	apply_state: Callable,
	order_panel,
	closed_day_panel,
	game,
	side: String
) -> Dictionary:
	var flow := MarketOrderFlowScript.submit(game, selected_stock, side, quantity)
	if not bool(flow.get(MarketOrderFlowConfigScript.KEY_HANDLED, false)):
		return flow

	var state: Dictionary = flow.get(MarketOrderFlowConfigScript.KEY_STATE, {})
	if apply_state.is_valid():
		apply_state.call(state)
	MarketScreenPanelFeedbackScript.set_flow_message(
		order_panel,
		closed_day_panel,
		String(flow.get(MarketOrderFlowConfigScript.KEY_MESSAGE, ""))
	)
	return flow
