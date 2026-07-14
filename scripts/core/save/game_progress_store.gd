class_name GameProgressStore
extends RefCounted

const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")
const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const GameStatePersistenceScript := preload("res://scripts/core/save/game_state_persistence.gd")

const DEFAULT_PATH := "user://game_progress.json"
const TEMP_SUFFIX := ".tmp"
const BACKUP_SUFFIX := ".bak"
const REPLACEMENT_SUFFIX := ".replace_old"
const ERROR_FILE_MISSING := GameSaveKeysScript.ERROR_PROGRESS_FILE_MISSING
const ERROR_INVALID_JSON := GameSaveKeysScript.ERROR_PROGRESS_INVALID_JSON
const ERROR_WRITE_FAILED := GameSaveKeysScript.ERROR_PROGRESS_WRITE_FAILED

var save_path := DEFAULT_PATH


func is_enabled() -> bool:
	return true


func has_saved_progress(path: String = "") -> bool:
	var target_path := _resolve_path(path)
	return FileAccess.file_exists(target_path) or FileAccess.file_exists(_backup_path(target_path))


func save_game(game, path: String = "", metadata: Dictionary = {}) -> Dictionary:
	return save_payload(game.to_save_dict(), path, metadata)


func save_payload(payload: Dictionary, path: String = "", metadata: Dictionary = {}) -> Dictionary:
	var target_path := _resolve_path(path)
	var save_data := GameStatePersistenceScript.normalize_save_dict(payload)
	for key in metadata:
		save_data[key] = metadata.get(key)
	var validation := GameStatePersistenceScript.validate_save_dict(save_data)
	if not bool(validation.get(GameSaveKeysScript.KEY_OK, false)):
		return _write_error(target_path)

	var text := JSON.stringify(save_data, "\t")
	var temp_path := target_path + TEMP_SUFFIX
	if not _write_verified_temp(temp_path, text):
		_remove_if_present(temp_path)
		return _write_error(target_path)

	if FileAccess.file_exists(target_path) and not _prepare_backup(target_path):
		_remove_if_present(temp_path)
		return _write_error(target_path)
	if not _install_temp(temp_path, target_path):
		_remove_if_present(temp_path)
		return _write_error(target_path)
	if not _verify_text_file(target_path, text):
		_restore_backup(target_path)
		return _write_error(target_path)

	return {
		GameSaveKeysScript.KEY_OK: true,
		GameSaveKeysScript.KEY_PATH: target_path,
		GameSaveKeysScript.KEY_DATE: save_data.get(GameSaveKeysScript.KEY_CURRENT_DATE, ""),
		GameSaveKeysScript.KEY_DATA: save_data
	}


func load_game(game, path: String = "") -> Dictionary:
	var loaded := read_payload(path)
	if not bool(loaded.get(GameSaveKeysScript.KEY_OK, false)):
		return loaded
	var result: Dictionary = game.load_from_save_dict(Dictionary(loaded.get(GameSaveKeysScript.KEY_DATA, {})))
	result[GameSaveKeysScript.KEY_PATH] = loaded.get(GameSaveKeysScript.KEY_PATH, _resolve_path(path))
	return result


func read_payload(path: String = "") -> Dictionary:
	var target_path := _resolve_path(path)
	var primary_result := _read_payload_from_path(target_path)
	if bool(primary_result.get(GameSaveKeysScript.KEY_OK, false)):
		return primary_result
	if not _should_try_backup(String(primary_result.get(GameSaveKeysScript.KEY_ERROR, ""))):
		return primary_result

	var backup_path := _backup_path(target_path)
	if FileAccess.file_exists(backup_path):
		var backup_result := _read_payload_from_path(backup_path)
		if bool(backup_result.get(GameSaveKeysScript.KEY_OK, false)):
			return backup_result
		if String(primary_result.get(GameSaveKeysScript.KEY_ERROR, "")) == ERROR_FILE_MISSING:
			return backup_result
	return primary_result


func _should_try_backup(error: String) -> bool:
	return error in [
		ERROR_FILE_MISSING,
		ERROR_INVALID_JSON,
		GameSaveKeysScript.ERROR_SAVE_DATA_INVALID,
		GameSaveKeysScript.ERROR_SAVE_VERSION_UNSUPPORTED
	]


func _read_payload_from_path(target_path: String) -> Dictionary:
	var loaded := JsonFileLoaderScript.read_dictionary(target_path, "game progress JSON", false)
	if String(loaded.get(GameSaveKeysScript.KEY_ERROR, "")) == JsonFileLoaderScript.ERROR_FILE_MISSING:
		return {
			GameSaveKeysScript.KEY_OK: false,
			GameSaveKeysScript.KEY_ERROR: ERROR_FILE_MISSING,
			GameSaveKeysScript.KEY_PATH: target_path
		}
	if not bool(loaded.get(GameSaveKeysScript.KEY_OK, false)):
		return {
			GameSaveKeysScript.KEY_OK: false,
			GameSaveKeysScript.KEY_ERROR: ERROR_INVALID_JSON,
			GameSaveKeysScript.KEY_PATH: target_path
		}

	var payload := GameStatePersistenceScript.normalize_save_dict(Dictionary(loaded.get(GameSaveKeysScript.KEY_DATA, {})))
	var validation := GameStatePersistenceScript.validate_save_dict(payload)
	if not bool(validation.get(GameSaveKeysScript.KEY_OK, false)):
		validation[GameSaveKeysScript.KEY_PATH] = target_path
		return validation
	return {
		GameSaveKeysScript.KEY_OK: true,
		GameSaveKeysScript.KEY_PATH: target_path,
		GameSaveKeysScript.KEY_DATA: payload,
		GameSaveKeysScript.KEY_DATE: payload.get(GameSaveKeysScript.KEY_CURRENT_DATE, "")
	}


func _write_verified_temp(temp_path: String, text: String) -> bool:
	if not _remove_if_present(temp_path):
		return false
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return false
	return _verify_text_file(temp_path, text)


func _verify_text_file(path: String, expected_text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var actual_text := file.get_as_text()
	file.close()
	if actual_text != expected_text:
		return false
	return typeof(JSON.parse_string(actual_text)) == TYPE_DICTIONARY


func _prepare_backup(target_path: String) -> bool:
	if not _is_valid_save_file(target_path):
		return true
	var target_file := FileAccess.open(target_path, FileAccess.READ)
	if target_file == null:
		return false
	var target_text := target_file.get_as_text()
	target_file.close()

	var backup_path := _backup_path(target_path)
	var backup_temp_path := backup_path + TEMP_SUFFIX
	if not _remove_if_present(backup_temp_path):
		return false
	if DirAccess.copy_absolute(_absolute_path(target_path), _absolute_path(backup_temp_path)) != OK:
		return false
	if not _verify_text_file(backup_temp_path, target_text):
		_remove_if_present(backup_temp_path)
		return false
	if not _install_temp(backup_temp_path, backup_path):
		_remove_if_present(backup_temp_path)
		return false
	return true


func _is_valid_save_file(path: String) -> bool:
	return bool(_read_payload_from_path(path).get(GameSaveKeysScript.KEY_OK, false))


func _install_temp(temp_path: String, target_path: String) -> bool:
	var temp_absolute := _absolute_path(temp_path)
	var target_absolute := _absolute_path(target_path)
	if DirAccess.rename_absolute(temp_absolute, target_absolute) == OK:
		return true
	if not FileAccess.file_exists(target_path):
		return false

	var replacement_path := target_path + REPLACEMENT_SUFFIX
	if not _remove_if_present(replacement_path):
		return false
	if DirAccess.rename_absolute(target_absolute, _absolute_path(replacement_path)) != OK:
		return false
	if DirAccess.rename_absolute(temp_absolute, target_absolute) == OK:
		_remove_if_present(replacement_path)
		return true
	DirAccess.rename_absolute(_absolute_path(replacement_path), target_absolute)
	return false


func _restore_backup(target_path: String) -> void:
	var backup_path := _backup_path(target_path)
	if not FileAccess.file_exists(backup_path):
		return
	_remove_if_present(target_path)
	DirAccess.copy_absolute(_absolute_path(backup_path), _absolute_path(target_path))


func _remove_if_present(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	return DirAccess.remove_absolute(_absolute_path(path)) == OK


func _absolute_path(path: String) -> String:
	return ProjectSettings.globalize_path(path)


func _backup_path(target_path: String) -> String:
	return target_path + BACKUP_SUFFIX


func _write_error(target_path: String) -> Dictionary:
	return {
		GameSaveKeysScript.KEY_OK: false,
		GameSaveKeysScript.KEY_ERROR: ERROR_WRITE_FAILED,
		GameSaveKeysScript.KEY_PATH: target_path
	}


func _resolve_path(path: String) -> String:
	return save_path if path.is_empty() else path
