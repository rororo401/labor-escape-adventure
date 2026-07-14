class_name ClosedDayFlowButtonState
extends RefCounted

const FlowButtonStateConfigScript := preload("res://scripts/ui/flow_button_state_config.gd")
const MarketFlowCopyScript := preload("res://scripts/ui/market_flow_copy.gd")


static func build(
	game_finished: bool,
	game_clear: bool,
	game_over: bool,
	day_completed: bool,
	sleep_sequence: bool,
	completing_day: bool,
	has_selection: bool
) -> Dictionary:
	if game_clear:
		return {
			FlowButtonStateConfigScript.KEY_TEXT: MarketFlowCopyScript.GAME_CLEAR_TEXT,
			FlowButtonStateConfigScript.KEY_DISABLED: true
		}
	if game_over:
		return {
			FlowButtonStateConfigScript.KEY_TEXT: MarketFlowCopyScript.GAME_OVER_TEXT,
			FlowButtonStateConfigScript.KEY_DISABLED: true
		}
	if day_completed:
		return {
			FlowButtonStateConfigScript.KEY_TEXT: MarketFlowCopyScript.SLEEP_TEXT,
			FlowButtonStateConfigScript.KEY_DISABLED: game_finished or sleep_sequence
		}
	return {
		FlowButtonStateConfigScript.KEY_TEXT: _active_day_text(completing_day, has_selection),
		FlowButtonStateConfigScript.KEY_DISABLED: sleep_sequence or completing_day or not has_selection
	}


static func _active_day_text(completing_day: bool, has_selection: bool) -> String:
	if completing_day:
		return MarketFlowCopyScript.IN_PROGRESS_TEXT
	return MarketFlowCopyScript.DEFAULT_READY_TEXT if has_selection else MarketFlowCopyScript.ACTION_REQUIRED_TEXT
