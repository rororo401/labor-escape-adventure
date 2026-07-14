class_name MarketScreenRefreshResultConfig
extends RefCounted

const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")
const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketRefreshStateConfigScript := preload("res://scripts/ui/market_refresh_state_config.gd")

const KEY_MARKET_CONTEXT := "market_context"
const KEY_PRESENTATION := "presentation"
const KEY_SELECTED_STOCK := MarketDayResultStateConfigScript.KEY_SELECTED_STOCK
const KEY_COMPLETED_MESSAGE := MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE

const EMPTY_MESSAGE := UiPayloadKeysScript.EMPTY_MESSAGE
