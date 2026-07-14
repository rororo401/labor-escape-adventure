extends "res://scripts/tests/test_scene_tree.gd"

const MarketScene := preload("res://scenes/market/MarketScreen.tscn")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	game_session.start_new_game("2016-07-01")

	var scene := MarketScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var date_label := _helpers.find_node(scene, "DateLabel") as Label
	var buy_button := _helpers.find_node(scene, "BuyButton") as Button
	_expect(date_label != null, "date label should exist")
	_expect(buy_button != null, "buy button should exist")
	_expect(date_label.text.contains("금요일 아침"), "first trading day should be labeled as Friday morning")
	_expect(not buy_button.disabled, "buy button should be enabled on first Friday morning")

	var game = game_session.get_game()
	_expect(game.get_total_held_quantity() == 0, "first day should start with no holdings")
	buy_button.emit_signal("pressed")
	await process_frame
	await process_frame
	_expect(game.get_total_held_quantity() == 1, "buy button should purchase one share")
	_expect(not buy_button.disabled, "buy button should remain enabled before day completion")

	game.complete_today("company_work", [], true)
	scene.call("_refresh_market")
	await process_frame
	_expect(date_label.text.contains("금요일 장마감"), "completed trading day should be labeled as market close")

	print("Market first-day buy UI test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
