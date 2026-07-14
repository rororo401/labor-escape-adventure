extends "res://scripts/tests/test_scene_tree.gd"

const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")


func _initialize() -> void:
	_expect(GameSessionAccessScript.KEY_SESSION == "session", "session payload key should stay stable")
	_expect(GameSessionAccessScript.KEY_GAME == "game", "game payload key should stay stable")
	_expect(GameSessionAccessScript.KEY_IS_READY == "is_ready", "session ready key should stay stable")

	var game_session := GameSessionAccessScript.get_from_tree(self)
	_expect(game_session != null, "GameSession access should find the autoload from the tree")
	_expect(not GameSessionAccessScript.is_ready(game_session), "GameSession should start unready in a fresh test tree")
	_expect(game_session.start_new_game("2016-07-01"), "GameSession access should return a usable session")
	_expect(GameSessionAccessScript.is_ready(game_session), "GameSession should report ready after start")
	_expect(game_session.get_game().get_today_context().get("date", "") == "2016-07-01", "GameSession should expose the started game")

	print("GameSession access smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
