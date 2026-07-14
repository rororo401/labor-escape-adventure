class_name PortfolioOrderMath
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")


static func buy_update(position: Dictionary, ticker: String, quantity: int, price: int) -> Dictionary:
	var cost := quantity * price
	var before_quantity := int(position.get(MarketDataKeysScript.KEY_QUANTITY, 0))
	var before_avg_cost := int(position.get(MarketDataKeysScript.KEY_AVG_COST, 0))
	var new_quantity := before_quantity + quantity
	var new_avg_cost := int(round(float(before_quantity * before_avg_cost + cost) / float(new_quantity)))
	return {
		MarketDataKeysScript.KEY_COST: cost,
		MarketDataKeysScript.KEY_POSITION: {
			MarketDataKeysScript.KEY_TICKER: ticker,
			MarketDataKeysScript.KEY_QUANTITY: new_quantity,
			MarketDataKeysScript.KEY_AVG_COST: new_avg_cost
		}
	}


static func sell_update(position: Dictionary, ticker: String, quantity: int, price: int) -> Dictionary:
	var held_quantity := int(position.get(MarketDataKeysScript.KEY_QUANTITY, 0))
	var avg_cost := int(position.get(MarketDataKeysScript.KEY_AVG_COST, 0))
	var proceeds := quantity * price
	var profit := (price - avg_cost) * quantity
	var remaining_quantity := held_quantity - quantity
	var next_position := {
		MarketDataKeysScript.KEY_TICKER: ticker,
		MarketDataKeysScript.KEY_QUANTITY: maxi(0, remaining_quantity),
		MarketDataKeysScript.KEY_AVG_COST: avg_cost if remaining_quantity > 0 else 0
	}
	return {
		MarketDataKeysScript.KEY_PROCEEDS: proceeds,
		MarketDataKeysScript.KEY_PROFIT: profit,
		MarketDataKeysScript.KEY_REMAINING_QUANTITY: remaining_quantity,
		MarketDataKeysScript.KEY_REMOVE_POSITION: remaining_quantity <= 0,
		MarketDataKeysScript.KEY_POSITION: next_position
	}
