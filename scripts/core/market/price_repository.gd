class_name PriceRepository
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")

var _prices_by_ticker := {}


func load_ticker(ticker: String, path: String) -> bool:
	if ticker.is_empty() or path.is_empty():
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open price CSV: %s" % path)
		return false

	var rows := {}
	var header := file.get_csv_line()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() < 6 or String(row[0]).is_empty():
			continue

		var date := String(row[0])
		rows[date] = {
			MarketDataKeysScript.KEY_TICKER: ticker,
			MarketDataKeysScript.KEY_DATE: date,
			MarketDataKeysScript.KEY_OPEN: int(float(row[1])),
			MarketDataKeysScript.KEY_HIGH: int(float(row[2])),
			MarketDataKeysScript.KEY_LOW: int(float(row[3])),
			MarketDataKeysScript.KEY_CLOSE: int(float(row[4])),
			MarketDataKeysScript.KEY_VOLUME: int(float(row[5])),
			MarketDataKeysScript.KEY_FOREIGN_OWNERSHIP_RATIO: float(row[6]) if row.size() > 6 and not String(row[6]).is_empty() else 0.0
		}

	_prices_by_ticker[ticker] = rows
	return not rows.is_empty()


func has_ticker(ticker: String) -> bool:
	return _prices_by_ticker.has(ticker)


func get_price(ticker: String, date: String) -> Dictionary:
	return _prices_by_ticker.get(ticker, {}).get(date, {})


func has_price(ticker: String, date: String) -> bool:
	return not get_price(ticker, date).is_empty()


func get_close(ticker: String, date: String) -> int:
	return int(get_price(ticker, date).get(MarketDataKeysScript.KEY_CLOSE, 0))


func get_open(ticker: String, date: String) -> int:
	return int(get_price(ticker, date).get(MarketDataKeysScript.KEY_OPEN, 0))
