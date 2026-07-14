extends "res://scripts/tests/test_scene_tree.gd"

const PlayerStatusScript := preload("res://scripts/core/player_status.gd")


func _initialize() -> void:
	var invested := PlayerStatusScript.new()
	invested.cash = 0
	invested.investment_assets = 1
	_expect(not invested.is_game_over(), "cash zero with investment assets should remain solvent")
	_expect(invested.get_game_over_reason().is_empty(), "solvent invested status should not expose a game-over reason")

	invested.investment_assets = 0
	_expect(invested.is_game_over(), "zero cash and zero investment assets should remain game over")
	_expect(invested.get_game_over_reason() == "cash_zero", "fully insolvent status should keep the cash-zero reason")

	var unhealthy_investor := PlayerStatusScript.new()
	unhealthy_investor.cash = 0
	unhealthy_investor.investment_assets = 1
	unhealthy_investor.health = 0
	_expect(unhealthy_investor.is_game_over(), "health zero should remain game over regardless of investment assets")
	_expect(unhealthy_investor.get_game_over_reason() == "health_zero", "health-zero reason should remain stable for a solvent portfolio")

	print("Player status solvency smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
