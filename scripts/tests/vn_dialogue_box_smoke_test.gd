extends "res://scripts/tests/test_scene_tree.gd"

const VnDialogueBoxScript := preload("res://scripts/ui/vn_dialogue_box.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var host := Control.new()
	host.size = Vector2(720, 1280)
	root.add_child(host)

	var refs: Dictionary = VnDialogueBoxScript.add_to(host, "나")
	var area := refs.get(VnDialogueBoxConfigScript.KEY_AREA) as Control
	var box := refs.get(VnDialogueBoxConfigScript.KEY_BOX) as TextureRect
	var name_label := refs.get(VnDialogueBoxConfigScript.KEY_NAME_LABEL) as Label
	var dialogue_label := refs.get(VnDialogueBoxConfigScript.KEY_DIALOGUE_LABEL) as Label

	_expect(area != null and area.name == VnDialogueBoxConfigScript.AREA_NAME, "dialogue helper should create the configured area")
	_expect(area.offset_left == VnDialogueBoxConfigScript.OFFSET_LEFT, "dialogue area left offset should use config")
	_expect(area.offset_top == -VnDialogueBoxConfigScript.AREA_HEIGHT - VnDialogueBoxConfigScript.BOTTOM_MARGIN, "dialogue area top offset should use config")
	_expect(area.offset_right == -VnDialogueBoxConfigScript.OFFSET_RIGHT, "dialogue area right offset should use config")
	_expect(area.offset_bottom == -VnDialogueBoxConfigScript.BOTTOM_MARGIN, "dialogue area bottom offset should use config")
	_expect(box != null and box.name == VnDialogueBoxConfigScript.BOX_NAME, "dialogue helper should create the configured box image")
	_expect(box.texture is AtlasTexture, "dialogue helper should trim the box texture through an atlas")
	var atlas := box.texture as AtlasTexture
	_expect(atlas.region.position.y == VnDialogueBoxConfigScript.BOX_TRIM_TOP, "dialogue box atlas should use configured top trim")
	_expect(name_label != null and name_label.text == "나", "dialogue helper should set the speaker text")
	_expect(name_label.name == VnDialogueBoxConfigScript.NAME_LABEL_NAME, "speaker label should use configured name")
	_expect(name_label.position == VnDialogueBoxConfigScript.NAME_LABEL_POSITION, "speaker label should use configured position")
	_expect(name_label.size == VnDialogueBoxConfigScript.NAME_LABEL_SIZE, "speaker label should use configured size")
	_expect(name_label.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == VnDialogueBoxConfigScript.NAME_COLOR, "speaker label should use configured color")
	_expect(name_label.get_theme_font(TextThemeHelpersScript.THEME_FONT) == UiHelpers.make_name_tag_font(), "speaker label should use name tag font")
	_expect(dialogue_label != null and dialogue_label.name == VnDialogueBoxConfigScript.DIALOGUE_LABEL_NAME, "dialogue label should use configured name")
	_expect(dialogue_label.position == VnDialogueBoxConfigScript.DIALOGUE_LABEL_POSITION, "dialogue label should use configured position")
	_expect(dialogue_label.size == VnDialogueBoxConfigScript.DIALOGUE_LABEL_SIZE, "dialogue label should use configured size")
	_expect(dialogue_label.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "dialogue label should keep smart autowrap")
	_expect(dialogue_label.vertical_alignment == VERTICAL_ALIGNMENT_TOP, "dialogue label should stay top-aligned")
	_expect(dialogue_label.get_theme_color(TextThemeHelpersScript.THEME_FONT_OUTLINE_COLOR) == VnDialogueBoxConfigScript.DIALOGUE_OUTLINE_COLOR, "dialogue label should use configured outline color")
	_expect(dialogue_label.get_theme_constant(TextThemeHelpersScript.THEME_OUTLINE_SIZE) == VnDialogueBoxConfigScript.DIALOGUE_OUTLINE_SIZE, "dialogue label should use configured outline size")

	var custom_refs: Dictionary = VnDialogueBoxScript.add_to(host, "이벤트", {
		VnDialogueBoxConfigScript.OPTION_AREA_NAME: "CustomDialogueArea",
		VnDialogueBoxConfigScript.OPTION_BOX_NAME: "CustomDialogueBox",
		VnDialogueBoxConfigScript.OPTION_NAME_LABEL_NAME: "CustomSpeaker",
		VnDialogueBoxConfigScript.OPTION_NAME_WIDTH: 210.0,
		VnDialogueBoxConfigScript.OPTION_DIALOGUE_LABEL_NAME: "CustomDialogueText",
		VnDialogueBoxConfigScript.OPTION_DIALOGUE_POSITION: Vector2(72, 94),
		VnDialogueBoxConfigScript.OPTION_DIALOGUE_SIZE: Vector2(520, 150),
		VnDialogueBoxConfigScript.OPTION_BOTTOM_MARGIN: 30.0
	})
	var custom_area := custom_refs.get(VnDialogueBoxConfigScript.KEY_AREA) as Control
	var custom_box := custom_refs.get(VnDialogueBoxConfigScript.KEY_BOX) as TextureRect
	var custom_name := custom_refs.get(VnDialogueBoxConfigScript.KEY_NAME_LABEL) as Label
	var custom_dialogue := custom_refs.get(VnDialogueBoxConfigScript.KEY_DIALOGUE_LABEL) as Label

	_expect(custom_area.name == "CustomDialogueArea", "dialogue helper should preserve custom area name")
	_expect(custom_area.offset_bottom == -30.0, "dialogue helper should preserve custom bottom margin")
	_expect(custom_box.name == "CustomDialogueBox", "dialogue helper should preserve custom box name")
	_expect(custom_name.name == "CustomSpeaker" and custom_name.size.x == 210.0, "dialogue helper should preserve custom speaker options")
	_expect(custom_dialogue.name == "CustomDialogueText", "dialogue helper should preserve custom dialogue name")
	_expect(custom_dialogue.position == Vector2(72, 94), "dialogue helper should preserve custom dialogue position")
	_expect(custom_dialogue.size == Vector2(520, 150), "dialogue helper should preserve custom dialogue size")

	host.free()
	print("VN dialogue box smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
