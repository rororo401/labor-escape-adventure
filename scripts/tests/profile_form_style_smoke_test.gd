extends "res://scripts/tests/test_scene_tree.gd"

const ProfileFormConfigScript := preload("res://scripts/ui/profile_form_config.gd")
const ProfileFormStyleScript := preload("res://scripts/ui/profile_form_style.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")


func _initialize() -> void:
	_verify_label_and_outline()
	_verify_panel_and_input_styles()
	_verify_button_style_application()

	print("Profile form style smoke test passed.")
	finish_test()


func _verify_label_and_outline() -> void:
	var label := ProfileFormStyleScript.make_label("테스트", 24, Color("#123456"), HORIZONTAL_ALIGNMENT_CENTER)
	_expect(label.text == "테스트", "style helper should set label text")
	_expect(label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "style helper should set label alignment")
	_expect(label.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == 24, "style helper should set label font size")
	_expect(label.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == Color("#123456"), "style helper should set label color")
	ProfileFormStyleScript.apply_outline(label)
	_expect(label.get_theme_color(TextThemeHelpersScript.THEME_FONT_OUTLINE_COLOR) == ProfileFormConfigScript.HEADER_OUTLINE_COLOR, "outline should use configured color")
	_expect(label.get_theme_constant(TextThemeHelpersScript.THEME_OUTLINE_SIZE) == ProfileFormConfigScript.HEADER_OUTLINE_SIZE, "outline should use configured size")
	label.free()


func _verify_panel_and_input_styles() -> void:
	var panel_style := ProfileFormStyleScript.panel_style(ProfileFormConfigScript.PANEL_COLOR, ProfileFormConfigScript.PANEL_BORDER_COLOR)
	_expect(panel_style.bg_color == ProfileFormConfigScript.PANEL_COLOR, "panel style should use configured background color")
	_expect(panel_style.border_color == ProfileFormConfigScript.PANEL_BORDER_COLOR, "panel style should use configured border color")
	_expect(panel_style.shadow_size == ProfileFormConfigScript.PANEL_SHADOW_SIZE, "panel style should keep configured shadow")

	var input := LineEdit.new()
	ProfileFormStyleScript.apply_name_input(input)
	_expect(input.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == ProfileFormConfigScript.NAME_INPUT_FONT_SIZE, "line edit should use configured font size")
	_expect(input.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == ProfileFormConfigScript.TEXT_COLOR, "line edit should use configured text color")
	var normal_style := StyleboxThemeHelpersScript.get_style(input, StyleboxThemeHelpersScript.STYLE_NORMAL) as StyleBoxFlat
	var focus_style := StyleboxThemeHelpersScript.get_style(input, StyleboxThemeHelpersScript.STYLE_FOCUS) as StyleBoxFlat
	_expect(normal_style != null, "line edit should have normal style")
	_expect(focus_style != null, "line edit should have focus style")
	_expect(normal_style.content_margin_left == ProfileFormConfigScript.LINE_EDIT_CONTENT_MARGIN_LEFT, "line edit normal style should use configured margin")
	_expect(focus_style.border_color == ProfileFormConfigScript.LINE_EDIT_FOCUS_BORDER, "line edit focus style should use configured border")
	input.free()


func _verify_button_style_application() -> void:
	var button := Button.new()
	ProfileFormStyleScript.apply_submit_button(button)
	_expect(button.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == ProfileFormConfigScript.SUBMIT_BUTTON_FONT_SIZE, "submit button should use configured font size")
	_expect(button.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == ProfileFormConfigScript.SUBMIT_TEXT_COLOR, "submit button should use configured text color")
	_expect(StyleboxThemeHelpersScript.get_style(button, StyleboxThemeHelpersScript.STYLE_NORMAL) != null, "submit button should have normal style")
	_expect(StyleboxThemeHelpersScript.get_style(button, StyleboxThemeHelpersScript.STYLE_HOVER) != null, "submit button should have hover style")
	_expect(StyleboxThemeHelpersScript.get_style(button, StyleboxThemeHelpersScript.STYLE_PRESSED) != null, "submit button should have pressed style")
	button.free()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
