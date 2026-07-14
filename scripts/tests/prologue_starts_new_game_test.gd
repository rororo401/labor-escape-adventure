extends "res://scripts/tests/test_scene_tree.gd"

const PrologueScene := preload("res://scenes/prologue/PrologueScene.tscn")
const PrologueSceneConfigScript := preload("res://scripts/ui/prologue_scene_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	_expect(game_session.start_new_game("2016-07-02"), "dirty session should start before prologue")

	var before_game = game_session.get_game()
	before_game.status.cash = 1234
	before_game.day_completed = true

	var prologue := PrologueScene.instantiate()
	root.add_child(prologue)
	await process_frame
	await process_frame

	_expect(game_session.is_ready, "prologue should initialize the game session")
	var game = game_session.get_game()
	_expect(game.get_today_context().get("date", "") == PrologueSceneConfigScript.FIRST_MARKET_DATE, "prologue should start the first market date")
	_expect(not game.day_completed, "prologue should reset completion state")
	_expect(game.status.cash != 1234, "prologue should reset player status")
	_expect(game.get_total_held_quantity() == 0, "prologue should reset holdings")

	print("Prologue starts new game test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
