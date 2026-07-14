class_name MarketOrderInput
extends RefCounted

const MarketOrderInputConfigScript := preload("res://scripts/ui/market_order_input_config.gd")

const MIN_QUANTITY := MarketOrderInputConfigScript.MIN_QUANTITY
const MAX_QUANTITY := MarketOrderInputConfigScript.MAX_QUANTITY


static func normalize_quantity(quantity: int) -> int:
	return clampi(quantity, MIN_QUANTITY, MAX_QUANTITY)


static func increase_quantity(quantity: int) -> int:
	return normalize_quantity(quantity + 1)


static func decrease_quantity(quantity: int) -> int:
	return normalize_quantity(quantity - 1)


static func selected_ticker(stock: Dictionary) -> String:
	return String(stock.get(MarketOrderInputConfigScript.KEY_TICKER, ""))


static func build_order_request(stock: Dictionary, side: String, quantity: int) -> Dictionary:
	var ticker := selected_ticker(stock)
	if ticker.is_empty():
		return {
			MarketOrderInputConfigScript.KEY_OK: false,
			MarketOrderInputConfigScript.KEY_ERROR: MarketOrderInputConfigScript.ERROR_STOCK_NOT_SELECTED
		}
	return {
		MarketOrderInputConfigScript.KEY_OK: true,
		MarketOrderInputConfigScript.KEY_TICKER: ticker,
		MarketOrderInputConfigScript.KEY_SIDE: side,
		MarketOrderInputConfigScript.KEY_QUANTITY: normalize_quantity(quantity)
	}
