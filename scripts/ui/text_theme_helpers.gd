class_name TextThemeHelpers
extends RefCounted

const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

const THEME_FONT := "font"
const THEME_FONT_OUTLINE_COLOR := "font_outline_color"
const THEME_OUTLINE_SIZE := "outline_size"
const THEME_FONT_SIZE := "font_size"
const THEME_FONT_COLOR := "font_color"
const THEME_FONT_HOVER_COLOR := "font_hover_color"
const THEME_FONT_DISABLED_COLOR := "font_disabled_color"
const THEME_FONT_PLACEHOLDER_COLOR := "font_placeholder_color"


static func apply_font(control: Control, font: Font) -> void:
	control.add_theme_font_override(THEME_FONT, font)


static func apply_ui_font(control: Control) -> void:
	apply_font(control, UiHelpers.make_ui_font())


static func apply_outline(label: Label, outline_color: Color, outline_size: int) -> void:
	label.add_theme_color_override(THEME_FONT_OUTLINE_COLOR, outline_color)
	label.add_theme_constant_override(THEME_OUTLINE_SIZE, outline_size)


static func apply_font_size(control: Control, font_size: int) -> void:
	control.add_theme_font_size_override(THEME_FONT_SIZE, font_size)


static func apply_font_color(control: Control, color: Color) -> void:
	control.add_theme_color_override(THEME_FONT_COLOR, color)


static func apply_hover_font_color(control: Control, color: Color) -> void:
	control.add_theme_color_override(THEME_FONT_HOVER_COLOR, color)


static func apply_disabled_font_color(control: Control, color: Color) -> void:
	control.add_theme_color_override(THEME_FONT_DISABLED_COLOR, color)


static func apply_placeholder_font_color(control: Control, color: Color) -> void:
	control.add_theme_color_override(THEME_FONT_PLACEHOLDER_COLOR, color)


static func apply_text_style(control: Control, font_size: int, color: Color) -> void:
	apply_font_size(control, font_size)
	apply_font_color(control, color)


static func apply_ui_text_style(control: Control, font_size: int, color: Color) -> void:
	apply_ui_font(control)
	apply_text_style(control, font_size, color)


static func apply_alignment(label: Label, horizontal: HorizontalAlignment, vertical: VerticalAlignment) -> void:
	label.horizontal_alignment = horizontal
	label.vertical_alignment = vertical


static func apply_horizontal_alignment(label: Label, horizontal: HorizontalAlignment) -> void:
	label.horizontal_alignment = horizontal


static func apply_vertical_alignment(label: Label, vertical: VerticalAlignment) -> void:
	label.vertical_alignment = vertical


static func center_text(label: Label) -> void:
	apply_alignment(label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)


static func center_vertical(label: Label) -> void:
	apply_vertical_alignment(label, VERTICAL_ALIGNMENT_CENTER)


static func top_vertical(label: Label) -> void:
	apply_vertical_alignment(label, VERTICAL_ALIGNMENT_TOP)
