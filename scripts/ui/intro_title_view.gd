class_name IntroTitleView
extends RefCounted

const IntroTitleViewConfigScript := preload("res://scripts/ui/intro_title_view_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")


func build(parent: Control, options: Dictionary, callbacks: Dictionary = {}) -> Dictionary:
	var layout := _build_layout(parent, String(options.get(IntroTitleViewConfigScript.OPTION_BACKGROUND_PATH, "")))
	var title_logo := _add_title_logo(layout, String(options.get(IntroTitleViewConfigScript.OPTION_TITLE_LOGO_PATH, "")))
	var start_frame := _add_start_button(
		layout,
		String(options.get(IntroTitleViewConfigScript.OPTION_START_BUTTON_PATH, "")),
		callbacks.get(IntroTitleViewConfigScript.CALLBACK_START_PRESSED, Callable())
	)
	var continue_button: Button = null
	if bool(options.get(IntroTitleViewConfigScript.OPTION_SHOW_CONTINUE_BUTTON, false)):
		continue_button = _add_continue_button(
			layout,
			String(options.get(IntroTitleViewConfigScript.OPTION_CONTINUE_BUTTON_PATH, "")),
			String(options.get(IntroTitleViewConfigScript.OPTION_CONTINUE_TEXT, "이어하기")),
			callbacks.get(IntroTitleViewConfigScript.CALLBACK_CONTINUE_PRESSED, Callable())
		)
	var gallery_button: Button = null
	if bool(options.get(IntroTitleViewConfigScript.OPTION_SHOW_GALLERY_BUTTON, true)):
		gallery_button = _add_gallery_button(
			layout,
			String(options.get(IntroTitleViewConfigScript.OPTION_GALLERY_BUTTON_PATH, "")),
			String(options.get(IntroTitleViewConfigScript.OPTION_GALLERY_TEXT, "앨범")),
			callbacks.get(IntroTitleViewConfigScript.CALLBACK_GALLERY_PRESSED, Callable())
		)
	var developer_button: Button = null
	if bool(options.get(IntroTitleViewConfigScript.OPTION_SHOW_DEVELOPER_QUICK_LAUNCH, false)):
		developer_button = _add_developer_quick_launch(
			layout,
			String(options.get(IntroTitleViewConfigScript.OPTION_DEVELOPER_QUICK_TEXT, "")),
			callbacks.get(IntroTitleViewConfigScript.CALLBACK_DEVELOPER_QUICK_LAUNCH_PRESSED, Callable())
		)
	return {
		IntroTitleViewConfigScript.KEY_TITLE_LOGO: title_logo,
		IntroTitleViewConfigScript.KEY_START_BUTTON_FRAME: start_frame.get(IntroTitleViewConfigScript.KEY_INTERNAL_FRAME, null),
		IntroTitleViewConfigScript.KEY_START_BUTTON: start_frame.get(IntroTitleViewConfigScript.KEY_INTERNAL_BUTTON, null),
		IntroTitleViewConfigScript.KEY_CONTINUE_BUTTON: continue_button,
		IntroTitleViewConfigScript.KEY_GALLERY_BUTTON: gallery_button,
		IntroTitleViewConfigScript.KEY_DEVELOPER_QUICK_BUTTON: developer_button
	}


func _build_layout(parent: Control, background_path: String) -> VBoxContainer:
	var background := TextureRect.new()
	background.name = IntroTitleViewConfigScript.BACKGROUND_NAME
	UiHelpers.apply_cover_texture(background, background_path)
	parent.add_child(background)

	var root := MarginContainer.new()
	root.name = IntroTitleViewConfigScript.CONTENT_NAME
	UiHelpers.apply_full_rect(root)
	PanelLayoutHelpersScript.apply_margins(root, IntroTitleViewConfigScript.CONTENT_MARGIN)
	parent.add_child(root)

	var layout := VBoxContainer.new()
	layout.name = IntroTitleViewConfigScript.LAYOUT_NAME
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	PanelLayoutHelpersScript.apply_separation(layout, IntroTitleViewConfigScript.LAYOUT_SEPARATION)
	root.add_child(layout)

	var top_spacer := Control.new()
	top_spacer.custom_minimum_size = IntroTitleViewConfigScript.TOP_SPACER_SIZE
	layout.add_child(top_spacer)
	return layout


func _add_title_logo(layout: VBoxContainer, title_logo_path: String) -> TextureRect:
	var title_logo := TextureRect.new()
	title_logo.name = IntroTitleViewConfigScript.TITLE_LOGO_NAME
	title_logo.texture = UiHelpers.load_texture(title_logo_path)
	title_logo.custom_minimum_size = IntroTitleViewConfigScript.TITLE_LOGO_SIZE
	title_logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	title_logo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	title_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	layout.add_child(title_logo)

	var middle_spacer := Control.new()
	middle_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(middle_spacer)
	return title_logo


func _add_start_button(layout: VBoxContainer, start_button_path: String, pressed_callback: Callable) -> Dictionary:
	return _add_image_menu_button(
		layout,
		IntroTitleViewConfigScript.START_BUTTON_FRAME_NAME,
		IntroTitleViewConfigScript.START_BUTTON_IMAGE_NAME,
		IntroTitleViewConfigScript.START_BUTTON_HIT_AREA_NAME,
		start_button_path,
		IntroTitleViewConfigScript.START_BUTTON_FRAME_SIZE,
		IntroTitleViewConfigScript.START_ACCESSIBILITY_TEXT,
		pressed_callback
	)


func _add_developer_quick_launch(layout: VBoxContainer, text: String, pressed_callback: Callable) -> Button:
	return _add_text_menu_button(
		layout,
		IntroTitleViewConfigScript.DEVELOPER_QUICK_BUTTON_NAME,
		text,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_SIZE,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_FONT_SIZE,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_TEXT_COLOR,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_DISABLED_TEXT_COLOR,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_NORMAL_COLOR,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_NORMAL_BORDER,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_HOVER_COLOR,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_HOVER_BORDER,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_PRESSED_COLOR,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_PRESSED_BORDER,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_DISABLED_COLOR,
		IntroTitleViewConfigScript.DEVELOPER_BUTTON_DISABLED_BORDER,
		pressed_callback
	)


func _add_continue_button(layout: VBoxContainer, button_path: String, accessibility_text: String, pressed_callback: Callable) -> Button:
	var frame := _add_image_menu_button(
		layout,
		IntroTitleViewConfigScript.CONTINUE_BUTTON_FRAME_NAME,
		IntroTitleViewConfigScript.CONTINUE_BUTTON_IMAGE_NAME,
		IntroTitleViewConfigScript.CONTINUE_BUTTON_NAME,
		button_path,
		IntroTitleViewConfigScript.CONTINUE_BUTTON_SIZE,
		accessibility_text,
		pressed_callback
	)
	return frame.get(IntroTitleViewConfigScript.KEY_INTERNAL_BUTTON, null) as Button


func _add_gallery_button(layout: VBoxContainer, button_path: String, accessibility_text: String, pressed_callback: Callable) -> Button:
	var frame := _add_image_menu_button(
		layout,
		IntroTitleViewConfigScript.GALLERY_BUTTON_FRAME_NAME,
		IntroTitleViewConfigScript.GALLERY_BUTTON_IMAGE_NAME,
		IntroTitleViewConfigScript.GALLERY_BUTTON_NAME,
		button_path,
		IntroTitleViewConfigScript.GALLERY_BUTTON_SIZE,
		accessibility_text,
		pressed_callback
	)
	return frame.get(IntroTitleViewConfigScript.KEY_INTERNAL_BUTTON, null) as Button


func _add_image_menu_button(
	layout: VBoxContainer,
	frame_name: String,
	image_name: String,
	button_name: String,
	image_path: String,
	minimum_size: Vector2,
	accessibility_text: String,
	pressed_callback: Callable
) -> Dictionary:
	var frame := Control.new()
	frame.name = frame_name
	frame.custom_minimum_size = minimum_size
	frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	layout.add_child(frame)

	var image := TextureRect.new()
	image.name = image_name
	image.texture = UiHelpers.load_texture(image_path)
	UiHelpers.apply_full_rect(image)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.add_child(image)

	var button := Button.new()
	button.name = button_name
	button.text = ""
	button.accessibility_name = accessibility_text
	button.tooltip_text = accessibility_text
	button.custom_minimum_size = minimum_size
	UiHelpers.apply_full_rect(button)
	button.focus_mode = Control.FOCUS_ALL
	StyleboxThemeHelpersScript.apply_button_styles(
		button,
		_empty_style(),
		_empty_style(),
		_empty_style(),
		_empty_style()
	)
	StyleboxThemeHelpersScript.apply_style(button, StyleboxThemeHelpersScript.STYLE_FOCUS, _focus_style())
	if pressed_callback.is_valid():
		button.pressed.connect(pressed_callback)
	frame.add_child(button)

	return {
		IntroTitleViewConfigScript.KEY_INTERNAL_FRAME: frame,
		IntroTitleViewConfigScript.KEY_INTERNAL_BUTTON: button
	}


func _add_text_menu_button(
	layout: VBoxContainer,
	button_name: String,
	text: String,
	minimum_size: Vector2,
	font_size: int,
	text_color: Color,
	disabled_text_color: Color,
	normal_color: Color,
	normal_border: Color,
	hover_color: Color,
	hover_border: Color,
	pressed_color: Color,
	pressed_border: Color,
	disabled_color: Color,
	disabled_border: Color,
	pressed_callback: Callable
) -> Button:
	var button := Button.new()
	button.name = button_name
	button.text = text
	button.custom_minimum_size = minimum_size
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	TextThemeHelpersScript.apply_ui_text_style(button, font_size, text_color)
	TextThemeHelpersScript.apply_disabled_font_color(button, disabled_text_color)
	StyleboxThemeHelpersScript.apply_button_styles(
		button,
		UiHelpers.button_style(normal_color, normal_border),
		UiHelpers.button_style(hover_color, hover_border),
		UiHelpers.button_style(pressed_color, pressed_border),
		UiHelpers.button_style(disabled_color, disabled_border)
	)
	if pressed_callback.is_valid():
		button.pressed.connect(pressed_callback)
	layout.add_child(button)
	return button


func _empty_style() -> StyleBoxEmpty:
	return StyleBoxEmpty.new()


func _focus_style() -> StyleBoxFlat:
	return StyleboxThemeHelpersScript.make_flat_style(
		Color("#00000000"),
		IntroTitleViewConfigScript.FOCUS_BORDER_COLOR,
		IntroTitleViewConfigScript.FOCUS_BORDER_WIDTH,
		IntroTitleViewConfigScript.FOCUS_CORNER_RADIUS
	)
