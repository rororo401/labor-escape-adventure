class_name UiPayloadKeys
extends RefCounted

const IdentityPayloadKeysScript := preload("res://scripts/core/identity_payload_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")
const TextPayloadKeysScript := preload("res://scripts/core/text_payload_keys.gd")

const KEY_MESSAGE := "message"
const KEY_RESULT := ResultKeysScript.KEY_RESULT
const KEY_STATE := "state"
const KEY_ACTION := "action"
const KEY_TEXT := TextPayloadKeysScript.KEY_TEXT
const KEY_DISABLED := "disabled"
const KEY_HANDLED := "handled"
const KEY_REQUEST := "request"
const KEY_ID := IdentityPayloadKeysScript.KEY_ID
const KEY_LABEL := "label"
const KEY_LABELS := "labels"
const KEY_TOOLTIP := "tooltip"
const KEY_SELECTED_INDEX := "selected_index"
const KEY_HAS_SELECTION := "has_selection"
const EMPTY_MESSAGE := ""
