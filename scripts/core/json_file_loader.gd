class_name JsonFileLoader
extends RefCounted

const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const KEY_OK := ResultKeysScript.KEY_OK
const KEY_DATA := ResultKeysScript.KEY_DATA
const KEY_ERROR := ResultKeysScript.KEY_ERROR
const KEY_PATH := ResultKeysScript.KEY_PATH

const ERROR_FILE_MISSING := "file_missing"
const ERROR_FILE_EMPTY := "file_empty"
const ERROR_INVALID_JSON := "invalid_json"
const ERROR_NOT_DICTIONARY := "not_dictionary"


static func read_dictionary(path: String, label: String = "JSON", report_errors: bool = true) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return _error(ERROR_FILE_MISSING, path, label, report_errors)

	var text := FileAccess.get_file_as_string(path)
	if text.strip_edges().is_empty():
		return _error(ERROR_FILE_EMPTY, path, label, report_errors)

	var json := JSON.new()
	if json.parse(text) != OK:
		return _error(ERROR_INVALID_JSON, path, label, report_errors)

	if typeof(json.data) != TYPE_DICTIONARY:
		return _error(ERROR_NOT_DICTIONARY, path, label, report_errors)

	return {
		KEY_OK: true,
		KEY_DATA: Dictionary(json.data),
		KEY_ERROR: "",
		KEY_PATH: path
	}


static func _error(error: String, path: String, label: String, report_errors: bool) -> Dictionary:
	if report_errors:
		push_error("Could not load %s dictionary (%s): %s" % [label, error, path])
	return {
		KEY_OK: false,
		KEY_DATA: {},
		KEY_ERROR: error,
		KEY_PATH: path
	}
