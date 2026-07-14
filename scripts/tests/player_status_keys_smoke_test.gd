extends "res://scripts/tests/test_scene_tree.gd"

const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")


func _initialize() -> void:
	_verify_status_keys()
	_verify_effect_keys()
	_verify_terminal_reason_keys()

	print("Player status keys smoke test passed.")
	finish_test()


func _verify_status_keys() -> void:
	_expect(PlayerStatusKeysScript.KEY_HEALTH == "health", "health key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_CASH == "cash", "cash key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS == "investment_assets", "investment assets key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_MOOD == "mood", "mood key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_FATIGUE == "fatigue", "fatigue key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_NET_WORTH == "net_worth", "net worth key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_TARGET_NET_WORTH == "target_net_worth", "target net worth key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_TARGET_REACHED == "target_reached", "target reached key should stay stable")


func _verify_effect_keys() -> void:
	_expect(PlayerStatusKeysScript.KEY_CASH_DELTA == "cash_delta", "cash delta key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_HEALTH_DELTA == "health_delta", "health delta key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_MOOD_DELTA == "mood_delta", "mood delta key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_FATIGUE_DELTA == "fatigue_delta", "fatigue delta key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_BEFORE == "before", "before key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_AFTER == "after", "after key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_DELTA == "delta", "delta key should stay stable")


func _verify_terminal_reason_keys() -> void:
	_expect(PlayerStatusKeysScript.KEY_GAME_OVER == "game_over", "game-over key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_GAME_CLEAR == "game_clear", "game-clear key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_CLEAR_REASON == "clear_reason", "clear reason key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_ENDING_ROUTE == "ending_route", "ending route key should stay stable")
	_expect(PlayerStatusKeysScript.KEY_ENDING_TIER == "ending_tier", "ending tier key should stay stable")
	_expect(PlayerStatusKeysScript.CLEAR_REASON_TARGET_NET_WORTH == "target_net_worth", "target clear reason should stay stable")
	_expect(PlayerStatusKeysScript.GAME_OVER_REASON_CASH_ZERO == "cash_zero", "cash-zero reason should stay stable")
	_expect(PlayerStatusKeysScript.GAME_OVER_REASON_HEALTH_ZERO == "health_zero", "health-zero reason should stay stable")
	_expect(PlayerStatusKeysScript.GAME_OVER_REASON_FINAL_BAD_ENDING == "final_bad_ending", "final bad-ending reason should stay stable")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
