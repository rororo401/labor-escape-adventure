extends "res://scripts/tests/test_scene_tree.gd"

const MarketScene := preload("res://scenes/market/MarketScreen.tscn")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	game_session.start_new_game("2016-07-02")
	var scene := MarketScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var stock_panel := scene.get_node_or_null("StockListPanel")
	var order_panel := scene.get_node_or_null("OrderPanel")
	var closed_panel := scene.get_node_or_null("ClosedDayPanel")

	_expect(stock_panel != null, "stock panel should exist")
	_expect(order_panel != null, "order panel should exist")
	_expect(closed_panel != null, "closed-day panel should exist")
	_expect(not stock_panel.visible, "stock list should be hidden on non-trading days")
	_expect(not order_panel.visible, "order panel should be hidden on non-trading days")
	_expect(closed_panel.visible, "closed-day panel should be visible on non-trading days")
	var category_row := _helpers.find_node(scene, "ClosedDayCategoryRow")
	var choice_grid := _helpers.find_node(scene, "ClosedDayChoiceGrid")
	var flow_button := _helpers.find_node(scene, "ClosedDayFlowButton")
	_expect(category_row != null, "closed-day category row should exist")
	_expect(choice_grid != null, "closed-day choice grid should exist")
	_expect(category_row.get_child_count() == 2, "closed-day category row should show two categories")
	_expect(choice_grid.get_child_count() == 0, "closed-day choices should wait for category selection")
	category_row.get_child(0).emit_signal("pressed")
	await process_frame
	_expect(choice_grid.get_child_count() == 4, "closed-day category should reveal four random choices")
	choice_grid.get_child(0).emit_signal("pressed")
	await create_timer(0.25).timeout
	var event_layer := _helpers.find_node(scene, "DayEventCgLayer")
	_expect(event_layer != null, "closed-day action should immediately show event CG layer")
	_expect(_helpers.find_node(scene, "EventCG") != null, "event layer should include CG texture node")
	_expect(_helpers.find_node(scene, "EventTitle") != null, "event layer should include title")
	_expect(_helpers.find_node(scene, "EventDialogue") != null, "event layer should include dialogue text")

	print("Market closed UI smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
