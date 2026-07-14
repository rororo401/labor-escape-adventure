extends "res://scripts/tests/test_scene_tree.gd"

const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")


func _initialize() -> void:
	_expect(VnDialogueBoxConfigScript.AREA_NAME == "DialogueArea", "dialogue area name should stay stable")
	_expect(VnDialogueBoxConfigScript.AREA_HEIGHT == 265.0, "dialogue area height should preserve current layout")
	_expect(VnDialogueBoxConfigScript.BOTTOM_MARGIN == 20.0, "dialogue bottom margin should preserve current layout")
	_expect(VnDialogueBoxConfigScript.OFFSET_LEFT == 8.0, "dialogue left offset should use the wider layout")
	_expect(VnDialogueBoxConfigScript.OFFSET_RIGHT == 8.0, "dialogue right offset should use the wider layout")
	_expect(VnDialogueBoxConfigScript.BOX_NAME == "DialogueBoxImage", "dialogue box node name should stay stable")
	_expect(VnDialogueBoxConfigScript.BOX_TEXTURE_PATH == "res://assets/ui/dialogue_box_large.png", "dialogue box texture path should be centralized")
	_expect(VnDialogueBoxConfigScript.BOX_TRIM_TOP == 124.0, "dialogue atlas top trim should preserve current crop")
	_expect(VnDialogueBoxConfigScript.BOX_TRIM_BOTTOM == 170.0, "dialogue atlas bottom trim should preserve current crop")
	_expect(VnDialogueBoxConfigScript.KEY_AREA == "area", "dialogue area ref key should stay stable")
	_expect(VnDialogueBoxConfigScript.KEY_BOX == "box", "dialogue box ref key should stay stable")
	_expect(VnDialogueBoxConfigScript.KEY_NAME_LABEL == "name_label", "speaker label ref key should stay stable")
	_expect(VnDialogueBoxConfigScript.KEY_DIALOGUE_LABEL == "dialogue_label", "dialogue label ref key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_AREA_NAME == "area_name", "area name option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_OFFSET_LEFT == "offset_left", "left offset option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_AREA_HEIGHT == "area_height", "area height option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_BOTTOM_MARGIN == "bottom_margin", "bottom margin option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_OFFSET_RIGHT == "offset_right", "right offset option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_BOX_NAME == "box_name", "box name option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_NAME_LABEL_NAME == "name_label_name", "speaker label name option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_NAME_WIDTH == "name_width", "speaker width option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_NAME_FONT_SIZE == "name_font_size", "speaker font-size option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_DIALOGUE_LABEL_NAME == "dialogue_label_name", "dialogue label name option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_DIALOGUE_POSITION == "dialogue_position", "dialogue position option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_DIALOGUE_SIZE == "dialogue_size", "dialogue size option key should stay stable")
	_expect(VnDialogueBoxConfigScript.OPTION_DIALOGUE_FONT_SIZE == "dialogue_font_size", "dialogue font-size option key should stay stable")
	_expect(VnDialogueBoxConfigScript.NAME_LABEL_NAME == "SpeakerName", "speaker label name should stay stable")
	_expect(VnDialogueBoxConfigScript.NAME_LABEL_POSITION == Vector2(72, 16), "speaker label position should sit higher inside the name tag")
	_expect(VnDialogueBoxConfigScript.NAME_LABEL_SIZE == Vector2(340, 42), "speaker label size should preserve current layout")
	_expect(VnDialogueBoxConfigScript.NAME_FONT_SIZE == 26, "speaker label font size should stay stable")
	_expect(VnDialogueBoxConfigScript.NAME_COLOR == Color.WHITE, "speaker label color should stay stable")
	_expect(VnDialogueBoxConfigScript.DIALOGUE_LABEL_NAME == "DialogueText", "dialogue label name should stay stable")
	_expect(VnDialogueBoxConfigScript.DIALOGUE_LABEL_POSITION == Vector2(42, 82), "dialogue text position should preserve current layout")
	_expect(VnDialogueBoxConfigScript.DIALOGUE_LABEL_SIZE == Vector2(632, 128), "dialogue text size should preserve current layout")
	_expect(VnDialogueBoxConfigScript.DIALOGUE_FONT_SIZE == 25, "dialogue font size should stay stable")
	_expect(VnDialogueBoxConfigScript.DIALOGUE_COLOR == Color("#33231e"), "dialogue text color should stay stable")
	_expect(VnDialogueBoxConfigScript.DIALOGUE_OUTLINE_COLOR == Color("#fff7e8"), "dialogue outline color should stay stable")
	_expect(VnDialogueBoxConfigScript.DIALOGUE_OUTLINE_SIZE == 2, "dialogue outline size should stay stable")

	print("VN dialogue box config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
