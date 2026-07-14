extends "res://scripts/tests/test_scene_tree.gd"

const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")


func _initialize() -> void:
	_verify_control_helpers()
	_verify_style_helpers()
	_verify_font_helpers()

	print("UI helpers smoke test passed.")
	finish_test()


func _verify_control_helpers() -> void:
	var control := Control.new()
	UiHelpers.apply_full_rect(control)
	_expect(control.anchor_left == 0.0, "full-rect helper should anchor left")
	_expect(control.anchor_top == 0.0, "full-rect helper should anchor top")
	_expect(control.anchor_right == 1.0, "full-rect helper should anchor right")
	_expect(control.anchor_bottom == 1.0, "full-rect helper should anchor bottom")

	UiHelpers.ignore_mouse(control)
	_expect(control.mouse_filter == Control.MOUSE_FILTER_IGNORE, "ignore-mouse helper should apply ignore filter")
	UiHelpers.pass_mouse(control)
	_expect(control.mouse_filter == Control.MOUSE_FILTER_PASS, "pass-mouse helper should apply pass filter")
	UiHelpers.stop_mouse(control)
	_expect(control.mouse_filter == Control.MOUSE_FILTER_STOP, "stop-mouse helper should apply stop filter")

	var scroll := ScrollContainer.new()
	UiHelpers.disable_horizontal_scroll(scroll)
	_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "scroll helper should disable horizontal scrolling")

	var texture_rect := TextureRect.new()
	UiHelpers.apply_cover_texture(texture_rect)
	_expect(texture_rect.expand_mode == TextureRect.EXPAND_IGNORE_SIZE, "cover-texture helper should ignore source size")
	_expect(texture_rect.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "cover-texture helper should keep aspect covered")
	_expect(texture_rect.anchor_right == 1.0 and texture_rect.anchor_bottom == 1.0, "cover-texture helper should apply full rect")

	control.free()
	scroll.free()
	texture_rect.free()


func _verify_style_helpers() -> void:
	var panel := UiHelpers.panel_style(Color("#101010"), Color("#202020"))
	_expect(panel.bg_color == Color("#101010"), "panel style should preserve background color")
	_expect(panel.border_color == Color("#202020"), "panel style should preserve border color")

	var button := UiHelpers.button_style(Color("#303030"), Color("#404040"), 16)
	_expect(button.bg_color == Color("#303030"), "button style should preserve background color")
	_expect(button.content_margin_left == 16 and button.content_margin_right == 16, "button style should apply horizontal margins")


func _verify_font_helpers() -> void:
	_expect(UiHelpers.DEFAULT_UI_FONT_PATH.ends_with("Pretendard-Regular.otf"), "default UI font should use Pretendard")
	_expect(ResourceLoader.exists(UiHelpers.DEFAULT_UI_FONT_PATH), "default UI font should be bundled")
	_expect(UiHelpers.make_ui_font() != null, "default UI font helper should return a font")
	_expect(ResourceLoader.exists(UiHelpers.NAME_TAG_FONT_PATH), "name tag font should be bundled")
	_expect(UiHelpers.make_name_tag_font() != null, "name tag font helper should return a font")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
