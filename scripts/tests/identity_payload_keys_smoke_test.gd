extends "res://scripts/tests/test_scene_tree.gd"

const IdentityPayloadKeysScript := preload("res://scripts/core/identity_payload_keys.gd")


func _initialize() -> void:
	_expect(IdentityPayloadKeysScript.KEY_ID == "id", "identity id key should stay stable")

	print("Identity payload keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
