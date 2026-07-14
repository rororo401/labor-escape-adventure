class_name MarketDayFlowTextConfig
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayCompletionResultScript := preload("res://scripts/core/dayflow/day_completion_result.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const TextBlockPayloadKeysScript := preload("res://scripts/core/text_block_payload_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_MARKET_CLOSE_REPORT := DayEventKeysScript.KEY_MARKET_CLOSE_REPORT
const KEY_GAME_CLEAR := PlayerStatusKeysScript.KEY_GAME_CLEAR
const KEY_GAME_OVER := PlayerStatusKeysScript.KEY_GAME_OVER
const KEY_GAME_OVER_REASON := PlayerStatusKeysScript.KEY_GAME_OVER_REASON
const KEY_ENDING_TITLE_KO := PlayerStatusKeysScript.KEY_ENDING_TITLE_KO
const KEY_DAY_ACTION := DayEventKeysScript.KEY_DAY_ACTION
const KEY_WEEKDAY_EVENTS := DayEventKeysScript.KEY_WEEKDAY_EVENTS
const KEY_NIGHT_EVENTS := DayEventKeysScript.KEY_NIGHT_EVENTS
const KEY_EVENT := DayEventKeysScript.KEY_EVENT
const KEY_UNREALIZED_PROFIT := MarketDataKeysScript.KEY_UNREALIZED_PROFIT
const KEY_CLOSED_NAME := GameStateContextKeysScript.KEY_CLOSED_NAME
const KEY_CLOSED_REASON := GameStateContextKeysScript.KEY_CLOSED_REASON
const KEY_TITLE := TextBlockPayloadKeysScript.KEY_TITLE
const KEY_BODY := TextBlockPayloadKeysScript.KEY_BODY

const CLOSED_REASON_WEEKEND := "weekend"
const WEEKEND_LABEL := "주말"
const HOLIDAY_LABEL := "휴장일"
const DEFAULT_DAY_ACTION_NAME := "하루"
const EMPTY_TEXT := UiPayloadKeysScript.EMPTY_MESSAGE

const ORDER_ERROR_MARKET_CLOSED := MarketDataKeysScript.ERROR_MARKET_CLOSED
const ORDER_ERROR_NOT_ENOUGH_CASH := MarketDataKeysScript.ERROR_NOT_ENOUGH_CASH
const ORDER_ERROR_NOT_ENOUGH_SHARES := MarketDataKeysScript.ERROR_NOT_ENOUGH_SHARES
const ORDER_ERROR_PRICE_MISSING := MarketDataKeysScript.ERROR_PRICE_MISSING
const ORDER_ERROR_INVALID_QUANTITY := MarketDataKeysScript.ERROR_INVALID_QUANTITY

const FLOW_ERROR_DAY_ALREADY_COMPLETED := DayCompletionResultScript.ERROR_DAY_ALREADY_COMPLETED
const FLOW_ERROR_DAY_NOT_COMPLETED := DayCompletionResultScript.ERROR_DAY_NOT_COMPLETED
const FLOW_ERROR_FIRST_DAY_STOCK_REQUIRED := DayCompletionResultScript.ERROR_FIRST_DAY_STOCK_REQUIRED
const FLOW_ERROR_GAME_OVER := GameStateGuardResultScript.ERROR_GAME_OVER
const FLOW_ERROR_GAME_CLEAR := GameStateGuardResultScript.ERROR_GAME_CLEAR
const FLOW_ERROR_GAME_NOT_STARTED := GameStateGuardResultScript.ERROR_GAME_NOT_STARTED

const GAME_OVER_REASON_FINAL_BAD_ENDING := PlayerStatusKeysScript.GAME_OVER_REASON_FINAL_BAD_ENDING
