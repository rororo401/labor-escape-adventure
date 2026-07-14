class_name MarketInteractionState
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketOrderInputScript := preload("res://scripts/ui/market_order_input.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")
const MarketStockSelectionScript := preload("res://scripts/ui/market_stock_selection.gd")


static func stock_selected(market_context: Dictionary, ticker: String) -> Dictionary:
	return {
		MarketScreenStateConfigScript.KEY_SELECTED_STOCK: MarketStockSelectionScript.find_stock(market_context.get(MarketDataKeysScript.KEY_STOCKS, []), ticker)
	}


static func quantity_increased(quantity: int) -> Dictionary:
	return {
		MarketScreenStateConfigScript.KEY_QUANTITY: MarketOrderInputScript.increase_quantity(quantity)
	}


static func quantity_decreased(quantity: int) -> Dictionary:
	return {
		MarketScreenStateConfigScript.KEY_QUANTITY: MarketOrderInputScript.decrease_quantity(quantity)
	}
