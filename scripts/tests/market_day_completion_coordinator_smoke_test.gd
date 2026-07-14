extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketDayCompletionCoordinatorScript := preload("res://scripts/ui/market_day_completion_coordinator.gd")
const MarketDayCompletionScreenFlowConfigScript := preload("res://scripts/ui/market_day_completion_screen_flow_config.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketDayFlowTextConfigScript := preload("res://scripts/ui/market_day_flow_text_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	_verify_missing_game_step()
	_verify_trading_day_finish_step()
	_verify_closed_day_event_step()
	print("Market day completion coordinator smoke test passed.")
	finish_test()


func _verify_missing_game_step() -> void:
	var step := MarketDayCompletionCoordinatorScript.next_step(null, "", {})
	_expect(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_ACTION, "") == MarketDayCompletionCoordinatorScript.ACTION_ERROR, "missing game should resolve to error step")
	_expect(
		String(Dictionary(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_STATE, {})).get("message", "")) == MarketDayFlowTextScript.flow_error_message(MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_NOT_STARTED),
		"missing game should include the shared error message"
	)


func _verify_trading_day_finish_step() -> void:
	var game = GameStateScript.new()
	_expect(game.setup("2016-07-01"), "trading game should set up")
	var stocks: Array = game.get_market_context().get("stocks", [])
	_expect(not stocks.is_empty(), "trading game should expose stocks")
	var ticker := String(Dictionary(stocks[0]).get("ticker", ""))
	_expect(game.submit_market_order(ticker, "buy", 1).get("ok", false), "first tutorial day should allow one buy")
	var step := MarketDayCompletionCoordinatorScript.next_step(game, "company_work", game.get_market_context())
	_expect(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_ACTION, "") == MarketDayCompletionCoordinatorScript.ACTION_PLAY_EVENT, "trading completion should request company work CG event")
	_expect(bool(Dictionary(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_RESULT, {})).get("ok", false)), "trading finish step should include completion result")
	_expect(String(Dictionary(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_STATE, {})).get("message", "")).contains("완료"), "trading finish step should include result message")


func _verify_closed_day_event_step() -> void:
	var game = GameStateScript.new()
	var date := _helpers.find_closed_date_with_choice(game, "go_out", "part_time")
	_expect(not date.is_empty(), "should find closed day with part-time choice")
	_expect(game.setup(date), "closed-day game should set up")
	var market_context: Dictionary = game.get_market_context()
	var step := MarketDayCompletionCoordinatorScript.next_step(game, "part_time", market_context)
	_expect(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_ACTION, "") == MarketDayCompletionCoordinatorScript.ACTION_PLAY_EVENT, "closed-day completion should request event CG")
	_expect(Dictionary(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_DAY_ACTION, {})).get("id", "") == "part_time", "event step should expose selected day action")
	_expect(bool(Dictionary(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_RESULT, {})).get("ok", false)), "event step should include completion result")
	_expect(String(Dictionary(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_STATE, {})).get("message", "")).contains("알바"), "event step should include final result message")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
