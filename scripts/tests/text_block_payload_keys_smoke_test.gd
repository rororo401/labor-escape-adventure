extends "res://scripts/tests/test_scene_tree.gd"

const TextBlockPayloadKeysScript := preload("res://scripts/core/text_block_payload_keys.gd")


func _initialize() -> void:
	_expect(TextBlockPayloadKeysScript.KEY_TITLE == "title", "text-block title key should stay stable")
	_expect(TextBlockPayloadKeysScript.KEY_BODY == "body", "text-block body key should stay stable")

	print("Text block payload keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
