extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const MarketDayCompletionFlowScript := preload("res://scripts/ui/market_day_completion_flow.gd")
const MarketDayCompletionScreenFlowConfigScript := preload("res://scripts/ui/market_day_completion_screen_flow_config.gd")
const MarketDayCompletionScreenFlowScript := preload("res://scripts/ui/market_day_completion_screen_flow.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	await _verify_error_callback()
	await _verify_trading_finish_callback()
	await _verify_event_fallback_finish_callback()
	await _verify_event_runner_callback_mode()
	await _verify_multiple_playback_events_callback_mode()
	await _verify_result_starts_under_final_fade()
	await _verify_workday_departure_transition_callback_mode()
	await _verify_summer_playback_event_cg()

	for child in root.get_children():
		child.free()
	await process_frame

	print("Market day completion screen flow smoke test passed.")
	finish_test()


func _verify_error_callback() -> void:
	var calls: Array[Dictionary] = []
	var flow = MarketDayCompletionScreenFlowScript.new()
	await flow.play(
		_make_host(),
		null,
		null,
		"",
		{},
		"",
		MarketDayCompletionScreenFlowScript.EVENT_MODE_AWAIT,
		{
			MarketDayCompletionScreenFlowConfigScript.CALLBACK_APPLY_ERROR: func(step: Dictionary, update_closed_day_choices: bool) -> void:
				calls.append({
					"action": step.get(MarketDayCompletionScreenFlowConfigScript.KEY_ACTION, ""),
					"update_closed_day_choices": update_closed_day_choices
				}),
			MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH: func(_result: Dictionary) -> void:
				calls.append({"action": "unexpected_finish"}),
			MarketDayCompletionScreenFlowConfigScript.CALLBACK_UPDATE_CLOSED_DAY_CHOICES: false
		}
	)
	_expect(calls.size() == 1, "error step should call only the error callback")
	_expect(calls[0].get("action", "") == "error", "error callback should receive error step")
	_expect(not bool(calls[0].get("update_closed_day_choices", true)), "error callback should receive update flag")


func _verify_trading_finish_callback() -> void:
	var game = GameStateScript.new()
	_expect(game.setup("2016-07-01"), "trading game should set up")
	var stocks: Array = game.get_market_context().get("stocks", [])
	_expect(not stocks.is_empty(), "trading game should expose stocks")
	var ticker := String(Dictionary(stocks[0]).get("ticker", ""))
	_expect(game.submit_market_order(ticker, "buy", 1).get("ok", false), "first tutorial day should allow one buy")

	var results: Array[Dictionary] = []
	var flow = MarketDayCompletionScreenFlowScript.new()
	await flow.play(
		_make_host(),
		null,
		game,
		"company_work",
		game.get_market_context(),
		"",
		MarketDayCompletionScreenFlowScript.EVENT_MODE_AWAIT,
			{
				MarketDayCompletionScreenFlowConfigScript.CALLBACK_APPLY_ERROR: func(_step: Dictionary, _update_closed_day_choices: bool) -> void:
					results.append({"ok": false}),
				MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH: func(result: Dictionary) -> void:
					results.append(result),
			}
		)
	_expect(results.size() == 1, "finish step should call finish callback once")
	_expect(bool(results[0].get("ok", false)), "finish callback should receive successful result")
	var day_event := Dictionary(Dictionary(results[0].get("day_action", {})).get("event", {}))
	_expect(String(day_event.get(DayEventKeysScript.KEY_GROUP, "")) == DayEventKeysScript.GROUP_COMPANY_WORK, "finish result should resolve to a company work variant")


func _verify_event_fallback_finish_callback() -> void:
	var game = GameStateScript.new()
	var date := _helpers.find_closed_date_with_choice(game, "go_out", "part_time")
	_expect(not date.is_empty(), "should find closed day with part-time choice")
	_expect(game.setup(date), "closed-day game should set up")

	var results: Array[Dictionary] = []
	var flow = MarketDayCompletionScreenFlowScript.new()
	await flow.play(
		_make_host(),
		null,
		game,
		"part_time",
		game.get_market_context(),
		"",
		MarketDayCompletionScreenFlowScript.EVENT_MODE_CALLBACK,
			{
				MarketDayCompletionScreenFlowConfigScript.CALLBACK_APPLY_ERROR: func(_step: Dictionary, _update_closed_day_choices: bool) -> void:
					results.append({"ok": false}),
				MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH: func(result: Dictionary) -> void:
					results.append(result),
			}
		)
	_expect(results.size() == 1, "event step without runner should fall back to finish callback")
	_expect(bool(results[0].get("ok", false)), "event fallback should receive successful result")
	_expect(String(Dictionary(results[0].get("day_action", {})).get("event", {}).get("id", "")) == "part_time", "event fallback should preserve selected event")


func _verify_event_runner_callback_mode() -> void:
	var game = GameStateScript.new()
	var date := _helpers.find_closed_date_with_choice(game, "go_out", "part_time")
	_expect(not date.is_empty(), "should find closed day with callback event choice")
	_expect(game.setup(date), "callback-mode game should set up")

	var results: Array[Dictionary] = []
	var event_runner := FakeEventRunner.new()
	var flow = MarketDayCompletionScreenFlowScript.new()
	await flow.play(
		_make_host(),
		event_runner,
		game,
		"part_time",
		game.get_market_context(),
		"res://fallback.png",
		MarketDayCompletionScreenFlowScript.EVENT_MODE_CALLBACK,
			{
				MarketDayCompletionScreenFlowConfigScript.CALLBACK_APPLY_ERROR: func(_step: Dictionary, _update_closed_day_choices: bool) -> void:
					results.append({"ok": false}),
				MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH: func(result: Dictionary) -> void:
					results.append(result),
			}
		)

	_expect(event_runner.calls.size() == 1, "callback event mode should ask the runner to begin once")
	_expect(results.is_empty(), "callback event mode should wait for the runner callback before finishing")
	_expect(event_runner.finish_callback.is_valid(), "callback event mode should pass a valid finish callback to the runner")
	event_runner.finish_callback.call()
	_expect(results.size() == 1, "runner callback should finish the day once")
	_expect(bool(results[0].get("ok", false)), "runner callback should receive successful day result")


func _verify_multiple_playback_events_callback_mode() -> void:
	var results: Array[Dictionary] = []
	var event_runner := FakeEventRunner.new()
	var flow = MarketDayCompletionScreenFlowScript.new()
	var step := {
		MarketDayCompletionScreenFlowConfigScript.KEY_RESULT: {"ok": true},
		MarketDayCompletionScreenFlowConfigScript.KEY_PLAYBACK_EVENTS: [
			{"id": "part_time", "dialogue": ["낮 이벤트"]},
			{"id": "night_chimaek", "dialogue": ["밤 이벤트"]}
		]
	}
	await flow.call(
		"_play_event_step",
		_make_host(),
		event_runner,
		step,
		"res://fallback.png",
		MarketDayCompletionScreenFlowScript.EVENT_MODE_CALLBACK,
			{
				MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH: func(result: Dictionary) -> void:
					results.append(result),
			}
		)

	_expect(event_runner.calls.size() == 1, "callback sequence should start with the first playback event")
	_expect(String(Dictionary(event_runner.calls[0].get("event", {})).get("id", "")) == "part_time", "first playback event should be the day event")
	_expect(bool(Dictionary(event_runner.calls[0].get("event", {})).get("_skip_finish_fade", false)), "intermediate playback event should skip fade-out before the next event")
	event_runner.finish_callback.call()
	_expect(event_runner.calls.size() == 2, "callback sequence should continue to the night event")
	_expect(String(Dictionary(event_runner.calls[1].get("event", {})).get("id", "")) == "night_chimaek", "second playback event should be the night event")
	_expect(not bool(Dictionary(event_runner.calls[1].get("event", {})).get("_skip_finish_fade", false)), "last playback event should keep the normal fade-out")
	event_runner.finish_callback.call()
	_expect(results.size() == 1, "callback sequence should finish after all playback events")


func _verify_result_starts_under_final_fade() -> void:
	var results: Array[Dictionary] = []
	var event_runner := TransitionEventRunner.new()
	var flow = MarketDayCompletionScreenFlowScript.new()
	await flow.call(
		"_play_event_step",
		_make_host(),
		event_runner,
		{
			MarketDayCompletionScreenFlowConfigScript.KEY_RESULT: {DayEventKeysScript.KEY_OK: true},
			MarketDayCompletionScreenFlowConfigScript.KEY_PLAYBACK_EVENTS: [{
				DayEventKeysScript.KEY_ID: "final_event",
				DayEventKeysScript.KEY_DIALOGUE: ["마지막 대사"]
			}]
		},
		"res://fallback.png",
		MarketDayCompletionScreenFlowScript.EVENT_MODE_CALLBACK,
		{
			MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH: func(result: Dictionary) -> void:
				results.append(result),
		}
	)
	_expect(results.is_empty(), "result should wait until the final event begins fading")
	event_runner.layer.finish_transition_started.emit()
	_expect(results.size() == 1, "result should appear below the final event fade without a market-only frame")
	event_runner.layer.finished.emit()
	_expect(results.size() == 1, "final fade completion should not show the result twice")


func _verify_workday_departure_transition_callback_mode() -> void:
	var results: Array[Dictionary] = []
	var event_runner := FakeEventRunner.new()
	var flow = MarketDayCompletionScreenFlowScript.new()
	var playback_events: Array[Dictionary] = MarketDayCompletionFlowScript._playback_events(
		{
			DayEventKeysScript.KEY_ID: "company_communication_01",
			DayEventKeysScript.KEY_GROUP: DayEventKeysScript.GROUP_COMPANY_WORK,
			DayEventKeysScript.KEY_DIALOGUE: ["회사 업무"]
		},
		[],
		[{
			DayEventKeysScript.KEY_EVENT: {
				DayEventKeysScript.KEY_ID: "night_chimaek",
				DayEventKeysScript.KEY_DIALOGUE: ["밤 이벤트"]
			}
		}],
		true
	)
	var step := {
		MarketDayCompletionScreenFlowConfigScript.KEY_RESULT: {
			DayEventKeysScript.KEY_OK: true,
			DayEventKeysScript.KEY_DATE: "2016-07-15"
		},
		MarketDayCompletionScreenFlowConfigScript.KEY_PLAYBACK_EVENTS: playback_events
	}
	await flow.call(
		"_play_event_step",
		_make_host(),
		event_runner,
		step,
		"res://fallback.png",
		MarketDayCompletionScreenFlowScript.EVENT_MODE_CALLBACK,
		{
			MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH: func(result: Dictionary) -> void:
				results.append(result),
		}
	)

	_expect(event_runner.calls.size() == 1, "workday sequence should start with company work")
	_expect(bool(Dictionary(event_runner.calls[0].get("event", {})).get("_skip_finish_fade", false)), "company work should flow into departure without a finish fade")
	event_runner.finish_callback.call()
	_expect(event_runner.calls.size() == 2, "workday sequence should continue to departure")
	var departure := Dictionary(event_runner.calls[1].get("event", {}))
	_expect(String(departure.get(DayEventKeysScript.KEY_ID, "")) == MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_ID, "the middle event should be workday departure")
	_expect(String(departure.get(DayEventKeysScript.KEY_CG_PATH, "")) == "res://assets/events_summer/transition/leave_work_evening.png", "summer callback playback should resolve the departure CG")
	_expect(bool(departure.get("_skip_finish_fade", false)), "departure should flow into the night event without a finish fade")
	event_runner.finish_callback.call()
	_expect(event_runner.calls.size() == 3, "workday sequence should continue from departure to night")
	var night_event := Dictionary(event_runner.calls[2].get("event", {}))
	_expect(String(night_event.get(DayEventKeysScript.KEY_ID, "")) == "night_chimaek", "night event should follow departure")
	_expect(not bool(night_event.get("_skip_finish_fade", false)), "the final night event should keep its normal finish fade")
	event_runner.finish_callback.call()
	_expect(results.size() == 1, "workday departure sequence should finish exactly once")


func _verify_summer_playback_event_cg() -> void:
	var results: Array[Dictionary] = []
	var event_runner := FakeEventRunner.new()
	var flow = MarketDayCompletionScreenFlowScript.new()
	var base_cg_path := "res://assets/events/company_work/phase5/company_communication_01.png"
	var summer_cg_path := "res://assets/events_summer/company_work/phase5/company_communication_01.png"
	var step := {
		MarketDayCompletionScreenFlowConfigScript.KEY_RESULT: {
			DayEventKeysScript.KEY_OK: true,
			DayEventKeysScript.KEY_DATE: "2016-07-01"
		},
		MarketDayCompletionScreenFlowConfigScript.KEY_PLAYBACK_EVENTS: [
			{
				DayEventKeysScript.KEY_ID: "company_communication_01",
				DayEventKeysScript.KEY_CG_PATH: base_cg_path,
				DayEventKeysScript.KEY_DIALOGUE: ["여름 CG 확인"]
			}
		]
	}
	await flow.call(
		"_play_event_step",
		_make_host(),
		event_runner,
		step,
		"res://fallback.png",
		MarketDayCompletionScreenFlowScript.EVENT_MODE_CALLBACK,
		{
			MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH: func(result: Dictionary) -> void:
				results.append(result),
		}
	)

	_expect(event_runner.calls.size() == 1, "summer playback should start one event")
	var event := Dictionary(event_runner.calls[0].get("event", {}))
	_expect(String(event.get(DayEventKeysScript.KEY_CG_PATH, "")) == summer_cg_path, "summer playback should pass the summer CG to the runner")
	event_runner.finish_callback.call()
	_expect(results.size() == 1, "summer playback should finish after callback")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _make_host() -> Control:
	var host := Control.new()
	root.add_child(host)
	return host


class FakeEventRunner:
	var calls: Array[Dictionary] = []
	var finish_callback := Callable()

	func begin(parent: Node, event: Dictionary, default_background_path: String, callback: Callable = Callable()) -> Control:
		calls.append({
			"has_parent": parent != null,
			"event": event,
			"default_background_path": default_background_path,
			"has_callback": callback.is_valid()
		})
		var layer := Control.new()
		parent.add_child(layer)
		finish_callback = func() -> void:
			var next_callback := callback
			finish_callback = Callable()
			if is_instance_valid(layer):
				layer.free()
			if next_callback.is_valid():
				next_callback.call()
		return layer


class TransitionEventLayer:
	extends Control

	signal finish_transition_started
	signal finished


class TransitionEventRunner:
	var layer: TransitionEventLayer

	func begin(parent: Node, _event: Dictionary, _default_background_path: String, callback: Callable = Callable()) -> Control:
		layer = TransitionEventLayer.new()
		parent.add_child(layer)
		if callback.is_valid():
			layer.finished.connect(callback, CONNECT_ONE_SHOT)
		return layer
