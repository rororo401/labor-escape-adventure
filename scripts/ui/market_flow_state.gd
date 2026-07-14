class_name MarketFlowState
extends RefCounted

const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketDayFlowTextConfigScript := preload("res://scripts/ui/market_day_flow_text_config.gd")
const MarketFlowControlStateConfigScript := preload("res://scripts/ui/market_flow_control_state_config.gd")
const MarketFlowActionConfigScript := preload("res://scripts/ui/market_flow_action_config.gd")

const FLOW_ACTION_IGNORE := MarketFlowActionConfigScript.ACTION_IGNORE
const FLOW_ACTION_SLEEP := MarketFlowActionConfigScript.ACTION_SLEEP
const FLOW_ACTION_COMPLETE_DAY := MarketFlowActionConfigScript.ACTION_COMPLETE_DAY
const DAY_ACTION_MESSAGE := MarketFlowActionConfigScript.ACTION_MESSAGE
const DAY_ACTION_FIRST_DAY_SCENE := MarketFlowActionConfigScript.ACTION_FIRST_DAY_SCENE
const DAY_ACTION_COMPLETE_DAY := MarketFlowActionConfigScript.ACTION_COMPLETE_DAY


static func build_control_state(
	game,
	market_open: bool,
	selected_day_action_id: String,
	is_sleep_sequence: bool,
	is_completing_day: bool,
	ready_text: String
) -> Dictionary:
	var game_clear := _is_game_clear(game)
	var game_over := _is_game_over(game)
	var game_finished := game_clear or game_over
	var day_completed := _is_day_completed(game)
	return {
		MarketFlowControlStateConfigScript.KEY_CAN_TRADE: market_open and not day_completed and not game_finished,
		MarketFlowControlStateConfigScript.KEY_ORDER_FLOW: {
			MarketFlowControlStateConfigScript.KEY_GAME_FINISHED: game_finished,
			MarketFlowControlStateConfigScript.KEY_GAME_CLEAR: game_clear,
			MarketFlowControlStateConfigScript.KEY_GAME_OVER: game_over,
			MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED: day_completed,
			MarketFlowControlStateConfigScript.KEY_SLEEP_SEQUENCE: is_sleep_sequence,
			MarketFlowControlStateConfigScript.KEY_READY_TEXT: ready_text
		},
		MarketFlowControlStateConfigScript.KEY_CLOSED_FLOW: {
			MarketFlowControlStateConfigScript.KEY_GAME_FINISHED: game_finished,
			MarketFlowControlStateConfigScript.KEY_GAME_CLEAR: game_clear,
			MarketFlowControlStateConfigScript.KEY_GAME_OVER: game_over,
			MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED: day_completed,
			MarketFlowControlStateConfigScript.KEY_SLEEP_SEQUENCE: is_sleep_sequence,
			MarketFlowControlStateConfigScript.KEY_COMPLETING_DAY: is_completing_day,
			MarketFlowControlStateConfigScript.KEY_HAS_SELECTION: not selected_day_action_id.is_empty()
		}
	}


static func can_select_day_action(game, is_completing_day: bool) -> bool:
	return game != null and not bool(game.day_completed) and not is_completing_day and not game.is_game_finished()


static func can_handle_flow(is_sleep_sequence: bool, is_completing_day: bool) -> bool:
	return not is_sleep_sequence and not is_completing_day


static func flow_button_action(game, is_sleep_sequence: bool, is_completing_day: bool) -> Dictionary:
	if not can_handle_flow(is_sleep_sequence, is_completing_day):
		return {MarketFlowActionConfigScript.KEY_ACTION: FLOW_ACTION_IGNORE}
	if game != null and bool(game.day_completed):
		return {MarketFlowActionConfigScript.KEY_ACTION: FLOW_ACTION_SLEEP}
	return {MarketFlowActionConfigScript.KEY_ACTION: FLOW_ACTION_COMPLETE_DAY}


static func day_completion_action(game) -> Dictionary:
	if game == null:
		return {
			MarketFlowActionConfigScript.KEY_ACTION: DAY_ACTION_MESSAGE,
			MarketFlowActionConfigScript.KEY_MESSAGE: MarketDayFlowTextScript.flow_error_message(MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_NOT_STARTED)
		}

	if game.is_first_tutorial_day():
		if game.get_total_held_quantity() < 1:
			return {
				MarketFlowActionConfigScript.KEY_ACTION: DAY_ACTION_MESSAGE,
				MarketFlowActionConfigScript.KEY_MESSAGE: MarketDayFlowTextScript.flow_error_message(MarketDayFlowTextConfigScript.FLOW_ERROR_FIRST_DAY_STOCK_REQUIRED)
			}
		return {MarketFlowActionConfigScript.KEY_ACTION: DAY_ACTION_FIRST_DAY_SCENE}

	return {MarketFlowActionConfigScript.KEY_ACTION: DAY_ACTION_COMPLETE_DAY}


static func should_play_day_event_after_completion(market_context: Dictionary) -> bool:
	return true


static func _is_game_clear(game) -> bool:
	return game != null and game.is_game_clear()


static func _is_game_over(game) -> bool:
	return game != null and game.is_game_over()


static func _is_day_completed(game) -> bool:
	return game != null and bool(game.day_completed)
