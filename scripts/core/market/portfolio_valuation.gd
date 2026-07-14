class_name PortfolioValuation
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")


static func position_row(ticker: String, position: Dictionary, price: int) -> Dictionary:
	var quantity := int(position.get(MarketDataKeysScript.KEY_QUANTITY, 0))
	var avg_cost := int(position.get(MarketDataKeysScript.KEY_AVG_COST, 0))
	var market_value := quantity * price
	var cost_basis := quantity * avg_cost
	return {
		MarketDataKeysScript.KEY_TICKER: ticker,
		MarketDataKeysScript.KEY_QUANTITY: quantity,
		MarketDataKeysScript.KEY_AVG_COST: avg_cost,
		MarketDataKeysScript.KEY_CLOSE: price,
		MarketDataKeysScript.KEY_MARKET_VALUE: market_value,
		MarketDataKeysScript.KEY_COST_BASIS: cost_basis,
		MarketDataKeysScript.KEY_UNREALIZED_PROFIT: market_value - cost_basis
	}


static func summary(cash: int, realized_profit: int, position_rows: Array[Dictionary]) -> Dictionary:
	var total_market_value := 0
	var total_cost := 0
	for row in position_rows:
		total_market_value += int(row.get(MarketDataKeysScript.KEY_MARKET_VALUE, 0))
		total_cost += int(row.get(MarketDataKeysScript.KEY_COST_BASIS, 0))
	return {
		MarketDataKeysScript.KEY_CASH: cash,
		MarketDataKeysScript.KEY_POSITIONS: position_rows,
		MarketDataKeysScript.KEY_INVESTMENT_ASSETS: total_market_value,
		MarketDataKeysScript.KEY_COST_BASIS: total_cost,
		MarketDataKeysScript.KEY_UNREALIZED_PROFIT: total_market_value - total_cost,
		MarketDataKeysScript.KEY_REALIZED_PROFIT: realized_profit,
		MarketDataKeysScript.KEY_NET_WORTH: cash + total_market_value
	}
