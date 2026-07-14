class_name DayEventRecencyIndex
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")

const KEY_EVENT_DAYS := "event_days"
const KEY_CG_DAYS := "cg_days"
const KEY_FAMILY_DAYS := "family_days"
const KEY_TAG_DAYS := "tag_days"
const MISSING_DAY := -999999


static func build(event_history: Array, completed_days: int) -> Dictionary:
	var index := empty()
	for history_item in event_history:
		if typeof(history_item) != TYPE_DICTIONARY:
			continue
		var row := Dictionary(history_item)
		if not bool(row.get(DayEventKeysScript.KEY_SELECTED, true)):
			continue
		var completed_day := int(row.get(DayEventKeysScript.KEY_COMPLETED_DAY, MISSING_DAY))
		if completed_day < 0 or completed_day > completed_days:
			continue
		add_event(index, row, completed_day)
	return index


static func empty() -> Dictionary:
	return {
		KEY_EVENT_DAYS: {},
		KEY_CG_DAYS: {},
		KEY_FAMILY_DAYS: {},
		KEY_TAG_DAYS: {}
	}


static func add_event(index: Dictionary, event: Dictionary, completed_day: int) -> void:
	if completed_day < 0:
		return
	_set_latest(Dictionary(index.get(KEY_EVENT_DAYS, {})), String(event.get(DayEventKeysScript.KEY_ID, "")), completed_day)
	_set_latest(Dictionary(index.get(KEY_CG_DAYS, {})), String(event.get(DayEventKeysScript.KEY_CG_PATH, "")), completed_day)
	_set_latest(Dictionary(index.get(KEY_FAMILY_DAYS, {})), numeric_suffix_family(String(event.get(DayEventKeysScript.KEY_ID, ""))), completed_day)
	var tag_days := Dictionary(index.get(KEY_TAG_DAYS, {}))
	for tag in event.get(DayEventKeysScript.KEY_TAGS, []):
		_set_latest(tag_days, String(tag), completed_day)


static func last_event_day(index: Dictionary, event_id: String) -> int:
	return int(Dictionary(index.get(KEY_EVENT_DAYS, {})).get(event_id, MISSING_DAY))


static func last_cg_day(index: Dictionary, cg_path: String) -> int:
	return int(Dictionary(index.get(KEY_CG_DAYS, {})).get(cg_path, MISSING_DAY))


static func last_family_day(index: Dictionary, family_id: String) -> int:
	return int(Dictionary(index.get(KEY_FAMILY_DAYS, {})).get(family_id, MISSING_DAY))


static func last_tag_day(index: Dictionary, tag: String) -> int:
	return int(Dictionary(index.get(KEY_TAG_DAYS, {})).get(tag, MISSING_DAY))


static func numeric_suffix_family(event_id: String) -> String:
	var index := event_id.length() - 1
	while index >= 0:
		var code := event_id.unicode_at(index)
		if code < 48 or code > 57:
			break
		index -= 1
	if index < 0 or index == event_id.length() - 1:
		return ""
	var separator := event_id.substr(index, 1)
	if separator != "_" and separator != "-":
		return ""
	return event_id.substr(0, index)


static func _set_latest(days: Dictionary, key: String, completed_day: int) -> void:
	if key.is_empty():
		return
	days[key] = maxi(int(days.get(key, MISSING_DAY)), completed_day)
