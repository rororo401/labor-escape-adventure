extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayCompletionScreenFlowScript := preload("res://scripts/ui/market_day_completion_screen_flow.gd")
const MarketDayCompletionScreenFlowConfigScript := preload("res://scripts/ui/market_day_completion_screen_flow_config.gd")
const MarketScreenDayCompletionLauncherScript := preload("res://scripts/ui/market_screen_day_completion_launcher.gd")


func _initialize() -> void:
	await _verify_closed_day_launch()
	await _verify_today_launch()

	print("Market screen day completion launcher smoke test passed.")
	finish_test()


func _verify_closed_day_launch() -> void:
	var flow := FakeScreenFlow.new()
	var finish_results: Array[Dictionary] = []
	var callbacks := MarketScreenDayCompletionLauncherScript.make_callbacks(
		func(_completion: Dictionary, _update_closed_day_choices: bool) -> void:
			finish_results.append({"ok": false}),
		func(result: Dictionary) -> void:
			finish_results.append(result)
	)

	await MarketScreenDayCompletionLauncherScript.play_closed_day_action(
		_make_host(),
		flow,
		"runner",
		"game",
		"part_time",
		{"source": "closed"},
		"res://closed.png",
		callbacks
	)

	_expect(flow.calls.size() == 1, "closed-day launcher should call the screen flow once")
	var call: Dictionary = flow.calls[0]
	_expect(String(call.get("selected_day_action_id", "")) == "part_time", "closed-day launcher should pass selected action id")
	_expect(String(call.get("event_mode", "")) == MarketDayCompletionScreenFlowScript.EVENT_MODE_CALLBACK, "closed-day launcher should use callback event mode")
	_expect(String(call.get("background", "")) == "res://closed.png", "closed-day launcher should pass event background")
	_expect(not Dictionary(call.get("callbacks", {})).has(MarketDayCompletionScreenFlowConfigScript.CALLBACK_UPDATE_CLOSED_DAY_CHOICES), "closed-day launcher should keep default choice-update behavior")
	_expect(finish_results.size() == 1 and bool(finish_results[0].get("ok", false)), "closed-day launcher should preserve finish callback")


func _verify_today_launch() -> void:
	var flow := FakeScreenFlow.new()
	var finish_results: Array[Dictionary] = []
	var callbacks := MarketScreenDayCompletionLauncherScript.make_callbacks(
		func(_completion: Dictionary, _update_closed_day_choices: bool) -> void:
			finish_results.append({"ok": false}),
		func(result: Dictionary) -> void:
			finish_results.append(result)
	)

	await MarketScreenDayCompletionLauncherScript.play_today(
		_make_host(),
		flow,
		"runner",
		"game",
		"company_work",
		{"source": "today"},
		"res://closed.png",
		callbacks
	)

	_expect(flow.calls.size() == 1, "today launcher should call the screen flow once")
	var call: Dictionary = flow.calls[0]
	_expect(String(call.get("selected_day_action_id", "")) == "company_work", "today launcher should pass selected action id")
	_expect(String(call.get("event_mode", "")) == MarketDayCompletionScreenFlowScript.EVENT_MODE_AWAIT, "today launcher should use await event mode")
	_expect(not bool(Dictionary(call.get("callbacks", {})).get(MarketDayCompletionScreenFlowConfigScript.CALLBACK_UPDATE_CLOSED_DAY_CHOICES, true)), "today launcher should disable closed-day choice refresh")
	_expect(finish_results.size() == 1 and bool(finish_results[0].get("ok", false)), "today launcher should preserve finish callback")


func _make_host() -> Control:
	var host := Control.new()
	root.add_child(host)
	return host


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakeScreenFlow:
	var calls: Array[Dictionary] = []

	func play(
		parent: Control,
		event_runner,
		game,
		selected_day_action_id: String,
		market_context: Dictionary,
		event_background_path: String,
		event_mode: String,
		callbacks: Dictionary
	) -> void:
		calls.append({
			"parent": parent,
			"event_runner": event_runner,
			"game": game,
			"selected_day_action_id": selected_day_action_id,
			"market_context": market_context,
			"background": event_background_path,
			"event_mode": event_mode,
			"callbacks": callbacks
		})
		var finish: Callable = callbacks.get(MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH, Callable())
		if finish.is_valid():
			finish.call({
				"ok": true,
				"selected_day_action_id": selected_day_action_id,
				"event_mode": event_mode
			})
