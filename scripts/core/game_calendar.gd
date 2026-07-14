class_name GameCalendar
extends RefCounted

const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")

const CSV_COLUMN_DATE := 0
const CSV_COLUMN_WEEKDAY := 1
const CSV_COLUMN_IS_TRADING_DAY := 2
const CSV_COLUMN_REASON := 3
const CSV_COLUMN_NAME := 4
const CSV_MIN_COLUMNS := 5

const CSV_TRUE := "true"
const DEFAULT_DATE := ""

var days: Array[Dictionary] = []


func load_from_csv(path: String) -> void:
	days.clear()

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open calendar CSV: %s" % path)
		return

	var header := file.get_csv_line()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() < CSV_MIN_COLUMNS or String(row[CSV_COLUMN_DATE]).is_empty():
			continue

		days.append({
			GameStateContextKeysScript.KEY_DATE: String(row[CSV_COLUMN_DATE]),
			GameStateContextKeysScript.KEY_WEEKDAY: String(row[CSV_COLUMN_WEEKDAY]),
			GameStateContextKeysScript.KEY_IS_TRADING_DAY: String(row[CSV_COLUMN_IS_TRADING_DAY]) == CSV_TRUE,
			GameStateContextKeysScript.KEY_REASON: String(row[CSV_COLUMN_REASON]),
			GameStateContextKeysScript.KEY_NAME: String(row[CSV_COLUMN_NAME])
		})


func count() -> int:
	return days.size()


func get_day(index: int) -> Dictionary:
	if index < 0 or index >= days.size():
		return {}
	return days[index]


func find_index_by_date(date: String) -> int:
	for index in days.size():
		if days[index].get(GameStateContextKeysScript.KEY_DATE, DEFAULT_DATE) == date:
			return index
	return -1
