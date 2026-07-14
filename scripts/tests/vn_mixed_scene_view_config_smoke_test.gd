extends "res://scripts/tests/test_scene_tree.gd"

const VnMixedSceneViewConfigScript := preload("res://scripts/ui/vn_mixed_scene_view_config.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const UiNodeRefKeysScript := preload("res://scripts/ui/ui_node_ref_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")


func _initialize() -> void:
	_expect(VnMixedSceneViewConfigScript.DEFAULT_BACKGROUND_NAME == "SceneBackground", "default background name should stay stable")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_BACKGROUND_PATH == UiPayloadKeysScript.EMPTY_MESSAGE, "default background path should use the shared empty UI message")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_DATE_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "default date text should use the shared empty UI message")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_SHOW_HUD, "mixed scene should show HUD by default")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_SHOW_TOP_BUTTONS, "mixed scene should show top buttons by default")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_SHOW_CHARACTER, "mixed scene should show character by default")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_CHARACTER_NAME == "ProtagonistBust", "default character node name should stay stable")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_SPEAKER_NAME == UiPayloadKeysScript.EMPTY_MESSAGE, "default speaker should use the shared empty UI message")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_CHARACTER_VISIBLE, "step visuals should keep character visible by default")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_OUTFIT == GameStateConfigScript.DEFAULT_PROTAGONIST_OUTFIT_ID, "default visual outfit should use the shared protagonist default")
	_expect(VnMixedSceneViewConfigScript.DEFAULT_EXPRESSION == GameStateConfigScript.DEFAULT_PROTAGONIST_EXPRESSION_ID, "default step expression should use the shared protagonist default")
	_expect(VnMixedSceneViewConfigScript.KEY_BACKGROUND_RECT == UiNodeRefKeysScript.KEY_BACKGROUND_RECT, "background ref key should use the shared node-ref key")
	_expect(VnMixedSceneViewConfigScript.KEY_CHARACTER_TEXTURE_RECT == "character_texture_rect", "character ref key should stay stable")
	_expect(VnMixedSceneViewConfigScript.KEY_DATE_LABEL == VnTopHudConfigScript.KEY_DATE_LABEL, "date label ref key should reuse the VN top HUD key")
	_expect(VnMixedSceneViewConfigScript.KEY_STATUS_BARS == VnTopHudConfigScript.KEY_STATUS_BARS, "status bars ref key should reuse the VN top HUD key")
	_expect(VnMixedSceneViewConfigScript.KEY_NAME_LABEL == VnDialogueBoxConfigScript.KEY_NAME_LABEL, "speaker label ref key should reuse the VN dialogue-box key")
	_expect(VnMixedSceneViewConfigScript.KEY_DIALOGUE_LABEL == VnDialogueBoxConfigScript.KEY_DIALOGUE_LABEL, "dialogue label ref key should reuse the VN dialogue-box key")

	print("VN mixed scene view config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
