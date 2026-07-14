class_name Portfolio
extends RefCounted

const PortfolioOrderMathScript := preload("res://scripts/core/market/portfolio_order_math.gd")
const PortfolioOrderResultScript := preload("res://scripts/core/market/portfolio_order_result.gd")
const PortfolioSnapshotScript := preload("res://scripts/core/market/portfolio_snapshot.gd")
const PortfolioValuationScript := preload("res://scripts/core/market/portfolio_valuation.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")

var cash := 0
var realized_profit := 0
var positions := {}


func reset(starting_cash: int) -> void:
	cash = maxi(0, starting_cash)
	realized_profit = 0
	positions.clear()


func buy(ticker: String, quantity: int, price: int) -> Dictionary:
	if quantity <= 0:
		return _order_error(MarketDataKeysScript.ERROR_INVALID_QUANTITY)
	if price <= 0:
		return _order_error(MarketDataKeysScript.ERROR_INVALID_PRICE)

	var cost := quantity * price
	if cost >= cash:
		return _order_error(MarketDataKeysScript.ERROR_NOT_ENOUGH_CASH)

	var position := _get_or_create_position(ticker)
	var update := PortfolioOrderMathScript.buy_update(position, ticker, quantity, price)

	position = Dictionary(update.get(MarketDataKeysScript.KEY_POSITION, {}))
	cash -= cost
	positions[ticker] = position

	return PortfolioOrderResultScript.buy_success(ticker, quantity, price, cost, cash, position)


func sell(ticker: String, quantity: int, price: int) -> Dictionary:
	if quantity <= 0:
		return _order_error(MarketDataKeysScript.ERROR_INVALID_QUANTITY)
	if price <= 0:
		return _order_error(MarketDataKeysScript.ERROR_INVALID_PRICE)

	var position: Dictionary = positions.get(ticker, {})
	var held_quantity := int(position.get(MarketDataKeysScript.KEY_QUANTITY, 0))
	if quantity > held_quantity:
		return _order_error(MarketDataKeysScript.ERROR_NOT_ENOUGH_SHARES)

	var update := PortfolioOrderMathScript.sell_update(position, ticker, quantity, price)
	var proceeds := int(update.get(MarketDataKeysScript.KEY_PROCEEDS, 0))
	var profit := int(update.get(MarketDataKeysScript.KEY_PROFIT, 0))
	realized_profit += profit
	cash += proceeds
	position = Dictionary(update.get(MarketDataKeysScript.KEY_POSITION, {}))

	if bool(update.get(MarketDataKeysScript.KEY_REMOVE_POSITION, false)):
		positions.erase(ticker)
	else:
		positions[ticker] = position

	return PortfolioOrderResultScript.sell_success(ticker, quantity, price, proceeds, cash, profit, realized_profit, position)


func get_position(ticker: String) -> Dictionary:
	return Dictionary(positions.get(ticker, {
		MarketDataKeysScript.KEY_TICKER: ticker,
		MarketDataKeysScript.KEY_QUANTITY: 0,
		MarketDataKeysScript.KEY_AVG_COST: 0
	}))


func get_total_quantity() -> int:
	var total := 0
	for position in positions.values():
		total += int(position.get(MarketDataKeysScript.KEY_QUANTITY, 0))
	return total


func mark_to_market(
	price_repository,
	date: String,
	price_field: String = MarketDataKeysScript.KEY_CLOSE,
	fallback_price_field: String = ""
) -> Dictionary:
	var position_rows: Array[Dictionary] = []

	for ticker in positions.keys():
		var position: Dictionary = positions[ticker]
		var price_row: Dictionary = price_repository.get_price(String(ticker), date)
		var price: int = int(price_row.get(price_field, 0))
		if price <= 0 and not fallback_price_field.is_empty():
			price = int(price_row.get(fallback_price_field, 0))
		position_rows.append(PortfolioValuationScript.position_row(String(ticker), position, price))

	return PortfolioValuationScript.summary(cash, realized_profit, position_rows)


func to_dict() -> Dictionary:
	return PortfolioSnapshotScript.to_dict(cash, realized_profit, positions)


func load_from_dict(data: Dictionary) -> void:
	cash = PortfolioSnapshotScript.normalize_cash(data.get(MarketDataKeysScript.KEY_CASH, 0))
	realized_profit = PortfolioSnapshotScript.normalize_realized_profit(data.get(MarketDataKeysScript.KEY_REALIZED_PROFIT, 0))
	positions = PortfolioSnapshotScript.load_positions(data)


func _get_or_create_position(ticker: String) -> Dictionary:
	return Dictionary(positions.get(ticker, {
		MarketDataKeysScript.KEY_TICKER: ticker,
		MarketDataKeysScript.KEY_QUANTITY: 0,
		MarketDataKeysScript.KEY_AVG_COST: 0
	}))


func _order_error(error: String) -> Dictionary:
	return PortfolioOrderResultScript.error(error, cash)
