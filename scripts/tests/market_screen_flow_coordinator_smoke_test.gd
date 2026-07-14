extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketFlowActionConfigScript := preload("res://scripts/ui/market_flow_action_config.gd")
const MarketScreenFlowCoordinatorScript := preload("res://scripts/ui/market_screen_flow_coordinator.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")


func _initialize() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up first market day")
	var order_panel = FakePanel.new()
	var closed_panel = FakePanel.new()

	var flow := MarketScreenFlowCoordinatorScript.flow_button_action(game, false, false)
	_expect(
		String(flow.get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketScreenFlowCoordinatorScript.ACTION_COMPLETE_DAY,
		"unfinished idle day should request completion"
	)

	var blocked_flow := MarketScreenFlowCoordinatorScript.flow_button_action(game, true, false)
	_expect(
		String(blocked_flow.get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketScreenFlowCoordinatorScript.ACTION_IGNORE,
		"sleeping state should ignore flow button"
	)
	var blocked_completion := MarketScreenFlowCoordinatorScript.day_completion_request(game, order_panel, closed_panel)
	_expect(
		String(blocked_completion.get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketScreenFlowCoordinatorScript.ACTION_MESSAGE,
		"first tutorial day before buying should show a message"
	)
	_expect(order_panel.message.contains("최소 1주"), "message action should update order panel")
	_expect(closed_panel.message == order_panel.message, "message action should update closed-day panel")

	var ticker := String(Dictionary(game.get_market_context().get("stocks", [])[0]).get("ticker", ""))
	_expect(game.submit_market_order(ticker, "buy", 1).get("ok", false), "test should buy one share")
	var first_day_scene := MarketScreenFlowCoordinatorScript.day_completion_request(game, order_panel, closed_panel)
	_expect(
		String(first_day_scene.get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketScreenFlowCoordinatorScript.ACTION_CHANGE_SCENE,
		"first tutorial day after buying should change to the first-day scene"
	)
	_expect(
		MarketScreenFlowCoordinatorScript.FIRST_DAY_SCENE_PATH == UiScenePathsScript.FIRST_DAY_WORK,
		"first-day scene path should use the shared scene path"
	)
	_expect(
		String(first_day_scene.get(MarketFlowActionConfigScript.KEY_SCENE_PATH, "")) == UiScenePathsScript.FIRST_DAY_WORK,
		"first-day scene action should carry the shared scene path"
	)

	_expect(game.complete_today("company_work", [], true).get("ok", false), "test should complete the day")
	var sleep_flow := MarketScreenFlowCoordinatorScript.flow_button_action(game, false, false)
	_expect(
		String(sleep_flow.get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketScreenFlowCoordinatorScript.ACTION_SLEEP,
		"completed day should request sleep"
	)

	var missing_game := MarketScreenFlowCoordinatorScript.day_completion_request(null, order_panel, closed_panel)
	_expect(
		String(missing_game.get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketScreenFlowCoordinatorScript.ACTION_MESSAGE,
		"missing game should show a message"
	)

	print("Market screen flow coordinator smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakePanel:
	var message := ""

	func set_message(text: String) -> void:
		message = text
