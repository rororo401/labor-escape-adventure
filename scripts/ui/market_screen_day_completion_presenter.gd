class_name MarketScreenDayCompletionPresenter
extends RefCounted

const MarketDayCompletionFlowConfigScript := preload("res://scripts/ui/market_day_completion_flow_config.gd")
const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketDayResultStateScript := preload("res://scripts/ui/market_day_result_state.gd")
const MarketScreenPanelFeedbackScript := preload("res://scripts/ui/market_screen_panel_feedback.gd")


static func apply_success(runtime_state, order_panel, closed_day_panel, result: Dictionary) -> Dictionary:
	var state := MarketDayResultStateScript.completion_success_state(result)
	_apply_state(runtime_state, state)
	MarketScreenPanelFeedbackScript.set_flow_message(
		order_panel,
		closed_day_panel,
		String(state.get(MarketDayResultStateConfigScript.KEY_MESSAGE, MarketDayResultStateConfigScript.CLEAR_MESSAGE))
	)
	return state


static func apply_error(
	runtime_state,
	order_panel,
	closed_day_panel,
	completion: Dictionary,
	update_closed_day_choices: bool = true
) -> Dictionary:
	var state: Dictionary = completion.get(MarketDayCompletionFlowConfigScript.KEY_STATE, {})
	_apply_state(runtime_state, state)
	if update_closed_day_choices:
		MarketScreenPanelFeedbackScript.set_closed_day_choice_buttons_disabled(
			closed_day_panel,
			bool(state.get(MarketDayResultStateConfigScript.KEY_CHOICE_BUTTONS_DISABLED, false))
		)
	MarketScreenPanelFeedbackScript.set_flow_message(
		order_panel,
		closed_day_panel,
		String(state.get(MarketDayResultStateConfigScript.KEY_MESSAGE, MarketDayResultStateConfigScript.CLEAR_MESSAGE))
	)
	return state


static func _apply_state(runtime_state, state: Dictionary) -> void:
	if runtime_state != null:
		runtime_state.apply(state)
