extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketFlowControlStateConfigScript := preload("res://scripts/ui/market_flow_control_state_config.gd")
const MarketScreenFlowControlsCoordinatorScript := preload("res://scripts/ui/market_screen_flow_controls_coordinator.gd")
const MarketScreenRuntimeStateScript := preload("res://scripts/ui/market_screen_runtime_state.gd")


func _initialize() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up first market day")
	var runtime_state = MarketScreenRuntimeStateScript.new()
	runtime_state.selected_day_action_id = "company_work"
	var order_panel = FakeOrderPanel.new()
	var closed_panel = FakeClosedDayPanel.new()

	var open_state := MarketScreenFlowControlsCoordinatorScript.refresh(
		game,
		runtime_state.selected_day_action_id,
		runtime_state.is_sleep_sequence,
		runtime_state.is_completing_day,
		game.get_market_context(),
		order_panel,
		closed_panel
	)
	_expect(bool(open_state.get(MarketFlowControlStateConfigScript.KEY_CAN_TRADE, false)), "open unfinished market should allow trading")
	_expect(order_panel.can_trade, "coordinator should apply trade button state")
	_expect(order_panel.ready_text == "1주 매수 필요", "coordinator should apply first-day ready text")
	_expect(not closed_panel.flow_disabled, "coordinator should enable closed-day flow when an action is selected")

	var ticker := String(Dictionary(game.get_market_context().get("stocks", [])[0]).get("ticker", ""))
	_expect(game.submit_market_order(ticker, "buy", 1).get("ok", false), "test should buy a first-day stock")
	_expect(game.complete_today("company_work", [], true).get("ok", false), "test should complete the day")
	var completed_state := MarketScreenFlowControlsCoordinatorScript.refresh(
		game,
		runtime_state.selected_day_action_id,
		runtime_state.is_sleep_sequence,
		runtime_state.is_completing_day,
		game.get_market_context(),
		order_panel,
		closed_panel
	)
	_expect(not bool(completed_state.get(MarketFlowControlStateConfigScript.KEY_CAN_TRADE, true)), "completed market day should block trading")
	_expect(not order_panel.can_trade, "coordinator should disable trade buttons on completed day")
	_expect(order_panel.day_completed, "coordinator should apply completed order flow")

	runtime_state.is_completing_day = true
	var completing_state := MarketScreenFlowControlsCoordinatorScript.refresh(
		game,
		runtime_state.selected_day_action_id,
		runtime_state.is_sleep_sequence,
		runtime_state.is_completing_day,
		{"is_open": false},
		order_panel,
		closed_panel
	)
	_expect(bool(completing_state.get(MarketFlowControlStateConfigScript.KEY_CLOSED_FLOW, {}).get(MarketFlowControlStateConfigScript.KEY_COMPLETING_DAY, false)), "coordinator should expose completing state")
	_expect(closed_panel.completing_day, "coordinator should apply completing closed-day flow")

	MarketScreenFlowControlsCoordinatorScript.refresh(null, "", false, false, {}, null, null)

	print("Market screen flow-controls coordinator smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakeOrderPanel:
	var can_trade := false
	var game_finished := false
	var game_clear := false
	var game_over := false
	var day_completed := false
	var sleep_sequence := false
	var ready_text := ""

	func update_trade_buttons(next_can_trade: bool) -> void:
		can_trade = next_can_trade

	func update_flow_button(
		next_game_finished: bool,
		next_game_clear: bool,
		next_game_over: bool,
		next_day_completed: bool,
		next_sleep_sequence: bool,
		next_ready_text: String
	) -> void:
		game_finished = next_game_finished
		game_clear = next_game_clear
		game_over = next_game_over
		day_completed = next_day_completed
		sleep_sequence = next_sleep_sequence
		ready_text = next_ready_text


class FakeClosedDayPanel:
	var game_finished := false
	var game_clear := false
	var game_over := false
	var day_completed := false
	var sleep_sequence := false
	var completing_day := false
	var has_selection := false
	var flow_disabled := true

	func update_flow_button(
		next_game_finished: bool,
		next_game_clear: bool,
		next_game_over: bool,
		next_day_completed: bool,
		next_sleep_sequence: bool,
		next_completing_day: bool,
		next_has_selection: bool
	) -> void:
		game_finished = next_game_finished
		game_clear = next_game_clear
		game_over = next_game_over
		day_completed = next_day_completed
		sleep_sequence = next_sleep_sequence
		completing_day = next_completing_day
		has_selection = next_has_selection
		flow_disabled = next_game_finished or next_day_completed or next_sleep_sequence or next_completing_day or not next_has_selection
