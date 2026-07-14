class_name EventCgGalleryStore
extends RefCounted

const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")

const DEFAULT_PATH := "user://event_cg_gallery.json"
const SAVE_VERSION := 1

const KEY_VERSION := "version"
const KEY_ENTRIES := "entries"
const KEY_CG_PATH := DayEventKeysScript.KEY_CG_PATH
const KEY_EVENT_ID := DayEventKeysScript.KEY_ID
const KEY_NAME_KO := DayEventKeysScript.KEY_NAME_KO
const KEY_GROUP := DayEventKeysScript.KEY_GROUP
const KEY_MODE := DayEventKeysScript.KEY_MODE
const KEY_TAGS := DayEventKeysScript.KEY_TAGS
const KEY_FIRST_SEEN_DATE := "first_seen_date"
const KEY_LAST_SEEN_DATE := "last_seen_date"
const KEY_SEEN_COUNT := "seen_count"
const KEY_UNLOCK_INDEX := "unlock_index"
const KEY_OK := DayEventKeysScript.KEY_OK
const KEY_ERROR := "error"
const ERROR_WRITE_FAILED := "gallery_write_failed"

var save_path := DEFAULT_PATH


func unlock_event_cg(event: Dictionary, resolved_cg_path: String, date: String = "") -> Dictionary:
	if resolved_cg_path.is_empty() or not _path_exists(resolved_cg_path):
		return {KEY_OK: false, KEY_ERROR: "missing_cg_path"}

	var payload := _load_payload()
	var entries: Array = payload.get(KEY_ENTRIES, [])
	_upsert_entry(entries, event, resolved_cg_path, date, true)

	payload[KEY_ENTRIES] = entries
	return _save_payload(payload)


func unlock_event_history(event_history: Array) -> Dictionary:
	var payload := _load_payload()
	var entries: Array = payload.get(KEY_ENTRIES, [])
	for event in event_history:
		var event_row := Dictionary(event)
		var cg_path := String(event_row.get(KEY_CG_PATH, ""))
		if cg_path.is_empty() or not _path_exists(cg_path):
			continue
		_upsert_entry(entries, event_row, cg_path, "", false)
	payload[KEY_ENTRIES] = entries
	return _save_payload(payload)


func get_unlocked_entries() -> Array[Dictionary]:
	var entries: Array = _load_payload().get(KEY_ENTRIES, [])
	var normalized: Array[Dictionary] = []
	for entry in entries:
		var row := Dictionary(entry)
		if not String(row.get(KEY_CG_PATH, "")).is_empty():
			normalized.append(row)
	normalized.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get(KEY_UNLOCK_INDEX, 0)) < int(b.get(KEY_UNLOCK_INDEX, 0))
	)
	return normalized


func has_unlocked(cg_path: String) -> bool:
	return _find_entry_index(_load_payload().get(KEY_ENTRIES, []), cg_path) >= 0


func clear(path: String = "") -> Dictionary:
	var target_path := save_path if path.is_empty() else path
	var file := FileAccess.open(target_path, FileAccess.WRITE)
	if file == null:
		return {KEY_OK: false, KEY_ERROR: ERROR_WRITE_FAILED}
	file.store_string(JSON.stringify({KEY_VERSION: SAVE_VERSION, KEY_ENTRIES: []}, "\t"))
	file.close()
	return {KEY_OK: true}


func _load_payload() -> Dictionary:
	var loaded := JsonFileLoaderScript.read_dictionary(save_path, "event CG gallery JSON", false)
	if not bool(loaded.get(KEY_OK, false)):
		return {KEY_VERSION: SAVE_VERSION, KEY_ENTRIES: []}
	var payload := Dictionary(loaded.get("data", {})).duplicate(true)
	if not payload.has(KEY_ENTRIES):
		payload[KEY_ENTRIES] = []
	return payload


func _save_payload(payload: Dictionary) -> Dictionary:
	payload[KEY_VERSION] = SAVE_VERSION
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return {KEY_OK: false, KEY_ERROR: ERROR_WRITE_FAILED}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return {KEY_OK: true}


func _entry_from_event(event: Dictionary, resolved_cg_path: String, date: String, unlock_index: int) -> Dictionary:
	return {
		KEY_CG_PATH: resolved_cg_path,
		KEY_EVENT_ID: String(event.get(DayEventKeysScript.KEY_ID, "")),
		KEY_NAME_KO: String(event.get(DayEventKeysScript.KEY_NAME_KO, "")),
		KEY_GROUP: String(event.get(DayEventKeysScript.KEY_GROUP, "")),
		KEY_MODE: String(event.get(DayEventKeysScript.KEY_MODE, "")),
		KEY_TAGS: event.get(DayEventKeysScript.KEY_TAGS, []).duplicate(true),
		KEY_FIRST_SEEN_DATE: date,
		KEY_LAST_SEEN_DATE: date,
		KEY_SEEN_COUNT: 1,
		KEY_UNLOCK_INDEX: unlock_index
	}


func _upsert_entry(entries: Array, event: Dictionary, resolved_cg_path: String, date: String, increment_seen_count: bool) -> void:
	var existing_index := _find_entry_index(entries, resolved_cg_path)
	if existing_index >= 0:
		var existing := Dictionary(entries[existing_index]).duplicate(true)
		if not date.is_empty():
			existing[KEY_LAST_SEEN_DATE] = date
		if increment_seen_count:
			existing[KEY_SEEN_COUNT] = int(existing.get(KEY_SEEN_COUNT, 1)) + 1
		entries[existing_index] = existing
		return
	entries.append(_entry_from_event(event, resolved_cg_path, date, _next_unlock_index(entries)))


func _find_entry_index(entries: Array, cg_path: String) -> int:
	for index in range(entries.size()):
		if String(Dictionary(entries[index]).get(KEY_CG_PATH, "")) == cg_path:
			return index
	return -1


func _next_unlock_index(entries: Array) -> int:
	var max_index := -1
	for entry in entries:
		max_index = maxi(max_index, int(Dictionary(entry).get(KEY_UNLOCK_INDEX, -1)))
	return max_index + 1


func _path_exists(path: String) -> bool:
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)
