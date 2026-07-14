extends "res://scripts/tests/test_scene_tree.gd"

const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")


func _initialize() -> void:
	_expect(GameDifficultyScript.normalize("unknown") == GameDifficultyScript.HARD, "unknown difficulty should fall back to the existing hard balance")
	_expect(GameDifficultyScript.salary_multiplier(GameDifficultyScript.HARD) == 1.0, "hard should preserve existing salary")
	_expect(GameDifficultyScript.salary_multiplier(GameDifficultyScript.NORMAL) == 2.75, "normal should use the calibrated salary multiplier")
	_expect(GameDifficultyScript.salary_multiplier(GameDifficultyScript.EASY) == 7.0, "easy should use the calibrated salary multiplier")
	_expect(GameDifficultyScript.display_name(GameDifficultyScript.EASY) == "이지", "easy should have a Korean display name")
	print("Game difficulty smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
