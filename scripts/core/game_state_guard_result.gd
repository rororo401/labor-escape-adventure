class_name GameStateGuardResult
extends RefCounted

const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const KEY_OK := ResultKeysScript.KEY_OK
const KEY_ERROR := ResultKeysScript.KEY_ERROR
const KEY_STATUS := ResultKeysScript.KEY_STATUS
const KEY_GAME_OVER_REASON := PlayerStatusKeysScript.KEY_GAME_OVER_REASON
const KEY_CLEAR_REASON := PlayerStatusKeysScript.KEY_CLEAR_REASON

const ERROR_CALENDAR_DAY_MISSING := "calendar_day_missing"
const ERROR_GAME_OVER := PlayerStatusKeysScript.KEY_GAME_OVER
const ERROR_GAME_CLEAR := PlayerStatusKeysScript.KEY_GAME_CLEAR
const ERROR_GAME_NOT_STARTED := "game_not_started"


static func error(error_id: String, extra: Dictionary = {}) -> Dictionary:
	var result := {
		KEY_OK: false,
		KEY_ERROR: error_id
	}
	result.merge(extra, true)
	return result


static func calendar_day_missing() -> Dictionary:
	return error(ERROR_CALENDAR_DAY_MISSING)


static func game_over(status_snapshot: Dictionary, reason: String, extra: Dictionary = {}) -> Dictionary:
	var payload := {
		KEY_STATUS: status_snapshot,
		KEY_GAME_OVER_REASON: reason
	}
	payload.merge(extra, true)
	return error(ERROR_GAME_OVER, payload)


static func game_clear(status_snapshot: Dictionary, reason: String, extra: Dictionary = {}) -> Dictionary:
	var payload := {
		KEY_STATUS: status_snapshot,
		KEY_CLEAR_REASON: reason
	}
	payload.merge(extra, true)
	return error(ERROR_GAME_CLEAR, payload)
