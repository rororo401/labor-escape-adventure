class_name MarketDayCompletionScreenFlowConfig
extends RefCounted

const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")

const EVENT_MODE_AWAIT := "await"
const EVENT_MODE_CALLBACK := "callback"

const KEY_ACTION := UiPayloadKeysScript.KEY_ACTION
const KEY_STATE := UiPayloadKeysScript.KEY_STATE
const KEY_RESULT := UiPayloadKeysScript.KEY_RESULT
const KEY_DAY_ACTION := DayEventKeysScript.KEY_DAY_ACTION
const KEY_PLAYBACK_EVENTS := "playback_events"

const ACTION_ERROR := "error"
const ACTION_FINISH := "finish"
const ACTION_PLAY_EVENT := "play_event"

const CALLBACK_APPLY_ERROR := "apply_error"
const CALLBACK_FINISH := "finish"
const CALLBACK_UPDATE_CLOSED_DAY_CHOICES := "update_closed_day_choices"
const DEFAULT_UPDATE_CLOSED_DAY_CHOICES := true
