class_name ProfileFormStyle
extends RefCounted

const ProfileFormConfigScript := preload("res://scripts/ui/profile_form_config.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")


static func make_label(
	text: String,
	font_size: int,
	color: Color,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	var label := Label.new()
	label.text = text
	TextThemeHelpersScript.apply_horizontal_alignment(label, alignment)
	TextThemeHelpersScript.apply_ui_text_style(label, font_size, color)
	return label


static func apply_outline(label: Label) -> void:
	TextThemeHelpersScript.apply_outline(
		label,
		ProfileFormConfigScript.HEADER_OUTLINE_COLOR,
		ProfileFormConfigScript.HEADER_OUTLINE_SIZE
	)


static func apply_name_input(input: LineEdit) -> void:
	TextThemeHelpersScript.apply_ui_text_style(input, ProfileFormConfigScript.NAME_INPUT_FONT_SIZE, ProfileFormConfigScript.TEXT_COLOR)
	TextThemeHelpersScript.apply_placeholder_font_color(input, ProfileFormConfigScript.PLACEHOLDER_COLOR)
	StyleboxThemeHelpersScript.apply_line_edit_styles(
		input,
		line_edit_style(ProfileFormConfigScript.LINE_EDIT_NORMAL_COLOR, ProfileFormConfigScript.LINE_EDIT_NORMAL_BORDER),
		line_edit_style(ProfileFormConfigScript.LINE_EDIT_FOCUS_COLOR, ProfileFormConfigScript.LINE_EDIT_FOCUS_BORDER)
	)


static func apply_difficulty_option(option: OptionButton) -> void:
	TextThemeHelpersScript.apply_ui_text_style(option, ProfileFormConfigScript.DIFFICULTY_OPTION_FONT_SIZE, ProfileFormConfigScript.TEXT_COLOR)
	StyleboxThemeHelpersScript.apply_button_styles(
		option,
		button_style(ProfileFormConfigScript.LINE_EDIT_NORMAL_COLOR, ProfileFormConfigScript.LINE_EDIT_NORMAL_BORDER),
		button_style(ProfileFormConfigScript.LINE_EDIT_FOCUS_COLOR, ProfileFormConfigScript.LINE_EDIT_FOCUS_BORDER),
		button_style(ProfileFormConfigScript.LINE_EDIT_FOCUS_COLOR, ProfileFormConfigScript.LINE_EDIT_FOCUS_BORDER)
	)


static func apply_submit_button(button: Button) -> void:
	TextThemeHelpersScript.apply_ui_text_style(button, ProfileFormConfigScript.SUBMIT_BUTTON_FONT_SIZE, ProfileFormConfigScript.SUBMIT_TEXT_COLOR)
	StyleboxThemeHelpersScript.apply_button_styles(
		button,
		button_style(ProfileFormConfigScript.SUBMIT_NORMAL_COLOR, ProfileFormConfigScript.SUBMIT_NORMAL_BORDER),
		button_style(ProfileFormConfigScript.SUBMIT_HOVER_COLOR, ProfileFormConfigScript.SUBMIT_HOVER_BORDER),
		button_style(ProfileFormConfigScript.SUBMIT_PRESSED_COLOR, ProfileFormConfigScript.SUBMIT_PRESSED_BORDER)
	)


static func panel_style(color: Color, border: Color) -> StyleBoxFlat:
	return UiHelpers.panel_style(
		color,
		border,
		ProfileFormConfigScript.PANEL_SHADOW_COLOR,
		ProfileFormConfigScript.PANEL_SHADOW_SIZE,
		ProfileFormConfigScript.PANEL_SHADOW_OFFSET
	)


static func button_style(color: Color, border: Color) -> StyleBoxFlat:
	var style := panel_style(color, border)
	StyleboxThemeHelpersScript.clear_shadow(style)
	return style


static func line_edit_style(color: Color, border: Color) -> StyleBoxFlat:
	var style := panel_style(color, border)
	StyleboxThemeHelpersScript.apply_content_margin(
		style,
		ProfileFormConfigScript.LINE_EDIT_CONTENT_MARGIN_LEFT,
		ProfileFormConfigScript.LINE_EDIT_CONTENT_MARGIN_TOP,
		ProfileFormConfigScript.LINE_EDIT_CONTENT_MARGIN_RIGHT,
		ProfileFormConfigScript.LINE_EDIT_CONTENT_MARGIN_BOTTOM
	)
	StyleboxThemeHelpersScript.clear_shadow(style)
	return style
