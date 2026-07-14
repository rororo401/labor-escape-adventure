class_name GameDateFormatter
extends RefCounted

const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")


static func weekday_ko(weekday: String) -> String:
	var names := {
		"Monday": "월요일",
		"Tuesday": "화요일",
		"Wednesday": "수요일",
		"Thursday": "목요일",
		"Friday": "금요일",
		"Saturday": "토요일",
		"Sunday": "일요일"
	}
	return names.get(weekday, weekday)


static func dot_date(date: String) -> String:
	var pieces := date.split("-")
	if pieces.size() != 3:
		return date
	return "%s.%s.%s" % [pieces[0], pieces[1], pieces[2]]


static func morning_label(date: String, weekday: String) -> String:
	return "%s  %s 아침" % [date, weekday_ko(weekday)]


static func transition_morning_label(weekday: String) -> String:
	return "%s 아침" % weekday_ko(weekday)


static func market_phase_label(today: Dictionary, day_completed: bool) -> String:
	var phase := "아침"
	if day_completed:
		phase = "장마감" if bool(today.get(GameStateContextKeysScript.KEY_IS_TRADING_DAY, false)) else "하루 마감"
	elif not bool(today.get(GameStateContextKeysScript.KEY_IS_TRADING_DAY, false)):
		phase = "휴장일"
	return "%s  %s %s" % [
		String(today.get(GameStateContextKeysScript.KEY_DATE, "")),
		weekday_ko(String(today.get(GameStateContextKeysScript.KEY_WEEKDAY, ""))),
		phase
	]
