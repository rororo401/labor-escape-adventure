extends "res://scripts/tests/test_scene_tree.gd"

const DayEventCatalogScript := preload("res://scripts/core/dayflow/day_event_catalog.gd")
const DayEventCatalogLoaderScript := preload("res://scripts/core/dayflow/day_event_catalog_loader.gd")
const DayEventConditionResolverScript := preload("res://scripts/core/dayflow/day_event_condition_resolver.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventRandomizerScript := preload("res://scripts/core/dayflow/day_event_randomizer.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	_verify_calendar_and_status_conditions()
	_verify_deterministic_weather_conditions()
	_verify_catalog_conditions_are_structured_and_attached()
	_verify_catalog_separates_condition_seed()
	_verify_random_selection_filters_before_occurrence_roll()
	_verify_same_day_material_is_filtered()
	print("Day event condition resolver smoke test passed.")
	finish_test()


func _verify_calendar_and_status_conditions() -> void:
	var event := {
		DayEventKeysScript.KEY_CONDITIONS: {
			"season_any": ["summer"],
			"day_of_month_min": 23,
			"day_of_month_max": 28,
			"health_max": 55,
			"fatigue_min": 70
		}
	}
	var eligible_status := {"health": 50, "mood": 50, "fatigue": 80}
	_expect(
		DayEventConditionResolverScript.is_event_eligible(event, _day("2020-07-25"), eligible_status, "conditions"),
		"matching season, date, and status should be eligible"
	)
	_expect(
		not DayEventConditionResolverScript.is_event_eligible(event, _day("2020-01-25"), eligible_status, "conditions"),
		"wrong season should be filtered"
	)
	_expect(
		not DayEventConditionResolverScript.is_event_eligible(event, _day("2020-07-10"), eligible_status, "conditions"),
		"wrong day-of-month should be filtered"
	)
	_expect(
		not DayEventConditionResolverScript.is_event_eligible(event, _day("2020-07-25"), {"health": 80, "fatigue": 80}, "conditions"),
		"status above the configured health maximum should be filtered"
	)


func _verify_deterministic_weather_conditions() -> void:
	var rainy_date := _find_weather_date("rain", "weather-seed")
	var clear_date := _find_weather_date("clear", "weather-seed")
	_expect(not rainy_date.is_empty(), "test range should contain a deterministic rainy date")
	_expect(not clear_date.is_empty(), "test range should contain a deterministic clear date")
	var rainy_event := {DayEventKeysScript.KEY_CONDITIONS: {"weather_any": ["rain"]}}
	_expect(
		DayEventConditionResolverScript.is_event_eligible(rainy_event, _day(rainy_date), {}, "weather-seed"),
		"rain condition should accept the deterministic rainy date"
	)
	_expect(
		not DayEventConditionResolverScript.is_event_eligible(rainy_event, _day(clear_date), {}, "weather-seed"),
		"rain condition should reject the deterministic clear date"
	)
	_expect(
		DayEventConditionResolverScript.weather_tags_for_date(rainy_date, "weather-seed")
			== DayEventConditionResolverScript.weather_tags_for_date(rainy_date, "weather-seed"),
		"weather should be stable for the same run seed and date"
	)


func _verify_catalog_conditions_are_structured_and_attached() -> void:
	var catalog = DayEventCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.DAY_EVENTS_PATH)
	var condition_rules := Dictionary(catalog.rules.get(DayEventKeysScript.RULE_EVENT_CONDITIONS, {}))
	_expect(condition_rules.size() >= 50, "production catalog should define structured conditions for conditional events")
	for event_id in condition_rules.keys():
		var event := catalog.get_action(String(event_id))
		if event.is_empty():
			event = catalog.get_weekday_event(String(event_id))
		if event.is_empty():
			event = catalog.get_night_event(String(event_id))
		_expect(not event.is_empty(), "condition map should not reference a missing event: %s" % event_id)
		_expect(
			Dictionary(event.get(DayEventKeysScript.KEY_CONDITIONS, {})) == Dictionary(condition_rules.get(event_id, {})),
			"loader should attach structured conditions to event: %s" % event_id
		)

	var summer_choices := catalog.get_available_day_choices(
		{"date": "2020-07-04", "is_trading_day": false, "reason": "weekend"},
		{"health": 100, "mood": 50, "fatigue": 0},
		"catalog-seed"
	)
	_expect(_has_id(summer_choices, "summer_ice_pack"), "summer-only closed-day action should be available in summer")
	_expect(not _has_id(summer_choices, "winter_sock_mending"), "winter-only closed-day action should be filtered in summer")


func _verify_random_selection_filters_before_occurrence_roll() -> void:
	var event := {
		"id": "summer_only",
		"chance": 1.0,
		"weight": 1,
		DayEventKeysScript.KEY_CONDITIONS: {"season_any": ["summer"]}
	}
	var events: Array[Dictionary] = [event]
	var by_id := {"summer_only": event}
	var winter := DayEventRandomizerScript.select_weekday_events(
		events, by_id, _day("2020-01-10"), 0, [], false, [], "condition-seed", {}, 1.0
	)
	var summer := DayEventRandomizerScript.select_weekday_events(
		events, by_id, _day("2020-07-10"), 0, [], false, [], "condition-seed", {}, 1.0
	)
	_expect(winter.is_empty(), "condition-mismatched event should not enter the random pool")
	_expect(_has_id(summer, "summer_only"), "condition-matched event should remain selectable")


func _verify_catalog_separates_condition_seed() -> void:
	var date := "2020-07-04"
	var rain_seed := _find_weather_seed(date, "rain")
	var clear_seed := _find_weather_seed(date, "clear")
	_expect(not rain_seed.is_empty(), "test should find a rainy condition seed")
	_expect(not clear_seed.is_empty(), "test should find a clear condition seed")

	var catalog = _catalog_from_parsed({
		DayEventKeysScript.KEY_DAY_ACTIONS: [
			_choice_action("rain_choice", "rain"),
			_choice_action("clear_choice", "clear")
		]
	})
	var day := {"date": date, "is_trading_day": false, "reason": "weekend"}
	var status := {"health": 100, "mood": 50, "fatigue": 0}
	var rainy_choices: Array[Dictionary] = catalog.get_available_day_choices(
		day, status, "narrative-seed", rain_seed
	)
	var clear_choices: Array[Dictionary] = catalog.get_available_day_choices(
		day, status, "narrative-seed", clear_seed
	)
	var fallback_choices: Array[Dictionary] = catalog.get_available_day_choices(day, status, rain_seed)
	_expect(_has_id(rainy_choices, "rain_choice"), "condition seed should control rainy action eligibility")
	_expect(not _has_id(rainy_choices, "clear_choice"), "rainy condition seed should filter clear actions")
	_expect(_has_id(clear_choices, "clear_choice"), "condition seed should control clear action eligibility")
	_expect(not _has_id(clear_choices, "rain_choice"), "clear condition seed should filter rainy actions")
	_expect(
		_ids(fallback_choices) == _ids(rainy_choices),
		"omitted condition seed should fall back to the narrative random seed"
	)


func _verify_same_day_material_is_filtered() -> void:
	var company_variant := _event("company_variant", "company_theme")
	company_variant[DayEventKeysScript.KEY_MODE] = DayEventKeysScript.MODE_AUTO_TRADING
	company_variant[DayEventKeysScript.KEY_GROUP] = DayEventKeysScript.GROUP_COMPANY_WORK
	var catalog = _catalog_from_parsed({
		DayEventKeysScript.KEY_DAY_ACTIONS: [
			{
				DayEventKeysScript.KEY_ID: DayEventKeysScript.ACTION_COMPANY_WORK,
				DayEventKeysScript.KEY_MODE: DayEventKeysScript.MODE_AUTO_TRADING
			},
			company_variant
		],
		DayEventKeysScript.KEY_WEEKDAY_EVENTS: [
			_event("weekday_company_repeat", "company_theme"),
			_event("weekday_distinct", "weekday_theme")
		],
		DayEventKeysScript.KEY_NIGHT_EVENTS: [
			_event("night_weekday_repeat", "weekday_theme"),
			_event("night_distinct", "night_theme")
		],
		DayEventKeysScript.KEY_RULES: {
			DayEventKeysScript.KEY_RANDOM_EVENT_OCCURRENCE: {
				DayEventKeysScript.KEY_WEEKDAY_OCCURRENCE: 1.0,
				DayEventKeysScript.KEY_NIGHT_OCCURRENCE: 1.0
			}
		}
	})
	var committed_history: Array = []
	var result: Dictionary = catalog.build_day_result(
		{"date": "2020-07-06", "is_trading_day": true},
		{"health": 100, "mood": 50, "fatigue": 0},
		0,
		DayEventKeysScript.ACTION_COMPANY_WORK,
		[],
		false,
		committed_history,
		"narrative-seed",
		"condition-seed"
	)
	_expect(
		String(Dictionary(result.get(DayEventKeysScript.KEY_DAY_ACTION, {})).get(DayEventKeysScript.KEY_ID, "")) == "company_variant",
		"company work should resolve before same-day material filtering"
	)
	_expect(
		_ids(Array(result.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []))) == ["weekday_distinct"],
		"weekday selection should avoid the company event's same-day theme"
	)
	_expect(
		_ids(Array(result.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []))) == ["night_distinct"],
		"night selection should avoid the selected weekday event's same-day theme"
	)
	_expect(committed_history.is_empty(), "provisional same-day history must not mutate committed history")


func _find_weather_date(weather: String, seed: String) -> String:
	for month in range(1, 13):
		for day_of_month in range(1, 29):
			var date := "2020-%02d-%02d" % [month, day_of_month]
			if DayEventConditionResolverScript.weather_tags_for_date(date, seed).has(weather):
				return date
	return ""


func _find_weather_seed(date: String, weather: String) -> String:
	for index in range(1000):
		var seed := "weather-seed-%d" % index
		if DayEventConditionResolverScript.weather_tags_for_date(date, seed).has(weather):
			return seed
	return ""


func _catalog_from_parsed(parsed: Dictionary):
	var catalog = DayEventCatalogScript.new()
	catalog._apply_payload(DayEventCatalogLoaderScript.payload_from_parsed(parsed))
	return catalog


func _choice_action(event_id: String, weather: String) -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: event_id,
		DayEventKeysScript.KEY_MODE: DayEventKeysScript.MODE_CHOICE_CLOSED,
		DayEventKeysScript.KEY_CATEGORY_ID: "test",
		DayEventKeysScript.KEY_CONDITIONS: {"weather_any": [weather]}
	}


func _event(event_id: String, theme: String) -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: event_id,
		DayEventKeysScript.KEY_TAGS: [theme],
		DayEventKeysScript.KEY_CG_PATH: "res://events/%s.png" % event_id,
		DayEventKeysScript.KEY_DIALOGUE: [event_id],
		DayEventKeysScript.KEY_CHANCE: 1.0,
		DayEventKeysScript.KEY_WEIGHT: 1.0
	}


func _day(date: String) -> Dictionary:
	return {"date": date, "is_trading_day": true}


func _has_id(events: Array, event_id: String) -> bool:
	for event in events:
		if String(Dictionary(event).get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false


func _ids(events: Array) -> Array[String]:
	var ids: Array[String] = []
	for event in events:
		ids.append(String(Dictionary(event).get(DayEventKeysScript.KEY_ID, "")))
	return ids


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
