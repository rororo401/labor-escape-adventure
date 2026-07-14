class_name MarketHud
extends Control

signal menu_requested
signal settings_requested

const MarketHudConfigScript := preload("res://scripts/ui/market_hud_config.gd")
const HudStatusBarsScript := preload("res://scripts/ui/hud_status_bars.gd")
const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var _date_label: Label
var _cash_label: Label
var _net_worth_label: Label
var _status_bars := {}


func build() -> void:
	name = MarketHudConfigScript.HUD_NAME
	UiHelpers.apply_full_rect(self)
	UiHelpers.ignore_mouse(self)

	var top_panel := TextureRect.new()
	top_panel.name = MarketHudConfigScript.TOP_PANEL_IMAGE_NAME
	top_panel.position = MarketHudConfigScript.TOP_PANEL_POSITION
	top_panel.size = MarketHudConfigScript.TOP_PANEL_SIZE
	top_panel.texture = UiHelpers.load_texture(MarketHudConfigScript.TOP_PANEL_TEXTURE_PATH)
	top_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	top_panel.stretch_mode = TextureRect.STRETCH_SCALE
	UiHelpers.ignore_mouse(top_panel)
	add_child(top_panel)

	_date_label = MarketUiStyleScript.make_label(MarketHudConfigScript.DATE_LABEL_FONT_SIZE, MarketHudConfigScript.DATE_LABEL_COLOR)
	_date_label.name = MarketHudConfigScript.DATE_LABEL_NAME
	_date_label.position = MarketHudConfigScript.DATE_LABEL_POSITION
	_date_label.size = MarketHudConfigScript.DATE_LABEL_SIZE
	TextThemeHelpersScript.apply_outline(
		_date_label,
		MarketHudConfigScript.DATE_LABEL_OUTLINE_COLOR,
		MarketHudConfigScript.DATE_LABEL_OUTLINE_SIZE
	)
	add_child(_date_label)

	_status_bars = HudStatusBarsScript.add_to(self, {}, MarketHudConfigScript.STATUS_BARS_POSITION)

	var button_row := HBoxContainer.new()
	button_row.name = MarketHudConfigScript.TOP_BUTTONS_NAME
	button_row.position = MarketHudConfigScript.TOP_BUTTONS_POSITION
	button_row.size = MarketHudConfigScript.TOP_BUTTONS_SIZE
	UiHelpers.pass_mouse(button_row)
	PanelLayoutHelpersScript.apply_separation(button_row, MarketHudConfigScript.TOP_BUTTONS_SEPARATION)
	add_child(button_row)
	var menu_button := MarketUiStyleScript.make_top_icon_button(MarketHudConfigScript.MENU_BUTTON_NAME)
	menu_button.tooltip_text = MarketHudConfigScript.MENU_BUTTON_TOOLTIP
	menu_button.accessibility_name = MarketHudConfigScript.MENU_BUTTON_TOOLTIP
	menu_button.pressed.connect(func() -> void:
		menu_requested.emit()
	)
	button_row.add_child(menu_button)
	var settings_button := MarketUiStyleScript.make_top_icon_button(MarketHudConfigScript.SETTINGS_BUTTON_NAME)
	settings_button.tooltip_text = MarketHudConfigScript.SETTINGS_BUTTON_TOOLTIP
	settings_button.accessibility_name = MarketHudConfigScript.SETTINGS_BUTTON_TOOLTIP
	settings_button.pressed.connect(func() -> void:
		settings_requested.emit()
	)
	button_row.add_child(settings_button)
	menu_button.focus_neighbor_right = menu_button.get_path_to(settings_button)
	settings_button.focus_neighbor_left = settings_button.get_path_to(menu_button)

	var status_panel := PanelContainer.new()
	status_panel.name = MarketHudConfigScript.STATUS_PANEL_NAME
	status_panel.position = MarketHudConfigScript.STATUS_PANEL_POSITION
	status_panel.size = MarketHudConfigScript.STATUS_PANEL_SIZE
	UiHelpers.pass_mouse(status_panel)
	StyleboxThemeHelpersScript.apply_panel_style(
		status_panel,
		MarketUiStyleScript.make_panel_style(MarketHudConfigScript.STATUS_PANEL_COLOR, MarketHudConfigScript.STATUS_PANEL_BORDER_COLOR)
	)
	add_child(status_panel)

	var status_row := HBoxContainer.new()
	PanelLayoutHelpersScript.apply_separation(status_row, MarketHudConfigScript.STATUS_ROW_SEPARATION)
	PanelLayoutHelpersScript.apply_theme_margins(status_row, MarketHudConfigScript.STATUS_ROW_MARGIN)
	status_panel.add_child(status_row)

	var cash_slot := Control.new()
	cash_slot.custom_minimum_size = MarketHudConfigScript.STATUS_LABEL_SIZE
	_cash_label = _make_stat_label()
	_cash_label.position = MarketHudConfigScript.STATUS_CASH_LABEL_OFFSET
	_cash_label.size = MarketHudConfigScript.STATUS_LABEL_SIZE - Vector2(MarketHudConfigScript.STATUS_CASH_LABEL_OFFSET.x, 0)
	_net_worth_label = _make_stat_label()
	status_row.add_child(cash_slot)
	cash_slot.add_child(_cash_label)
	status_row.add_child(_net_worth_label)


func set_date_text(text: String) -> void:
	if _date_label != null:
		_date_label.text = text


func set_status_text(cash_text: String, net_worth_text: String) -> void:
	if _cash_label != null:
		_cash_label.text = cash_text
	if _net_worth_label != null:
		_net_worth_label.text = net_worth_text


func set_status_bars(status: Dictionary) -> void:
	HudStatusBarsScript.update(_status_bars, status)


func _make_stat_label() -> Label:
	var label := MarketUiStyleScript.make_label(MarketHudConfigScript.STATUS_LABEL_FONT_SIZE, MarketHudConfigScript.STATUS_LABEL_COLOR)
	label.custom_minimum_size = MarketHudConfigScript.STATUS_LABEL_SIZE
	TextThemeHelpersScript.center_vertical(label)
	return label
