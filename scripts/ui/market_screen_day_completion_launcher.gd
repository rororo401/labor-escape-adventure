class_name MarketScreenDayCompletionLauncher
extends RefCounted

const MarketDayCompletionScreenFlowScript := preload("res://scripts/ui/market_day_completion_screen_flow.gd")
const MarketDayCompletionScreenFlowConfigScript := preload("res://scripts/ui/market_day_completion_screen_flow_config.gd")


static func play_closed_day_action(
	parent: Control,
	screen_flow,
	event_runner,
	game,
	selected_day_action_id: String,
	market_context: Dictionary,
	event_background_path: String,
	callbacks: Dictionary
) -> void:
	await _play(
		parent,
		screen_flow,
		event_runner,
		game,
		selected_day_action_id,
		market_context,
		event_background_path,
		MarketDayCompletionScreenFlowScript.EVENT_MODE_CALLBACK,
		callbacks
	)


static func play_today(
	parent: Control,
	screen_flow,
	event_runner,
	game,
	selected_day_action_id: String,
	market_context: Dictionary,
	event_background_path: String,
	callbacks: Dictionary
) -> void:
	var next_callbacks := callbacks.duplicate()
	next_callbacks[MarketDayCompletionScreenFlowConfigScript.CALLBACK_UPDATE_CLOSED_DAY_CHOICES] = false
	await _play(
		parent,
		screen_flow,
		event_runner,
		game,
		selected_day_action_id,
		market_context,
		event_background_path,
		MarketDayCompletionScreenFlowScript.EVENT_MODE_AWAIT,
		next_callbacks
	)


static func make_callbacks(apply_error: Callable, finish: Callable) -> Dictionary:
	return {
		MarketDayCompletionScreenFlowConfigScript.CALLBACK_APPLY_ERROR: apply_error,
		MarketDayCompletionScreenFlowConfigScript.CALLBACK_FINISH: finish
	}


static func _play(
	parent: Control,
	screen_flow,
	event_runner,
	game,
	selected_day_action_id: String,
	market_context: Dictionary,
	event_background_path: String,
	event_mode: String,
	callbacks: Dictionary
) -> void:
	if screen_flow == null:
		return

	await screen_flow.play(
		parent,
		event_runner,
		game,
		selected_day_action_id,
		market_context,
		event_background_path,
		event_mode,
		callbacks
	)
