class_name MarketEngine
extends RefCounted

const StockCatalogScript := preload("res://scripts/core/market/stock_catalog.gd")
const PriceRepositoryScript := preload("res://scripts/core/market/price_repository.gd")
const PortfolioScript := preload("res://scripts/core/market/portfolio.gd")
const MarketSnapshotBuilderScript := preload("res://scripts/core/market/market_snapshot_builder.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")

const COMPANIES_PATH := GameStateConfigScript.COMPANIES_PATH

var catalog = StockCatalogScript.new()
var prices = PriceRepositoryScript.new()
var portfolio = PortfolioScript.new()
var real_name_mode := false


func setup(starting_cash: int, companies_path: String = COMPANIES_PATH) -> bool:
	catalog.load_from_json(companies_path)
	real_name_mode = catalog.debug_real_name_mode
	portfolio.reset(starting_cash)

	var loaded_count := 0
	for ticker in catalog.get_tickers():
		if prices.load_ticker(ticker, catalog.get_price_path(ticker)):
			loaded_count += 1

	if loaded_count == 0:
		push_error("No stock price data loaded.")
		return false
	return true


func set_real_name_mode(enabled: bool) -> void:
	real_name_mode = enabled


func get_market_snapshot(date: String, previous_trading_date: String = "", limit: int = 30) -> Dictionary:
	return MarketSnapshotBuilderScript.build(catalog.get_companies(real_name_mode), prices, portfolio, date, previous_trading_date, limit)


func submit_order(date: String, is_trading_day: bool, ticker: String, side: String, quantity: int) -> Dictionary:
	if not is_trading_day:
		return {
			MarketDataKeysScript.KEY_OK: false,
			MarketDataKeysScript.KEY_ERROR: MarketDataKeysScript.ERROR_MARKET_CLOSED
		}

	var price := prices.get_open(ticker, date)
	if price <= 0:
		return {
			MarketDataKeysScript.KEY_OK: false,
			MarketDataKeysScript.KEY_ERROR: MarketDataKeysScript.ERROR_PRICE_MISSING
		}

	if side == MarketDataKeysScript.SIDE_BUY:
		return portfolio.buy(ticker, quantity, price)
	if side == MarketDataKeysScript.SIDE_SELL:
		return portfolio.sell(ticker, quantity, price)

	return {
		MarketDataKeysScript.KEY_OK: false,
		MarketDataKeysScript.KEY_ERROR: MarketDataKeysScript.ERROR_INVALID_SIDE
	}


func get_close_report(date: String) -> Dictionary:
	return portfolio.mark_to_market(prices, date)


func get_open_report(date: String) -> Dictionary:
	return portfolio.mark_to_market(
		prices,
		date,
		MarketDataKeysScript.KEY_OPEN,
		MarketDataKeysScript.KEY_CLOSE
	)


func set_cash_balance(value: int) -> void:
	portfolio.cash = maxi(0, value)


func to_save_dict() -> Dictionary:
	return {
		MarketDataKeysScript.KEY_REAL_NAME_MODE: real_name_mode,
		MarketDataKeysScript.KEY_PORTFOLIO: portfolio.to_dict()
	}


func load_from_save_dict(data: Dictionary) -> void:
	# The project catalog is the authority for whether real company names may be shown.
	# This prevents older saves made while debug names were enabled from restoring them.
	real_name_mode = catalog.debug_real_name_mode and bool(data.get(MarketDataKeysScript.KEY_REAL_NAME_MODE, real_name_mode))
	portfolio.load_from_dict(Dictionary(data.get(MarketDataKeysScript.KEY_PORTFOLIO, {})))
