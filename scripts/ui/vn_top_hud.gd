class_name VnTopHud
extends RefCounted

const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")
const HudStatusBarsScript := preload("res://scripts/ui/hud_status_bars.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")


static func add_to(parent: Control, date_text: String, show_buttons: bool = true, options: Dictionary = {}) -> Dictionary:
	var panel_image := TextureRect.new()
	panel_image.name = VnTopHudConfigScript.PANEL_IMAGE_NAME
	panel_image.position = options.get(VnTopHudConfigScript.OPTION_PANEL_POSITION, VnTopHudConfigScript.PANEL_POSITION)
	panel_image.size = VnTopHudConfigScript.PANEL_SIZE
	panel_image.texture = UiHelpers.load_texture(VnTopHudConfigScript.PANEL_TEXTURE_PATH)
	panel_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel_image.stretch_mode = TextureRect.STRETCH_SCALE
	UiHelpers.ignore_mouse(panel_image)
	parent.add_child(panel_image)

	var date_label := Label.new()
	date_label.name = String(options.get(VnTopHudConfigScript.OPTION_DATE_LABEL_NAME, VnTopHudConfigScript.DATE_LABEL_NAME))
	date_label.text = date_text
	date_label.position = options.get(VnTopHudConfigScript.OPTION_DATE_POSITION, VnTopHudConfigScript.DATE_LABEL_POSITION)
	date_label.size = Vector2(float(options.get(VnTopHudConfigScript.OPTION_DATE_WIDTH, VnTopHudConfigScript.DATE_LABEL_WIDTH)), VnTopHudConfigScript.DATE_LABEL_HEIGHT)
	TextThemeHelpersScript.apply_ui_text_style(
		date_label,
		int(options.get(VnTopHudConfigScript.OPTION_DATE_FONT_SIZE, VnTopHudConfigScript.DATE_FONT_SIZE)),
		VnTopHudConfigScript.DATE_TEXT_COLOR
	)
	TextThemeHelpersScript.apply_outline(
		date_label,
		VnTopHudConfigScript.DATE_OUTLINE_COLOR,
		VnTopHudConfigScript.DATE_OUTLINE_SIZE
	)
	parent.add_child(date_label)

	var status_bars := {}
	if bool(options.get(VnTopHudConfigScript.OPTION_SHOW_STATUS_BARS, true)):
		status_bars = HudStatusBarsScript.add_to(
			parent,
			Dictionary(options.get(VnTopHudConfigScript.OPTION_STATUS, {})),
			options.get(VnTopHudConfigScript.OPTION_STATUS_BARS_POSITION, VnTopHudConfigScript.STATUS_BARS_POSITION)
		)

	var button_row: HBoxContainer = null
	var auto_button: Button = null
	var menu_button: TextureButton = null
	var settings_button: TextureButton = null
	if show_buttons:
		button_row = HBoxContainer.new()
		button_row.name = String(options.get(VnTopHudConfigScript.OPTION_BUTTON_ROW_NAME, VnTopHudConfigScript.BUTTON_ROW_NAME))
		button_row.position = options.get(VnTopHudConfigScript.OPTION_BUTTON_ROW_POSITION, VnTopHudConfigScript.BUTTON_ROW_POSITION)
		button_row.size = VnTopHudConfigScript.BUTTON_ROW_SIZE
		PanelLayoutHelpersScript.apply_separation(button_row, VnTopHudConfigScript.BUTTON_ROW_SEPARATION)
		parent.add_child(button_row)

		auto_button = make_auto_button()
		menu_button = make_top_button(
			VnTopHudConfigScript.MENU_BUTTON_NAME,
			VnTopHudConfigScript.MENU_BUTTON_NORMAL_TEXTURE_PATH,
			VnTopHudConfigScript.MENU_BUTTON_HOVER_TEXTURE_PATH,
			VnTopHudConfigScript.MENU_BUTTON_PRESSED_TEXTURE_PATH
		)
		settings_button = make_top_button(
			VnTopHudConfigScript.SETTINGS_BUTTON_NAME,
			VnTopHudConfigScript.SETTINGS_BUTTON_NORMAL_TEXTURE_PATH,
			VnTopHudConfigScript.SETTINGS_BUTTON_HOVER_TEXTURE_PATH,
			VnTopHudConfigScript.SETTINGS_BUTTON_PRESSED_TEXTURE_PATH
		)
		menu_button.tooltip_text = VnTopHudConfigScript.MENU_BUTTON_TOOLTIP
		menu_button.accessibility_name = VnTopHudConfigScript.MENU_BUTTON_TOOLTIP
		settings_button.tooltip_text = VnTopHudConfigScript.SETTINGS_BUTTON_TOOLTIP
		settings_button.accessibility_name = VnTopHudConfigScript.SETTINGS_BUTTON_TOOLTIP
		auto_button.accessibility_name = VnTopHudConfigScript.AUTO_BUTTON_TOOLTIP
		button_row.add_child(auto_button)
		button_row.add_child(menu_button)
		button_row.add_child(settings_button)
		auto_button.focus_neighbor_right = auto_button.get_path_to(menu_button)
		menu_button.focus_neighbor_left = menu_button.get_path_to(auto_button)
		menu_button.focus_neighbor_right = menu_button.get_path_to(settings_button)
		settings_button.focus_neighbor_left = settings_button.get_path_to(menu_button)

	return {
		VnTopHudConfigScript.KEY_PANEL_IMAGE: panel_image,
		VnTopHudConfigScript.KEY_DATE_LABEL: date_label,
		VnTopHudConfigScript.KEY_STATUS_BARS: status_bars,
		VnTopHudConfigScript.KEY_BUTTON_ROW: button_row,
		VnTopHudConfigScript.KEY_AUTO_BUTTON: auto_button,
		VnTopHudConfigScript.KEY_MENU_BUTTON: menu_button,
		VnTopHudConfigScript.KEY_SETTINGS_BUTTON: settings_button
	}


static func make_auto_button() -> Button:
	var button := Button.new()
	button.name = VnTopHudConfigScript.AUTO_BUTTON_NAME
	button.text = VnTopHudConfigScript.AUTO_BUTTON_TEXT
	button.custom_minimum_size = VnTopHudConfigScript.AUTO_BUTTON_SIZE
	button.toggle_mode = true
	button.tooltip_text = VnTopHudConfigScript.AUTO_BUTTON_TOOLTIP
	button.focus_mode = Control.FOCUS_ALL
	TextThemeHelpersScript.apply_ui_text_style(
		button,
		VnTopHudConfigScript.AUTO_BUTTON_FONT_SIZE,
		VnTopHudConfigScript.AUTO_BUTTON_TEXT_COLOR
	)
	button.add_theme_color_override("font_pressed_color", VnTopHudConfigScript.AUTO_BUTTON_ON_TEXT_COLOR)
	button.add_theme_color_override("font_hover_pressed_color", VnTopHudConfigScript.AUTO_BUTTON_ON_TEXT_COLOR)
	button.add_theme_stylebox_override("normal", UiHelpers.button_style(VnTopHudConfigScript.AUTO_BUTTON_NORMAL_COLOR, VnTopHudConfigScript.AUTO_BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("hover", UiHelpers.button_style(VnTopHudConfigScript.AUTO_BUTTON_HOVER_COLOR, VnTopHudConfigScript.AUTO_BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("pressed", UiHelpers.button_style(VnTopHudConfigScript.AUTO_BUTTON_PRESSED_COLOR, VnTopHudConfigScript.AUTO_BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("hover_pressed", UiHelpers.button_style(VnTopHudConfigScript.AUTO_BUTTON_PRESSED_COLOR.lightened(0.05), VnTopHudConfigScript.AUTO_BUTTON_BORDER_COLOR))
	return button


static func make_top_button(node_name: String, normal_path: String, hover_path: String, pressed_path: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.custom_minimum_size = VnTopHudConfigScript.TOP_BUTTON_SIZE
	button.focus_mode = Control.FOCUS_ALL
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_normal = UiHelpers.load_texture(normal_path)
	button.texture_hover = UiHelpers.load_texture(hover_path)
	button.texture_pressed = UiHelpers.load_texture(pressed_path)
	return button
