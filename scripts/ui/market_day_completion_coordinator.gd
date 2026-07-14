class_name MarketDayCompletionCoordinator
extends RefCounted

const MarketDayCompletionFlowConfigScript := preload("res://scripts/ui/market_day_completion_flow_config.gd")
const MarketDayCompletionFlowScript := preload("res://scripts/ui/market_day_completion_flow.gd")
const MarketDayCompletionScreenFlowConfigScript := preload("res://scripts/ui/market_day_completion_screen_flow_config.gd")
const MarketDayResultStateScript := preload("res://scripts/ui/market_day_result_state.gd")

const ACTION_ERROR := MarketDayCompletionScreenFlowConfigScript.ACTION_ERROR
const ACTION_FINISH := MarketDayCompletionScreenFlowConfigScript.ACTION_FINISH
const ACTION_PLAY_EVENT := MarketDayCompletionScreenFlowConfigScript.ACTION_PLAY_EVENT


static func next_step(game, selected_day_action_id: String, market_context: Dictionary) -> Dictionary:
	var completion := MarketDayCompletionFlowScript.complete(game, selected_day_action_id, market_context)
	if not bool(completion.get(MarketDayCompletionFlowConfigScript.KEY_OK, false)):
		return {
			MarketDayCompletionScreenFlowConfigScript.KEY_ACTION: ACTION_ERROR,
			MarketDayCompletionScreenFlowConfigScript.KEY_STATE: completion.get(MarketDayCompletionFlowConfigScript.KEY_STATE, {}),
			MarketDayCompletionScreenFlowConfigScript.KEY_RESULT: completion.get(MarketDayCompletionFlowConfigScript.KEY_RESULT, {})
		}

	var result: Dictionary = completion.get(MarketDayCompletionFlowConfigScript.KEY_RESULT, {})
	var state := MarketDayResultStateScript.completion_success_state(result)
	if bool(completion.get(MarketDayCompletionFlowConfigScript.KEY_SHOULD_PLAY_DAY_EVENT, false)):
		return {
			MarketDayCompletionScreenFlowConfigScript.KEY_ACTION: ACTION_PLAY_EVENT,
			MarketDayCompletionScreenFlowConfigScript.KEY_RESULT: result,
			MarketDayCompletionScreenFlowConfigScript.KEY_DAY_ACTION: completion.get(MarketDayCompletionFlowConfigScript.KEY_DAY_ACTION, {}),
			MarketDayCompletionScreenFlowConfigScript.KEY_PLAYBACK_EVENTS: completion.get(MarketDayCompletionFlowConfigScript.KEY_PLAYBACK_EVENTS, []),
			MarketDayCompletionScreenFlowConfigScript.KEY_STATE: state
		}

	return {
		MarketDayCompletionScreenFlowConfigScript.KEY_ACTION: ACTION_FINISH,
		MarketDayCompletionScreenFlowConfigScript.KEY_RESULT: result,
		MarketDayCompletionScreenFlowConfigScript.KEY_STATE: state
	}
