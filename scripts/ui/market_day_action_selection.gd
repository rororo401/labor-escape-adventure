class_name MarketDayActionSelection
extends RefCounted

const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")
const MarketDayActionOptionsScript := preload("res://scripts/ui/market_day_action_options.gd")
const MarketDayActionSelectionResultConfigScript := preload("res://scripts/ui/market_day_action_selection_result_config.gd")
const MarketFlowStateScript := preload("res://scripts/ui/market_flow_state.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")


static func refresh_state(
	game,
	selected_category_id: String,
	selected_action_id: String,
	disabled: bool,
	limit: int = 4
) -> Dictionary:
	if game == null:
		return {}

	var flow: Dictionary = game.get_day_flow_context()
	var choices: Array = flow.get(MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CHOICES, [])
	if choices.is_empty():
		return MarketDayActionOptionsScript.closed_day_empty_state(flow)

	var categories: Array = flow.get(MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CATEGORIES, [])
	var resolved_category_id := MarketDayActionOptionsScript.resolve_category_id(categories, selected_category_id)
	var category_choices: Array = game.get_closed_day_choices(resolved_category_id, limit) if not resolved_category_id.is_empty() else []
	return MarketDayActionOptionsScript.closed_day_refresh_state(
		flow,
		resolved_category_id,
		selected_action_id,
		category_choices,
		disabled
	)


static func category_state(game, category_id: String, limit: int = 4) -> Dictionary:
	if game == null:
		return {}

	return MarketDayActionOptionsScript.closed_day_category_state(
		game.get_closed_day_categories(),
		category_id,
		game.get_closed_day_choices(category_id, limit)
	)


static func category_selected(game, category_id: String, limit: int = 4) -> Dictionary:
	if game == null or bool(game.day_completed):
		return {MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED: MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED}
	return {
		MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED: true,
		MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE: {
			MarketScreenStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID: category_id,
			MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID: MarketScreenStateConfigScript.DEFAULT_SELECTED_DAY_ACTION_ID
		},
		MarketDayActionSelectionResultConfigScript.KEY_PANEL_STATE: category_state(game, category_id, limit),
		MarketDayResultStateConfigScript.KEY_MESSAGE: MarketDayResultStateConfigScript.CLEAR_MESSAGE
	}


static func action_selected(game, is_completing_day: bool, action_id: String) -> Dictionary:
	if not MarketFlowStateScript.can_select_day_action(game, is_completing_day):
		return {MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED: MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED}
	return {
		MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED: true,
		MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE: {
			MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID: action_id
		},
		MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID: action_id,
		MarketDayResultStateConfigScript.KEY_MESSAGE: "%s로 하루를 보내기로 했다." % MarketDayFlowTextScript.day_action_name(game.get_day_flow_context(), action_id)
	}


static func action_start(game, is_completing_day: bool, action_id: String) -> Dictionary:
	if action_id.is_empty() or not MarketFlowStateScript.can_select_day_action(game, is_completing_day):
		return {MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED: MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED}
	return {
		MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED: true,
		MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE: {
			MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID: action_id,
			MarketScreenStateConfigScript.KEY_IS_COMPLETING_DAY: true
		},
		MarketDayActionSelectionResultConfigScript.KEY_DISABLE_CHOICES: true
	}


static func selected_action_from_index(action_ids: Array[String], index: int, current_action_id: String = "") -> String:
	if index < 0 or index >= action_ids.size():
		return current_action_id
	return action_ids[index]
