extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const MarketSleepFlowScript := preload("res://scripts/ui/market_sleep_flow.gd")
const MarketSleepFlowConfigScript := preload("res://scripts/ui/market_sleep_flow_config.gd")


class FakeSleepSequence:
	extends Control

	var calls: Array[String] = []

	func play_sleep_intro(_date: String = "") -> void:
		calls.append("intro")

	func play_date_transition(_result: Dictionary) -> void:
		calls.append("date_transition")

	func play_morning(_result: Dictionary) -> void:
		calls.append("morning")

	func cancel_after_error(_duration: float = 0.20) -> void:
		calls.append("cancel")


class FakeSleepFlow:
	extends MarketSleepFlowScript

	var fake_sequence := FakeSleepSequence.new()

	func _make_sleep_sequence() -> Control:
		return fake_sequence


func _initialize() -> void:
	var error_game := GameStateScript.new()
	_expect(error_game.setup("2016-07-01"), "error game should set up")
	var error_flow := FakeSleepFlow.new()
	var error_result: Dictionary = await error_flow.play_until_transition(root, error_game)
	_expect(not bool(error_result.get(MarketSleepFlowConfigScript.KEY_OK, true)), "unfinished day should fail before sleeping")
	_expect(String(error_result.get(MarketSleepFlowConfigScript.KEY_RESULT, {}).get(GameDayProgressKeysScript.KEY_ERROR, "")) == "day_not_completed", "unfinished day should preserve backend sleep error")
	_expect(error_flow.fake_sequence.calls == ["intro", "cancel"], "error sleep flow should play intro then cancel")
	_expect(not bool(error_result.get(MarketSleepFlowConfigScript.KEY_ERROR_STATE, {}).get("is_sleep_sequence", true)), "error state should clear sleep sequence")

	var success_game := GameStateScript.new()
	_expect(success_game.setup("2016-07-01"), "success game should set up")
	var ticker := String(Dictionary(success_game.get_market_context().get("stocks", [])[0]).get("ticker", ""))
	_expect(success_game.submit_market_order(ticker, "buy", 1).get("ok", false), "test should buy one share")
	_expect(success_game.complete_today("company_work", [], true).get("ok", false), "test should complete the day before sleeping")

	var success_flow := FakeSleepFlow.new()
	var transition_result: Dictionary = await success_flow.play_until_transition(root, success_game)
	_expect(bool(transition_result.get(MarketSleepFlowConfigScript.KEY_OK, false)), "completed day should sleep through date transition")
	_expect(String(transition_result.get(MarketSleepFlowConfigScript.KEY_RESULT, {}).get(GameDayProgressKeysScript.KEY_TO_DATE, "")) == "2016-07-02", "sleep result should advance to Saturday")
	_expect(success_flow.fake_sequence.calls == ["intro", "date_transition"], "success flow should play intro then date transition")
	_expect(bool(transition_result.get(MarketSleepFlowConfigScript.KEY_TRANSITION_STATE, {}).get("is_sleep_sequence", false)), "transition state should keep sleep sequence active")

	var morning_state: Dictionary = await success_flow.play_morning(transition_result.get(MarketSleepFlowConfigScript.KEY_RESULT, {}))
	_expect(success_flow.fake_sequence.calls == ["intro", "date_transition", "morning"], "morning flow should finish the sequence")
	_expect(not bool(morning_state.get("is_sleep_sequence", true)), "morning state should clear sleep sequence")

	print("Market sleep flow smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
