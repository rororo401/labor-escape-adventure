extends "res://scripts/tests/test_scene_tree.gd"

const VnTopHudScript := preload("res://scripts/ui/vn_top_hud.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")
const HudStatusBarsConfigScript := preload("res://scripts/ui/hud_status_bars_config.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var host := Control.new()
	root.add_child(host)

	var hud := VnTopHudScript.add_to(host, "테스트 날짜", true, {
		VnTopHudConfigScript.OPTION_STATUS: {
			PlayerStatusKeysScript.KEY_HEALTH: 87,
			PlayerStatusKeysScript.KEY_MOOD: 53,
			PlayerStatusKeysScript.KEY_FATIGUE: 19
		}
	})
	var panel_image := hud.get(VnTopHudConfigScript.KEY_PANEL_IMAGE) as TextureRect
	var date_label := hud.get(VnTopHudConfigScript.KEY_DATE_LABEL) as Label
	var status_bars: Dictionary = hud.get(VnTopHudConfigScript.KEY_STATUS_BARS, {})
	var button_row_from_refs := hud.get(VnTopHudConfigScript.KEY_BUTTON_ROW) as HBoxContainer
	var auto_button := hud.get(VnTopHudConfigScript.KEY_AUTO_BUTTON) as Button
	var menu_button := hud.get(VnTopHudConfigScript.KEY_MENU_BUTTON) as TextureButton
	var settings_button := hud.get(VnTopHudConfigScript.KEY_SETTINGS_BUTTON) as TextureButton
	var status_bars_root := _helpers.find_node(host, HudStatusBarsConfigScript.ROOT_NAME) as Control
	_expect(panel_image != null, "VN top HUD should create an image panel")
	_expect(panel_image.position == VnTopHudConfigScript.PANEL_POSITION, "VN top HUD should use configured panel position")
	_expect(panel_image.texture != null, "VN top HUD should load the image panel texture")
	_expect(date_label != null, "VN top HUD should create a date label")
	_expect(date_label.text == "테스트 날짜", "VN top HUD should set date text")
	_expect(date_label.position == VnTopHudConfigScript.DATE_LABEL_POSITION, "VN top HUD should use configured date position")
	_expect(date_label.size == Vector2(VnTopHudConfigScript.DATE_LABEL_WIDTH, VnTopHudConfigScript.DATE_LABEL_HEIGHT), "VN top HUD should use configured date size")
	_expect(date_label.get_theme_color(TextThemeHelpersScript.THEME_FONT_OUTLINE_COLOR) == VnTopHudConfigScript.DATE_OUTLINE_COLOR, "VN top HUD should use configured date outline")
	_expect(date_label.get_theme_constant(TextThemeHelpersScript.THEME_OUTLINE_SIZE) == VnTopHudConfigScript.DATE_OUTLINE_SIZE, "VN top HUD should use configured outline size")
	var health_row := Dictionary(status_bars.get(PlayerStatusKeysScript.KEY_HEALTH, {}))
	var health_value := health_row.get("value") as Label
	var health_fill := health_row.get("fill") as ColorRect
	_expect(health_value != null and health_value.text == "87", "VN top HUD should render health value")
	_expect(health_fill != null and int(health_fill.size.x) == int(HudStatusBarsConfigScript.BAR_SIZE.x * 0.87), "VN top HUD should render health bar width")
	_expect(status_bars_root != null and status_bars_root.position == VnTopHudConfigScript.STATUS_BARS_POSITION, "VN top HUD should place status bars on the second row")
	var button_row := _helpers.find_node(host, VnTopHudConfigScript.BUTTON_ROW_NAME) as HBoxContainer
	_expect(button_row != null, "VN top HUD should create top buttons when requested")
	_expect(button_row_from_refs == button_row, "VN top HUD should return the button row ref")
	_expect(button_row.position == VnTopHudConfigScript.BUTTON_ROW_POSITION, "VN top HUD should use configured button row position")
	_expect(auto_button != null and auto_button.name == VnTopHudConfigScript.AUTO_BUTTON_NAME, "VN top HUD should create the auto button")
	_expect(auto_button.toggle_mode, "VN top HUD auto button should remain a toggle")
	_expect(auto_button.tooltip_text == VnTopHudConfigScript.AUTO_BUTTON_TOOLTIP, "VN top HUD auto button should explain its behavior")
	_expect(menu_button != null and menu_button.name == VnTopHudConfigScript.MENU_BUTTON_NAME, "VN top HUD should create the menu button")
	_expect(menu_button.custom_minimum_size == VnTopHudConfigScript.TOP_BUTTON_SIZE, "VN top HUD should use configured menu size")
	_expect(menu_button.texture_normal != null and menu_button.texture_hover != null and menu_button.texture_pressed != null, "VN top HUD menu button should use image textures")
	_expect(settings_button != null and settings_button.name == VnTopHudConfigScript.SETTINGS_BUTTON_NAME, "VN top HUD should create the settings button")
	_expect(settings_button.texture_normal != null and settings_button.texture_hover != null and settings_button.texture_pressed != null, "VN top HUD settings button should use image textures")

	var date_only_host := Control.new()
	root.add_child(date_only_host)
	var date_only := VnTopHudScript.add_to(date_only_host, "날짜만", false)
	_expect((date_only.get(VnTopHudConfigScript.KEY_DATE_LABEL) as Label).text == "날짜만", "VN top HUD should create date-only labels")
	_expect(date_only.get(VnTopHudConfigScript.KEY_BUTTON_ROW) == null, "VN top HUD should return null button row in date-only mode")
	_expect(_helpers.find_node(date_only_host, VnTopHudConfigScript.BUTTON_ROW_NAME) == null, "VN top HUD should skip buttons in date-only mode")

	print("VN top HUD smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
