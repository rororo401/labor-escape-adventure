class_name VnDialogueBox
extends RefCounted

const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")


static func add_to(parent: Control, speaker_name: String = "", options: Dictionary = {}) -> Dictionary:
	var dialogue_area := Control.new()
	dialogue_area.name = String(options.get(VnDialogueBoxConfigScript.OPTION_AREA_NAME, VnDialogueBoxConfigScript.AREA_NAME))
	dialogue_area.anchor_left = 0.0
	dialogue_area.anchor_top = 1.0
	dialogue_area.anchor_right = 1.0
	dialogue_area.anchor_bottom = 1.0
	dialogue_area.offset_left = float(options.get(VnDialogueBoxConfigScript.OPTION_OFFSET_LEFT, VnDialogueBoxConfigScript.OFFSET_LEFT))
	dialogue_area.offset_top = -float(options.get(VnDialogueBoxConfigScript.OPTION_AREA_HEIGHT, VnDialogueBoxConfigScript.AREA_HEIGHT)) - float(options.get(VnDialogueBoxConfigScript.OPTION_BOTTOM_MARGIN, VnDialogueBoxConfigScript.BOTTOM_MARGIN))
	dialogue_area.offset_right = -float(options.get(VnDialogueBoxConfigScript.OPTION_OFFSET_RIGHT, VnDialogueBoxConfigScript.OFFSET_RIGHT))
	dialogue_area.offset_bottom = -float(options.get(VnDialogueBoxConfigScript.OPTION_BOTTOM_MARGIN, VnDialogueBoxConfigScript.BOTTOM_MARGIN))
	parent.add_child(dialogue_area)

	var box := TextureRect.new()
	box.name = String(options.get(VnDialogueBoxConfigScript.OPTION_BOX_NAME, VnDialogueBoxConfigScript.BOX_NAME))
	box.texture = make_box_texture()
	UiHelpers.apply_full_rect(box)
	box.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	box.stretch_mode = TextureRect.STRETCH_SCALE
	dialogue_area.add_child(box)

	var font := UiHelpers.make_ui_font()
	var name_tag_font := UiHelpers.make_name_tag_font()
	var name_label := Label.new()
	name_label.name = String(options.get(VnDialogueBoxConfigScript.OPTION_NAME_LABEL_NAME, VnDialogueBoxConfigScript.NAME_LABEL_NAME))
	name_label.text = speaker_name
	name_label.position = VnDialogueBoxConfigScript.NAME_LABEL_POSITION
	name_label.size = Vector2(
		float(options.get(VnDialogueBoxConfigScript.OPTION_NAME_WIDTH, VnDialogueBoxConfigScript.NAME_LABEL_SIZE.x)),
		VnDialogueBoxConfigScript.NAME_LABEL_SIZE.y
	)
	TextThemeHelpersScript.apply_font(name_label, name_tag_font)
	TextThemeHelpersScript.apply_text_style(
		name_label,
		int(options.get(VnDialogueBoxConfigScript.OPTION_NAME_FONT_SIZE, VnDialogueBoxConfigScript.NAME_FONT_SIZE)),
		VnDialogueBoxConfigScript.NAME_COLOR
	)
	dialogue_area.add_child(name_label)

	var dialogue_label := Label.new()
	dialogue_label.name = String(options.get(VnDialogueBoxConfigScript.OPTION_DIALOGUE_LABEL_NAME, VnDialogueBoxConfigScript.DIALOGUE_LABEL_NAME))
	dialogue_label.position = options.get(VnDialogueBoxConfigScript.OPTION_DIALOGUE_POSITION, VnDialogueBoxConfigScript.DIALOGUE_LABEL_POSITION)
	dialogue_label.size = options.get(VnDialogueBoxConfigScript.OPTION_DIALOGUE_SIZE, VnDialogueBoxConfigScript.DIALOGUE_LABEL_SIZE)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.top_vertical(dialogue_label)
	TextThemeHelpersScript.apply_font(dialogue_label, font)
	TextThemeHelpersScript.apply_text_style(
		dialogue_label,
		int(options.get(VnDialogueBoxConfigScript.OPTION_DIALOGUE_FONT_SIZE, VnDialogueBoxConfigScript.DIALOGUE_FONT_SIZE)),
		VnDialogueBoxConfigScript.DIALOGUE_COLOR
	)
	TextThemeHelpersScript.apply_outline(
		dialogue_label,
		VnDialogueBoxConfigScript.DIALOGUE_OUTLINE_COLOR,
		VnDialogueBoxConfigScript.DIALOGUE_OUTLINE_SIZE
	)
	dialogue_area.add_child(dialogue_label)

	return {
		VnDialogueBoxConfigScript.KEY_AREA: dialogue_area,
		VnDialogueBoxConfigScript.KEY_BOX: box,
		VnDialogueBoxConfigScript.KEY_NAME_LABEL: name_label,
		VnDialogueBoxConfigScript.KEY_DIALOGUE_LABEL: dialogue_label
	}


static func make_box_texture() -> Texture2D:
	var texture := UiHelpers.load_texture(VnDialogueBoxConfigScript.BOX_TEXTURE_PATH)
	if texture == null:
		return null

	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(
		0.0,
		VnDialogueBoxConfigScript.BOX_TRIM_TOP,
		float(texture.get_width()),
		float(texture.get_height()) - VnDialogueBoxConfigScript.BOX_TRIM_TOP - VnDialogueBoxConfigScript.BOX_TRIM_BOTTOM
	)
	return atlas
