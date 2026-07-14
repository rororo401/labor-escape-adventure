extends "res://scripts/tests/test_scene_tree.gd"

const GameDateFormatterScript := preload("res://scripts/core/game_date_formatter.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")


func _initialize() -> void:
	_expect(GameDateFormatterScript.weekday_ko("Friday") == "금요일", "formatter should localize known weekdays")
	_expect(GameDateFormatterScript.weekday_ko("Unknown") == "Unknown", "formatter should keep unknown weekdays unchanged")
	_expect(GameDateFormatterScript.dot_date("2016-07-01") == "2016.07.01", "formatter should convert ISO date to dotted date")
	_expect(GameDateFormatterScript.dot_date("bad-date") == "bad-date", "formatter should keep invalid dates unchanged")
	_expect(GameDateFormatterScript.morning_label("2016-07-01", "Friday") == "2016-07-01  금요일 아침", "formatter should build morning labels")
	_expect(GameDateFormatterScript.transition_morning_label("Saturday") == "토요일 아침", "formatter should build transition morning labels")

	var trading_day := {
		GameStateContextKeysScript.KEY_DATE: "2016-07-01",
		GameStateContextKeysScript.KEY_WEEKDAY: "Friday",
		GameStateContextKeysScript.KEY_IS_TRADING_DAY: true
	}
	_expect(GameDateFormatterScript.market_phase_label(trading_day, false) == "2016-07-01  금요일 아침", "open trading day should be morning")
	_expect(GameDateFormatterScript.market_phase_label(trading_day, true) == "2016-07-01  금요일 장마감", "completed trading day should be market close")

	var closed_day := {
		GameStateContextKeysScript.KEY_DATE: "2016-07-02",
		GameStateContextKeysScript.KEY_WEEKDAY: "Saturday",
		GameStateContextKeysScript.KEY_IS_TRADING_DAY: false
	}
	_expect(GameDateFormatterScript.market_phase_label(closed_day, false) == "2016-07-02  토요일 휴장일", "closed day should be labeled as closed")
	_expect(GameDateFormatterScript.market_phase_label(closed_day, true) == "2016-07-02  토요일 하루 마감", "completed closed day should be day close")

	print("Game date formatter smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
