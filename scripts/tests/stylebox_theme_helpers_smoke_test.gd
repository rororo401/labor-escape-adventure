extends "res://scripts/tests/test_scene_tree.gd"

const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")


func _initialize() -> void:
	var button := Button.new()
	var normal := StyleBoxFlat.new()
	var hover := StyleBoxFlat.new()
	var pressed := StyleBoxFlat.new()
	var disabled := StyleBoxFlat.new()
	var focus := StyleBoxFlat.new()
	var panel_style := StyleBoxFlat.new()

	normal.bg_color = Color("#111111")
	hover.bg_color = Color("#222222")
	pressed.bg_color = Color("#333333")
	disabled.bg_color = Color("#444444")
	focus.bg_color = Color("#555555")
	panel_style.bg_color = Color("#666666")

	StyleboxThemeHelpersScript.apply_button_styles(button, normal, hover, pressed, disabled)
	StyleboxThemeHelpersScript.apply_style(button, StyleboxThemeHelpersScript.STYLE_FOCUS, focus)
	StyleboxThemeHelpersScript.apply_panel_style(button, panel_style)
	var flat := StyleBoxFlat.new()
	StyleboxThemeHelpersScript.apply_border_width(flat, 3)
	StyleboxThemeHelpersScript.apply_corner_radius(flat, 9)
	StyleboxThemeHelpersScript.apply_shadow(flat, Color("#abcdef"), 5, Vector2(1, 2))
	StyleboxThemeHelpersScript.apply_content_margin(flat, 11, 12, 13, 14)
	var made := StyleboxThemeHelpersScript.make_flat_style(Color("#101010"), Color("#202020"), 4, 6, Color("#303030"), 7, Vector2(3, 4))

	_expect(StyleboxThemeHelpersScript.STYLE_NORMAL == "normal", "normal style key should stay stable")
	_expect(StyleboxThemeHelpersScript.STYLE_HOVER == "hover", "hover style key should stay stable")
	_expect(StyleboxThemeHelpersScript.STYLE_PRESSED == "pressed", "pressed style key should stay stable")
	_expect(StyleboxThemeHelpersScript.STYLE_DISABLED == "disabled", "disabled style key should stay stable")
	_expect(StyleboxThemeHelpersScript.STYLE_FOCUS == "focus", "focus style key should stay stable")
	_expect(StyleboxThemeHelpersScript.STYLE_PANEL == "panel", "panel style key should stay stable")
	_expect((StyleboxThemeHelpersScript.get_style(button, StyleboxThemeHelpersScript.STYLE_NORMAL) as StyleBoxFlat).bg_color == Color("#111111"), "helper should apply normal style")
	_expect((StyleboxThemeHelpersScript.get_style(button, StyleboxThemeHelpersScript.STYLE_HOVER) as StyleBoxFlat).bg_color == Color("#222222"), "helper should apply hover style")
	_expect((StyleboxThemeHelpersScript.get_style(button, StyleboxThemeHelpersScript.STYLE_PRESSED) as StyleBoxFlat).bg_color == Color("#333333"), "helper should apply pressed style")
	_expect((StyleboxThemeHelpersScript.get_style(button, StyleboxThemeHelpersScript.STYLE_DISABLED) as StyleBoxFlat).bg_color == Color("#444444"), "helper should apply disabled style")
	_expect((StyleboxThemeHelpersScript.get_style(button, StyleboxThemeHelpersScript.STYLE_FOCUS) as StyleBoxFlat).bg_color == Color("#555555"), "helper should apply focus style")
	_expect((StyleboxThemeHelpersScript.get_style(button, StyleboxThemeHelpersScript.STYLE_PANEL) as StyleBoxFlat).bg_color == Color("#666666"), "helper should apply panel style")
	_expect(flat.border_width_left == 3 and flat.border_width_bottom == 3, "helper should apply uniform border width")
	_expect(flat.corner_radius_top_left == 9 and flat.corner_radius_bottom_right == 9, "helper should apply uniform corner radius")
	_expect(flat.shadow_color == Color("#abcdef") and flat.shadow_size == 5 and flat.shadow_offset == Vector2(1, 2), "helper should apply shadow values")
	_expect(flat.content_margin_left == 11 and flat.content_margin_top == 12 and flat.content_margin_right == 13 and flat.content_margin_bottom == 14, "helper should apply content margins")
	StyleboxThemeHelpersScript.clear_shadow(flat)
	_expect(flat.shadow_size == 0 and flat.shadow_color == Color.TRANSPARENT and flat.shadow_offset == Vector2.ZERO, "helper should clear shadow values")
	_expect(made.bg_color == Color("#101010") and made.border_color == Color("#202020"), "factory should apply base colors")
	_expect(made.border_width_left == 4 and made.corner_radius_top_left == 6, "factory should apply border and radius")
	_expect(made.shadow_color == Color("#303030") and made.shadow_size == 7 and made.shadow_offset == Vector2(3, 4), "factory should apply shadow")

	button.free()
	print("Stylebox theme helpers smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
