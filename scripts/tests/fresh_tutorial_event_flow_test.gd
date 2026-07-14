extends "res://scripts/tests/test_scene_tree.gd"

const MarketScene := preload("res://scenes/market/MarketScreen.tscn")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)

	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	_expect(game_session.start_new_game("2016-07-01"), "fresh tutorial game should start")

	var scene := MarketScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var flow_button := _helpers.find_button_containing(scene, "1주 매수 필요")
	var buy_button := _helpers.find_node(scene, "BuyButton") as Button
	_expect(flow_button != null, "fresh first day should explain that one share is required")
	_expect(buy_button != null and not buy_button.disabled, "fresh first day should allow buying")

	flow_button.emit_signal("pressed")
	await process_frame
	_expect(_helpers.find_node(root, "FirstDayWorkScene") == null, "first event should not start before buying")

	buy_button.emit_signal("pressed")
	await process_frame
	await process_frame

	flow_button = _helpers.find_button_containing(scene, "회사 출근하기")
	_expect(flow_button != null, "first day should show the company event entry after buying")
	flow_button.emit_signal("pressed")
	await process_frame
	await process_frame

	_expect(_helpers.find_node(root, "FirstDayWorkScene") != null, "fresh first-day flow should open the company event scene")

	print("Fresh tutorial event flow test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
