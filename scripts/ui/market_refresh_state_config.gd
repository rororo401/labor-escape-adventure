class_name MarketRefreshStateConfig
extends RefCounted

const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketStatusTextConfigScript := preload("res://scripts/ui/market_status_text_config.gd")
const DisplayPayloadKeysScript := preload("res://scripts/core/display_payload_keys.gd")
const TextBlockPayloadKeysScript := preload("res://scripts/core/text_block_payload_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_MARKET_OPEN := "market_open"
const KEY_DATE_TEXT := DisplayPayloadKeysScript.KEY_DATE_TEXT
const KEY_STATUS_TEXT := "status_text"
const KEY_STATUS_SNAPSHOT := "status_snapshot"
const KEY_SELECTED_STOCK := MarketDayResultStateConfigScript.KEY_SELECTED_STOCK
const KEY_STOCKS := MarketDataKeysScript.KEY_STOCKS
const KEY_CLOSED_DAY_TEXT := "closed_day_text"
const KEY_CLOSED_DAY_MESSAGE := "closed_day_message"
const KEY_COMPLETED_MESSAGE := "completed_message"

const KEY_STATUS_CASH := MarketStatusTextConfigScript.KEY_CASH
const KEY_STATUS_NET_WORTH := MarketStatusTextConfigScript.KEY_NET_WORTH
const KEY_CLOSED_DAY_TITLE := TextBlockPayloadKeysScript.KEY_TITLE
const KEY_CLOSED_DAY_BODY := TextBlockPayloadKeysScript.KEY_BODY

const EMPTY_TEXT := UiPayloadKeysScript.EMPTY_MESSAGE
const DEFAULT_MARKET_OPEN := false
