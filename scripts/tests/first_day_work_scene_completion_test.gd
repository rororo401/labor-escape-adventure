extends "res://scripts/tests/test_scene_tree.gd"

const FirstDayWorkScene := preload("res://scenes/day/FirstDayWorkScene.tscn")
const FirstDayWorkSceneConfigScript := preload("res://scripts/ui/first_day_work_scene_config.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	_expect(game_session.start_new_game("2016-07-01"), "first day game should start")

	var game = game_session.get_game()
	var stocks: Array = game.get_market_context().get("stocks", [])
	_expect(not stocks.is_empty(), "first day should have market stocks")
	var first_ticker := String(Dictionary(stocks[0]).get("ticker", ""))
	_expect(game.submit_market_order(first_ticker, "buy", 1).get("ok", false), "first day should allow one share purchase before work")
	_expect(not game.day_completed, "first day should not be complete before work scene")

	var scene := FirstDayWorkScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	_expect(_helpers.find_node(scene, "SceneBackground") != null, "first work scene should show a background")
	_expect(_helpers.find_node(scene, "DialogueBoxImage") != null, "first work scene should show the shared dialogue box")
	var protagonist := _helpers.find_node(scene, "ProtagonistBust") as TextureRect
	var date_label := _helpers.find_node(scene, "DateLabel") as Label
	_expect(protagonist != null, "first work scene should show the protagonist bust")
	_expect(protagonist.visible, "office visual mode should show the protagonist bust")
	_expect(date_label != null and date_label.text.contains("첫 출근"), "office visual mode should show first-work HUD text")

	for _index in 4:
		scene.call("_advance_dialogue")
		await process_frame
	_expect(not protagonist.visible, "event visual mode should hide the protagonist bust")
	_expect(date_label.text.contains("회사"), "event visual mode should show company HUD text")

	for _index in 18:
		scene.call("_advance_dialogue")
		await process_frame
	await create_timer(0.3).timeout
	await process_frame

	_expect(game.day_completed, "first work scene completion should complete the day")
	_expect(
		game.last_day_result.get("day_action", {}).get("event", {}).get(DayEventKeysScript.KEY_GROUP, "") == DayEventKeysScript.GROUP_COMPANY_WORK,
		"first work scene should complete a company work variant"
	)
	_expect(_helpers.find_node(root, "MarketScreen") != null, "first work scene should return to the market screen")

	print("First-day work scene completion test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
