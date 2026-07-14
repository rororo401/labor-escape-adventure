extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayResultStateScript := preload("res://scripts/ui/market_day_result_state.gd")
const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const MarketSleepScreenFlowScript := preload("res://scripts/ui/market_sleep_screen_flow.gd")
const MarketSleepFlowConfigScript := preload("res://scripts/ui/market_sleep_flow_config.gd")


class FakeSleepFlow:
	extends RefCounted

	var should_succeed := true
	var calls: Array[String] = []
	var timeline: Array[String] = []

	func play_until_transition(_parent: Node, _game) -> Dictionary:
		calls.append("transition")
		timeline.append("transition")
		if should_succeed:
			return {
				MarketSleepFlowConfigScript.KEY_OK: true,
				MarketSleepFlowConfigScript.KEY_TRANSITION_STATE: MarketDayResultStateScript.after_sleep_transition_state(),
				MarketSleepFlowConfigScript.KEY_RESULT: {
					GameDayProgressKeysScript.KEY_TO_DATE: "2016-07-02"
				}
			}
		return {
			MarketSleepFlowConfigScript.KEY_OK: false,
			MarketSleepFlowConfigScript.KEY_ERROR_STATE: MarketDayResultStateScript.sleep_error_state("day_not_completed")
		}

	func play_morning(_result: Dictionary) -> Dictionary:
		calls.append("morning")
		timeline.append("morning_start")
		await Engine.get_main_loop().process_frame
		timeline.append("morning_finished")
		return MarketDayResultStateScript.after_sleep_morning_state()


class FakeSleepScreenFlow:
	extends MarketSleepScreenFlowScript

	var fake_sleep_flow := FakeSleepFlow.new()

	func _make_sleep_flow():
		return fake_sleep_flow


class CallbackRecorder:
	extends RefCounted

	var states: Array[Dictionary] = []
	var messages: Array[String] = []
	var refresh_flow_count := 0
	var refresh_market_count := 0
	var market_reveal_count := 0
	var timeline: Array[String] = []

	func apply_state(state: Dictionary) -> void:
		states.append(state)

	func set_message(message: String) -> void:
		messages.append(message)

	func refresh_flow_controls() -> void:
		refresh_flow_count += 1

	func refresh_market() -> void:
		refresh_market_count += 1
		timeline.append("refresh_market")

	func market_reveal_ready() -> void:
		market_reveal_count += 1
		timeline.append("market_reveal_ready")


func _initialize() -> void:
	await _verify_success_flow()
	await _verify_error_flow()
	print("Market sleep screen flow smoke test passed.")
	finish_test()


func _verify_success_flow() -> void:
	var flow := FakeSleepScreenFlow.new()
	flow.fake_sleep_flow.should_succeed = true
	var recorder := CallbackRecorder.new()
	recorder.timeline = flow.fake_sleep_flow.timeline
	await flow.play(root, {}, _callbacks(recorder))

	_expect(flow.fake_sleep_flow.calls == ["transition", "morning"], "success flow should run transition then morning")
	_expect(recorder.states.size() == 3, "success flow should apply start, transition, and morning states")
	_expect(bool(recorder.states[0].get("is_sleep_sequence", false)), "success flow should start sleep sequence")
	_expect(bool(recorder.states[1].get("is_sleep_sequence", false)), "success flow should keep sleep sequence during transition")
	_expect(not bool(recorder.states[2].get("is_sleep_sequence", true)), "success flow should clear sleep sequence after morning")
	_expect(recorder.refresh_flow_count == 2, "success flow should disable controls at start and enable them after morning")
	_expect(recorder.refresh_market_count == 1, "success flow should prepare the next market screen exactly once")
	_expect(recorder.market_reveal_count == 1, "success flow should resume market events after the morning briefing finishes")
	_expect(recorder.timeline == ["transition", "refresh_market", "morning_start", "morning_finished", "market_reveal_ready"], "next-day market UI should be prepared under the transition cover before morning, while market events wait until morning finishes")
	_expect(recorder.messages == [""], "success flow should pass transition message through")


func _verify_error_flow() -> void:
	var flow := FakeSleepScreenFlow.new()
	flow.fake_sleep_flow.should_succeed = false
	var recorder := CallbackRecorder.new()
	await flow.play(root, {}, _callbacks(recorder))

	_expect(flow.fake_sleep_flow.calls == ["transition"], "error flow should not play morning")
	_expect(recorder.states.size() == 2, "error flow should apply start and error states")
	_expect(bool(recorder.states[0].get("is_sleep_sequence", false)), "error flow should start sleep sequence")
	_expect(not bool(recorder.states[1].get("is_sleep_sequence", true)), "error flow should clear sleep sequence")
	_expect(recorder.refresh_flow_count == 2, "error flow should refresh controls after start and error")
	_expect(recorder.refresh_market_count == 0, "error flow should not refresh market")
	_expect(recorder.market_reveal_count == 0, "error flow should not resume market events")
	_expect(recorder.messages.size() == 1 and not recorder.messages[0].is_empty(), "error flow should show error message")


func _callbacks(recorder: CallbackRecorder) -> Dictionary:
	return {
		MarketSleepFlowConfigScript.CALLBACK_APPLY_STATE: recorder.apply_state,
		MarketSleepFlowConfigScript.CALLBACK_SET_MESSAGE: recorder.set_message,
		MarketSleepFlowConfigScript.CALLBACK_REFRESH_FLOW_CONTROLS: recorder.refresh_flow_controls,
		MarketSleepFlowConfigScript.CALLBACK_REFRESH_MARKET: recorder.refresh_market,
		MarketSleepFlowConfigScript.CALLBACK_MARKET_REVEAL_READY: recorder.market_reveal_ready
	}


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
