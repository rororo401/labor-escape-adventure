class_name GameStateContextKeys
extends RefCounted

const CalendarPayloadKeysScript := preload("res://scripts/core/calendar_payload_keys.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const KEY_DATE := CalendarPayloadKeysScript.KEY_DATE
const KEY_WEEKDAY := CalendarPayloadKeysScript.KEY_WEEKDAY
const KEY_IS_TRADING_DAY := CalendarPayloadKeysScript.KEY_IS_TRADING_DAY
const KEY_REASON := DayEventKeysScript.KEY_REASON
const KEY_NAME := DayEventKeysScript.KEY_NAME
const KEY_CLOSED_REASON := "closed_reason"
const KEY_CLOSED_NAME := "closed_name"
const KEY_DAY_MODE := "day_mode"
const KEY_MARKET_PHASE_AVAILABLE := "market_phase_available"
const KEY_MARKET := DayEventKeysScript.KEY_MARKET
const KEY_DAY_FLOW := "day_flow"
const KEY_AVAILABLE_LIFE_ACTIONS := "available_life_actions"
const KEY_CHARACTER_ASSETS := "character_assets"
const KEY_STATUS := ResultKeysScript.KEY_STATUS
const KEY_GAME_OVER := PlayerStatusKeysScript.KEY_GAME_OVER
const KEY_GAME_OVER_REASON := PlayerStatusKeysScript.KEY_GAME_OVER_REASON
const KEY_GAME_CLEAR := PlayerStatusKeysScript.KEY_GAME_CLEAR
const KEY_CLEAR_REASON := PlayerStatusKeysScript.KEY_CLEAR_REASON
const KEY_GAME_FINISHED := DayEventKeysScript.KEY_GAME_FINISHED

const KEY_CALENDAR_DATE := "calendar_date"
const KEY_IS_OPEN := DayEventKeysScript.KEY_IS_OPEN
const KEY_PHASE := "phase"
const KEY_DAY_COMPLETED := "day_completed"
const KEY_LAST_DAY_RESULT := "last_day_result"

const DAY_MODE_MARKET_AND_LIFE := "market_and_life"
const DAY_MODE_LIFE_ONLY := "life_only"
const MARKET_PHASE_MORNING_ORDER := "morning_order"
const MARKET_PHASE_CLOSED := "closed"
