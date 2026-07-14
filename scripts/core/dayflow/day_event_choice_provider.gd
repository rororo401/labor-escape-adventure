class_name DayEventChoiceProvider
extends RefCounted

const DayEventRuleResolverScript := preload("res://scripts/core/dayflow/day_event_rule_resolver.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")


static func available_categories(
	day_actions: Array,
	actions_by_id: Dictionary,
	rules: Dictionary,
	day: Dictionary,
	status: Dictionary
) -> Array[Dictionary]:
	if not can_choose_day_action(actions_by_id, rules, day, status):
		return []

	var seen := {}
	var categories: Array[Dictionary] = []
	for action in day_actions:
		var action_row := Dictionary(action)
		if String(action_row.get(DayEventKeysScript.KEY_MODE, "")) != DayEventKeysScript.MODE_CHOICE_CLOSED:
			continue
		var category_id := String(action_row.get(DayEventKeysScript.KEY_CATEGORY_ID, ""))
		if category_id.is_empty() or seen.has(category_id):
			continue
		seen[category_id] = true
		categories.append({
			DayEventKeysScript.KEY_ID: category_id,
			DayEventKeysScript.KEY_NAME_KO: String(action_row.get(DayEventKeysScript.KEY_CATEGORY_KO, category_id))
		})
	return categories


static func available_choices(
	day_actions: Array,
	actions_by_id: Dictionary,
	rules: Dictionary,
	day: Dictionary,
	status: Dictionary
) -> Array[Dictionary]:
	if not can_choose_day_action(actions_by_id, rules, day, status):
		return []

	var choices: Array[Dictionary] = []
	for action in day_actions:
		var action_row := Dictionary(action)
		if String(action_row.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_CHOICE_CLOSED:
			choices.append(action_row)
	return choices


static func available_life_actions(
	day_actions: Array,
	actions_by_id: Dictionary,
	rules: Dictionary,
	day: Dictionary,
	status: Dictionary
) -> Array[Dictionary]:
	if bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
		var default_action := DayEventRuleResolverScript.get_default_day_action(actions_by_id, day)
		return [] if default_action.is_empty() else [default_action]
	return available_choices(day_actions, actions_by_id, rules, day, status)


static func resolve_selected_or_default_action(
	day_actions: Array,
	actions_by_id: Dictionary,
	rules: Dictionary,
	day: Dictionary,
	status: Dictionary,
	selected_action_id: String
) -> Dictionary:
	var resolved_action_id := DayEventKeysScript.ACTION_COMPANY_WORK if selected_action_id == DayEventKeysScript.ACTION_GO_TO_WORK_ALIAS else selected_action_id
	var choices := available_choices(day_actions, actions_by_id, rules, day, status)
	if not resolved_action_id.is_empty():
		for choice in choices:
			if String(choice.get(DayEventKeysScript.KEY_ID, "")) == resolved_action_id:
				return choice
		var selected := DayEventRuleResolverScript.get_action(actions_by_id, resolved_action_id)
		if not selected.is_empty() and bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)) and String(selected.get(DayEventKeysScript.KEY_ID, "")) == DayEventKeysScript.ACTION_COMPANY_WORK:
			return selected

	return DayEventRuleResolverScript.get_default_day_action(actions_by_id, day)


static func can_choose_day_action(actions_by_id: Dictionary, rules: Dictionary, day: Dictionary, status: Dictionary) -> bool:
	if not DayEventRuleResolverScript.annual_special_event_id(rules, day).is_empty():
		return false
	if bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
		return false
	if String(day.get(DayEventKeysScript.KEY_REASON, "")) == DayEventKeysScript.REASON_HOLIDAY:
		return DayEventRuleResolverScript.is_free_choice_holiday(rules, day)
	return not DayEventRuleResolverScript.is_summer_vacation(rules, day)
