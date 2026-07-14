class_name MarketOrderFlowButtonState
extends RefCounted

const FlowButtonStateConfigScript := preload("res://scripts/ui/flow_button_state_config.gd")
const MarketFlowCopyScript := preload("res://scripts/ui/market_flow_copy.gd")


static func build(
	game_finished: bool,
	game_clear: bool,
	game_over: bool,
	day_completed: bool,
	sleep_sequence: bool,
	ready_text: String = ""
) -> Dictionary:
	var resolved_ready_text := MarketFlowCopyScript.DEFAULT_READY_TEXT if ready_text.is_empty() else ready_text
	return {
		FlowButtonStateConfigScript.KEY_TEXT: _button_text(game_clear, game_over, day_completed, resolved_ready_text),
		FlowButtonStateConfigScript.KEY_DISABLED: game_finished or sleep_sequence
	}


static func _button_text(game_clear: bool, game_over: bool, day_completed: bool, ready_text: String) -> String:
	if game_clear:
		return MarketFlowCopyScript.GAME_CLEAR_TEXT
	if game_over:
		return MarketFlowCopyScript.GAME_OVER_TEXT
	return MarketFlowCopyScript.SLEEP_TEXT if day_completed else ready_text
