extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperUiHelpersConfigScript := preload("res://scripts/dev/developer_ui_helpers_config.gd")
const DeveloperUiHelpersScript := preload("res://scripts/dev/developer_ui_helpers.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")

var _created_controls: Array[Control] = []


func _initialize() -> void:
	_verify_menu_button()
	_verify_compact_button()
	_verify_tool_button()
	_verify_line_edit()
	_verify_panel_and_button_styles()
	for control in _created_controls:
		control.free()
	_created_controls.clear()

	print("Developer UI helpers smoke test passed.")
	finish_test()


func _verify_menu_button() -> void:
	var button := DeveloperUiHelpersScript.make_menu_button("메뉴")
	_created_controls.append(button)
	_expect(button.custom_minimum_size == DeveloperUiHelpersConfigScript.MENU_BUTTON_SIZE, "menu button should use configured size")
	_expect(button.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == DeveloperUiHelpersConfigScript.MENU_BUTTON_FONT_SIZE, "menu button should use configured font size")
	_expect(button.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == DeveloperUiHelpersConfigScript.BUTTON_TEXT_COLOR, "menu button should use configured text color")
	_expect(button.get_theme_color(TextThemeHelpersScript.THEME_FONT_DISABLED_COLOR) == DeveloperUiHelpersConfigScript.MENU_BUTTON_DISABLED_TEXT_COLOR, "menu button should use configured disabled text color")


func _verify_compact_button() -> void:
	var button := DeveloperUiHelpersScript.make_compact_button("이동")
	_created_controls.append(button)
	_expect(button.custom_minimum_size == DeveloperUiHelpersConfigScript.COMPACT_BUTTON_SIZE, "compact button should use configured size")
	_expect(button.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == DeveloperUiHelpersConfigScript.COMPACT_BUTTON_FONT_SIZE, "compact button should use configured font size")


func _verify_tool_button() -> void:
	var button := DeveloperUiHelpersScript.make_tool_button("도구")
	_created_controls.append(button)
	_expect(button.custom_minimum_size == DeveloperUiHelpersConfigScript.TOOL_BUTTON_DEFAULT_SIZE, "tool button should use configured default size")
	_expect(button.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == DeveloperUiHelpersConfigScript.TOOL_BUTTON_DEFAULT_FONT_SIZE, "tool button should use configured default font size")
	_expect(button.get_theme_color(TextThemeHelpersScript.THEME_FONT_DISABLED_COLOR) == DeveloperUiHelpersConfigScript.TOOL_BUTTON_DISABLED_TEXT_COLOR, "tool button should use configured disabled text color")


func _verify_line_edit() -> void:
	var input := LineEdit.new()
	_created_controls.append(input)
	DeveloperUiHelpersScript.style_line_edit(input)
	_expect(input.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == DeveloperUiHelpersConfigScript.LINE_EDIT_FONT_SIZE, "line edit should use configured font size")
	_expect(input.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == DeveloperUiHelpersConfigScript.LINE_EDIT_TEXT_COLOR, "line edit should use configured text color")
	_expect(input.get_theme_color(TextThemeHelpersScript.THEME_FONT_PLACEHOLDER_COLOR) == DeveloperUiHelpersConfigScript.LINE_EDIT_PLACEHOLDER_COLOR, "line edit should use configured placeholder color")
	var normal_style := StyleboxThemeHelpersScript.get_style(input, StyleboxThemeHelpersScript.STYLE_NORMAL) as StyleBoxFlat
	_expect(normal_style != null and normal_style.content_margin_left == DeveloperUiHelpersConfigScript.LINE_EDIT_CONTENT_MARGIN_X, "line edit should use configured content margin")


func _verify_panel_and_button_styles() -> void:
	var panel_style := DeveloperUiHelpersScript.panel_style(Color("#123456"), Color("#abcdef"))
	_expect(panel_style.bg_color == Color("#123456"), "panel style should use requested background")
	_expect(panel_style.border_color == Color("#abcdef"), "panel style should use requested border")
	_expect(panel_style.corner_radius_top_left == DeveloperUiHelpersConfigScript.PANEL_RADIUS, "panel style should use configured radius")
	_expect(panel_style.shadow_size == DeveloperUiHelpersConfigScript.PANEL_SHADOW_SIZE, "panel style should use configured shadow")
	var panel := PanelContainer.new()
	_created_controls.append(panel)
	DeveloperUiHelpersScript.apply_panel_style(panel, Color("#123456"), Color("#abcdef"))
	var applied_panel_style := StyleboxThemeHelpersScript.get_style(panel, StyleboxThemeHelpersScript.STYLE_PANEL) as StyleBoxFlat
	_expect(applied_panel_style != null and applied_panel_style.bg_color == Color("#123456"), "panel helper should apply requested background")

	var button_style := DeveloperUiHelpersScript.button_style(Color("#123456"), Color("#abcdef"))
	_expect(button_style.shadow_size == 0, "button style should remove panel shadow")
	_expect(button_style.content_margin_left == DeveloperUiHelpersConfigScript.BUTTON_CONTENT_MARGIN_X, "button style should use configured horizontal content margin")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
