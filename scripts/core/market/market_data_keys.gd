class_name MarketDataKeys
extends RefCounted

const CalendarPayloadKeysScript := preload("res://scripts/core/calendar_payload_keys.gd")
const LocalizedPayloadKeysScript := preload("res://scripts/core/localized_payload_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const KEY_OK := ResultKeysScript.KEY_OK
const KEY_ERROR := ResultKeysScript.KEY_ERROR
const KEY_DATA := ResultKeysScript.KEY_DATA
const KEY_SIDE := "side"
const KEY_TICKER := "ticker"
const KEY_DATE := CalendarPayloadKeysScript.KEY_DATE
const KEY_NAME_KO := LocalizedPayloadKeysScript.KEY_NAME_KO
const KEY_REAL_NAME_KO := "real_name_ko"
const KEY_DISPLAY_NAME_KO := LocalizedPayloadKeysScript.KEY_DISPLAY_NAME_KO
const KEY_SECTOR_HINT := "sector_hint"
const KEY_SOURCE_FILE := "source_file"
const KEY_PRICE_PATH := "price_path"

const KEY_OPEN := "open"
const KEY_HIGH := "high"
const KEY_LOW := "low"
const KEY_CLOSE := "close"
const KEY_VOLUME := "volume"
const KEY_FOREIGN_OWNERSHIP_RATIO := "foreign_ownership_ratio"
const KEY_PREVIOUS_CLOSE := "previous_close"
const KEY_CHANGE_RATE := "change_rate"

const KEY_QUANTITY := "quantity"
const KEY_HELD_QUANTITY := "held_quantity"
const KEY_AVG_COST := "avg_cost"
const KEY_PRICE := "price"
const KEY_CASH := PlayerStatusKeysScript.KEY_CASH
const KEY_CASH_DELTA := PlayerStatusKeysScript.KEY_CASH_DELTA
const KEY_CASH_AFTER := "cash_after"
const KEY_POSITION := "position"
const KEY_POSITIONS := "positions"
const KEY_REALIZED_PROFIT := "realized_profit"
const KEY_REALIZED_PROFIT_DELTA := "realized_profit_delta"
const KEY_INVESTMENT_ASSETS := PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS
const KEY_MARKET_VALUE := "market_value"
const KEY_COST_BASIS := "cost_basis"
const KEY_UNREALIZED_PROFIT := "unrealized_profit"
const KEY_NET_WORTH := PlayerStatusKeysScript.KEY_NET_WORTH

const KEY_COST := "cost"
const KEY_PROCEEDS := "proceeds"
const KEY_PROFIT := "profit"
const KEY_REMAINING_QUANTITY := "remaining_quantity"
const KEY_REMOVE_POSITION := "remove_position"

const KEY_PREVIOUS_TRADING_DATE := "previous_trading_date"
const KEY_STOCKS := "stocks"
const KEY_PORTFOLIO := "portfolio"
const KEY_COMPANIES := "companies"
const KEY_COMPANY_BY_TICKER := "company_by_ticker"
const KEY_DEBUG_REAL_NAME_MODE := "debug_real_name_mode"
const KEY_ALIAS_FILE := "alias_file"
const KEY_ALIASES := "aliases"
const KEY_REAL_NAME_MODE := "real_name_mode"
const KEY_STATUS := ResultKeysScript.KEY_STATUS
const KEY_IS_TRADING_DAY := CalendarPayloadKeysScript.KEY_IS_TRADING_DAY

const SIDE_BUY := "buy"
const SIDE_SELL := "sell"

const ERROR_INVALID_QUANTITY := "invalid_quantity"
const ERROR_INVALID_PRICE := "invalid_price"
const ERROR_NOT_ENOUGH_CASH := "not_enough_cash"
const ERROR_NOT_ENOUGH_SHARES := "not_enough_shares"
const ERROR_MARKET_CLOSED := "market_closed"
const ERROR_PRICE_MISSING := "price_missing"
const ERROR_INVALID_SIDE := "invalid_side"
