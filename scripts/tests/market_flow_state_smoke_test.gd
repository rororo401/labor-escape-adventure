extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketDayFlowTextConfigScript := preload("res://scripts/ui/market_day_flow_text_config.gd")
const MarketFlowActionConfigScript := preload("res://scripts/ui/market_flow_action_config.gd")
const MarketFlowControlStateConfigScript := preload("res://scripts/ui/market_flow_control_state_config.gd")
const MarketFlowStateScript := preload("res://scripts/ui/market_flow_state.gd")


func _initialize() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up first market day")

	var state: Dictionary = MarketFlowStateScript.build_control_state(
		game,
		true,
		"company_work",
		false,
		false,
		MarketDayFlowTextScript.ready_text(game)
	)
	_expect(bool(state.get(MarketFlowControlStateConfigScript.KEY_CAN_TRADE, false)), "fresh open market should allow trading")
	var order_flow: Dictionary = state.get(MarketFlowControlStateConfigScript.KEY_ORDER_FLOW, {})
	_expect(not bool(order_flow.get(MarketFlowControlStateConfigScript.KEY_GAME_FINISHED, true)), "fresh game should not be finished")
	_expect(not bool(order_flow.get(MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED, true)), "fresh game should not be completed")
	_expect(String(order_flow.get(MarketFlowControlStateConfigScript.KEY_READY_TEXT, "")) == "1주 매수 필요", "first day ready text should explain required purchase")

	var closed_flow: Dictionary = state.get(MarketFlowControlStateConfigScript.KEY_CLOSED_FLOW, {})
	_expect(bool(closed_flow.get(MarketFlowControlStateConfigScript.KEY_HAS_SELECTION, false)), "selected action id should be reflected")
	_expect(MarketFlowStateScript.can_select_day_action(game, false), "unfinished day should allow action selection")
	_expect(not MarketFlowStateScript.can_select_day_action(game, true), "completion in progress should block action selection")
	_expect(MarketFlowStateScript.can_handle_flow(false, false), "idle flow button should be accepted")
	_expect(not MarketFlowStateScript.can_handle_flow(true, false), "sleeping flow should be blocked")
	_expect(not MarketFlowStateScript.can_handle_flow(false, true), "completing flow should be blocked")
	_expect(
		String(MarketFlowStateScript.flow_button_action(game, true, false).get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketFlowStateScript.FLOW_ACTION_IGNORE,
		"sleeping flow button action should be ignored"
	)
	_expect(
		String(MarketFlowStateScript.flow_button_action(game, false, false).get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketFlowStateScript.FLOW_ACTION_COMPLETE_DAY,
		"idle unfinished flow button action should complete the day"
	)
	var first_day_block: Dictionary = MarketFlowStateScript.day_completion_action(game)
	_expect(String(first_day_block.get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketFlowStateScript.DAY_ACTION_MESSAGE, "first tutorial day should show a message before buying")
	_expect(
		String(first_day_block.get(MarketFlowActionConfigScript.KEY_MESSAGE, "")) == MarketDayFlowTextScript.flow_error_message(MarketDayFlowTextConfigScript.FLOW_ERROR_FIRST_DAY_STOCK_REQUIRED),
		"first tutorial day message should use shared flow error copy"
	)
	var missing_game_action: Dictionary = MarketFlowStateScript.day_completion_action(null)
	_expect(String(missing_game_action.get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketFlowStateScript.DAY_ACTION_MESSAGE, "missing game should show a message")
	_expect(
		String(missing_game_action.get(MarketFlowActionConfigScript.KEY_MESSAGE, "")) == MarketDayFlowTextScript.flow_error_message(MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_NOT_STARTED),
		"missing game should use shared flow error copy"
	)
	_expect(MarketFlowStateScript.should_play_day_event_after_completion({"is_open": false}), "closed days should play day-event scenes")
	_expect(MarketFlowStateScript.should_play_day_event_after_completion({"is_open": true}), "open market days should play company work scenes")

	var ticker := String(Dictionary(game.get_market_context().get("stocks", [])[0]).get("ticker", ""))
	_expect(game.submit_market_order(ticker, "buy", 1).get("ok", false), "test should buy one share")
	_expect(
		String(MarketFlowStateScript.day_completion_action(game).get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketFlowStateScript.DAY_ACTION_FIRST_DAY_SCENE,
		"first tutorial day should open the first-day event scene after buying"
	)
	_expect(game.complete_today("company_work", [], true).get("ok", false), "test should complete the first day")
	var completed_state: Dictionary = MarketFlowStateScript.build_control_state(
		game,
		true,
		"company_work",
		false,
		false,
		MarketDayFlowTextScript.ready_text(game)
	)
	_expect(not bool(completed_state.get(MarketFlowControlStateConfigScript.KEY_CAN_TRADE, true)), "completed days should block trading")
	var completed_order_flow: Dictionary = completed_state.get(MarketFlowControlStateConfigScript.KEY_ORDER_FLOW, {})
	_expect(bool(completed_order_flow.get(MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED, false)), "completed state should expose day completion")
	_expect(
		String(MarketFlowStateScript.flow_button_action(game, false, false).get(MarketFlowActionConfigScript.KEY_ACTION, "")) == MarketFlowStateScript.FLOW_ACTION_SLEEP,
		"completed flow button action should sleep to the next day"
	)

	var target_reached_game := GameStateScript.new()
	_expect(target_reached_game.setup("2016-07-04"), "target-reached game should set up before final day")
	target_reached_game.status.cash = 1000000000
	var target_reached_state: Dictionary = MarketFlowStateScript.build_control_state(
		target_reached_game,
		true,
		"company_work",
		false,
		false,
		MarketDayFlowTextScript.ready_text(target_reached_game)
	)
	_expect(bool(target_reached_state.get(MarketFlowControlStateConfigScript.KEY_CAN_TRADE, false)), "target reached before final day should still allow trading")

	var invested_cash_zero_game := GameStateScript.new()
	_expect(invested_cash_zero_game.setup("2016-07-04"), "invested cash-zero game should set up")
	invested_cash_zero_game.status.cash = 0
	invested_cash_zero_game.status.investment_assets = 1000
	var invested_cash_zero_state: Dictionary = MarketFlowStateScript.build_control_state(
		invested_cash_zero_game,
		true,
		"company_work",
		false,
		false,
		MarketDayFlowTextScript.ready_text(invested_cash_zero_game)
	)
	_expect(bool(invested_cash_zero_state.get(MarketFlowControlStateConfigScript.KEY_CAN_TRADE, false)), "cash zero with investment assets should keep trade controls enabled")

	var final_clear_game := GameStateScript.new()
	_expect(final_clear_game.setup("2026-06-30"), "final clear game should set up")
	final_clear_game.status.cash = 1000000000
	final_clear_game.day_completed = true
	var final_clear_state: Dictionary = MarketFlowStateScript.build_control_state(
		final_clear_game,
		true,
		"company_work",
		false,
		false,
		MarketDayFlowTextScript.ready_text(final_clear_game)
	)
	var final_order_flow: Dictionary = final_clear_state.get(MarketFlowControlStateConfigScript.KEY_ORDER_FLOW, {})
	_expect(bool(final_order_flow.get(MarketFlowControlStateConfigScript.KEY_GAME_FINISHED, false)), "final clear should finish flow")
	_expect(bool(final_order_flow.get(MarketFlowControlStateConfigScript.KEY_GAME_CLEAR, false)), "final clear should expose clear flag")

	print("Market flow state smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
