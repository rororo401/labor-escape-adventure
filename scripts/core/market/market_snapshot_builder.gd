class_name MarketSnapshotBuilder
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")


static func build(
	companies: Array,
	price_repository,
	portfolio,
	date: String,
	previous_trading_date: String = "",
	limit: int = 30
) -> Dictionary:
	var rows: Array[Dictionary] = []
	for company in companies:
		if rows.size() >= limit:
			break
		if typeof(company) != TYPE_DICTIONARY:
			continue

		var ticker := String(Dictionary(company).get(MarketDataKeysScript.KEY_TICKER, ""))
		var price: Dictionary = price_repository.get_price(ticker, date)
		if price.is_empty():
			continue

		var previous_close: int = price_repository.get_close(ticker, previous_trading_date) if not previous_trading_date.is_empty() else 0
		rows.append(row(Dictionary(company), price, previous_close, portfolio.get_position(ticker)))

	return {
		MarketDataKeysScript.KEY_DATE: date,
		MarketDataKeysScript.KEY_PREVIOUS_TRADING_DATE: previous_trading_date,
		MarketDataKeysScript.KEY_STOCKS: rows,
		MarketDataKeysScript.KEY_PORTFOLIO: portfolio.to_dict()
	}


static func row(company: Dictionary, price: Dictionary, previous_close: int, position: Dictionary) -> Dictionary:
	var open_price := int(price.get(MarketDataKeysScript.KEY_OPEN, 0))
	return {
		MarketDataKeysScript.KEY_TICKER: String(company.get(MarketDataKeysScript.KEY_TICKER, "")),
		MarketDataKeysScript.KEY_NAME_KO: company.get(MarketDataKeysScript.KEY_NAME_KO, ""),
		MarketDataKeysScript.KEY_SECTOR_HINT: company.get(MarketDataKeysScript.KEY_SECTOR_HINT, ""),
		MarketDataKeysScript.KEY_OPEN: open_price,
		MarketDataKeysScript.KEY_PREVIOUS_CLOSE: previous_close,
		MarketDataKeysScript.KEY_CHANGE_RATE: change_rate(open_price, previous_close),
		MarketDataKeysScript.KEY_HELD_QUANTITY: int(position.get(MarketDataKeysScript.KEY_QUANTITY, 0)),
		MarketDataKeysScript.KEY_AVG_COST: int(position.get(MarketDataKeysScript.KEY_AVG_COST, 0))
	}


static func change_rate(open_price: int, previous_close: int) -> float:
	if previous_close <= 0:
		return 0.0
	return (float(open_price - previous_close) / float(previous_close)) * 100.0
