extends "res://scripts/tests/test_scene_tree.gd"

const MarketScene := preload("res://scenes/market/MarketScreen.tscn")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	_expect(game_session.start_new_game("2016-07-01"), "fresh game should start on first tutorial day")

	var game = game_session.get_game()
	var market_context: Dictionary = game.get_market_context()
	var stocks: Array = market_context.get("stocks", [])
	_expect(not stocks.is_empty(), "fresh Friday market should have stocks")
	var first_ticker := String(Dictionary(stocks[0]).get("ticker", ""))
	_expect(game.submit_market_order(first_ticker, "buy", 1).get("ok", false), "fresh Friday should allow first stock buy")
	_expect(game.complete_today("company_work", [], true).get("ok", false), "first workday should complete after buying")
	var sleep_result: Dictionary = game.sleep_to_next_day()
	_expect(sleep_result.get("ok", false), "sleep should advance to the first weekend")
	_expect(sleep_result.get("to_date", "") == "2016-07-02", "fresh flow should reach Saturday 2016-07-02")

	var scene := MarketScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	scene.call("_select_closed_day_category", "go_out")
	await process_frame
	var choice_grid := _helpers.find_node(scene, "ClosedDayChoiceGrid")
	_expect(choice_grid != null, "first weekend choice grid should exist")
	var choice_button := _find_first_choice_button(choice_grid)
	_expect(choice_button != null, "first weekend should expose at least one go-out choice")

	choice_button.emit_signal("pressed")
	await create_timer(0.25).timeout
	var event_layer := _helpers.find_node(scene, "DayEventCgLayer")
	_expect(event_layer != null, "first weekend choice should show event CG layer")
	_expect(_helpers.find_node(scene, "EventCG") != null, "first weekend choice should show event CG")
	_expect(_helpers.find_node(scene, "EventDialogue") != null, "first weekend choice should show event dialogue")

	print("First weekend part-time flow test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _find_first_choice_button(root: Node) -> Button:
	if root == null:
		return null
	if root is Button:
		var button := root as Button
		if not button.text.strip_edges().is_empty():
			return button
	for child in root.get_children():
		var found := _find_first_choice_button(child)
		if found != null:
			return found
	return null
