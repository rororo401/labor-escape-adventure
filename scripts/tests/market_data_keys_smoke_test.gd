extends "res://scripts/tests/test_scene_tree.gd"

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const CalendarPayloadKeysScript := preload("res://scripts/core/calendar_payload_keys.gd")
const LocalizedPayloadKeysScript := preload("res://scripts/core/localized_payload_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_verify_common_payload_keys()
	_verify_price_and_snapshot_keys()
	_verify_portfolio_and_order_keys()
	_verify_catalog_and_context_keys()
	_verify_order_codes()

	print("Market data keys smoke test passed.")
	finish_test()


func _verify_common_payload_keys() -> void:
	_expect(MarketDataKeysScript.KEY_OK == ResultKeysScript.KEY_OK, "ok key should use the shared result key")
	_expect(MarketDataKeysScript.KEY_ERROR == ResultKeysScript.KEY_ERROR, "error key should use the shared result key")
	_expect(MarketDataKeysScript.KEY_DATA == ResultKeysScript.KEY_DATA, "data key should use the shared result key")
	_expect(MarketDataKeysScript.KEY_TICKER == "ticker", "ticker key should stay stable")
	_expect(MarketDataKeysScript.KEY_DATE == CalendarPayloadKeysScript.KEY_DATE, "date key should use the shared calendar payload key")


func _verify_price_and_snapshot_keys() -> void:
	_expect(MarketDataKeysScript.KEY_OPEN == "open", "open key should stay stable")
	_expect(MarketDataKeysScript.KEY_CLOSE == "close", "close key should stay stable")
	_expect(MarketDataKeysScript.KEY_VOLUME == "volume", "volume key should stay stable")
	_expect(MarketDataKeysScript.KEY_PREVIOUS_CLOSE == "previous_close", "previous close key should stay stable")
	_expect(MarketDataKeysScript.KEY_CHANGE_RATE == "change_rate", "change-rate key should stay stable")
	_expect(MarketDataKeysScript.KEY_STOCKS == "stocks", "stocks key should stay stable")
	_expect(MarketDataKeysScript.KEY_PREVIOUS_TRADING_DATE == "previous_trading_date", "previous trading date key should stay stable")


func _verify_portfolio_and_order_keys() -> void:
	_expect(MarketDataKeysScript.KEY_QUANTITY == "quantity", "quantity key should stay stable")
	_expect(MarketDataKeysScript.KEY_HELD_QUANTITY == "held_quantity", "held quantity key should stay stable")
	_expect(MarketDataKeysScript.KEY_AVG_COST == "avg_cost", "average cost key should stay stable")
	_expect(MarketDataKeysScript.KEY_CASH == PlayerStatusKeysScript.KEY_CASH, "cash key should use the shared player-status key")
	_expect(MarketDataKeysScript.KEY_CASH_DELTA == PlayerStatusKeysScript.KEY_CASH_DELTA, "cash delta key should use the shared player-status key")
	_expect(MarketDataKeysScript.KEY_POSITIONS == "positions", "positions key should stay stable")
	_expect(MarketDataKeysScript.KEY_REALIZED_PROFIT == "realized_profit", "realized profit key should stay stable")
	_expect(MarketDataKeysScript.KEY_REALIZED_PROFIT_DELTA == "realized_profit_delta", "realized profit delta key should stay stable")
	_expect(MarketDataKeysScript.KEY_INVESTMENT_ASSETS == PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, "investment assets key should use the shared player-status key")
	_expect(MarketDataKeysScript.KEY_UNREALIZED_PROFIT == "unrealized_profit", "unrealized profit key should stay stable")
	_expect(MarketDataKeysScript.KEY_NET_WORTH == PlayerStatusKeysScript.KEY_NET_WORTH, "net worth key should use the shared player-status key")
	_expect(MarketDataKeysScript.KEY_POSITION == "position", "position key should stay stable")
	_expect(MarketDataKeysScript.KEY_REMOVE_POSITION == "remove_position", "remove-position key should stay stable")


func _verify_catalog_and_context_keys() -> void:
	_expect(MarketDataKeysScript.KEY_NAME_KO == LocalizedPayloadKeysScript.KEY_NAME_KO, "Korean display-name key should use the shared localized payload key")
	_expect(MarketDataKeysScript.KEY_REAL_NAME_KO == "real_name_ko", "real-name key should stay stable")
	_expect(MarketDataKeysScript.KEY_DISPLAY_NAME_KO == LocalizedPayloadKeysScript.KEY_DISPLAY_NAME_KO, "alias display-name key should use the shared localized payload key")
	_expect(MarketDataKeysScript.KEY_PRICE_PATH == "price_path", "price path key should stay stable")
	_expect(MarketDataKeysScript.KEY_COMPANIES == "companies", "companies key should stay stable")
	_expect(MarketDataKeysScript.KEY_COMPANY_BY_TICKER == "company_by_ticker", "company index key should stay stable")
	_expect(MarketDataKeysScript.KEY_DEBUG_REAL_NAME_MODE == "debug_real_name_mode", "real-name debug flag should stay stable")
	_expect(MarketDataKeysScript.KEY_REAL_NAME_MODE == "real_name_mode", "saved real-name mode key should stay stable")
	_expect(MarketDataKeysScript.KEY_IS_TRADING_DAY == CalendarPayloadKeysScript.KEY_IS_TRADING_DAY, "trading-day key should use the shared calendar payload key")


func _verify_order_codes() -> void:
	_expect(MarketDataKeysScript.SIDE_BUY == "buy", "buy side should stay stable")
	_expect(MarketDataKeysScript.SIDE_SELL == "sell", "sell side should stay stable")
	_expect(MarketDataKeysScript.ERROR_INVALID_QUANTITY == "invalid_quantity", "invalid quantity error should stay stable")
	_expect(MarketDataKeysScript.ERROR_INVALID_PRICE == "invalid_price", "invalid price error should stay stable")
	_expect(MarketDataKeysScript.ERROR_NOT_ENOUGH_CASH == "not_enough_cash", "cash error should stay stable")
	_expect(MarketDataKeysScript.ERROR_NOT_ENOUGH_SHARES == "not_enough_shares", "shares error should stay stable")
	_expect(MarketDataKeysScript.ERROR_MARKET_CLOSED == "market_closed", "market closed error should stay stable")
	_expect(MarketDataKeysScript.ERROR_PRICE_MISSING == "price_missing", "price missing error should stay stable")
	_expect(MarketDataKeysScript.ERROR_INVALID_SIDE == "invalid_side", "invalid side error should stay stable")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
