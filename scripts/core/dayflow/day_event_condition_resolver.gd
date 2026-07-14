class_name DayEventConditionResolver
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")

const SEASON_SPRING := "spring"
const SEASON_SUMMER := "summer"
const SEASON_AUTUMN := "autumn"
const SEASON_WINTER := "winter"

const WEATHER_CLEAR := "clear"
const WEATHER_RAIN := "rain"
const WEATHER_HEATWAVE := "heatwave"
const WEATHER_COLD_WAVE := "cold_wave"

const KEY_SEASON_ANY := "season_any"
const KEY_WEATHER_ANY := "weather_any"
const KEY_DAY_OF_MONTH_MIN := "day_of_month_min"
const KEY_DAY_OF_MONTH_MAX := "day_of_month_max"
const KEY_HEALTH_MIN := "health_min"
const KEY_HEALTH_MAX := "health_max"
const KEY_MOOD_MIN := "mood_min"
const KEY_MOOD_MAX := "mood_max"
const KEY_FATIGUE_MIN := "fatigue_min"
const KEY_FATIGUE_MAX := "fatigue_max"


static func is_event_eligible(
	event: Dictionary,
	day: Dictionary,
	status: Dictionary,
	random_seed: String = ""
) -> bool:
	var conditions := Dictionary(event.get(DayEventKeysScript.KEY_CONDITIONS, {}))
	if conditions.is_empty():
		return true

	var parts := _date_parts(String(day.get(DayEventKeysScript.KEY_DATE, "")))
	if parts.is_empty():
		return false

	var month := int(parts.get(DayEventKeysScript.KEY_MONTH, 0))
	var day_of_month := int(parts.get(DayEventKeysScript.KEY_DAY, 0))
	if not _matches_text_list(conditions.get(KEY_SEASON_ANY, []), season_for_month(month)):
		return false
	if not _matches_day_of_month(conditions, day_of_month):
		return false
	if not _matches_status_range(conditions, status, PlayerStatusKeysScript.KEY_HEALTH, KEY_HEALTH_MIN, KEY_HEALTH_MAX):
		return false
	if not _matches_status_range(conditions, status, PlayerStatusKeysScript.KEY_MOOD, KEY_MOOD_MIN, KEY_MOOD_MAX):
		return false
	if not _matches_status_range(conditions, status, PlayerStatusKeysScript.KEY_FATIGUE, KEY_FATIGUE_MIN, KEY_FATIGUE_MAX):
		return false

	var weather_conditions: Array = conditions.get(KEY_WEATHER_ANY, [])
	if not weather_conditions.is_empty():
		var weather := weather_tags_for_date(String(day.get(DayEventKeysScript.KEY_DATE, "")), random_seed)
		if not _has_overlap(weather_conditions, weather):
			return false
	return true


static func season_for_month(month: int) -> String:
	if month >= 3 and month <= 5:
		return SEASON_SPRING
	if month >= 6 and month <= 8:
		return SEASON_SUMMER
	if month >= 9 and month <= 11:
		return SEASON_AUTUMN
	if month == 12 or month == 1 or month == 2:
		return SEASON_WINTER
	return ""


static func weather_tags_for_date(date: String, random_seed: String = "") -> Array[String]:
	var parts := _date_parts(date)
	if parts.is_empty():
		return []

	var month := int(parts.get(DayEventKeysScript.KEY_MONTH, 0))
	var season := season_for_month(month)
	var rain_chance := 0.12
	if month == 6 or month == 7:
		rain_chance = 0.38
	elif month == 8:
		rain_chance = 0.24

	var tags: Array[String] = []
	if _stable_value(date, "rain", random_seed) < rain_chance:
		tags.append(WEATHER_RAIN)
	else:
		tags.append(WEATHER_CLEAR)
	if season == SEASON_SUMMER and _stable_value(date, "heatwave", random_seed) < 0.22:
		tags.append(WEATHER_HEATWAVE)
	if season == SEASON_WINTER and _stable_value(date, "cold_wave", random_seed) < 0.22:
		tags.append(WEATHER_COLD_WAVE)
	return tags


static func _matches_text_list(raw_expected, actual: String) -> bool:
	var expected := Array(raw_expected)
	if expected.is_empty():
		return true
	for value in expected:
		if String(value) == actual:
			return true
	return false


static func _matches_day_of_month(conditions: Dictionary, day_of_month: int) -> bool:
	if conditions.has(KEY_DAY_OF_MONTH_MIN) and day_of_month < int(conditions.get(KEY_DAY_OF_MONTH_MIN, 1)):
		return false
	if conditions.has(KEY_DAY_OF_MONTH_MAX) and day_of_month > int(conditions.get(KEY_DAY_OF_MONTH_MAX, 31)):
		return false
	return true


static func _matches_status_range(
	conditions: Dictionary,
	status: Dictionary,
	status_key: String,
	minimum_key: String,
	maximum_key: String
) -> bool:
	if not conditions.has(minimum_key) and not conditions.has(maximum_key):
		return true
	var value := int(status.get(status_key, 0))
	if conditions.has(minimum_key) and value < int(conditions.get(minimum_key, value)):
		return false
	if conditions.has(maximum_key) and value > int(conditions.get(maximum_key, value)):
		return false
	return true


static func _has_overlap(expected: Array, actual: Array[String]) -> bool:
	for value in expected:
		if actual.has(String(value)):
			return true
	return false


static func _date_parts(date: String) -> Dictionary:
	var pieces := date.split("-")
	if pieces.size() != 3:
		return {}
	return {
		DayEventKeysScript.KEY_YEAR: int(pieces[0]),
		DayEventKeysScript.KEY_MONTH: int(pieces[1]),
		DayEventKeysScript.KEY_DAY: int(pieces[2])
	}


static func _stable_value(date: String, group: String, random_seed: String) -> float:
	var text := "%s:%s:%s" % [random_seed, date, group]
	var state := 0
	for byte in text.to_utf8_buffer():
		state = int((state * 131 + int(byte)) % 1000003)
	return float(state % 10000) / 10000.0
