class_name MarketScreenSessionBootstrapConfig
extends RefCounted

const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_OK := ResultKeysScript.KEY_OK
const KEY_SESSION := GameSessionAccessScript.KEY_SESSION
const KEY_GAME := GameSessionAccessScript.KEY_GAME
const KEY_MESSAGE := UiPayloadKeysScript.KEY_MESSAGE

const DEFAULT_OK := false
const EMPTY_MESSAGE := UiPayloadKeysScript.EMPTY_MESSAGE
