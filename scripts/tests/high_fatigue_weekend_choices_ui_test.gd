extends "res://scripts/tests/test_scene_tree.gd"

const MarketScene := preload("res://scenes/market/MarketScreen.tscn")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	_expect(game_session.start_new_game("2016-07-02"), "test game should start on the first weekend")

	var game = game_session.get_game()
	game.status.fatigue = 95

	var scene := MarketScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var category_row := _helpers.find_node(scene, "ClosedDayCategoryRow")
	_expect(category_row != null, "closed-day category row should exist")
	_expect(category_row.get_child_count() == 2, "high-fatigue weekend should still show stay-home and go-out categories")
	_expect(_helpers.find_button_containing(category_row, "집에") != null, "stay-home category should be visible")
	_expect(_helpers.find_button_containing(category_row, "외출") != null, "go-out category should be visible")

	var flow_button := _helpers.find_node(scene, "ClosedDayFlowButton") as Button
	_expect(flow_button != null, "closed-day flow button should exist")
	_expect(flow_button.disabled, "flow button should wait until the player chooses a weekend action")

	print("High-fatigue weekend choices UI test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
