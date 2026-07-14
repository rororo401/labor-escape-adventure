extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketOrderFlowConfigScript := preload("res://scripts/ui/market_order_flow_config.gd")
const MarketScreenOrderPresenterScript := preload("res://scripts/ui/market_screen_order_presenter.gd")
const MarketScreenRuntimeStateScript := preload("res://scripts/ui/market_screen_runtime_state.gd")


func _initialize() -> void:
	var runtime_state = MarketScreenRuntimeStateScript.new()
	runtime_state.showing_close_report = true
	var order_panel = FakePanel.new()
	var closed_panel = FakePanel.new()

	var missing_stock_flow := MarketScreenOrderPresenterScript.submit_order(
		runtime_state.selected_stock,
		runtime_state.quantity,
		runtime_state.apply,
		order_panel,
		closed_panel,
		null,
		"buy"
	)
	_expect(not bool(missing_stock_flow.get(MarketOrderFlowConfigScript.KEY_HANDLED, true)), "missing stock should not submit through presenter")
	_expect(runtime_state.showing_close_report, "unhandled order should not apply state patch")
	_expect(order_panel.message.is_empty(), "unhandled order should not update order message")
	_expect(closed_panel.message.is_empty(), "unhandled order should not update closed-day message")

	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up a trading day")
	runtime_state.selected_stock = Dictionary(game.get_market_context().get("stocks", [])[0])
	runtime_state.quantity = 1
	var buy_flow := MarketScreenOrderPresenterScript.submit_order(
		runtime_state.selected_stock,
		runtime_state.quantity,
		runtime_state.apply,
		order_panel,
		closed_panel,
		game,
		"buy"
	)
	_expect(bool(buy_flow.get(MarketOrderFlowConfigScript.KEY_HANDLED, false)), "valid order should be handled")
	_expect(bool(buy_flow.get(MarketOrderFlowConfigScript.KEY_RESULT, {}).get(MarketOrderFlowConfigScript.KEY_OK, false)), "valid buy order should succeed")
	_expect(not runtime_state.showing_close_report, "handled order should hide close report")
	_expect(order_panel.message.contains("매수 1주 체결"), "handled order should update order message")
	_expect(closed_panel.message == order_panel.message, "handled order should update closed-day message")
	_expect(game.get_total_held_quantity() == 1, "handled order should reach backend order submission")

	var missing_selection_flow := MarketScreenOrderPresenterScript.submit_order({}, 1, Callable(), null, null, game, "buy")
	_expect(not bool(missing_selection_flow.get(MarketOrderFlowConfigScript.KEY_HANDLED, true)), "missing selected stock should remain unhandled")

	print("Market screen order presenter smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakePanel:
	var message := ""

	func set_message(text: String) -> void:
		message = text
