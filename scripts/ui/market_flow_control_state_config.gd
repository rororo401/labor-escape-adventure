class_name MarketFlowControlStateConfig
extends RefCounted

const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_CAN_TRADE := "can_trade"
const KEY_ORDER_FLOW := "order_flow"
const KEY_CLOSED_FLOW := "closed_flow"

const KEY_GAME_FINISHED := GameStateContextKeysScript.KEY_GAME_FINISHED
const KEY_GAME_CLEAR := GameStateContextKeysScript.KEY_GAME_CLEAR
const KEY_GAME_OVER := GameStateContextKeysScript.KEY_GAME_OVER
const KEY_DAY_COMPLETED := GameStateContextKeysScript.KEY_DAY_COMPLETED
const KEY_SLEEP_SEQUENCE := "sleep_sequence"
const KEY_READY_TEXT := "ready_text"
const KEY_COMPLETING_DAY := "completing_day"
const KEY_HAS_SELECTION := UiPayloadKeysScript.KEY_HAS_SELECTION

const DEFAULT_CAN_TRADE := false
const DEFAULT_FLOW_FLAG := false
const DEFAULT_READY_TEXT := UiPayloadKeysScript.EMPTY_MESSAGE
const DEFAULT_HAS_SELECTION := false
