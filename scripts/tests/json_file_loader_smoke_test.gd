extends "res://scripts/tests/test_scene_tree.gd"

const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const TEST_VALID_PATH := "user://json_file_loader.valid.test.json"
const TEST_INVALID_PATH := "user://json_file_loader.invalid.test.json"
const TEST_ARRAY_PATH := "user://json_file_loader.array.test.json"
const TEST_EMPTY_PATH := "user://json_file_loader.empty.test.json"


func _initialize() -> void:
	_remove_test_file(TEST_VALID_PATH)
	_remove_test_file(TEST_INVALID_PATH)
	_remove_test_file(TEST_ARRAY_PATH)
	_remove_test_file(TEST_EMPTY_PATH)

	_verify_valid_dictionary()
	_verify_quiet_failures()

	_remove_test_file(TEST_VALID_PATH)
	_remove_test_file(TEST_INVALID_PATH)
	_remove_test_file(TEST_ARRAY_PATH)
	_remove_test_file(TEST_EMPTY_PATH)

	print("JSON file loader smoke test passed.")
	finish_test()


func _verify_valid_dictionary() -> void:
	_write_text(TEST_VALID_PATH, "{\"name\":\"테스트 사용자\",\"value\":7}")
	var loaded := JsonFileLoaderScript.read_dictionary(TEST_VALID_PATH, "test JSON", false)
	_expect(JsonFileLoaderScript.KEY_OK == ResultKeysScript.KEY_OK, "ok result key should use the shared result key")
	_expect(JsonFileLoaderScript.KEY_DATA == ResultKeysScript.KEY_DATA, "data result key should use the shared result key")
	_expect(JsonFileLoaderScript.KEY_ERROR == ResultKeysScript.KEY_ERROR, "error result key should use the shared result key")
	_expect(JsonFileLoaderScript.KEY_PATH == ResultKeysScript.KEY_PATH, "path result key should use the shared result key")
	_expect(bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)), "valid dictionary JSON should load")
	_expect(Dictionary(loaded.get(JsonFileLoaderScript.KEY_DATA, {})).get("name", "") == "테스트 사용자", "valid JSON should expose data")
	_expect(int(Dictionary(loaded.get(JsonFileLoaderScript.KEY_DATA, {})).get("value", 0)) == 7, "valid JSON should keep numeric data")
	_expect(String(loaded.get(JsonFileLoaderScript.KEY_ERROR, "bad")) == "", "valid JSON should have no error")


func _verify_quiet_failures() -> void:
	var missing := JsonFileLoaderScript.read_dictionary("user://missing_json_file_loader.test.json", "test JSON", false)
	_expect(not bool(missing.get(JsonFileLoaderScript.KEY_OK, true)), "missing JSON should fail")
	_expect(String(missing.get(JsonFileLoaderScript.KEY_ERROR, "")) == JsonFileLoaderScript.ERROR_FILE_MISSING, "missing JSON should expose file_missing")

	_write_text(TEST_EMPTY_PATH, "   ")
	var empty := JsonFileLoaderScript.read_dictionary(TEST_EMPTY_PATH, "test JSON", false)
	_expect(String(empty.get(JsonFileLoaderScript.KEY_ERROR, "")) == JsonFileLoaderScript.ERROR_FILE_EMPTY, "empty JSON should expose file_empty")

	_write_text(TEST_INVALID_PATH, "not json")
	var invalid := JsonFileLoaderScript.read_dictionary(TEST_INVALID_PATH, "test JSON", false)
	_expect(String(invalid.get(JsonFileLoaderScript.KEY_ERROR, "")) == JsonFileLoaderScript.ERROR_INVALID_JSON, "invalid JSON should expose invalid_json")

	_write_text(TEST_ARRAY_PATH, "[1,2,3]")
	var array_payload := JsonFileLoaderScript.read_dictionary(TEST_ARRAY_PATH, "test JSON", false)
	_expect(String(array_payload.get(JsonFileLoaderScript.KEY_ERROR, "")) == JsonFileLoaderScript.ERROR_NOT_DICTIONARY, "array JSON should expose not_dictionary")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write test JSON: %s" % path)
		fail_test()
	file.store_string(text)
	file.close()


func _remove_test_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
