class_name StyleboxThemeHelpers
extends RefCounted

const STYLE_NORMAL := "normal"
const STYLE_HOVER := "hover"
const STYLE_PRESSED := "pressed"
const STYLE_DISABLED := "disabled"
const STYLE_FOCUS := "focus"
const STYLE_PANEL := "panel"


static func apply_style(control: Control, state: String, style: StyleBox) -> void:
	control.add_theme_stylebox_override(state, style)


static func get_style(control: Control, state: String) -> StyleBox:
	return control.get_theme_stylebox(state)


static func apply_button_styles(
	button: Button,
	normal_style: StyleBox,
	hover_style: StyleBox,
	pressed_style: StyleBox,
	disabled_style: StyleBox = null
) -> void:
	apply_style(button, STYLE_NORMAL, normal_style)
	apply_style(button, STYLE_HOVER, hover_style)
	apply_style(button, STYLE_PRESSED, pressed_style)
	if disabled_style != null:
		apply_style(button, STYLE_DISABLED, disabled_style)


static func apply_line_edit_styles(control: Control, normal_style: StyleBox, focus_style: StyleBox, hover_style: StyleBox = null) -> void:
	apply_style(control, STYLE_NORMAL, normal_style)
	apply_style(control, STYLE_FOCUS, focus_style)
	if hover_style != null:
		apply_style(control, STYLE_HOVER, hover_style)


static func apply_panel_style(control: Control, panel_style: StyleBox) -> void:
	apply_style(control, STYLE_PANEL, panel_style)


static func make_flat_style(
	color: Color,
	border: Color,
	border_width: int,
	radius: int,
	shadow_color: Color = Color.TRANSPARENT,
	shadow_size: int = 0,
	shadow_offset: Vector2 = Vector2.ZERO
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	apply_border_width(style, border_width)
	apply_corner_radius(style, radius)
	apply_shadow(style, shadow_color, shadow_size, shadow_offset)
	return style


static func apply_border_width(style: StyleBoxFlat, width: int) -> void:
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width


static func apply_corner_radius(style: StyleBoxFlat, radius: int) -> void:
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius


static func apply_shadow(style: StyleBoxFlat, color: Color, size: int, offset: Vector2) -> void:
	style.shadow_color = color
	style.shadow_size = size
	style.shadow_offset = offset


static func clear_shadow(style: StyleBoxFlat) -> void:
	apply_shadow(style, Color.TRANSPARENT, 0, Vector2.ZERO)


static func apply_horizontal_content_margin(style: StyleBoxFlat, margin: int) -> void:
	style.content_margin_left = margin
	style.content_margin_right = margin


static func apply_content_margin(style: StyleBoxFlat, left: int, top: int, right: int, bottom: int) -> void:
	style.content_margin_left = left
	style.content_margin_top = top
	style.content_margin_right = right
	style.content_margin_bottom = bottom
