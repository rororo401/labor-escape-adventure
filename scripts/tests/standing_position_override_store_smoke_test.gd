extends "res://scripts/tests/test_scene_tree.gd"

const StandingPositionOverrideStoreScript := preload("res://scripts/core/standing_position_override_store.gd")

const TEST_USER_PATH := "user://standing_position_override_store.user.test.json"
const TEST_DEFAULT_PATH := "user://standing_position_override_store.default.test.json"


func _initialize() -> void:
	_remove_test_file(TEST_USER_PATH)
	_remove_test_file(TEST_DEFAULT_PATH)

	_verify_save_payload_and_roundtrip()
	_verify_load_priority_and_missing_files()

	_remove_test_file(TEST_USER_PATH)
	_remove_test_file(TEST_DEFAULT_PATH)

	print("Standing position override store smoke test passed.")
	finish_test()


func _verify_save_payload_and_roundtrip() -> void:
	var store = StandingPositionOverrideStoreScript.new(TEST_USER_PATH, TEST_DEFAULT_PATH)
	var offsets := {
		"homewear:smile": {
			"x": 3,
			"y": -2
		}
	}

	_expect(store.save_offsets(offsets), "save should report user override write success")
	_expect(FileAccess.file_exists(TEST_USER_PATH), "save should write user override file")
	_expect(FileAccess.file_exists(TEST_DEFAULT_PATH), "save should write generated default override file")

	var user_payload = JSON.parse_string(FileAccess.get_file_as_string(TEST_USER_PATH))
	_expect(typeof(user_payload) == TYPE_DICTIONARY, "saved user override should be JSON")
	_expect(int(user_payload.get("version", 0)) == 1, "saved payload should include version")
	_expect(String(user_payload.get("note", "")).contains("StandingPositionCalibrator"), "saved payload should include note")
	_expect(int(user_payload.get("offsets", {}).get("homewear:smile", {}).get("x", 0)) == 3, "saved payload should keep x offset")

	offsets["homewear:smile"]["x"] = 99
	var reread := StandingPositionOverrideStoreScript.read_offsets(TEST_USER_PATH)
	_expect(int(reread.get("homewear:smile", {}).get("x", 0)) == 3, "saved payload should not be affected by later source mutation")


func _verify_load_priority_and_missing_files() -> void:
	var store = StandingPositionOverrideStoreScript.new(TEST_USER_PATH, TEST_DEFAULT_PATH)
	var loaded := store.load_offsets()
	_expect(String(loaded.get("loaded_path", "")) == TEST_USER_PATH, "user override should load before default override")
	_expect(int(loaded.get("offsets", {}).get("homewear:smile", {}).get("y", 0)) == -2, "load should include saved user offset")

	_remove_test_file(TEST_USER_PATH)
	loaded = store.load_offsets()
	_expect(String(loaded.get("loaded_path", "")) == TEST_DEFAULT_PATH, "default override should load when user override is missing")

	_remove_test_file(TEST_DEFAULT_PATH)
	loaded = store.load_offsets()
	_expect(String(loaded.get("loaded_path", "")) == "", "missing override files should report empty loaded path")
	_expect(Dictionary(loaded.get("offsets", {"bad": true})).is_empty(), "missing override files should return empty offsets")

	StandingPositionOverrideStoreScript.write_text(TEST_DEFAULT_PATH, "not json")
	loaded = store.load_offsets()
	_expect(String(loaded.get("loaded_path", "")) == TEST_DEFAULT_PATH, "invalid JSON file should still report attempted loaded path")
	_expect(Dictionary(loaded.get("offsets", {"bad": true})).is_empty(), "invalid JSON file should return empty offsets")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _remove_test_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
