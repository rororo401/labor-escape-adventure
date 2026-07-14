class_name DateTransitionDisplayStateConfig
extends RefCounted

const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")
const DisplayPayloadKeysScript := preload("res://scripts/core/display_payload_keys.gd")

const KEY_DATE_TEXT := DisplayPayloadKeysScript.KEY_DATE_TEXT
const KEY_WEEKDAY_TEXT := "weekday_text"
const KEY_STAMP_TEXT := "stamp_text"

const CLOSING_TEXT := "하루를 마무리하는 중"
const MORNING_STAMP_TEXT := "새로운 하루!"
const EMPTY_TEXT := UiPayloadKeysScript.EMPTY_MESSAGE
