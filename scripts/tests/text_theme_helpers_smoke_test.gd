extends "res://scripts/tests/test_scene_tree.gd"

const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")


func _initialize() -> void:
	var label := Label.new()
	TextThemeHelpersScript.apply_ui_font(label)
	TextThemeHelpersScript.apply_outline(label, Color("#123456"), 7)
	TextThemeHelpersScript.apply_text_style(label, 23, Color("#abcdef"))
	TextThemeHelpersScript.apply_hover_font_color(label, Color("#fedcba"))
	TextThemeHelpersScript.apply_disabled_font_color(label, Color("#654321"))
	TextThemeHelpersScript.apply_placeholder_font_color(label, Color("#111111"))
	TextThemeHelpersScript.center_text(label)

	_expect(TextThemeHelpersScript.THEME_FONT == "font", "font key should stay stable")
	_expect(TextThemeHelpersScript.THEME_FONT_OUTLINE_COLOR == "font_outline_color", "font outline color key should stay stable")
	_expect(TextThemeHelpersScript.THEME_OUTLINE_SIZE == "outline_size", "outline size key should stay stable")
	_expect(TextThemeHelpersScript.THEME_FONT_SIZE == "font_size", "font size key should stay stable")
	_expect(TextThemeHelpersScript.THEME_FONT_COLOR == "font_color", "font color key should stay stable")
	_expect(TextThemeHelpersScript.THEME_FONT_HOVER_COLOR == "font_hover_color", "font hover color key should stay stable")
	_expect(TextThemeHelpersScript.THEME_FONT_DISABLED_COLOR == "font_disabled_color", "font disabled color key should stay stable")
	_expect(TextThemeHelpersScript.THEME_FONT_PLACEHOLDER_COLOR == "font_placeholder_color", "font placeholder color key should stay stable")
	_expect(label.get_theme_font(TextThemeHelpersScript.THEME_FONT) != null, "helper should apply the UI font")
	_expect(label.get_theme_color(TextThemeHelpersScript.THEME_FONT_OUTLINE_COLOR) == Color("#123456"), "helper should apply outline color")
	_expect(label.get_theme_constant(TextThemeHelpersScript.THEME_OUTLINE_SIZE) == 7, "helper should apply outline size")
	_expect(label.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == 23, "helper should apply font size")
	_expect(label.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == Color("#abcdef"), "helper should apply font color")
	_expect(label.get_theme_color(TextThemeHelpersScript.THEME_FONT_HOVER_COLOR) == Color("#fedcba"), "helper should apply hover font color")
	_expect(label.get_theme_color(TextThemeHelpersScript.THEME_FONT_DISABLED_COLOR) == Color("#654321"), "helper should apply disabled font color")
	_expect(label.get_theme_color(TextThemeHelpersScript.THEME_FONT_PLACEHOLDER_COLOR) == Color("#111111"), "helper should apply placeholder font color")
	_expect(label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "helper should apply horizontal center alignment")
	_expect(label.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "helper should apply vertical center alignment")
	TextThemeHelpersScript.apply_horizontal_alignment(label, HORIZONTAL_ALIGNMENT_RIGHT)
	TextThemeHelpersScript.top_vertical(label)
	_expect(label.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT, "helper should apply horizontal alignment")
	_expect(label.vertical_alignment == VERTICAL_ALIGNMENT_TOP, "helper should apply top vertical alignment")

	label.free()
	print("Text theme helpers smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
