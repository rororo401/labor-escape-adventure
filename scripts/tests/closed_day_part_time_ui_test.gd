extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketScene := preload("res://scenes/market/MarketScreen.tscn")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	var fixture_game := GameStateScript.new()
	var test_date := _helpers.find_closed_date_with_choice(fixture_game, "go_out", "part_time")
	_expect(not test_date.is_empty(), "should find a closed day where part time is offered")
	game_session.start_new_game(test_date)
	game_session.get_game().random_seed = fixture_game.random_seed

	var scene := MarketScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	scene.call("_select_closed_day_category", "go_out")
	await process_frame
	var choice_grid := _helpers.find_node(scene, "ClosedDayChoiceGrid")
	_expect(choice_grid != null, "closed-day choice grid should exist")
	var part_time_button := _helpers.find_button_containing(choice_grid, "알바")
	_expect(part_time_button != null, "part-time should be visible as an actual choice button")

	part_time_button.emit_signal("pressed")
	await create_timer(0.25).timeout
	var event_layer := _helpers.find_node(scene, "DayEventCgLayer")
	_expect(event_layer != null, "part-time should immediately show event CG layer")
	_expect(_helpers.find_node(scene, "EventCG") != null, "part-time should show event CG")
	_expect(_helpers.find_node(scene, "EventDialogue") != null, "part-time should show event dialogue")

	var flow_button := _helpers.find_node(scene, "ClosedDayFlowButton") as Button
	_expect(flow_button != null, "closed-day flow button should exist")
	for _index in 8:
		event_layer.call("_advance")
		await process_frame
	await create_timer(0.25).timeout
	_expect(flow_button.text == "잠들기", "part-time should end with sleep button active")
	_expect(not flow_button.disabled, "sleep button should be enabled after part-time event")

	print("Closed-day part-time UI test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
