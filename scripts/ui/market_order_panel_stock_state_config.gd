class_name MarketOrderPanelStockStateConfig
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketStockRowConfigScript := preload("res://scripts/ui/market_stock_row_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_NAME := MarketStockRowConfigScript.KEY_NAME
const KEY_PRICE := MarketDataKeysScript.KEY_PRICE
const KEY_HOLDING := "holding"
const KEY_QUANTITY := MarketDataKeysScript.KEY_QUANTITY

const EMPTY_TEXT := UiPayloadKeysScript.EMPTY_MESSAGE
const EMPTY_STOCK_NAME := "선택 종목 없음"
