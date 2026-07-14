extends "res://scripts/tests/test_scene_tree.gd"

const DisplayPayloadKeysScript := preload("res://scripts/core/display_payload_keys.gd")


func _initialize() -> void:
	_expect(DisplayPayloadKeysScript.KEY_DATE_TEXT == "date_text", "date text payload key should stay stable")

	print("Display payload keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
