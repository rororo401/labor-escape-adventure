extends "res://scripts/tests/test_scene_tree.gd"

const DayEventCatalogLoaderScript := preload("res://scripts/core/dayflow/day_event_catalog_loader.gd")
const DayEventChoiceProviderScript := preload("res://scripts/core/dayflow/day_event_choice_provider.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()
var _payload: Dictionary


func _initialize() -> void:
	_payload = DayEventCatalogLoaderScript.load_from_json(GameStateConfigScript.DAY_EVENTS_PATH)
	_verify_closed_day_choices()
	_verify_blocked_choice_days()
	_verify_selected_or_default_action()

	print("Day event choice provider smoke test passed.")
	finish_test()


func _verify_closed_day_choices() -> void:
	var day := _closed_day("2016-07-02", "weekend")
	var categories: Array[Dictionary] = DayEventChoiceProviderScript.available_categories(_day_actions(), _actions_by_id(), _rules(), day, _default_status())
	var choices: Array[Dictionary] = DayEventChoiceProviderScript.available_choices(_day_actions(), _actions_by_id(), _rules(), day, _default_status())
	var category_ids := _helpers.ids_from_items(categories)
	var choice_ids := _helpers.ids_from_items(choices)

	_expect(category_ids.has("stay_home"), "closed day should expose stay-home category")
	_expect(category_ids.has("go_out"), "closed day should expose go-out category")
	_expect(choice_ids.has("part_time"), "closed day choices should include part-time")
	_expect(DayEventChoiceProviderScript.can_choose_day_action(_actions_by_id(), _rules(), day, _default_status()), "regular closed day should allow choices")


func _verify_blocked_choice_days() -> void:
	_expect(_is_choice_blocked(_trading_day("2016-07-01")), "trading day should not expose closed-day choices")
	_expect(_is_choice_blocked(_closed_day("2016-08-15", "holiday", "광복절")), "holiday should not expose closed-day choices")
	_expect(not _is_choice_blocked(_closed_day("2020-01-27", "holiday", "설날")), "extra family holiday should expose closed-day choices")
	_expect(not _is_choice_blocked(_closed_day("2017-10-06", "holiday", "대체공휴일")), "substitute holiday should expose closed-day choices")
	_expect(_is_choice_blocked(_closed_day("2020-01-25", "weekend", "주말")), "annual holiday core weekend should not expose closed-day choices")
	_expect(_is_choice_blocked(_trading_day("2016-08-01")), "summer vacation override should not expose choices")
	_expect(
		_is_choice_blocked(_trading_day("2016-07-04"), {"health": 90, "fatigue": 98}),
		"sick override should not expose choices"
	)
	_expect(
		not _is_choice_blocked(_closed_day("2016-07-02", "weekend"), {"health": 90, "fatigue": 98}),
		"regular weekend should still expose choices when fatigue is high"
	)


func _verify_selected_or_default_action() -> void:
	var closed_day := _closed_day("2016-07-02", "weekend")
	var selected: Dictionary = DayEventChoiceProviderScript.resolve_selected_or_default_action(
		_day_actions(),
		_actions_by_id(),
		_rules(),
		closed_day,
		_default_status(),
		"part_time"
	)
	_expect(selected.get("id", "") == "part_time", "closed-day selected choice should resolve")

	var fallback: Dictionary = DayEventChoiceProviderScript.resolve_selected_or_default_action(
		_day_actions(),
		_actions_by_id(),
		_rules(),
		closed_day,
		_default_status(),
		"missing"
	)
	_expect(fallback.get("id", "") == "nap", "missing closed-day action should fall back to nap")

	var work: Dictionary = DayEventChoiceProviderScript.resolve_selected_or_default_action(
		_day_actions(),
		_actions_by_id(),
		_rules(),
		_trading_day("2016-07-01"),
		_default_status(),
		"go_to_work"
	)
	_expect(work.get("id", "") == "company_work", "go_to_work alias should resolve to company work")


func _is_choice_blocked(day: Dictionary, status: Dictionary = {}) -> bool:
	var actual_status := _default_status() if status.is_empty() else status
	return DayEventChoiceProviderScript.available_categories(_day_actions(), _actions_by_id(), _rules(), day, actual_status).is_empty() \
		and DayEventChoiceProviderScript.available_choices(_day_actions(), _actions_by_id(), _rules(), day, actual_status).is_empty() \
		and not DayEventChoiceProviderScript.can_choose_day_action(_actions_by_id(), _rules(), day, actual_status)


func _day_actions() -> Array:
	return _payload.get("day_actions", [])


func _actions_by_id() -> Dictionary:
	return Dictionary(_payload.get("actions_by_id", {}))


func _rules() -> Dictionary:
	return Dictionary(_payload.get("rules", {}))


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
