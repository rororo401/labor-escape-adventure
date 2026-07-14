class_name PortfolioOrderResult
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")


static func buy_success(ticker: String, quantity: int, price: int, cost: int, cash_after: int, position: Dictionary) -> Dictionary:
	return {
		MarketDataKeysScript.KEY_OK: true,
		MarketDataKeysScript.KEY_SIDE: MarketDataKeysScript.SIDE_BUY,
		MarketDataKeysScript.KEY_TICKER: ticker,
		MarketDataKeysScript.KEY_QUANTITY: quantity,
		MarketDataKeysScript.KEY_PRICE: price,
		MarketDataKeysScript.KEY_CASH_DELTA: -cost,
		MarketDataKeysScript.KEY_CASH_AFTER: cash_after,
		MarketDataKeysScript.KEY_POSITION: position.duplicate(true)
	}


static func sell_success(
	ticker: String,
	quantity: int,
	price: int,
	proceeds: int,
	cash_after: int,
	realized_profit_delta: int,
	realized_profit: int,
	position: Dictionary
) -> Dictionary:
	return {
		MarketDataKeysScript.KEY_OK: true,
		MarketDataKeysScript.KEY_SIDE: MarketDataKeysScript.SIDE_SELL,
		MarketDataKeysScript.KEY_TICKER: ticker,
		MarketDataKeysScript.KEY_QUANTITY: quantity,
		MarketDataKeysScript.KEY_PRICE: price,
		MarketDataKeysScript.KEY_CASH_DELTA: proceeds,
		MarketDataKeysScript.KEY_CASH_AFTER: cash_after,
		MarketDataKeysScript.KEY_REALIZED_PROFIT_DELTA: realized_profit_delta,
		MarketDataKeysScript.KEY_REALIZED_PROFIT: realized_profit,
		MarketDataKeysScript.KEY_POSITION: position.duplicate(true)
	}


static func error(error_code: String, cash_after: int) -> Dictionary:
	return {
		MarketDataKeysScript.KEY_OK: false,
		MarketDataKeysScript.KEY_ERROR: error_code,
		MarketDataKeysScript.KEY_CASH_AFTER: cash_after
	}
