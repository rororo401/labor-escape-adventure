extends "res://scripts/tests/test_scene_tree.gd"

const GameEndingScript := preload("res://scripts/core/game_ending.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")


func _initialize() -> void:
	_verify_final_day_detection()
	_verify_bad_ending_routes()
	_verify_active_ending_state()
	print("Game ending smoke test passed.")
	finish_test()


func _verify_final_day_detection() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2026-06-29"), "game should set up penultimate day")
	_expect(not GameEndingScript.is_final_day(game), "2026-06-29 should not be final day")
	_expect(game.setup("2026-06-30"), "game should set up final day")
	_expect(GameEndingScript.is_final_day(game), "2026-06-30 should be final day")


func _verify_bad_ending_routes() -> void:
	_expect(GameEndingScript.bad_ending_route(9999999) == GameEndingScript.BAD_ENDING_01_ROUTE, "under 10M route mismatch")
	_expect(GameEndingScript.bad_ending_route(10000000) == GameEndingScript.BAD_ENDING_02_ROUTE, "10M route mismatch")
	_expect(GameEndingScript.bad_ending_route(50000000) == GameEndingScript.BAD_ENDING_03_ROUTE, "50M route mismatch")
	_expect(GameEndingScript.bad_ending_route(200000000) == GameEndingScript.BAD_ENDING_04_ROUTE, "200M route mismatch")
	_expect(GameEndingScript.bad_ending_route(500000000) == GameEndingScript.BAD_ENDING_05_ROUTE, "500M route mismatch")


func _verify_active_ending_state() -> void:
	var running_game := GameStateScript.new()
	_expect(running_game.setup("2016-07-04"), "running game should set up")
	running_game.status.cash = 1000000000
	running_game.day_completed = true
	var running_state := GameEndingScript.active_ending_state(running_game)
	_expect(not bool(running_state.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, true)), "target reached before final day should not be active clear")
	_expect(not bool(running_state.get("game_finished", true)), "target reached before final day should not finish")

	var clear_game := GameStateScript.new()
	_expect(clear_game.setup("2026-06-30"), "clear game should set up")
	clear_game.status.cash = 1000000000
	clear_game.day_completed = true
	var clear_state := GameEndingScript.active_ending_state(clear_game)
	_expect(bool(clear_state.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, false)), "final target reached should clear")
	_expect(clear_state.get(PlayerStatusKeysScript.KEY_ENDING_ROUTE, "") == GameEndingScript.CLEAR_ENDING_ROUTE, "clear route mismatch")

	var bad_game := GameStateScript.new()
	_expect(bad_game.setup("2026-06-30"), "bad game should set up")
	bad_game.status.cash = 500000000
	bad_game.day_completed = true
	var bad_state := GameEndingScript.active_ending_state(bad_game)
	_expect(bool(bad_state.get(PlayerStatusKeysScript.KEY_GAME_OVER, false)), "final target missed should be terminal")
	_expect(bad_state.get(PlayerStatusKeysScript.KEY_GAME_OVER_REASON, "") == PlayerStatusKeysScript.GAME_OVER_REASON_FINAL_BAD_ENDING, "bad ending reason mismatch")
	_expect(int(bad_state.get(PlayerStatusKeysScript.KEY_ENDING_TIER, 0)) == 5, "bad ending tier mismatch")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
