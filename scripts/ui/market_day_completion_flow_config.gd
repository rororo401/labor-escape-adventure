class_name MarketDayCompletionFlowConfig
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_OK := ResultKeysScript.KEY_OK
const KEY_RESULT := UiPayloadKeysScript.KEY_RESULT
const KEY_STATE := UiPayloadKeysScript.KEY_STATE
const KEY_DAY_ACTION := DayEventKeysScript.KEY_DAY_ACTION
const KEY_EVENT := DayEventKeysScript.KEY_EVENT
const KEY_SHOULD_PLAY_DAY_EVENT := "should_play_day_event"
const KEY_PLAYBACK_EVENTS := "playback_events"
const KEY_ERROR := ResultKeysScript.KEY_ERROR

const DEFAULT_MISSING_GAME_ERROR := GameStateGuardResultScript.ERROR_GAME_NOT_STARTED
