class_name GameSaveSlotStore
extends RefCounted

const GameProgressStoreScript := preload("res://scripts/core/save/game_progress_store.gd")
const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")

const DEFAULT_BASE_DIR := "user://saves"
const SLOT_KIND_MANUAL := "manual"
const SLOT_KIND_AUTO := "auto"
const MANUAL_SLOT_COUNT := 3
const AUTO_SLOT_COUNT := 3

const KEY_KIND := "kind"
const KEY_INDEX := "index"
const KEY_OCCUPIED := "occupied"
const KEY_VALID := "valid"
const KEY_CURRENT_DATE := GameSaveKeysScript.KEY_CURRENT_DATE
const KEY_COMPLETED_DAYS := GameSaveKeysScript.KEY_COMPLETED_DAYS
const KEY_SAVED_AT_UNIX := GameSaveKeysScript.KEY_SAVED_AT_UNIX
const KEY_NET_WORTH := PlayerStatusKeysScript.KEY_NET_WORTH
const KEY_DIFFICULTY := GameSaveKeysScript.KEY_DIFFICULTY
const KEY_PATH := GameSaveKeysScript.KEY_PATH
const KEY_ERROR := GameSaveKeysScript.KEY_ERROR

var base_dir := DEFAULT_BASE_DIR
var progress_store = GameProgressStoreScript.new()


func save_manual(game, slot_index: int) -> Dictionary:
	if not _valid_slot(SLOT_KIND_MANUAL, slot_index) or not _ensure_base_dir():
		return _slot_error("invalid_manual_slot", SLOT_KIND_MANUAL, slot_index)
	return progress_store.save_game(
		game,
		slot_path(SLOT_KIND_MANUAL, slot_index),
		_slot_metadata(SLOT_KIND_MANUAL, slot_index, Time.get_unix_time_from_system())
	)


func save_auto(game) -> Dictionary:
	if not _ensure_base_dir():
		return _slot_error("save_directory_failed", SLOT_KIND_AUTO, 1)
	_rotate_auto_slots()
	return progress_store.save_game(
		game,
		slot_path(SLOT_KIND_AUTO, 1),
		_slot_metadata(SLOT_KIND_AUTO, 1, Time.get_unix_time_from_system())
	)


func load_slot(game, kind: String, slot_index: int) -> Dictionary:
	if not _valid_slot(kind, slot_index):
		return _slot_error("invalid_save_slot", kind, slot_index)
	var result := progress_store.load_game(game, slot_path(kind, slot_index))
	result[KEY_KIND] = kind
	result[KEY_INDEX] = slot_index
	return result


func load_latest(game) -> Dictionary:
	var candidates := valid_slot_summaries()
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get(KEY_SAVED_AT_UNIX, 0.0)) > float(b.get(KEY_SAVED_AT_UNIX, 0.0))
	)
	for summary in candidates:
		var result := load_slot(game, String(summary.get(KEY_KIND, "")), int(summary.get(KEY_INDEX, 0)))
		if bool(result.get(GameSaveKeysScript.KEY_OK, false)):
			return result
	return _slot_error(GameSaveKeysScript.ERROR_PROGRESS_FILE_MISSING, "", 0)


func has_saved_progress() -> bool:
	return not valid_slot_summaries().is_empty()


func migrate_legacy_save(legacy_path: String = GameProgressStoreScript.DEFAULT_PATH) -> Dictionary:
	if has_any_slot_file():
		return {GameSaveKeysScript.KEY_OK: true, "migrated": false}
	var legacy_store = GameProgressStoreScript.new()
	legacy_store.save_path = legacy_path
	if not legacy_store.has_saved_progress():
		return _slot_error(GameSaveKeysScript.ERROR_PROGRESS_FILE_MISSING, SLOT_KIND_MANUAL, 1)
	var legacy_game := GameStateScript.new()
	var loaded := legacy_store.load_game(legacy_game)
	if not bool(loaded.get(GameSaveKeysScript.KEY_OK, false)):
		return loaded
	var saved := save_manual(legacy_game, 1)
	saved["migrated"] = bool(saved.get(GameSaveKeysScript.KEY_OK, false))
	return saved


func has_any_slot_file() -> bool:
	for kind in [SLOT_KIND_MANUAL, SLOT_KIND_AUTO]:
		for slot_index in range(1, _slot_count(kind) + 1):
			var path := slot_path(kind, slot_index)
			if FileAccess.file_exists(path) or FileAccess.file_exists(path + GameProgressStoreScript.BACKUP_SUFFIX):
				return true
	return false


func slot_summaries() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	for kind in [SLOT_KIND_MANUAL, SLOT_KIND_AUTO]:
		for slot_index in range(1, _slot_count(kind) + 1):
			summaries.append(slot_summary(kind, slot_index))
	return summaries


func valid_slot_summaries() -> Array[Dictionary]:
	var valid: Array[Dictionary] = []
	for summary in slot_summaries():
		if bool(summary.get(KEY_VALID, false)):
			valid.append(summary)
	return valid


func slot_summary(kind: String, slot_index: int) -> Dictionary:
	var path := slot_path(kind, slot_index)
	var occupied := FileAccess.file_exists(path) or FileAccess.file_exists(path + GameProgressStoreScript.BACKUP_SUFFIX)
	var summary := {
		KEY_KIND: kind,
		KEY_INDEX: slot_index,
		KEY_OCCUPIED: occupied,
		KEY_VALID: false,
		KEY_PATH: path,
		KEY_SAVED_AT_UNIX: 0.0,
		KEY_CURRENT_DATE: "",
		KEY_COMPLETED_DAYS: 0,
		KEY_NET_WORTH: 0,
		KEY_DIFFICULTY: GameSaveKeysScript.DIFFICULTY_HARD
	}
	if not occupied:
		return summary
	var loaded := progress_store.read_payload(path)
	if not bool(loaded.get(GameSaveKeysScript.KEY_OK, false)):
		summary[KEY_ERROR] = String(loaded.get(GameSaveKeysScript.KEY_ERROR, ""))
		return summary
	var payload: Dictionary = loaded.get(GameSaveKeysScript.KEY_DATA, {})
	var status: Dictionary = payload.get(GameSaveKeysScript.KEY_STATUS, {})
	summary[KEY_VALID] = true
	summary[KEY_CURRENT_DATE] = String(payload.get(GameSaveKeysScript.KEY_CURRENT_DATE, ""))
	summary[KEY_COMPLETED_DAYS] = int(payload.get(GameSaveKeysScript.KEY_COMPLETED_DAYS, 0))
	summary[KEY_SAVED_AT_UNIX] = float(payload.get(GameSaveKeysScript.KEY_SAVED_AT_UNIX, 0.0))
	summary[KEY_NET_WORTH] = int(status.get(PlayerStatusKeysScript.KEY_NET_WORTH, 0))
	summary[KEY_DIFFICULTY] = String(payload.get(GameSaveKeysScript.KEY_DIFFICULTY, GameSaveKeysScript.DIFFICULTY_HARD))
	return summary


func slot_path(kind: String, slot_index: int) -> String:
	return "%s/%s_%d.json" % [base_dir.trim_suffix("/"), kind, slot_index]


func _rotate_auto_slots() -> void:
	for source_index in range(AUTO_SLOT_COUNT - 1, 0, -1):
		var source_path := slot_path(SLOT_KIND_AUTO, source_index)
		var loaded := progress_store.read_payload(source_path)
		if not bool(loaded.get(GameSaveKeysScript.KEY_OK, false)):
			continue
		var payload: Dictionary = loaded.get(GameSaveKeysScript.KEY_DATA, {})
		var saved_at := float(payload.get(GameSaveKeysScript.KEY_SAVED_AT_UNIX, 0.0))
		progress_store.save_payload(
			payload,
			slot_path(SLOT_KIND_AUTO, source_index + 1),
			_slot_metadata(SLOT_KIND_AUTO, source_index + 1, saved_at)
		)


func _slot_metadata(kind: String, slot_index: int, saved_at_unix: float) -> Dictionary:
	return {
		GameSaveKeysScript.KEY_SLOT_KIND: kind,
		GameSaveKeysScript.KEY_SLOT_INDEX: slot_index,
		GameSaveKeysScript.KEY_SAVED_AT_UNIX: saved_at_unix
	}


func _slot_count(kind: String) -> int:
	return MANUAL_SLOT_COUNT if kind == SLOT_KIND_MANUAL else AUTO_SLOT_COUNT if kind == SLOT_KIND_AUTO else 0


func _valid_slot(kind: String, slot_index: int) -> bool:
	return slot_index >= 1 and slot_index <= _slot_count(kind)


func _ensure_base_dir() -> bool:
	var absolute := ProjectSettings.globalize_path(base_dir)
	if DirAccess.dir_exists_absolute(absolute):
		return true
	return DirAccess.make_dir_recursive_absolute(absolute) == OK


func _slot_error(error: String, kind: String, slot_index: int) -> Dictionary:
	return {
		GameSaveKeysScript.KEY_OK: false,
		GameSaveKeysScript.KEY_ERROR: error,
		KEY_KIND: kind,
		KEY_INDEX: slot_index
	}
