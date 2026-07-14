extends "res://scripts/tests/test_scene_tree.gd"

const DayEventCatalogScript := preload("res://scripts/core/dayflow/day_event_catalog.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameCalendarScript := preload("res://scripts/core/game_calendar.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	var catalog = DayEventCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.DAY_EVENTS_PATH)
	var calendar = GameCalendarScript.new()
	calendar.load_from_csv(GameStateConfigScript.CALENDAR_PATH)

	var trading_days := 0
	var weekday_event_days := 0
	var night_event_days := 0
	var night_event_counts := {}
	var status := {"cash": 5000000, "health": 100, "mood": 50, "fatigue": 0}
	for index in range(calendar.count()):
		var day: Dictionary = calendar.get_day(index)
		if not bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
			continue
		trading_days += 1
		var plan: Dictionary = catalog.build_day_result(
			day, status, index, "", [], false, [], "occurrence-statistics"
		)
		if not Array(plan.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, [])).is_empty():
			weekday_event_days += 1
		var selected_night_events: Array = plan.get(DayEventKeysScript.KEY_NIGHT_EVENTS, [])
		if not selected_night_events.is_empty():
			night_event_days += 1
			var event_id := String(Dictionary(selected_night_events[0]).get(DayEventKeysScript.KEY_ID, ""))
			night_event_counts[event_id] = int(night_event_counts.get(event_id, 0)) + 1

	var weekday_rate := float(weekday_event_days) / float(trading_days)
	var night_rate := float(night_event_days) / float(trading_days)
	_expect(trading_days > 2000, "production calendar should provide a meaningful statistical sample")
	_expect(weekday_rate >= 0.25 and weekday_rate <= 0.33, "production weekday occurrence should remain near configured 30%")
	_expect(night_rate >= 0.29 and night_rate <= 0.38, "production night occurrence should remain near configured 35%")
	_expect(weekday_rate < 0.50 and night_rate < 0.50, "production event pools must not return to near-certain occurrence")
	var highest_night_count := 0
	for event_id in night_event_counts:
		highest_night_count = maxi(highest_night_count, int(night_event_counts.get(event_id, 0)))
	var highest_night_share := float(highest_night_count) / float(night_event_days)
	_expect(highest_night_share < 0.04, "no single night event should dominate the configured random pool")
	print(
		"Day event occurrence statistics passed: weekday=%d/%d (%.3f), night=%d/%d (%.3f), max_night_share=%.3f"
		% [weekday_event_days, trading_days, weekday_rate, night_event_days, trading_days, night_rate, highest_night_share]
	)
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
