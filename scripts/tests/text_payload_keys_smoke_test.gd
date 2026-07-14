extends "res://scripts/tests/test_scene_tree.gd"

const TextPayloadKeysScript := preload("res://scripts/core/text_payload_keys.gd")


func _initialize() -> void:
	_expect(TextPayloadKeysScript.KEY_TEXT == "text", "text payload key should stay stable")

	print("Text payload keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
