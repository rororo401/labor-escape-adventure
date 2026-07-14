extends "res://scripts/tests/test_scene_tree.gd"

const CalendarPayloadKeysScript := preload("res://scripts/core/calendar_payload_keys.gd")


func _initialize() -> void:
	_expect(CalendarPayloadKeysScript.KEY_DATE == "date", "calendar date key should stay stable")
	_expect(CalendarPayloadKeysScript.KEY_WEEKDAY == "weekday", "calendar weekday key should stay stable")
	_expect(CalendarPayloadKeysScript.KEY_IS_TRADING_DAY == "is_trading_day", "calendar trading-day key should stay stable")

	print("Calendar payload keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
