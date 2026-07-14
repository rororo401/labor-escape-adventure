class_name MarketDayActionOptions
extends RefCounted

const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")


static func default_action_state(flow: Dictionary) -> Dictionary:
	var default_action: Dictionary = Dictionary(flow.get(MarketDayActionOptionsConfigScript.FLOW_DEFAULT_ACTION, {}))
	var action_id := String(default_action.get(MarketDayActionOptionsConfigScript.ACTION_ID, MarketDayActionOptionsConfigScript.EMPTY_ID))
	return {
		MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID: action_id,
		MarketDayActionOptionsConfigScript.KEY_ACTION_IDS: [action_id],
		MarketDayActionOptionsConfigScript.KEY_LABELS: [String(default_action.get(MarketDayActionOptionsConfigScript.ACTION_NAME, MarketDayActionOptionsConfigScript.DEFAULT_ACTION_LABEL))]
	}


static func choice_action_state(choices: Array, selected_action_id: String) -> Dictionary:
	var selected_index := MarketDayActionOptionsConfigScript.DEFAULT_SELECTED_INDEX
	var action_ids: Array[String] = []
	var labels: Array[String] = []
	for index in choices.size():
		var action: Dictionary = Dictionary(choices[index])
		var action_id := String(action.get(MarketDayActionOptionsConfigScript.ACTION_ID, MarketDayActionOptionsConfigScript.EMPTY_ID))
		action_ids.append(action_id)
		labels.append(String(action.get(MarketDayActionOptionsConfigScript.ACTION_NAME, "")))
		if action_id == selected_action_id:
			selected_index = index
	return {
		MarketDayActionOptionsConfigScript.KEY_SELECTED_INDEX: selected_index,
		MarketDayActionOptionsConfigScript.KEY_ACTION_IDS: action_ids,
		MarketDayActionOptionsConfigScript.KEY_LABELS: labels
	}


static func resolve_category_id(categories: Array, selected_category_id: String) -> String:
	for category in categories:
		if String(Dictionary(category).get(MarketDayActionOptionsConfigScript.ACTION_ID, "")) == selected_category_id:
			return selected_category_id
	return MarketDayActionOptionsConfigScript.EMPTY_ID


static func closed_day_empty_state(flow: Dictionary) -> Dictionary:
	var default_state := default_action_state(flow)
	return {
		MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID: MarketDayActionOptionsConfigScript.EMPTY_ID,
		MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID: String(default_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, MarketDayActionOptionsConfigScript.EMPTY_ID)),
		MarketDayActionOptionsConfigScript.KEY_ACTION_IDS: default_state.get(MarketDayActionOptionsConfigScript.KEY_ACTION_IDS, []),
		MarketDayActionOptionsConfigScript.KEY_ACTION_LABELS: default_state.get(MarketDayActionOptionsConfigScript.KEY_LABELS, []),
		MarketDayActionOptionsConfigScript.KEY_ACTION_SELECTED_INDEX: MarketDayActionOptionsConfigScript.DEFAULT_SELECTED_INDEX,
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES: [],
		MarketDayActionOptionsConfigScript.KEY_CHOICES: [],
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED: true,
		MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED: true,
		MarketDayActionOptionsConfigScript.KEY_ORDER_ACTIONS_DISABLED: true
	}


static func closed_day_refresh_state(
	flow: Dictionary,
	selected_category_id: String,
	selected_action_id: String,
	choices_for_category: Array,
	disabled: bool
) -> Dictionary:
	var choices: Array = flow.get(MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CHOICES, [])
	if choices.is_empty():
		return closed_day_empty_state(flow)

	var categories: Array = flow.get(MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CATEGORIES, [])
	var resolved_category_id := resolve_category_id(categories, selected_category_id)
	var resolved_action_id := selected_action_id
	var rendered_choices: Array = []
	if resolved_category_id.is_empty():
		resolved_action_id = MarketDayActionOptionsConfigScript.EMPTY_ID
	else:
		rendered_choices = choices_for_category

	var choice_state := choice_action_state(choices, resolved_action_id)
	return {
		MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID: resolved_category_id,
		MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID: resolved_action_id,
		MarketDayActionOptionsConfigScript.KEY_ACTION_IDS: choice_state.get(MarketDayActionOptionsConfigScript.KEY_ACTION_IDS, []),
		MarketDayActionOptionsConfigScript.KEY_ACTION_LABELS: choice_state.get(MarketDayActionOptionsConfigScript.KEY_LABELS, []),
		MarketDayActionOptionsConfigScript.KEY_ACTION_SELECTED_INDEX: int(choice_state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_INDEX, MarketDayActionOptionsConfigScript.DEFAULT_SELECTED_INDEX)),
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES: categories,
		MarketDayActionOptionsConfigScript.KEY_CHOICES: rendered_choices,
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED: disabled,
		MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED: disabled,
		MarketDayActionOptionsConfigScript.KEY_ORDER_ACTIONS_DISABLED: disabled
	}


static func closed_day_category_state(categories: Array, selected_category_id: String, choices: Array) -> Dictionary:
	return {
		MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID: selected_category_id,
		MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID: MarketDayActionOptionsConfigScript.EMPTY_ID,
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES: categories,
		MarketDayActionOptionsConfigScript.KEY_CHOICES: choices,
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED: false,
		MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED: false
	}
