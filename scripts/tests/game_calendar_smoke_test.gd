extends "res://scripts/tests/test_scene_tree.gd"

const GameCalendarScript := preload("res://scripts/core/game_calendar.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	_expect(GameCalendarScript.CSV_COLUMN_DATE == 0, "calendar date column should stay stable")
	_expect(GameCalendarScript.CSV_MIN_COLUMNS == 5, "calendar CSV should require five columns")
	_expect(GameCalendarScript.CSV_TRUE == "true", "calendar true literal should stay stable")

	var calendar = GameCalendarScript.new()
	calendar.load_from_csv(GameStateConfigScript.CALENDAR_PATH)

	_expect(calendar.count() > 0, "calendar should load rows")

	var first_day := calendar.get_day(0)
	_expect(String(first_day.get(GameStateContextKeysScript.KEY_DATE, "")) == "2016-07-01", "first day should expose date")
	_expect(String(first_day.get(GameStateContextKeysScript.KEY_WEEKDAY, "")) == "Friday", "first day should expose weekday")
	_expect(bool(first_day.get(GameStateContextKeysScript.KEY_IS_TRADING_DAY, false)), "first day should be trading day")
	_expect(calendar.find_index_by_date("2016-07-01") == 0, "calendar should find the first date")
	_expect(calendar.find_index_by_date("missing-date") == -1, "calendar should return -1 for missing dates")
	_expect(calendar.get_day(-1).is_empty(), "calendar should return empty row for negative index")
	_expect(calendar.get_day(calendar.count()).is_empty(), "calendar should return empty row past the end")

	print("Game calendar smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
