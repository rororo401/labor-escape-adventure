extends "res://scripts/tests/test_scene_tree.gd"

const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_expect(ResultKeysScript.KEY_OK == "ok", "result ok key should stay stable")
	_expect(ResultKeysScript.KEY_ERROR == "error", "result error key should stay stable")
	_expect(ResultKeysScript.KEY_DATA == "data", "result data key should stay stable")
	_expect(ResultKeysScript.KEY_PATH == "path", "result path key should stay stable")
	_expect(ResultKeysScript.KEY_RESULT == "result", "result payload key should stay stable")
	_expect(ResultKeysScript.KEY_STATUS == "status", "result status key should stay stable")

	print("Result keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
