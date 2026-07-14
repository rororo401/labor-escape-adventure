extends "res://scripts/tests/test_scene_tree.gd"

const DayEventCatalogScript := preload("res://scripts/core/dayflow/day_event_catalog.gd")
const DayEventRuleResolverScript := preload("res://scripts/core/dayflow/day_event_rule_resolver.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	var catalog = DayEventCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.DAY_EVENTS_PATH)

	_verify_forced_event(catalog)
	_verify_sick_override(catalog)
	_verify_market_fixed(catalog)
	_verify_holiday_rules(catalog)
	_verify_summer_vacation(catalog)
	_verify_default_actions(catalog)
	_verify_date_helpers()

	print("Day event rule resolver smoke test passed.")
	finish_test()


func _verify_forced_event(catalog) -> void:
	var action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		_trading_day("2016-07-01"),
		_default_status(),
		["part_time"]
	)
	_expect(action.get("id", "") == "part_time", "explicit forced event should win first")


func _verify_sick_override(catalog) -> void:
	var action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		_trading_day("2016-07-01"),
		{"health": 20, "fatigue": 10}
	)
	_expect(action.get("id", "") == "sick_rest", "low health should force sick rest")

	action = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		_trading_day("2016-07-01"),
		{"health": 80, "fatigue": 98}
	)
	_expect(action.get("id", "") == "sick_rest", "high fatigue should force sick rest")

	action = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		_closed_day("2016-07-02", "weekend"),
		{"health": 80, "fatigue": 98}
	)
	_expect(action.is_empty(), "high fatigue should not hide regular weekend choices")


func _verify_market_fixed(catalog) -> void:
	var action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		_trading_day("2020-03-13"),
		_default_status()
	)
	_expect(action.is_empty(), "fixed market event should not replace the normal trading-day action")
	_expect(
		DayEventRuleResolverScript.market_fixed_event_id(catalog.rules, _trading_day("2020-03-13")) == "market_covid_circuit_breaker_2020_03_13",
		"fixed market event id should still resolve from the trading date"
	)

	action = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		_closed_day("2020-03-13", "holiday"),
		_default_status()
	)
	_expect(action.get("id", "") != "market_covid_circuit_breaker_2020_03_13", "fixed market event should require a trading day")


func _verify_holiday_rules(catalog) -> void:
	var family_action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		{"date": "2016-09-15", "is_trading_day": false, "reason": "holiday", "name": "추석"},
		_default_status()
	)
	_expect(family_action.get("id", "") == "chuseok_2016_day_2", "annual Chuseok event should force the matching year and day event")

	var seollal_action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		{"date": "2017-01-28", "is_trading_day": false, "reason": "weekend", "name": ""},
		{"health": 20, "fatigue": 95}
	)
	_expect(seollal_action.get("id", "") == "seollal_2017_day_2", "annual Seollal date should override weekend and status events")

	var new_year_action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		{"date": "2022-01-01", "is_trading_day": false, "reason": "weekend", "name": ""},
		{"health": 20, "fatigue": 95}
	)
	_expect(new_year_action.get("id", "") == "new_year_2022", "annual New Year date should run a one-day event and override weekend/status events")

	var substitute_action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		{"date": "2017-10-06", "is_trading_day": false, "reason": "holiday", "name": "대체공휴일"},
		_default_status()
	)
	_expect(substitute_action.is_empty(), "substitute holiday should leave room for closed-day choices")

	var extra_family_action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		{"date": "2020-01-27", "is_trading_day": false, "reason": "holiday", "name": "설날"},
		_default_status()
	)
	_expect(extra_family_action.is_empty(), "extra family holiday should leave room for closed-day choices")

	var rest_action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		{"date": "2016-08-15", "is_trading_day": false, "reason": "holiday", "name": "광복절"},
		_default_status()
	)
	_expect(rest_action.get("id", "") == "holiday_rest", "ordinary holiday should force holiday rest")


func _verify_summer_vacation(catalog) -> void:
	var vacation_action: Dictionary = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		{"date": "2016-08-01", "is_trading_day": true, "reason": "", "name": ""},
		_default_status()
	)
	_expect(vacation_action.get("id", "") == "summer_vacation_2016_day_1", "first Monday of August should force annual summer vacation")

	vacation_action = DayEventRuleResolverScript.resolve_forced_day_action(
		catalog.actions_by_id,
		catalog.rules,
		{"date": "2016-08-03", "is_trading_day": true, "reason": "", "name": ""},
		_default_status()
	)
	_expect(vacation_action.get("id", "") == "summer_vacation_2016_day_3", "third vacation day should force the matching annual scene")
	_expect(DayEventRuleResolverScript.is_summer_vacation(catalog.rules, {"date": "2016-08-03"}), "vacation should include configured duration")
	_expect(not DayEventRuleResolverScript.is_summer_vacation(catalog.rules, {"date": "2016-08-04"}), "vacation should end after configured duration")
	_expect(DayEventRuleResolverScript.summer_vacation_event_id(catalog.rules, {"date": "2025-08-06"}) == "summer_vacation_2025_day_3", "vacation id should include year and day index")


func _verify_default_actions(catalog) -> void:
	var work: Dictionary = DayEventRuleResolverScript.get_default_day_action(catalog.actions_by_id, _trading_day("2016-07-01"))
	_expect(work.get("id", "") == "company_work", "trading day should default to company work")

	var holiday: Dictionary = DayEventRuleResolverScript.get_default_day_action(catalog.actions_by_id, {"is_trading_day": false, "reason": "holiday"})
	_expect(holiday.get("id", "") == "holiday_rest", "holiday should default to holiday rest")

	var closed: Dictionary = DayEventRuleResolverScript.get_default_day_action(catalog.actions_by_id, {"is_trading_day": false, "reason": "weekend"})
	_expect(closed.get("id", "") == "nap", "ordinary closed day should default to nap")


func _verify_date_helpers() -> void:
	var parts: Dictionary = DayEventRuleResolverScript.date_parts("2016-08-01")
	_expect(parts.get("year", 0) == 2016 and parts.get("month", 0) == 8 and parts.get("day", 0) == 1, "date parts should parse yyyy-mm-dd")
	_expect(DayEventRuleResolverScript.date_parts("bad-date").is_empty(), "invalid date should return empty parts")
	_expect(DayEventRuleResolverScript.first_weekday_day(2016, 8, 1) == 1, "first Monday of August 2016 should be day 1")


func _trading_day(date: String) -> Dictionary:
	return {
		"date": date,
		"is_trading_day": true,
		"reason": "",
		"name": ""
	}


func _closed_day(date: String, reason: String, day_name: String = "") -> Dictionary:
	return {
		"date": date,
		"is_trading_day": false,
		"reason": reason,
		"name": day_name
	}


func _default_status() -> Dictionary:
	return {
		"health": 100,
		"fatigue": 0
	}


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
