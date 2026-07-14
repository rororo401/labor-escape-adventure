class_name MarketStockSelection
extends RefCounted

const MarketStockRowConfigScript := preload("res://scripts/ui/market_stock_row_config.gd")


static func find_stock(stocks: Array, ticker: String) -> Dictionary:
	for stock in stocks:
		var stock_data: Dictionary = Dictionary(stock)
		if String(stock_data.get(MarketStockRowConfigScript.KEY_TICKER, MarketStockRowConfigScript.EMPTY_TEXT)) == ticker:
			return stock_data
	return {}


static func resolve_after_refresh(stocks: Array, current_selection: Dictionary) -> Dictionary:
	if stocks.is_empty():
		return {}
	if current_selection.is_empty():
		return Dictionary(stocks[0])
	return find_stock(stocks, String(current_selection.get(MarketStockRowConfigScript.KEY_TICKER, MarketStockRowConfigScript.EMPTY_TEXT)))
