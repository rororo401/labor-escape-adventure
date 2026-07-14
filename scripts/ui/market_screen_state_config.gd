class_name MarketScreenStateConfig
extends RefCounted

const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_IS_SLEEP_SEQUENCE := MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE
const KEY_IS_COMPLETING_DAY := MarketDayResultStateConfigScript.KEY_IS_COMPLETING_DAY
const KEY_SHOWING_CLOSE_REPORT := MarketDayResultStateConfigScript.KEY_SHOWING_CLOSE_REPORT
const KEY_SELECTED_STOCK := MarketDayResultStateConfigScript.KEY_SELECTED_STOCK
const KEY_SELECTED_DAY_ACTION_ID := MarketDayResultStateConfigScript.KEY_SELECTED_DAY_ACTION_ID
const KEY_SELECTED_CLOSED_DAY_CATEGORY_ID := MarketDayResultStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID
const KEY_QUANTITY := MarketDataKeysScript.KEY_QUANTITY

const DEFAULT_SELECTED_STOCK := {}
const DEFAULT_SELECTED_DAY_ACTION_ID := UiPayloadKeysScript.EMPTY_MESSAGE
const DEFAULT_SELECTED_CLOSED_DAY_CATEGORY_ID := UiPayloadKeysScript.EMPTY_MESSAGE
const DEFAULT_QUANTITY := 1
const DEFAULT_FLAG := false

const KNOWN_KEYS := [
	KEY_IS_SLEEP_SEQUENCE,
	KEY_IS_COMPLETING_DAY,
	KEY_SHOWING_CLOSE_REPORT,
	KEY_SELECTED_STOCK,
	KEY_SELECTED_DAY_ACTION_ID,
	KEY_SELECTED_CLOSED_DAY_CATEGORY_ID,
	KEY_QUANTITY
]
