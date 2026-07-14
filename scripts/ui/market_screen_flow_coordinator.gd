class_name MarketScreenFlowCoordinator
extends RefCounted

const MarketFlowStateScript := preload("res://scripts/ui/market_flow_state.gd")
const MarketFlowActionConfigScript := preload("res://scripts/ui/market_flow_action_config.gd")
const MarketScreenPanelFeedbackScript := preload("res://scripts/ui/market_screen_panel_feedback.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")

const ACTION_IGNORE := MarketFlowActionConfigScript.ACTION_IGNORE
const ACTION_SLEEP := MarketFlowActionConfigScript.ACTION_SLEEP
const ACTION_COMPLETE_DAY := MarketFlowActionConfigScript.ACTION_COMPLETE_DAY
const ACTION_MESSAGE := MarketFlowActionConfigScript.ACTION_MESSAGE
const ACTION_CHANGE_SCENE := MarketFlowActionConfigScript.ACTION_CHANGE_SCENE
const FIRST_DAY_SCENE_PATH := UiScenePathsScript.FIRST_DAY_WORK


static func flow_button_action(game, is_sleep_sequence: bool, is_completing_day: bool) -> Dictionary:
	return MarketFlowStateScript.flow_button_action(game, is_sleep_sequence, is_completing_day)


static func day_completion_request(game, order_panel, closed_day_panel) -> Dictionary:
	var decision := MarketFlowStateScript.day_completion_action(game)
	match String(decision.get(MarketFlowActionConfigScript.KEY_ACTION, MarketFlowActionConfigScript.EMPTY_ACTION)):
		MarketFlowStateScript.DAY_ACTION_MESSAGE:
			var message := String(decision.get(MarketFlowActionConfigScript.KEY_MESSAGE, MarketFlowActionConfigScript.EMPTY_MESSAGE))
			MarketScreenPanelFeedbackScript.set_flow_message(order_panel, closed_day_panel, message)
			return {
				MarketFlowActionConfigScript.KEY_ACTION: ACTION_MESSAGE,
				MarketFlowActionConfigScript.KEY_MESSAGE: message
			}
		MarketFlowStateScript.DAY_ACTION_FIRST_DAY_SCENE:
			return {
				MarketFlowActionConfigScript.KEY_ACTION: ACTION_CHANGE_SCENE,
				MarketFlowActionConfigScript.KEY_SCENE_PATH: FIRST_DAY_SCENE_PATH
			}
		MarketFlowStateScript.DAY_ACTION_COMPLETE_DAY:
			return {MarketFlowActionConfigScript.KEY_ACTION: ACTION_COMPLETE_DAY}
		_:
			return {MarketFlowActionConfigScript.KEY_ACTION: ACTION_IGNORE}
