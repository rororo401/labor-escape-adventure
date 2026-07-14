class_name DayEventRuleResolver
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")


static func resolve_forced_day_action(
	actions_by_id: Dictionary,
	rules: Dictionary,
	day: Dictionary,
	status: Dictionary,
	forced_event_ids: Array = []
) -> Dictionary:
	for event_id in forced_event_ids:
		var forced := get_action(actions_by_id, String(event_id))
		if not forced.is_empty():
			return forced

	var annual_special := get_action(actions_by_id, annual_special_event_id(rules, day))
	if not annual_special.is_empty():
		return annual_special

	if bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
		var sick_rule: Dictionary = rules.get(DayEventKeysScript.RULE_SICK_OVERRIDE, {})
		if int(status.get(DayEventKeysScript.KEY_HEALTH, DayEventKeysScript.DEFAULT_HEALTH)) <= int(sick_rule.get(DayEventKeysScript.KEY_HEALTH_MAX, DayEventKeysScript.DEFAULT_SICK_HEALTH_MAX)) or int(status.get(DayEventKeysScript.KEY_FATIGUE, DayEventKeysScript.DEFAULT_FATIGUE)) >= int(sick_rule.get(DayEventKeysScript.KEY_FATIGUE_MIN, DayEventKeysScript.DEFAULT_SICK_FATIGUE_MIN)):
			return get_action(actions_by_id, String(sick_rule.get(DayEventKeysScript.KEY_EVENT_ID, DayEventKeysScript.ACTION_SICK_REST)))

	if is_summer_vacation(rules, day):
		var vacation_rule: Dictionary = rules.get(DayEventKeysScript.RULE_SUMMER_VACATION, {})
		var annual_event := get_action(actions_by_id, summer_vacation_event_id(rules, day))
		if not annual_event.is_empty():
			return annual_event
		return get_action(actions_by_id, String(vacation_rule.get(DayEventKeysScript.KEY_EVENT_ID, DayEventKeysScript.ACTION_SUMMER_VACATION)))

	var holiday_name := String(day.get(DayEventKeysScript.KEY_NAME, ""))
	if String(day.get(DayEventKeysScript.KEY_REASON, "")) == DayEventKeysScript.REASON_HOLIDAY:
		if is_free_choice_holiday(rules, day):
			return {}
		for family_name in rules.get(DayEventKeysScript.RULE_FAMILY_HOLIDAY_NAMES, []):
			if holiday_name.find(String(family_name)) >= 0:
				return get_action(actions_by_id, DayEventKeysScript.ACTION_HOLIDAY_FAMILY)
		return get_action(actions_by_id, DayEventKeysScript.ACTION_HOLIDAY_REST)

	return {}


static func get_default_day_action(actions_by_id: Dictionary, day: Dictionary) -> Dictionary:
	if bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
		return get_action(actions_by_id, DayEventKeysScript.ACTION_COMPANY_WORK)
	return get_action(actions_by_id, DayEventKeysScript.ACTION_HOLIDAY_REST) if String(day.get(DayEventKeysScript.KEY_REASON, "")) == DayEventKeysScript.REASON_HOLIDAY else get_action(actions_by_id, DayEventKeysScript.ACTION_NAP)


static func get_action(actions_by_id: Dictionary, action_id: String) -> Dictionary:
	return Dictionary(actions_by_id.get(action_id, {}))


static func annual_special_event_id(rules: Dictionary, day: Dictionary) -> String:
	return String(Dictionary(rules.get(DayEventKeysScript.RULE_ANNUAL_SPECIAL_DATES, {})).get(
		String(day.get(DayEventKeysScript.KEY_DATE, "")),
		""
	))


static func market_fixed_event_id(rules: Dictionary, day: Dictionary) -> String:
	if not bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
		return ""
	return String(Dictionary(rules.get(DayEventKeysScript.RULE_MARKET_FIXED_DATES, {})).get(
		String(day.get(DayEventKeysScript.KEY_DATE, "")),
		""
	))


static func is_free_choice_holiday(rules: Dictionary, day: Dictionary) -> bool:
	if String(day.get(DayEventKeysScript.KEY_REASON, "")) != DayEventKeysScript.REASON_HOLIDAY:
		return false
	if not annual_special_event_id(rules, day).is_empty():
		return false

	var holiday_name := String(day.get(DayEventKeysScript.KEY_NAME, ""))
	if _holiday_name_matches(holiday_name, rules.get(
		DayEventKeysScript.RULE_FREE_CHOICE_HOLIDAY_NAMES,
		[DayEventKeysScript.HOLIDAY_NAME_SUBSTITUTE]
	)):
		return true
	return _holiday_name_matches(holiday_name, rules.get(DayEventKeysScript.RULE_FAMILY_HOLIDAY_NAMES, []))


static func _holiday_name_matches(holiday_name: String, names: Array) -> bool:
	for name in names:
		if holiday_name.find(String(name)) >= 0:
			return true
	return false


static func is_summer_vacation(rules: Dictionary, day: Dictionary) -> bool:
	return summer_vacation_day_index(rules, day) > 0


static func summer_vacation_day_index(rules: Dictionary, day: Dictionary) -> int:
	var parts := date_parts(String(day.get(DayEventKeysScript.KEY_DATE, "")))
	if parts.is_empty():
		return 0

	var vacation_rule: Dictionary = rules.get(DayEventKeysScript.RULE_SUMMER_VACATION, {})
	if int(parts.get(DayEventKeysScript.KEY_MONTH, 0)) != int(vacation_rule.get(DayEventKeysScript.KEY_MONTH_RULE, DayEventKeysScript.DEFAULT_VACATION_MONTH)):
		return 0

	var first_monday := first_weekday_day(int(parts.get(DayEventKeysScript.KEY_YEAR, 0)), int(parts.get(DayEventKeysScript.KEY_MONTH, 0)), 1)
	var date_day := int(parts.get(DayEventKeysScript.KEY_DAY, 0))
	var duration_days := int(vacation_rule.get(DayEventKeysScript.KEY_DURATION_DAYS, DayEventKeysScript.DEFAULT_VACATION_DURATION_DAYS))
	if date_day < first_monday or date_day >= first_monday + duration_days:
		return 0
	return date_day - first_monday + 1


static func summer_vacation_event_id(rules: Dictionary, day: Dictionary) -> String:
	var day_index := summer_vacation_day_index(rules, day)
	if day_index <= 0:
		return ""
	var parts := date_parts(String(day.get(DayEventKeysScript.KEY_DATE, "")))
	if parts.is_empty():
		return ""
	var vacation_rule: Dictionary = rules.get(DayEventKeysScript.RULE_SUMMER_VACATION, {})
	var pattern := String(vacation_rule.get(DayEventKeysScript.KEY_EVENT_ID_PATTERN, "summer_vacation_%04d_day_%d"))
	return pattern % [int(parts.get(DayEventKeysScript.KEY_YEAR, 0)), day_index]


static func first_weekday_day(year: int, month: int, target_weekday: int) -> int:
	var weekday_of_first := weekday_index(year, month, 1)
	return 1 + ((target_weekday - weekday_of_first + 7) % 7)


static func weekday_index(year: int, month: int, day: int) -> int:
	var offsets := [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	var adjusted_year := year
	if month < 3:
		adjusted_year -= 1
	return (adjusted_year + int(adjusted_year / 4) - int(adjusted_year / 100) + int(adjusted_year / 400) + int(offsets[month - 1]) + day) % 7


static func date_parts(date: String) -> Dictionary:
	var pieces := date.split("-")
	if pieces.size() != 3:
		return {}
	return {
		DayEventKeysScript.KEY_YEAR: int(pieces[0]),
		DayEventKeysScript.KEY_MONTH: int(pieces[1]),
		DayEventKeysScript.KEY_DAY: int(pieces[2])
	}
