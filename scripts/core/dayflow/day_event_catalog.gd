class_name DayEventCatalog
extends RefCounted

const DayEventRuleResolverScript := preload("res://scripts/core/dayflow/day_event_rule_resolver.gd")
const DayEventRandomizerScript := preload("res://scripts/core/dayflow/day_event_randomizer.gd")
const DayEventCatalogLoaderScript := preload("res://scripts/core/dayflow/day_event_catalog_loader.gd")
const DayEventChoiceProviderScript := preload("res://scripts/core/dayflow/day_event_choice_provider.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventConditionResolverScript := preload("res://scripts/core/dayflow/day_event_condition_resolver.gd")

var day_actions: Array[Dictionary] = []
var weekday_events: Array[Dictionary] = []
var night_events: Array[Dictionary] = []
var actions_by_id := {}
var weekday_events_by_id := {}
var night_events_by_id := {}
var rules := {}
var closed_day_choice_limit := 4


func load_from_json(path: String) -> void:
	_apply_payload(DayEventCatalogLoaderScript.load_from_json(path))


func _apply_payload(payload: Dictionary) -> void:
	day_actions.assign(payload.get(DayEventKeysScript.KEY_DAY_ACTIONS, []))
	weekday_events.assign(payload.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []))
	night_events.assign(payload.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []))
	actions_by_id = Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {}))
	weekday_events_by_id = Dictionary(payload.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS_BY_ID, {}))
	night_events_by_id = Dictionary(payload.get(DayEventKeysScript.KEY_NIGHT_EVENTS_BY_ID, {}))
	rules = Dictionary(payload.get(DayEventKeysScript.KEY_RULES, {}))
	closed_day_choice_limit = int(payload.get(
		DayEventKeysScript.KEY_CLOSED_DAY_CHOICE_LIMIT,
		DayEventKeysScript.DEFAULT_CLOSED_DAY_CHOICE_LIMIT
	))


func get_action(action_id: String) -> Dictionary:
	return Dictionary(actions_by_id.get(action_id, {}))


func get_night_event(event_id: String) -> Dictionary:
	return Dictionary(night_events_by_id.get(event_id, {}))


func get_weekday_event(event_id: String) -> Dictionary:
	return Dictionary(weekday_events_by_id.get(event_id, {}))


func get_market_fixed_event(day: Dictionary) -> Dictionary:
	return DayEventRuleResolverScript.get_action(
		actions_by_id,
		DayEventRuleResolverScript.market_fixed_event_id(rules, day)
	)


func get_day_flow_context(
	day: Dictionary,
	status: Dictionary,
	completed_days: int,
	event_history: Array = [],
	random_seed: String = "",
	condition_seed: String = ""
) -> Dictionary:
	var forced_action := _resolve_forced_day_action(day, status)
	var choices := get_available_day_choices(day, status, random_seed, condition_seed)
	var default_action := forced_action
	if default_action.is_empty():
		default_action = _get_default_day_action(day)

	return {
		DayEventKeysScript.KEY_DEFAULT_ACTION: default_action,
		DayEventKeysScript.KEY_AVAILABLE_CATEGORIES: get_available_day_categories(day, status, random_seed, condition_seed),
		DayEventKeysScript.KEY_AVAILABLE_CHOICES: choices,
		DayEventKeysScript.KEY_HAS_CHOICE: not choices.is_empty(),
		DayEventKeysScript.KEY_NIGHT_EVENT_PREVIEW: _select_night_events(
			day,
			status,
			completed_days,
			[],
			false,
			event_history,
			random_seed,
			_condition_seed_for(random_seed, condition_seed)
		)
	}


func get_available_day_categories(
	day: Dictionary,
	status: Dictionary,
	random_seed: String = "",
	condition_seed: String = ""
) -> Array[Dictionary]:
	return DayEventChoiceProviderScript.available_categories(
		_eligible_day_actions(day, status, _condition_seed_for(random_seed, condition_seed)),
		actions_by_id,
		rules,
		day,
		status
	)


func get_available_day_choices(
	day: Dictionary,
	status: Dictionary,
	random_seed: String = "",
	condition_seed: String = ""
) -> Array[Dictionary]:
	return DayEventChoiceProviderScript.available_choices(
		_eligible_day_actions(day, status, _condition_seed_for(random_seed, condition_seed)),
		actions_by_id,
		rules,
		day,
		status
	)


func get_available_life_actions(
	day: Dictionary,
	status: Dictionary,
	random_seed: String = "",
	condition_seed: String = ""
) -> Array[Dictionary]:
	return DayEventChoiceProviderScript.available_life_actions(
		_eligible_day_actions(day, status, _condition_seed_for(random_seed, condition_seed)),
		actions_by_id,
		rules,
		day,
		status
	)


func get_random_day_choices(
	day: Dictionary,
	status: Dictionary,
	category_id: String,
	completed_days: int,
	limit: int = -1,
	event_history: Array = [],
	random_seed: String = "",
	condition_seed: String = ""
) -> Array[Dictionary]:
	var max_count := closed_day_choice_limit if limit <= 0 else limit
	return DayEventRandomizerScript.limited_category_choices(
		get_available_day_choices(day, status, random_seed, condition_seed),
		category_id,
		String(day.get(DayEventKeysScript.KEY_DATE, "")),
		completed_days,
		max_count,
		event_history,
		random_seed
	)


func build_day_result(
	day: Dictionary,
	status: Dictionary,
	completed_days: int,
	selected_action_id: String = "",
	forced_event_ids: Array = [],
	suppress_random_night_events: bool = false,
	event_history: Array = [],
	random_seed: String = "",
	condition_seed: String = ""
) -> Dictionary:
	var resolved_condition_seed := _condition_seed_for(random_seed, condition_seed)
	var day_action := _resolve_forced_day_action(day, status, forced_event_ids)
	if day_action.is_empty():
		day_action = _resolve_selected_or_default_action(day, status, selected_action_id, resolved_condition_seed)
		day_action = _resolve_company_work_variant(day_action, day, completed_days, event_history, random_seed)

	var suppress_random_events := suppress_random_night_events or _should_suppress_random_events(day_action)
	var provisional_history := _history_with_selected_events(event_history, [day_action], completed_days)
	var selected_weekday_events := _select_weekday_events(
		day,
		status,
		completed_days,
		forced_event_ids,
		suppress_random_events,
		provisional_history,
		random_seed,
		resolved_condition_seed
	)
	provisional_history = _history_with_selected_events(provisional_history, selected_weekday_events, completed_days)
	var selected_night_events := _select_night_events(
		day,
		status,
		completed_days,
		forced_event_ids,
		suppress_random_events,
		provisional_history,
		random_seed,
		resolved_condition_seed
	)
	return {
		DayEventKeysScript.KEY_DAY_ACTION: day_action,
		DayEventKeysScript.KEY_WEEKDAY_EVENTS: selected_weekday_events,
		DayEventKeysScript.KEY_NIGHT_EVENTS: selected_night_events
	}


func _resolve_selected_or_default_action(
	day: Dictionary,
	status: Dictionary,
	selected_action_id: String,
	condition_seed: String
) -> Dictionary:
	return DayEventChoiceProviderScript.resolve_selected_or_default_action(
		_eligible_day_actions(day, status, condition_seed), actions_by_id, rules, day, status, selected_action_id
	)


func _eligible_day_actions(day: Dictionary, status: Dictionary, random_seed: String) -> Array[Dictionary]:
	var eligible: Array[Dictionary] = []
	for action in day_actions:
		var action_row := Dictionary(action)
		if DayEventConditionResolverScript.is_event_eligible(action_row, day, status, random_seed):
			eligible.append(action_row)
	return eligible


func _resolve_forced_day_action(day: Dictionary, status: Dictionary, forced_event_ids: Array = []) -> Dictionary:
	return DayEventRuleResolverScript.resolve_forced_day_action(actions_by_id, rules, day, status, forced_event_ids)


func _get_default_day_action(day: Dictionary) -> Dictionary:
	return DayEventRuleResolverScript.get_default_day_action(actions_by_id, day)


func _should_suppress_random_events(day_action: Dictionary) -> bool:
	var mode := String(day_action.get(DayEventKeysScript.KEY_MODE, ""))
	return mode == DayEventKeysScript.MODE_ANNUAL_SPECIAL or mode == DayEventKeysScript.MODE_MARKET_FIXED or mode.ends_with("override")


func _resolve_company_work_variant(
	day_action: Dictionary,
	day: Dictionary,
	completed_days: int,
	event_history: Array,
	random_seed: String
) -> Dictionary:
	if String(day_action.get(DayEventKeysScript.KEY_ID, "")) != DayEventKeysScript.ACTION_COMPANY_WORK:
		return day_action
	if not bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
		return day_action

	var candidates: Array[Dictionary] = []
	for action in day_actions:
		var action_row := Dictionary(action)
		if (
			String(action_row.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_AUTO_TRADING
			and String(action_row.get(DayEventKeysScript.KEY_GROUP, "")) == DayEventKeysScript.GROUP_COMPANY_WORK
		):
			candidates.append(action_row)
	if candidates.is_empty():
		return day_action

	return DayEventRandomizerScript.select_stable_event(
		candidates,
		String(day.get(DayEventKeysScript.KEY_DATE, "")),
		DayEventKeysScript.GROUP_COMPANY_WORK,
		completed_days,
		event_history,
		random_seed
	)


func _select_night_events(
	day: Dictionary,
	status: Dictionary,
	completed_days: int,
	forced_event_ids: Array,
	suppress_random_night_events: bool = false,
	event_history: Array = [],
	random_seed: String = "",
	condition_seed: String = ""
) -> Array[Dictionary]:
	var occurrence_rules := Dictionary(rules.get(DayEventKeysScript.KEY_RANDOM_EVENT_OCCURRENCE, {}))
	return DayEventRandomizerScript.select_night_events(
		night_events,
		night_events_by_id,
		day,
		completed_days,
		forced_event_ids,
		suppress_random_night_events,
		event_history,
		random_seed,
		status,
		float(occurrence_rules.get(
			DayEventKeysScript.KEY_NIGHT_OCCURRENCE,
			DayEventKeysScript.DEFAULT_NIGHT_EVENT_OCCURRENCE
		)),
		condition_seed
	)


func _select_weekday_events(
	day: Dictionary,
	status: Dictionary,
	completed_days: int,
	forced_event_ids: Array,
	suppress_random_events: bool = false,
	event_history: Array = [],
	random_seed: String = "",
	condition_seed: String = ""
) -> Array[Dictionary]:
	var occurrence_rules := Dictionary(rules.get(DayEventKeysScript.KEY_RANDOM_EVENT_OCCURRENCE, {}))
	return DayEventRandomizerScript.select_weekday_events(
		weekday_events,
		weekday_events_by_id,
		day,
		completed_days,
		forced_event_ids,
		suppress_random_events,
		event_history,
		random_seed,
		status,
		float(occurrence_rules.get(
			DayEventKeysScript.KEY_WEEKDAY_OCCURRENCE,
			DayEventKeysScript.DEFAULT_WEEKDAY_EVENT_OCCURRENCE
		)),
		condition_seed
	)


static func _condition_seed_for(random_seed: String, condition_seed: String) -> String:
	return random_seed if condition_seed.is_empty() else condition_seed


static func _history_with_selected_events(
	event_history: Array,
	selected_events: Array,
	completed_days: int
) -> Array:
	var provisional_history := event_history.duplicate(true)
	for event in selected_events:
		var event_row := Dictionary(event).duplicate(true)
		if String(event_row.get(DayEventKeysScript.KEY_ID, "")).is_empty():
			continue
		event_row[DayEventKeysScript.KEY_COMPLETED_DAY] = completed_days
		event_row[DayEventKeysScript.KEY_SELECTED] = true
		provisional_history.append(event_row)
	return provisional_history
