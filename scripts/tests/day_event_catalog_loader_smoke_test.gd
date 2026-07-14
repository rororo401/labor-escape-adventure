extends "res://scripts/tests/test_scene_tree.gd"

const DayEventCatalogLoaderScript := preload("res://scripts/core/dayflow/day_event_catalog_loader.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	_verify_payload_from_parsed()
	_verify_index_rows()
	_verify_real_file_load()

	print("Day event catalog loader smoke test passed.")
	finish_test()


func _verify_payload_from_parsed() -> void:
	var payload: Dictionary = DayEventCatalogLoaderScript.payload_from_parsed({
		DayEventKeysScript.KEY_CLOSED_DAY_CHOICE_LIMIT: 7,
		DayEventKeysScript.KEY_RULES: {"sample": true},
		DayEventKeysScript.KEY_DAY_ACTIONS: [
			{DayEventKeysScript.KEY_ID: DayEventKeysScript.ACTION_COMPANY_WORK, DayEventKeysScript.KEY_NAME_KO: "회사 업무"},
			{DayEventKeysScript.KEY_NAME_KO: "id 없음"},
			"bad row"
		],
		DayEventKeysScript.KEY_WEEKDAY_EVENTS: [
			{DayEventKeysScript.KEY_ID: "weekday_sample", DayEventKeysScript.KEY_CHANCE: 1.0},
			{}
		],
		DayEventKeysScript.KEY_NIGHT_EVENTS: [
			{DayEventKeysScript.KEY_ID: "night_early_sleep", DayEventKeysScript.KEY_CHANCE: 1.0},
			{}
		]
	})

	_expect(int(payload.get(DayEventKeysScript.KEY_CLOSED_DAY_CHOICE_LIMIT, 0)) == 7, "payload should preserve closed-day choice limit")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_RULES, {})).get("sample", false), "payload should preserve rules")
	_expect(Array(payload.get(DayEventKeysScript.KEY_DAY_ACTIONS, [])).size() == 1, "payload should keep only valid day actions")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).has(DayEventKeysScript.ACTION_COMPANY_WORK), "payload should index day actions by id")
	_expect(Array(payload.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, [])).size() == 1, "payload should keep only valid weekday events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS_BY_ID, {})).has("weekday_sample"), "payload should index weekday events by id")
	_expect(Array(payload.get(DayEventKeysScript.KEY_NIGHT_EVENTS, [])).size() == 1, "payload should keep only valid night events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_NIGHT_EVENTS_BY_ID, {})).has("night_early_sleep"), "payload should index night events by id")


func _verify_index_rows() -> void:
	var indexed: Dictionary = DayEventCatalogLoaderScript.index_rows([
		{DayEventKeysScript.KEY_ID: "a", "value": 1},
		{DayEventKeysScript.KEY_ID: ""},
		7,
		{DayEventKeysScript.KEY_ID: "b", "value": 2}
	])
	_expect(Array(indexed.get(DayEventKeysScript.KEY_ROWS, [])).size() == 2, "index rows should skip invalid rows")
	_expect(Dictionary(indexed.get(DayEventKeysScript.KEY_BY_ID, {})).get("a", {}).get("value", 0) == 1, "index rows should store first valid row")
	_expect(Dictionary(indexed.get(DayEventKeysScript.KEY_BY_ID, {})).get("b", {}).get("value", 0) == 2, "index rows should store second valid row")


func _verify_real_file_load() -> void:
	var payload: Dictionary = DayEventCatalogLoaderScript.load_from_json(GameStateConfigScript.DAY_EVENTS_PATH)
	_expect(Array(payload.get(DayEventKeysScript.KEY_DAY_ACTIONS, [])).size() >= 445, "real day-event file should load company work variants")
	_expect(Array(payload.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, [])).size() == 180, "real day-event file should load phase4 weekday events")
	_expect(Array(payload.get(DayEventKeysScript.KEY_NIGHT_EVENTS, [])).size() == 160, "real day-event file should load phase4 night events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).has(DayEventKeysScript.ACTION_COMPANY_WORK), "real day-event file should index company work")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).has("company_inbox_01"), "real day-event file should index company work variant events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).has("summer_vacation_2016_day_1"), "real day-event file should merge annual summer vacation events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).has("new_year_2017"), "real day-event file should merge annual New Year events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).has("seollal_2017_day_1"), "real day-event file should merge annual Seollal events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).has("chuseok_2025_day_3"), "real day-event file should merge annual Chuseok events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).has("market_covid_circuit_breaker_2020_03_13"), "real day-event file should merge fixed market events")
	_expect(Dictionary(Dictionary(payload.get(DayEventKeysScript.KEY_RULES, {})).get(DayEventKeysScript.RULE_ANNUAL_SPECIAL_DATES, {})).get("2017-01-01", "") == "new_year_2017", "real day-event file should merge annual New Year date rules")
	_expect(Dictionary(Dictionary(payload.get(DayEventKeysScript.KEY_RULES, {})).get(DayEventKeysScript.RULE_ANNUAL_SPECIAL_DATES, {})).get("2017-01-28", "") == "seollal_2017_day_2", "real day-event file should merge annual special date rules")
	_expect(Dictionary(Dictionary(payload.get(DayEventKeysScript.KEY_RULES, {})).get(DayEventKeysScript.RULE_MARKET_FIXED_DATES, {})).get("2020-03-13", "") == "market_covid_circuit_breaker_2020_03_13", "real day-event file should merge fixed market date rules")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS_BY_ID, {})).has("overtime_request"), "real day-event file should index weekday events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_NIGHT_EVENTS_BY_ID, {})).has("night_chimaek"), "real day-event file should index night events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS_BY_ID, {})).has("weekday_subway_door_delay"), "real day-event file should index phase4 weekday events")
	_expect(Dictionary(payload.get(DayEventKeysScript.KEY_NIGHT_EVENTS_BY_ID, {})).has("night_afterwork_toast"), "real day-event file should index phase4 night events")
	_expect(int(payload.get(DayEventKeysScript.KEY_CLOSED_DAY_CHOICE_LIMIT, 0)) > 0, "real day-event file should expose a choice limit")
	_verify_company_work_variants(payload)


func _verify_company_work_variants(payload: Dictionary) -> void:
	var variants: Array[Dictionary] = []
	for row in payload.get(DayEventKeysScript.KEY_DAY_ACTIONS, []):
		var action := Dictionary(row)
		if String(action.get(DayEventKeysScript.KEY_GROUP, "")) == DayEventKeysScript.GROUP_COMPANY_WORK:
			variants.append(action)
	_expect(variants.size() == 200, "real day-event file should load 200 company work variants")
	for variant in variants:
		_expect(String(variant.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_AUTO_TRADING, "company work variants should use auto trading mode")
		_expect(ResourceLoader.exists(String(variant.get(DayEventKeysScript.KEY_CG_PATH, ""))), "company work variant CG should exist")
		_expect(Array(variant.get(DayEventKeysScript.KEY_DIALOGUE, [])).size() == 3, "company work variants should include three dialogue lines")

	var annual_event := Dictionary(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).get("summer_vacation_2025_day_3", {}))
	_expect(Array(annual_event.get(DayEventKeysScript.KEY_DIALOGUE, [])).size() >= 8, "annual vacation events should include longer dialogue")
	_expect(String(annual_event.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_ANNUAL_SPECIAL, "annual vacation events should use annual special mode")
	var seollal_event := Dictionary(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).get("seollal_2026_day_2", {}))
	_expect(Array(seollal_event.get(DayEventKeysScript.KEY_DIALOGUE, [])).size() >= 8, "annual holiday events should include longer dialogue")
	_expect(String(seollal_event.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_ANNUAL_SPECIAL, "annual holiday events should use annual special mode")
	var new_year_event := Dictionary(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).get("new_year_2026", {}))
	_expect(Array(new_year_event.get(DayEventKeysScript.KEY_DIALOGUE, [])).size() >= 10, "annual New Year events should include longer dialogue")
	_expect(String(new_year_event.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_ANNUAL_SPECIAL, "annual New Year events should use annual special mode")
	var market_event := Dictionary(Dictionary(payload.get(DayEventKeysScript.KEY_ACTIONS_BY_ID, {})).get("market_trump_election_2016_11_09", {}))
	_expect(String(market_event.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_MARKET_FIXED, "market fixed events should use market fixed mode")
	_expect(String(market_event.get("playback_mode", "")) == "cg_then_standing", "market fixed events should use CG then standing playback")
	_expect(not String(market_event.get(DayEventKeysScript.KEY_SUMMARY_KO, "")).contains("{person_trump}"), "market fixed event aliases should be resolved")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
