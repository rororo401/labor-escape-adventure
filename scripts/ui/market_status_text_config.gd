class_name MarketStatusTextConfig
extends RefCounted

const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_CASH := PlayerStatusKeysScript.KEY_CASH
const KEY_NET_WORTH := PlayerStatusKeysScript.KEY_NET_WORTH

const CASH_LABEL := "현금"
const NET_WORTH_LABEL := "순자산"
const EMPTY_TEXT := UiPayloadKeysScript.EMPTY_MESSAGE
const DEFAULT_AMOUNT := 0
