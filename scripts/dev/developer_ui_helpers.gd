class_name DeveloperUiHelpers
extends RefCounted

const DeveloperUiHelpersConfigScript := preload("res://scripts/dev/developer_ui_helpers_config.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")


static func make_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	TextThemeHelpersScript.apply_ui_text_style(label, font_size, color)
	TextThemeHelpersScript.center_vertical(label)
	return label


static func make_menu_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = DeveloperUiHelpersConfigScript.MENU_BUTTON_SIZE
	TextThemeHelpersScript.apply_ui_text_style(button, DeveloperUiHelpersConfigScript.MENU_BUTTON_FONT_SIZE, DeveloperUiHelpersConfigScript.BUTTON_TEXT_COLOR)
	TextThemeHelpersScript.apply_disabled_font_color(button, DeveloperUiHelpersConfigScript.MENU_BUTTON_DISABLED_TEXT_COLOR)
	StyleboxThemeHelpersScript.apply_button_styles(
		button,
		button_style(DeveloperUiHelpersConfigScript.BUTTON_NORMAL_COLOR, DeveloperUiHelpersConfigScript.BUTTON_NORMAL_BORDER),
		button_style(DeveloperUiHelpersConfigScript.BUTTON_HOVER_COLOR, DeveloperUiHelpersConfigScript.BUTTON_HOVER_BORDER),
		button_style(DeveloperUiHelpersConfigScript.BUTTON_PRESSED_COLOR, DeveloperUiHelpersConfigScript.BUTTON_PRESSED_BORDER),
		button_style(DeveloperUiHelpersConfigScript.MENU_BUTTON_DISABLED_COLOR, DeveloperUiHelpersConfigScript.MENU_BUTTON_DISABLED_BORDER)
	)
	return button


static func make_compact_button(text: String) -> Button:
	var button := make_menu_button(text)
	button.custom_minimum_size = DeveloperUiHelpersConfigScript.COMPACT_BUTTON_SIZE
	TextThemeHelpersScript.apply_font_size(button, DeveloperUiHelpersConfigScript.COMPACT_BUTTON_FONT_SIZE)
	return button


static func make_tool_button(
	text: String,
	min_size: Vector2 = DeveloperUiHelpersConfigScript.TOOL_BUTTON_DEFAULT_SIZE,
	font_size: int = DeveloperUiHelpersConfigScript.TOOL_BUTTON_DEFAULT_FONT_SIZE
) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	TextThemeHelpersScript.apply_ui_text_style(button, font_size, DeveloperUiHelpersConfigScript.BUTTON_TEXT_COLOR)
	TextThemeHelpersScript.apply_disabled_font_color(button, DeveloperUiHelpersConfigScript.TOOL_BUTTON_DISABLED_TEXT_COLOR)
	StyleboxThemeHelpersScript.apply_button_styles(
		button,
		button_style(DeveloperUiHelpersConfigScript.BUTTON_NORMAL_COLOR, DeveloperUiHelpersConfigScript.BUTTON_NORMAL_BORDER),
		button_style(DeveloperUiHelpersConfigScript.BUTTON_HOVER_COLOR, DeveloperUiHelpersConfigScript.BUTTON_HOVER_BORDER),
		button_style(DeveloperUiHelpersConfigScript.BUTTON_PRESSED_COLOR, DeveloperUiHelpersConfigScript.BUTTON_PRESSED_BORDER),
		button_style(DeveloperUiHelpersConfigScript.TOOL_BUTTON_DISABLED_COLOR, DeveloperUiHelpersConfigScript.TOOL_BUTTON_DISABLED_BORDER)
	)
	return button


static func style_line_edit(control: Control) -> void:
	TextThemeHelpersScript.apply_ui_text_style(control, DeveloperUiHelpersConfigScript.LINE_EDIT_FONT_SIZE, DeveloperUiHelpersConfigScript.LINE_EDIT_TEXT_COLOR)
	TextThemeHelpersScript.apply_hover_font_color(control, DeveloperUiHelpersConfigScript.LINE_EDIT_TEXT_COLOR)
	TextThemeHelpersScript.apply_placeholder_font_color(control, DeveloperUiHelpersConfigScript.LINE_EDIT_PLACEHOLDER_COLOR)
	var focus_style := line_edit_style(DeveloperUiHelpersConfigScript.LINE_EDIT_FOCUS_COLOR, DeveloperUiHelpersConfigScript.LINE_EDIT_FOCUS_BORDER)
	StyleboxThemeHelpersScript.apply_line_edit_styles(
		control,
		line_edit_style(DeveloperUiHelpersConfigScript.LINE_EDIT_NORMAL_COLOR, DeveloperUiHelpersConfigScript.LINE_EDIT_NORMAL_BORDER),
		focus_style,
		focus_style
	)


static func apply_panel_style(control: Control, color: Color, border: Color) -> void:
	StyleboxThemeHelpersScript.apply_panel_style(control, panel_style(color, border))


static func panel_style(color: Color, border: Color) -> StyleBoxFlat:
	return StyleboxThemeHelpersScript.make_flat_style(
		color,
		border,
		DeveloperUiHelpersConfigScript.PANEL_BORDER_WIDTH,
		DeveloperUiHelpersConfigScript.PANEL_RADIUS,
		DeveloperUiHelpersConfigScript.PANEL_SHADOW_COLOR,
		DeveloperUiHelpersConfigScript.PANEL_SHADOW_SIZE,
		DeveloperUiHelpersConfigScript.PANEL_SHADOW_OFFSET
	)


static func button_style(color: Color, border: Color) -> StyleBoxFlat:
	var style := panel_style(color, border)
	StyleboxThemeHelpersScript.clear_shadow(style)
	StyleboxThemeHelpersScript.apply_horizontal_content_margin(style, DeveloperUiHelpersConfigScript.BUTTON_CONTENT_MARGIN_X)
	return style


static func line_edit_style(color: Color, border: Color) -> StyleBoxFlat:
	var style := panel_style(color, border)
	StyleboxThemeHelpersScript.clear_shadow(style)
	StyleboxThemeHelpersScript.apply_content_margin(
		style,
		DeveloperUiHelpersConfigScript.LINE_EDIT_CONTENT_MARGIN_X,
		DeveloperUiHelpersConfigScript.LINE_EDIT_CONTENT_MARGIN_Y,
		DeveloperUiHelpersConfigScript.LINE_EDIT_CONTENT_MARGIN_X,
		DeveloperUiHelpersConfigScript.LINE_EDIT_CONTENT_MARGIN_Y
	)
	return style
