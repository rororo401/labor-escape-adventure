extends "res://scripts/tests/test_scene_tree.gd"

const LocalizedPayloadKeysScript := preload("res://scripts/core/localized_payload_keys.gd")


func _initialize() -> void:
	_expect(LocalizedPayloadKeysScript.KEY_NAME_KO == "name_ko", "Korean name key should stay stable")
	_expect(LocalizedPayloadKeysScript.KEY_DISPLAY_NAME_KO == "display_name_ko", "Korean display-name key should stay stable")
	_expect(LocalizedPayloadKeysScript.KEY_SUMMARY_KO == "summary_ko", "Korean summary key should stay stable")

	print("Localized payload keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
