class_name MarketStockDisplayText
extends RefCounted

const MarketStockRowConfigScript := preload("res://scripts/ui/market_stock_row_config.gd")
const MarketUiFormat := preload("res://scripts/ui/market_ui_format.gd")


static func display_name(stock: Dictionary) -> String:
	var name := String(stock.get(MarketStockRowConfigScript.KEY_DISPLAY_NAME, MarketStockRowConfigScript.EMPTY_TEXT))
	if name.is_empty():
		name = String(stock.get(MarketStockRowConfigScript.KEY_NAME_KO, MarketStockRowConfigScript.EMPTY_TEXT))
	if name.is_empty():
		name = String(stock.get(MarketStockRowConfigScript.KEY_NAME, MarketStockRowConfigScript.EMPTY_TEXT))
	return name


static func title(stock: Dictionary) -> String:
	var ticker := String(stock.get(MarketStockRowConfigScript.KEY_TICKER, MarketStockRowConfigScript.EMPTY_TEXT))
	var name := display_name(stock)
	if name.is_empty():
		return ticker
	return name


static func price_line(stock: Dictionary) -> String:
	return "시가 %s  전일종가 %s  등락 %s" % [
		MarketUiFormat.format_won(int(stock.get(MarketStockRowConfigScript.KEY_OPEN, MarketStockRowConfigScript.DEFAULT_NUMBER))),
		_previous_close_text(int(stock.get(MarketStockRowConfigScript.KEY_PREVIOUS_CLOSE, MarketStockRowConfigScript.DEFAULT_NUMBER))),
		MarketUiFormat.format_pct(float(stock.get(MarketStockRowConfigScript.KEY_CHANGE_RATE, MarketStockRowConfigScript.DEFAULT_RATE)))
	]


static func holding_line(stock: Dictionary) -> String:
	return "보유 %s  평균 %s" % [
		quantity(int(stock.get(MarketStockRowConfigScript.KEY_HELD_QUANTITY, MarketStockRowConfigScript.DEFAULT_NUMBER))),
		MarketUiFormat.format_won(int(stock.get(MarketStockRowConfigScript.KEY_AVG_COST, MarketStockRowConfigScript.DEFAULT_NUMBER)))
	]


static func open_price(stock: Dictionary) -> String:
	return MarketUiFormat.format_won(int(stock.get(MarketStockRowConfigScript.KEY_OPEN, MarketStockRowConfigScript.DEFAULT_NUMBER)))


static func change_rate(stock: Dictionary) -> String:
	return MarketUiFormat.format_pct(float(stock.get(MarketStockRowConfigScript.KEY_CHANGE_RATE, MarketStockRowConfigScript.DEFAULT_RATE)))


static func quantity(value: int) -> String:
	return "%d주" % value


static func _previous_close_text(value: int) -> String:
	if value <= 0:
		return "-"
	return MarketUiFormat.format_won(value)
