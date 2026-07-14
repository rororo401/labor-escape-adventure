class_name MarketOrderFlow
extends RefCounted

const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketOrderFlowConfigScript := preload("res://scripts/ui/market_order_flow_config.gd")
const MarketOrderInputScript := preload("res://scripts/ui/market_order_input.gd")


static func submit(game, selected_stock: Dictionary, side: String, quantity: int) -> Dictionary:
	var request := MarketOrderInputScript.build_order_request(selected_stock, side, quantity)
	if not bool(request.get(MarketOrderFlowConfigScript.KEY_OK, false)):
		return {
			MarketOrderFlowConfigScript.KEY_HANDLED: false,
			MarketOrderFlowConfigScript.KEY_REQUEST: request
		}

	var result: Dictionary
	if game == null:
		result = {
			MarketOrderFlowConfigScript.KEY_OK: false,
			MarketOrderFlowConfigScript.KEY_ERROR: MarketOrderFlowConfigScript.ERROR_GAME_NOT_STARTED
		}
	else:
		result = game.submit_market_order(
			String(request.get(MarketOrderFlowConfigScript.KEY_TICKER, "")),
			String(request.get(MarketOrderFlowConfigScript.KEY_SIDE, "")),
			int(request.get(MarketOrderFlowConfigScript.KEY_QUANTITY, MarketOrderFlowConfigScript.DEFAULT_QUANTITY))
		)

	return {
		MarketOrderFlowConfigScript.KEY_HANDLED: true,
		MarketOrderFlowConfigScript.KEY_REQUEST: request,
		MarketOrderFlowConfigScript.KEY_RESULT: result,
		MarketOrderFlowConfigScript.KEY_STATE: MarketOrderFlowConfigScript.post_order_state(),
		MarketOrderFlowConfigScript.KEY_MESSAGE: _message_for_result(side, int(request.get(MarketOrderFlowConfigScript.KEY_QUANTITY, MarketOrderFlowConfigScript.DEFAULT_QUANTITY)), result)
	}


static func _message_for_result(side: String, quantity: int, result: Dictionary) -> String:
	if result.get(MarketOrderFlowConfigScript.KEY_OK, false):
		return MarketDayFlowTextScript.order_success_message(side, quantity, int(result.get(MarketOrderFlowConfigScript.KEY_PRICE, 0)))
	return MarketDayFlowTextScript.order_error_message(String(result.get(MarketOrderFlowConfigScript.KEY_ERROR, "")))
