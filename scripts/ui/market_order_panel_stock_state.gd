class_name MarketOrderPanelStockState
extends RefCounted

const MarketOrderPanelStockStateConfigScript := preload("res://scripts/ui/market_order_panel_stock_state_config.gd")
const MarketStockDisplayTextScript := preload("res://scripts/ui/market_stock_display_text.gd")


static func selected_stock_texts(stock: Dictionary, quantity: int) -> Dictionary:
	if stock.is_empty():
		return {
			MarketOrderPanelStockStateConfigScript.KEY_NAME: MarketOrderPanelStockStateConfigScript.EMPTY_STOCK_NAME,
			MarketOrderPanelStockStateConfigScript.KEY_PRICE: MarketOrderPanelStockStateConfigScript.EMPTY_TEXT,
			MarketOrderPanelStockStateConfigScript.KEY_HOLDING: MarketOrderPanelStockStateConfigScript.EMPTY_TEXT,
			MarketOrderPanelStockStateConfigScript.KEY_QUANTITY: MarketStockDisplayTextScript.quantity(quantity)
		}

	return {
		MarketOrderPanelStockStateConfigScript.KEY_NAME: MarketStockDisplayTextScript.title(stock),
		MarketOrderPanelStockStateConfigScript.KEY_PRICE: MarketStockDisplayTextScript.price_line(stock),
		MarketOrderPanelStockStateConfigScript.KEY_HOLDING: MarketStockDisplayTextScript.holding_line(stock),
		MarketOrderPanelStockStateConfigScript.KEY_QUANTITY: MarketStockDisplayTextScript.quantity(quantity)
	}
