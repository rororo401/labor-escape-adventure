extends "res://scripts/tests/test_scene_tree.gd"

const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const CharacterVisualKeysScript := preload("res://scripts/core/character_visual_keys.gd")
const DisplayPayloadKeysScript := preload("res://scripts/core/display_payload_keys.gd")
const LocalizedPayloadKeysScript := preload("res://scripts/core/localized_payload_keys.gd")
const TextPayloadKeysScript := preload("res://scripts/core/text_payload_keys.gd")


func _initialize() -> void:
	_verify_catalog_keys()
	_verify_step_keys()
	_verify_view_option_keys()
	_verify_event_keys()

	print("VN story keys smoke test passed.")
	finish_test()


func _verify_catalog_keys() -> void:
	_expect(VnStoryKeysScript.KEY_STORIES == "stories", "stories key should stay stable")
	_expect(VnStoryKeysScript.KEY_VISUALS == "visuals", "visuals key should stay stable")
	_expect(VnStoryKeysScript.KEY_DEFAULT_MODE == "default_mode", "default visual mode key should stay stable")
	_expect(VnStoryKeysScript.KEY_MODES == "modes", "visual modes key should stay stable")


func _verify_step_keys() -> void:
	_expect(VnStoryKeysScript.KEY_MODE == "mode", "step mode key should stay stable")
	_expect(VnStoryKeysScript.KEY_SPEAKER == "speaker", "step speaker key should stay stable")
	_expect(VnStoryKeysScript.KEY_SPEAKER_NAME == "speaker_name", "view speaker-name key should stay stable")
	_expect(VnStoryKeysScript.KEY_TEXT == TextPayloadKeysScript.KEY_TEXT, "step text key should use the shared text key")
	_expect(VnStoryKeysScript.KEY_OUTFIT == CharacterVisualKeysScript.KEY_OUTFIT, "step outfit key should use the shared character visual key")
	_expect(VnStoryKeysScript.KEY_EXPRESSION == CharacterVisualKeysScript.KEY_EXPRESSION, "step expression key should use the shared character visual key")


func _verify_view_option_keys() -> void:
	_expect(VnStoryKeysScript.KEY_BACKGROUND_NAME == "background_name", "background node-name key should stay stable")
	_expect(VnStoryKeysScript.KEY_BACKGROUND_PATH == "background_path", "background path key should stay stable")
	_expect(VnStoryKeysScript.KEY_CHARACTER_NAME == "character_name", "character node-name key should stay stable")
	_expect(VnStoryKeysScript.KEY_SHOW_HUD == "show_hud", "HUD visibility key should stay stable")
	_expect(VnStoryKeysScript.KEY_SHOW_TOP_BUTTONS == "show_top_buttons", "top-button visibility key should stay stable")
	_expect(VnStoryKeysScript.KEY_SHOW_CHARACTER == "show_character", "character visibility option key should stay stable")
	_expect(VnStoryKeysScript.KEY_CHARACTER_VISIBLE == "character_visible", "visual-mode character visibility key should stay stable")
	_expect(VnStoryKeysScript.KEY_DATE_TEXT == DisplayPayloadKeysScript.KEY_DATE_TEXT, "date text key should use the shared display payload key")
	_expect(VnStoryKeysScript.KEY_HUD_OPTIONS == "hud_options", "HUD options key should stay stable")
	_expect(VnStoryKeysScript.KEY_DIALOGUE_OPTIONS == "dialogue_options", "dialogue options key should stay stable")
	_expect(VnStoryKeysScript.KEY_DEFAULT_OUTFIT == CharacterVisualKeysScript.KEY_DEFAULT_OUTFIT, "default outfit visual key should use the shared character visual key")
	_expect(VnStoryKeysScript.KEY_DEFAULT_EXPRESSION == CharacterVisualKeysScript.KEY_DEFAULT_EXPRESSION, "default expression visual key should use the shared character visual key")


func _verify_event_keys() -> void:
	_expect(VnStoryKeysScript.EVENT_KEY_CG_PATH == "cg_path", "event CG path key should stay stable")
	_expect(VnStoryKeysScript.EVENT_KEY_DIALOGUE == "dialogue", "event dialogue key should stay stable")
	_expect(VnStoryKeysScript.EVENT_KEY_NAME_KO == LocalizedPayloadKeysScript.KEY_NAME_KO, "event Korean-name key should use the shared localized payload key")
	_expect(VnStoryKeysScript.EVENT_KEY_SUMMARY_KO == LocalizedPayloadKeysScript.KEY_SUMMARY_KO, "event summary key should use the shared localized payload key")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
