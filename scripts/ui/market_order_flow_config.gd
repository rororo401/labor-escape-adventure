class_name MarketOrderFlowConfig
extends RefCounted

const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketOrderInputConfigScript := preload("res://scripts/ui/market_order_input_config.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_HANDLED := UiPayloadKeysScript.KEY_HANDLED
const KEY_REQUEST := UiPayloadKeysScript.KEY_REQUEST
const KEY_RESULT := UiPayloadKeysScript.KEY_RESULT
const KEY_STATE := UiPayloadKeysScript.KEY_STATE
const KEY_MESSAGE := UiPayloadKeysScript.KEY_MESSAGE
const KEY_OK := MarketOrderInputConfigScript.KEY_OK
const KEY_ERROR := MarketOrderInputConfigScript.KEY_ERROR
const KEY_PRICE := MarketDataKeysScript.KEY_PRICE
const KEY_TICKER := MarketOrderInputConfigScript.KEY_TICKER
const KEY_SIDE := MarketOrderInputConfigScript.KEY_SIDE
const KEY_QUANTITY := MarketOrderInputConfigScript.KEY_QUANTITY

const ERROR_GAME_NOT_STARTED := GameStateGuardResultScript.ERROR_GAME_NOT_STARTED
const DEFAULT_QUANTITY := MarketOrderInputConfigScript.MIN_QUANTITY
const DEFAULT_HANDLED := false
const CLOSE_REPORT_AFTER_ORDER := false


static func post_order_state() -> Dictionary:
	return {
		MarketScreenStateConfigScript.KEY_SHOWING_CLOSE_REPORT: CLOSE_REPORT_AFTER_ORDER
	}
