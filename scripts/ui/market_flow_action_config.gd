class_name MarketFlowActionConfig
extends RefCounted

const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_ACTION := UiPayloadKeysScript.KEY_ACTION
const KEY_MESSAGE := UiPayloadKeysScript.KEY_MESSAGE
const KEY_SCENE_PATH := "scene_path"

const ACTION_IGNORE := "ignore"
const ACTION_SLEEP := "sleep"
const ACTION_COMPLETE_DAY := "complete_day"
const ACTION_MESSAGE := "message"
const ACTION_FIRST_DAY_SCENE := "first_day_scene"
const ACTION_CHANGE_SCENE := "change_scene"

const EMPTY_ACTION := UiPayloadKeysScript.EMPTY_MESSAGE
const EMPTY_MESSAGE := UiPayloadKeysScript.EMPTY_MESSAGE
const EMPTY_SCENE_PATH := UiPayloadKeysScript.EMPTY_MESSAGE
