class_name MarketFlowControlsPresenter
extends RefCounted

const MarketFlowControlStateConfigScript := preload("res://scripts/ui/market_flow_control_state_config.gd")
const MarketOrderPanelConfigScript := preload("res://scripts/ui/market_order_panel_config.gd")


static func apply(order_panel, closed_day_panel, state: Dictionary) -> void:
	if order_panel != null:
		order_panel.update_trade_buttons(bool(state.get(MarketFlowControlStateConfigScript.KEY_CAN_TRADE, MarketFlowControlStateConfigScript.DEFAULT_CAN_TRADE)))
		var order_flow: Dictionary = state.get(MarketFlowControlStateConfigScript.KEY_ORDER_FLOW, {})
		order_panel.update_flow_button(
			bool(order_flow.get(MarketFlowControlStateConfigScript.KEY_GAME_FINISHED, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(order_flow.get(MarketFlowControlStateConfigScript.KEY_GAME_CLEAR, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(order_flow.get(MarketFlowControlStateConfigScript.KEY_GAME_OVER, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(order_flow.get(MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(order_flow.get(MarketFlowControlStateConfigScript.KEY_SLEEP_SEQUENCE, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			String(order_flow.get(MarketFlowControlStateConfigScript.KEY_READY_TEXT, MarketOrderPanelConfigScript.DEFAULT_FLOW_TEXT))
		)

	if closed_day_panel != null:
		var closed_flow: Dictionary = state.get(MarketFlowControlStateConfigScript.KEY_CLOSED_FLOW, {})
		closed_day_panel.update_flow_button(
			bool(closed_flow.get(MarketFlowControlStateConfigScript.KEY_GAME_FINISHED, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(closed_flow.get(MarketFlowControlStateConfigScript.KEY_GAME_CLEAR, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(closed_flow.get(MarketFlowControlStateConfigScript.KEY_GAME_OVER, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(closed_flow.get(MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(closed_flow.get(MarketFlowControlStateConfigScript.KEY_SLEEP_SEQUENCE, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(closed_flow.get(MarketFlowControlStateConfigScript.KEY_COMPLETING_DAY, MarketFlowControlStateConfigScript.DEFAULT_FLOW_FLAG)),
			bool(closed_flow.get(MarketFlowControlStateConfigScript.KEY_HAS_SELECTION, MarketFlowControlStateConfigScript.DEFAULT_HAS_SELECTION))
		)
