class_name PortfolioSnapshot
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")


static func to_dict(cash: int, realized_profit: int, positions: Dictionary) -> Dictionary:
	var position_rows: Array[Dictionary] = []
	for ticker in positions.keys():
		var position := normalize_position(Dictionary(positions[ticker]))
		if not position.is_empty():
			position_rows.append(position)
	return {
		MarketDataKeysScript.KEY_CASH: cash,
		MarketDataKeysScript.KEY_POSITIONS: position_rows,
		MarketDataKeysScript.KEY_REALIZED_PROFIT: realized_profit
	}


static func load_positions(data: Dictionary) -> Dictionary:
	var restored := {}
	for item in data.get(MarketDataKeysScript.KEY_POSITIONS, []):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var position := normalize_position(Dictionary(item))
		if position.is_empty():
			continue
		restored[String(position.get(MarketDataKeysScript.KEY_TICKER, ""))] = position
	return restored


static func normalize_cash(value) -> int:
	return maxi(0, int(value))


static func normalize_realized_profit(value) -> int:
	return int(value)


static func normalize_position(position: Dictionary) -> Dictionary:
	var ticker := String(position.get(MarketDataKeysScript.KEY_TICKER, ""))
	var quantity := int(position.get(MarketDataKeysScript.KEY_QUANTITY, 0))
	if ticker.is_empty() or quantity <= 0:
		return {}
	return {
		MarketDataKeysScript.KEY_TICKER: ticker,
		MarketDataKeysScript.KEY_QUANTITY: quantity,
		MarketDataKeysScript.KEY_AVG_COST: maxi(0, int(position.get(MarketDataKeysScript.KEY_AVG_COST, 0)))
	}
