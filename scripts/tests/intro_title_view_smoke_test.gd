extends "res://scripts/tests/test_scene_tree.gd"

const IntroTitleViewScript := preload("res://scripts/ui/intro_title_view.gd")
const IntroScreenConfigScript := preload("res://scripts/ui/intro_screen_config.gd")
const IntroTitleViewConfigScript := preload("res://scripts/ui/intro_title_view_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()
var _start_count := 0
var _continue_count := 0
var _gallery_count := 0
var _developer_count := 0


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	_verify_view_with_developer_button()
	_verify_view_without_developer_button()

	print("Intro title view smoke test passed.")
	finish_test()


func _verify_view_with_developer_button() -> void:
	var host := Control.new()
	root.add_child(host)
	var view = IntroTitleViewScript.new()
	var nodes: Dictionary = view.build(host, {
		IntroTitleViewConfigScript.OPTION_BACKGROUND_PATH: IntroScreenConfigScript.BACKGROUND_PATH,
		IntroTitleViewConfigScript.OPTION_TITLE_LOGO_PATH: IntroScreenConfigScript.TITLE_LOGO_PATH,
		IntroTitleViewConfigScript.OPTION_START_BUTTON_PATH: IntroScreenConfigScript.START_BUTTON_PATH,
		IntroTitleViewConfigScript.OPTION_SHOW_CONTINUE_BUTTON: true,
		IntroTitleViewConfigScript.OPTION_CONTINUE_BUTTON_PATH: IntroScreenConfigScript.CONTINUE_BUTTON_PATH,
		IntroTitleViewConfigScript.OPTION_CONTINUE_TEXT: IntroScreenConfigScript.CONTINUE_TEXT,
		IntroTitleViewConfigScript.OPTION_SHOW_GALLERY_BUTTON: true,
		IntroTitleViewConfigScript.OPTION_GALLERY_BUTTON_PATH: IntroScreenConfigScript.GALLERY_BUTTON_PATH,
		IntroTitleViewConfigScript.OPTION_GALLERY_TEXT: IntroScreenConfigScript.GALLERY_TEXT,
		IntroTitleViewConfigScript.OPTION_SHOW_DEVELOPER_QUICK_LAUNCH: true,
		IntroTitleViewConfigScript.OPTION_DEVELOPER_QUICK_TEXT: IntroScreenConfigScript.DEVELOPER_QUICK_TEXT_PREFIX + IntroScreenConfigScript.DEFAULT_DEVELOPER_RUN_DATE
	}, {
		IntroTitleViewConfigScript.CALLBACK_START_PRESSED: _on_start_pressed,
		IntroTitleViewConfigScript.CALLBACK_CONTINUE_PRESSED: _on_continue_pressed,
		IntroTitleViewConfigScript.CALLBACK_GALLERY_PRESSED: _on_gallery_pressed,
		IntroTitleViewConfigScript.CALLBACK_DEVELOPER_QUICK_LAUNCH_PRESSED: _on_developer_pressed
	})

	_expect(nodes.get(IntroTitleViewConfigScript.KEY_TITLE_LOGO, null) != null, "view should return title logo")
	_expect(nodes.get(IntroTitleViewConfigScript.KEY_START_BUTTON_FRAME, null) != null, "view should return start button frame")
	var start_button := nodes.get(IntroTitleViewConfigScript.KEY_START_BUTTON, null) as Button
	var continue_button := nodes.get(IntroTitleViewConfigScript.KEY_CONTINUE_BUTTON, null) as Button
	var gallery_button := nodes.get(IntroTitleViewConfigScript.KEY_GALLERY_BUTTON, null) as Button
	var developer_button := nodes.get(IntroTitleViewConfigScript.KEY_DEVELOPER_QUICK_BUTTON, null) as Button
	_expect(start_button != null, "view should return start button")
	_expect(continue_button != null, "view should return continue button when enabled")
	_expect(gallery_button != null, "view should return gallery button when enabled")
	_expect(developer_button != null, "view should return developer quick button when enabled")
	_expect(start_button.accessibility_name == IntroTitleViewConfigScript.START_ACCESSIBILITY_TEXT, "image start button should expose an accessible name")
	_expect(continue_button.accessibility_name == IntroScreenConfigScript.CONTINUE_TEXT, "image continue button should expose its visible meaning")
	_expect(gallery_button.accessibility_name == IntroScreenConfigScript.GALLERY_TEXT, "image gallery button should expose its visible meaning")
	var content := _helpers.find_node(host, IntroTitleViewConfigScript.CONTENT_NAME) as MarginContainer
	var layout := _helpers.find_node(host, IntroTitleViewConfigScript.LAYOUT_NAME) as VBoxContainer
	var title_logo := _helpers.find_node(host, IntroTitleViewConfigScript.TITLE_LOGO_NAME) as TextureRect
	var start_frame := _helpers.find_node(host, IntroTitleViewConfigScript.START_BUTTON_FRAME_NAME) as Control
	var continue_frame := _helpers.find_node(host, IntroTitleViewConfigScript.CONTINUE_BUTTON_FRAME_NAME) as Control
	var continue_image := _helpers.find_node(host, IntroTitleViewConfigScript.CONTINUE_BUTTON_IMAGE_NAME) as TextureRect
	var gallery_frame := _helpers.find_node(host, IntroTitleViewConfigScript.GALLERY_BUTTON_FRAME_NAME) as Control
	var gallery_image := _helpers.find_node(host, IntroTitleViewConfigScript.GALLERY_BUTTON_IMAGE_NAME) as TextureRect
	_expect(_helpers.find_node(host, IntroTitleViewConfigScript.BACKGROUND_NAME) != null, "view should add background node")
	_expect(content != null, "view should add content node")
	_expect(layout != null and layout.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == IntroTitleViewConfigScript.LAYOUT_SEPARATION, "view should use configured layout separation")
	_expect(title_logo != null and title_logo.custom_minimum_size == IntroTitleViewConfigScript.TITLE_LOGO_SIZE, "view should add configured title logo")
	_expect(start_frame != null and start_frame.custom_minimum_size == IntroTitleViewConfigScript.START_BUTTON_FRAME_SIZE, "view should add configured start button frame")
	_expect(_helpers.find_node(host, IntroTitleViewConfigScript.START_BUTTON_HIT_AREA_NAME) != null, "view should add start hit area")
	_expect(continue_frame != null and continue_frame.custom_minimum_size == IntroTitleViewConfigScript.CONTINUE_BUTTON_SIZE, "view should add configured continue image frame")
	_expect(continue_image != null and continue_image.texture != null, "continue button should use an image")
	_expect(continue_button.custom_minimum_size == IntroTitleViewConfigScript.CONTINUE_BUTTON_SIZE, "continue button should use configured size")
	_expect(continue_button.text == "", "continue button copy should be baked into the image")
	_expect(gallery_frame != null and gallery_frame.custom_minimum_size == IntroTitleViewConfigScript.GALLERY_BUTTON_SIZE, "view should add configured gallery image frame")
	_expect(gallery_image != null and gallery_image.texture != null, "gallery button should use an image")
	_expect(gallery_button.custom_minimum_size == IntroTitleViewConfigScript.GALLERY_BUTTON_SIZE, "gallery button should use configured size")
	_expect(gallery_button.text == "", "gallery button copy should be baked into the image")
	_expect(developer_button.custom_minimum_size == IntroTitleViewConfigScript.DEVELOPER_BUTTON_SIZE, "developer button should use configured size")
	_expect(developer_button.text.contains(IntroScreenConfigScript.DEFAULT_DEVELOPER_RUN_DATE), "developer button should show provided run date")

	start_button.emit_signal("pressed")
	continue_button.emit_signal("pressed")
	gallery_button.emit_signal("pressed")
	developer_button.emit_signal("pressed")
	_expect(_start_count == 1, "start button should call provided callback")
	_expect(_continue_count == 1, "continue button should call provided callback")
	_expect(_gallery_count == 1, "gallery button should call provided callback")
	_expect(_developer_count == 1, "developer button should call provided callback")


func _verify_view_without_developer_button() -> void:
	var host := Control.new()
	root.add_child(host)
	var view = IntroTitleViewScript.new()
	var nodes: Dictionary = view.build(host, {
		IntroTitleViewConfigScript.OPTION_BACKGROUND_PATH: IntroScreenConfigScript.BACKGROUND_PATH,
		IntroTitleViewConfigScript.OPTION_TITLE_LOGO_PATH: IntroScreenConfigScript.TITLE_LOGO_PATH,
		IntroTitleViewConfigScript.OPTION_START_BUTTON_PATH: IntroScreenConfigScript.START_BUTTON_PATH,
		IntroTitleViewConfigScript.OPTION_SHOW_GALLERY_BUTTON: false,
		IntroTitleViewConfigScript.OPTION_SHOW_DEVELOPER_QUICK_LAUNCH: false
	}, {})

	_expect(nodes.get(IntroTitleViewConfigScript.KEY_DEVELOPER_QUICK_BUTTON, null) == null, "view should omit developer button when disabled")
	_expect(nodes.get(IntroTitleViewConfigScript.KEY_CONTINUE_BUTTON, null) == null, "view should omit continue button when disabled")
	_expect(nodes.get(IntroTitleViewConfigScript.KEY_GALLERY_BUTTON, null) == null, "view should omit gallery button when disabled")
	_expect(_helpers.find_node(host, IntroTitleViewConfigScript.CONTINUE_BUTTON_NAME) == null, "disabled continue button should not be in tree")
	_expect(_helpers.find_node(host, IntroTitleViewConfigScript.GALLERY_BUTTON_NAME) == null, "disabled gallery button should not be in tree")
	_expect(_helpers.find_node(host, IntroTitleViewConfigScript.DEVELOPER_QUICK_BUTTON_NAME) == null, "disabled developer button should not be in tree")


func _on_start_pressed() -> void:
	_start_count += 1


func _on_continue_pressed() -> void:
	_continue_count += 1


func _on_gallery_pressed() -> void:
	_gallery_count += 1


func _on_developer_pressed() -> void:
	_developer_count += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
