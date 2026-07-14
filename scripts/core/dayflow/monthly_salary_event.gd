class_name MonthlySalaryEvent
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")

const PAYDAY_DAY := 25
const MIN_SALARY := 500000
const MAX_SALARY := 800000
const SALARY_STEP := 10000
const EVENT_ID_PREFIX := "monthly_salary"


static func event_for_day(day: Dictionary, event_history: Array, difficulty: String = GameDifficultyScript.DEFAULT) -> Dictionary:
	if not is_due(day, event_history):
		return {}

	var date := String(day.get(DayEventKeysScript.KEY_DATE, ""))
	var amount := salary_amount_for_date(date, difficulty)
	var event_id := event_id_for_date(date)
	return {
		DayEventKeysScript.KEY_ID: event_id,
		DayEventKeysScript.KEY_NAME_KO: "월급 입금",
		DayEventKeysScript.KEY_SUMMARY_KO: "생활비를 제외한 이번 달 투자 가능 금액이 입금된다.",
		DayEventKeysScript.KEY_MODE: "monthly_salary",
		DayEventKeysScript.KEY_TAGS: ["salary", "income", "monthly"],
		DayEventKeysScript.KEY_COOLDOWN_DAYS: 0,
		DayEventKeysScript.KEY_WEIGHT: 1,
		DayEventKeysScript.KEY_RARITY: "monthly",
		DayEventKeysScript.KEY_CHANCE: 1.0,
		DayEventKeysScript.KEY_DIALOGUE: [
			"은행 앱 알림이 조용히 떴다. 월급날이다.",
			"월세와 카드값, 식비를 먼저 떼어내고 남은 돈만 투자 계좌로 옮겼다.",
			"이번 달 투자 가능 금액은 %s원. 무리하지 않는 선에서 다시 시작한다." % _format_won(amount)
		],
		DayEventKeysScript.KEY_EFFECTS: {
			PlayerStatusKeysScript.KEY_CASH_DELTA: amount,
			PlayerStatusKeysScript.KEY_HEALTH_DELTA: 0,
			PlayerStatusKeysScript.KEY_MOOD_DELTA: [3, 7],
			PlayerStatusKeysScript.KEY_FATIGUE_DELTA: 0
		}
	}


static func is_due(day: Dictionary, event_history: Array) -> bool:
	if not bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
		return false
	var date := String(day.get(DayEventKeysScript.KEY_DATE, ""))
	if _day_of_month(date) < PAYDAY_DAY:
		return false
	return not _history_has_event_id(event_history, event_id_for_date(date))


static func event_id_for_date(date: String) -> String:
	var parts := _date_parts(date)
	if parts.is_empty():
		return ""
	return "%s_%04d_%02d" % [EVENT_ID_PREFIX, int(parts[0]), int(parts[1])]


static func salary_amount_for_date(date: String, difficulty: String = GameDifficultyScript.DEFAULT) -> int:
	var month_key := _month_key(date)
	if month_key.is_empty():
		return roundi(MIN_SALARY * GameDifficultyScript.salary_multiplier(difficulty))
	var slots := int((MAX_SALARY - MIN_SALARY) / SALARY_STEP) + 1
	var base_amount := MIN_SALARY + (_stable_hash(month_key) % slots) * SALARY_STEP
	return roundi(base_amount * GameDifficultyScript.salary_multiplier(difficulty))


static func _history_has_event_id(event_history: Array, event_id: String) -> bool:
	if event_id.is_empty():
		return false
	for history_item in event_history:
		if typeof(history_item) != TYPE_DICTIONARY:
			continue
		if String(Dictionary(history_item).get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false


static func _date_parts(date: String) -> Array[int]:
	var chunks := date.split("-")
	if chunks.size() != 3:
		return []
	return [int(chunks[0]), int(chunks[1]), int(chunks[2])]


static func _day_of_month(date: String) -> int:
	var parts := _date_parts(date)
	if parts.is_empty():
		return 0
	return int(parts[2])


static func _month_key(date: String) -> String:
	var parts := _date_parts(date)
	if parts.is_empty():
		return ""
	return "%04d-%02d" % [int(parts[0]), int(parts[1])]


static func _stable_hash(text: String) -> int:
	var state := 0
	for byte in text.to_utf8_buffer():
		state = int((state * 131 + int(byte)) % 1000003)
	return state


static func _format_won(amount: int) -> String:
	var text := str(amount)
	var formatted := ""
	var count := 0
	for index in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			formatted = "," + formatted
		formatted = text.substr(index, 1) + formatted
		count += 1
	return formatted
