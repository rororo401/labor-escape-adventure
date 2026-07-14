extends "res://scripts/tests/test_scene_tree.gd"

const MarketHudConfigScript := preload("res://scripts/ui/market_hud_config.gd")
const MarketHudScript := preload("res://scripts/ui/market_hud.gd")
const HudStatusBarsConfigScript := preload("res://scripts/ui/hud_status_bars_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")


func _initialize() -> void:
	var hud = MarketHudScript.new()
	hud.build()
	root.add_child(hud)
	await process_frame

	var top_panel := hud.get_node_or_null(MarketHudConfigScript.TOP_PANEL_IMAGE_NAME) as TextureRect
	var date_label := hud.get_node_or_null(MarketHudConfigScript.DATE_LABEL_NAME) as Label
	var top_buttons := hud.get_node_or_null(MarketHudConfigScript.TOP_BUTTONS_NAME) as HBoxContainer
	var status_panel := hud.get_node_or_null(MarketHudConfigScript.STATUS_PANEL_NAME) as PanelContainer
	var status_bars_root := hud.get_node_or_null(HudStatusBarsConfigScript.ROOT_NAME) as Control
	_expect(hud.name == MarketHudConfigScript.HUD_NAME, "HUD should use configured node name")
	_expect(top_panel != null and top_panel.texture != null, "HUD should create the top image panel")
	_expect(top_panel.position == MarketHudConfigScript.TOP_PANEL_POSITION, "top image panel should use configured position")
	_expect(date_label != null, "HUD should create the configured date label")
	_expect(date_label.position == MarketHudConfigScript.DATE_LABEL_POSITION, "date label should use configured position")
	_expect(date_label.size == MarketHudConfigScript.DATE_LABEL_SIZE, "date label should use configured size")
	_expect(date_label.get_theme_color(TextThemeHelpersScript.THEME_FONT_OUTLINE_COLOR) == MarketHudConfigScript.DATE_LABEL_OUTLINE_COLOR, "date label should use configured outline color")
	_expect(date_label.get_theme_constant(TextThemeHelpersScript.THEME_OUTLINE_SIZE) == MarketHudConfigScript.DATE_LABEL_OUTLINE_SIZE, "date label should use configured outline size")
	_expect(status_bars_root != null and status_bars_root.position == MarketHudConfigScript.STATUS_BARS_POSITION, "status bars should use configured second-row position")
	_expect(top_buttons != null, "HUD should create configured top button row")
	_expect(top_buttons.position == MarketHudConfigScript.TOP_BUTTONS_POSITION, "top buttons should use configured position")
	var menu_button := top_buttons.get_node_or_null(MarketHudConfigScript.MENU_BUTTON_NAME) as BaseButton
	var settings_button := top_buttons.get_node_or_null(MarketHudConfigScript.SETTINGS_BUTTON_NAME) as BaseButton
	_expect(menu_button != null, "HUD should create configured menu button")
	_expect(settings_button != null, "HUD should create configured settings button")
	_expect(menu_button.tooltip_text == MarketHudConfigScript.MENU_BUTTON_TOOLTIP, "icon-only menu should expose a text description")
	_expect(settings_button.tooltip_text == MarketHudConfigScript.SETTINGS_BUTTON_TOOLTIP, "icon-only settings should expose a text description")
	_expect(not menu_button.focus_neighbor_right.is_empty(), "top buttons should define keyboard focus order")
	_expect(status_panel != null, "HUD should create configured status panel")
	_expect(status_panel.position == MarketHudConfigScript.STATUS_PANEL_POSITION, "status panel should use configured position")
	_expect(status_panel.size == MarketHudConfigScript.STATUS_PANEL_SIZE, "status panel should use configured size")

	hud.set_date_text("2016-07-01 금요일")
	hud.set_status_text("현금 1,000원", "순자산 1,200원")
	hud.set_status_bars({
		PlayerStatusKeysScript.KEY_HEALTH: 75,
		PlayerStatusKeysScript.KEY_MOOD: 45,
		PlayerStatusKeysScript.KEY_FATIGUE: 20
	})
	_expect(date_label.text == "2016-07-01 금요일", "HUD should update date text")
	var fatigue_value := hud.get_node_or_null("%s/%s" % [HudStatusBarsConfigScript.ROOT_NAME, HudStatusBarsConfigScript.VALUE_NAME_FORMAT % [3]]) as Label
	var fatigue_fill := hud.get_node_or_null("%s/%s" % [HudStatusBarsConfigScript.ROOT_NAME, HudStatusBarsConfigScript.BAR_FILL_NAME_FORMAT % [3]]) as ColorRect
	_expect(fatigue_value != null and fatigue_value.text == "20", "HUD should update fatigue value")
	_expect(fatigue_fill != null and int(fatigue_fill.size.x) == int(HudStatusBarsConfigScript.BAR_SIZE.x * 0.2), "HUD should update fatigue bar width")

	var status_row := status_panel.get_child(0) as HBoxContainer
	_expect(status_row != null, "HUD should create a status row")
	_expect(status_row.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_LEFT) == int(MarketHudConfigScript.STATUS_ROW_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)), "status row should use configured left margin")
	_expect(status_row.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_BOTTOM) == int(MarketHudConfigScript.STATUS_ROW_MARGIN.get(PanelLayoutHelpersScript.KEY_BOTTOM, 0)), "status row should use configured bottom margin")
	_expect(status_row.get_child_count() == 2, "HUD should create cash and net-worth labels")
	var cash_slot := status_row.get_child(0) as Control
	var cash_label := cash_slot.get_child(0) as Label
	var net_worth_label := status_row.get_child(1) as Label
	_expect(cash_label.text == "현금 1,000원", "HUD should update cash label")
	_expect(cash_label.position == MarketHudConfigScript.STATUS_CASH_LABEL_OFFSET, "HUD should offset the cash label inside its slot")
	_expect(net_worth_label.text == "순자산 1,200원", "HUD should update net-worth label")
	_expect(cash_slot.custom_minimum_size == MarketHudConfigScript.STATUS_LABEL_SIZE, "cash slot should preserve configured size")
	_expect(net_worth_label.custom_minimum_size == MarketHudConfigScript.STATUS_LABEL_SIZE, "status labels should use configured size")

	print("Market HUD smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
