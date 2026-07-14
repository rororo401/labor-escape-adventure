extends "res://scripts/tests/test_scene_tree.gd"

const ProfileFormTextStateConfigScript := preload("res://scripts/ui/profile_form_text_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(ProfileFormTextStateConfigScript.KEY_TEXT == UiPayloadKeysScript.KEY_TEXT, "header text key should use the shared UI payload key")
	_expect(ProfileFormTextStateConfigScript.KEY_FONT_SIZE == "font_size", "header font-size key should stay stable")
	_expect(ProfileFormTextStateConfigScript.KEY_COLOR == "color", "header color key should stay stable")
	_expect(ProfileFormTextStateConfigScript.KEY_ALIGNMENT == "alignment", "header alignment key should stay stable")
	_expect(ProfileFormTextStateConfigScript.KEY_OUTLINE == "outline", "header outline key should stay stable")
	_expect(ProfileFormTextStateConfigScript.EMPTY_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "empty text fallback should use the shared UI payload default")
	_expect(ProfileFormTextStateConfigScript.DEFAULT_FONT_SIZE == 20, "default font-size fallback should stay stable")
	_expect(ProfileFormTextStateConfigScript.DEFAULT_ALIGNMENT == HORIZONTAL_ALIGNMENT_LEFT, "default alignment fallback should stay stable")
	_expect(not ProfileFormTextStateConfigScript.DEFAULT_OUTLINE, "default outline fallback should stay false")

	print("Profile form text state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
