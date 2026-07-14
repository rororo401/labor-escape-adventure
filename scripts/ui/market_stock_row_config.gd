class_name MarketStockRowConfig
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_TICKER := MarketDataKeysScript.KEY_TICKER
const KEY_DISPLAY_NAME := MarketDataKeysScript.KEY_DISPLAY_NAME_KO
const KEY_NAME_KO := MarketDataKeysScript.KEY_NAME_KO
const KEY_NAME := "name"
const KEY_OPEN := MarketDataKeysScript.KEY_OPEN
const KEY_PREVIOUS_CLOSE := MarketDataKeysScript.KEY_PREVIOUS_CLOSE
const KEY_CHANGE_RATE := MarketDataKeysScript.KEY_CHANGE_RATE
const KEY_HELD_QUANTITY := MarketDataKeysScript.KEY_HELD_QUANTITY
const KEY_AVG_COST := MarketDataKeysScript.KEY_AVG_COST

const EMPTY_TEXT := UiPayloadKeysScript.EMPTY_MESSAGE
const DEFAULT_NUMBER := 0
const DEFAULT_RATE := 0.0
