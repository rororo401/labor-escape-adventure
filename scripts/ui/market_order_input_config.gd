class_name MarketOrderInputConfig
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const MIN_QUANTITY := 1
const MAX_QUANTITY := 999

const KEY_OK := ResultKeysScript.KEY_OK
const KEY_ERROR := ResultKeysScript.KEY_ERROR
const KEY_TICKER := MarketDataKeysScript.KEY_TICKER
const KEY_SIDE := MarketDataKeysScript.KEY_SIDE
const KEY_QUANTITY := MarketDataKeysScript.KEY_QUANTITY

const ERROR_STOCK_NOT_SELECTED := "stock_not_selected"
