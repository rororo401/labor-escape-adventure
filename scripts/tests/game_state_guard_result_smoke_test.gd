extends "res://scripts/tests/test_scene_tree.gd"

const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_verify_stable_keys_and_errors()
	_verify_payloads()

	print("Game state guard result smoke test passed.")
	finish_test()


func _verify_stable_keys_and_errors() -> void:
	_expect(GameStateGuardResultScript.KEY_OK == ResultKeysScript.KEY_OK, "guard ok key should use the shared result key")
	_expect(GameStateGuardResultScript.KEY_ERROR == ResultKeysScript.KEY_ERROR, "guard error key should use the shared result key")
	_expect(GameStateGuardResultScript.KEY_STATUS == ResultKeysScript.KEY_STATUS, "guard status key should use the shared result key")
	_expect(GameStateGuardResultScript.KEY_GAME_OVER_REASON == PlayerStatusKeysScript.KEY_GAME_OVER_REASON, "guard game-over reason key should use the shared player-status key")
	_expect(GameStateGuardResultScript.KEY_CLEAR_REASON == PlayerStatusKeysScript.KEY_CLEAR_REASON, "guard clear reason key should use the shared player-status key")
	_expect(GameStateGuardResultScript.ERROR_CALENDAR_DAY_MISSING == "calendar_day_missing", "calendar-missing error should stay stable")
	_expect(GameStateGuardResultScript.ERROR_GAME_OVER == PlayerStatusKeysScript.KEY_GAME_OVER, "game-over error should use the shared player-status key")
	_expect(GameStateGuardResultScript.ERROR_GAME_CLEAR == PlayerStatusKeysScript.KEY_GAME_CLEAR, "game-clear error should use the shared player-status key")
	_expect(GameStateGuardResultScript.ERROR_GAME_NOT_STARTED == "game_not_started", "game-not-started error should stay stable")


func _verify_payloads() -> void:
	var generic: Dictionary = GameStateGuardResultScript.error("custom_error", {
		"value": 12
	})
	_expect(not generic.get(GameStateGuardResultScript.KEY_OK, true), "generic guard result should be a failure")
	_expect(generic.get(GameStateGuardResultScript.KEY_ERROR, "") == "custom_error", "generic guard result should keep the error id")
	_expect(generic.get("value", 0) == 12, "generic guard result should merge extra data")

	var missing: Dictionary = GameStateGuardResultScript.calendar_day_missing()
	_expect(not missing.get(GameStateGuardResultScript.KEY_OK, true), "missing calendar day should be a failure")
	_expect(missing.get(GameStateGuardResultScript.KEY_ERROR, "") == GameStateGuardResultScript.ERROR_CALENDAR_DAY_MISSING, "missing calendar day error mismatch")

	var over: Dictionary = GameStateGuardResultScript.game_over({
		"cash": 0
	}, "cash_zero")
	_expect(over.get(GameStateGuardResultScript.KEY_ERROR, "") == GameStateGuardResultScript.ERROR_GAME_OVER, "game-over error mismatch")
	_expect(over.get(GameStateGuardResultScript.KEY_STATUS, {}).get("cash", -1) == 0, "game-over result should keep status")
	_expect(over.get(GameStateGuardResultScript.KEY_GAME_OVER_REASON, "") == "cash_zero", "game-over result should keep reason")

	var clear: Dictionary = GameStateGuardResultScript.game_clear({
		"net_worth": 1000000000
	}, "target_net_worth")
	_expect(clear.get(GameStateGuardResultScript.KEY_ERROR, "") == GameStateGuardResultScript.ERROR_GAME_CLEAR, "game-clear error mismatch")
	_expect(clear.get(GameStateGuardResultScript.KEY_STATUS, {}).get("net_worth", 0) == 1000000000, "game-clear result should keep status")
	_expect(clear.get(GameStateGuardResultScript.KEY_CLEAR_REASON, "") == "target_net_worth", "game-clear result should keep reason")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
