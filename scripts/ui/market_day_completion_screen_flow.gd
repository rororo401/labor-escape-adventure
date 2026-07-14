class_name MarketDayCompletionScreenFlow
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventPlaybackRequestScript := preload("res://scripts/ui/day_event_playback_request.gd")
const MarketDayCompletionCoordinatorScript := preload("res://scripts/ui/market_day_completion_coordinator.gd")
const MarketDayCompletionScreenFlowConfigScript := preload("res://scripts/ui/market_day_completion_screen_flow_config.gd")

const EVENT_MODE_AWAIT := MarketDayCompletionScreenFlowConfigScript.EVENT_MODE_AWAIT
const EVENT_MODE_CALLBACK := MarketDayCompletionScreenFlowConfigScript.EVENT_MODE_CALLBACK


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
	var step := MarketDayCompletionCoordinatorScript.next_step(game, selected_day_action_id, market_context)
	match String(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_ACTION, "")):
		MarketDayCompletionScreenFlowConfigScript.ACTION_ERROR:
			_apply_error(step, callbacks)
		MarketDayCompletionScreenFlowConfigScript.ACTION_PLAY_EVENT:
			await _play_event_step(parent, event_runner, step, event_background_path, event_mode, callbacks)
		MarketDayCompletionScreenFlowConfigScript.ACTION_FINISH:
			_finish(step.get(MarketDayCompletionScreenFlowConfigScript.KEY_RESULT, {}), callbacks)


func _play_event_step(
	parent: Control,
	event_runner,
	step: Dictionary,
	event_background_path: String,
	event_mode: String,
	callbacks: Dictionary
) -> void:
	var result: Dictionary = step.get(MarketDayCompletionScreenFlowConfigScript.KEY_RESULT, {})
	var events := _playback_events(step)
	if event_runner == null:
		_finish(result, callbacks)
		return

	if event_mode == MarketDayCompletionScreenFlowConfigScript.EVENT_MODE_CALLBACK:
		_play_callback_events(parent, event_runner, events, event_background_path, 0, result, callbacks)
		return

	var date := String(result.get(DayEventKeysScript.KEY_DATE, ""))
	var finish_state := {"done": false}
	for index in range(events.size()):
		var event := _event_with_transition_flags(Dictionary(events[index]), index < events.size() - 1)
		var awaited_layer: Control = event_runner.begin(
			parent,
			DayEventPlaybackRequestScript.event_for_date(event, date),
			event_background_path
		)
		if awaited_layer != null:
			if index == events.size() - 1 and awaited_layer.has_signal("finish_transition_started"):
				awaited_layer.connect(
					"finish_transition_started",
					_finish_once.bind(finish_state, result, callbacks),
					CONNECT_ONE_SHOT
				)
			await awaited_layer.finished
	_finish_once(finish_state, result, callbacks)


func _playback_events(step: Dictionary) -> Array:
	var events: Array = step.get(MarketDayCompletionScreenFlowConfigScript.KEY_PLAYBACK_EVENTS, [])
	if not events.is_empty():
		return events

	var day_action: Dictionary = step.get(MarketDayCompletionScreenFlowConfigScript.KEY_DAY_ACTION, {})
	return [] if day_action.is_empty() else [day_action]


func _play_callback_events(
	parent: Control,
	event_runner,
	events: Array,
	event_background_path: String,
	index: int,
	result: Dictionary,
	callbacks: Dictionary
) -> void:
	if index >= events.size():
		_finish(result, callbacks)
		return

	var date := String(result.get(DayEventKeysScript.KEY_DATE, ""))
	var event := _event_with_transition_flags(Dictionary(events[index]), index < events.size() - 1)
	event = DayEventPlaybackRequestScript.event_for_date(event, date)
	if index == events.size() - 1:
		var finish_state := {"done": false}
		var final_layer: Control = event_runner.begin(
			parent,
			event,
			event_background_path,
			_finish_once.bind(finish_state, result, callbacks)
		)
		if final_layer == null:
			_finish_once(finish_state, result, callbacks)
			return
		if final_layer.has_signal("finish_transition_started"):
			final_layer.connect(
				"finish_transition_started",
				_finish_once.bind(finish_state, result, callbacks),
				CONNECT_ONE_SHOT
			)
		return
	var callback_layer: Control = event_runner.begin(
		parent,
		event,
		event_background_path,
		_play_callback_events.bind(parent, event_runner, events, event_background_path, index + 1, result, callbacks)
	)
	if callback_layer == null:
		_play_callback_events(parent, event_runner, events, event_background_path, index + 1, result, callbacks)


func _finish_once(state: Dictionary, result: Dictionary, callbacks: Dictionary) -> void:
	if bool(state.get("done", false)):
		return
	state["done"] = true
	_finish(result, callbacks)


func _event_with_transition_flags(event: Dictionary, has_next_event: bool) -> Dictionary:
	var next_event := event.duplicate(true)
	if has_next_event:
		next_event["_skip_finish_fade"] = true
	return next_event


func _apply_error(step: Dictionary, callbacks: Dictionary) -> void:
	var callback: Callable = callbacks.get(MarketDayCompletionScreenFlowConfigScript.CALLBACK_APPLY_ERROR, Callable())
	if callback.is_valid():
		callback.call(
			step,
			bool(callbacks.get(
				MarketDayCompletionScreenFlowConfigScript.CALLBACK_UPDATE_CLOSED_DAY_CHOICES,
				MarketDayCompletionScreenFlowConfigScript.DEFAULT_UPDATE_CLOSED_DAY_CHOICES
			))
		)


func _finish(result: Dictionary, callbacks: Dictionary) -> void:
	var callback: Callable = callbacks.get(MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH, Callable())
	if callback.is_valid():
		callback.call(result)
