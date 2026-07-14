class_name MarketHudConfig
extends RefCounted

const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")

const HUD_NAME := "MarketHud"
const TOP_PANEL_IMAGE_NAME := VnTopHudConfigScript.PANEL_IMAGE_NAME
const DATE_LABEL_NAME := VnTopHudConfigScript.DATE_LABEL_NAME
const TOP_BUTTONS_NAME := VnTopHudConfigScript.BUTTON_ROW_NAME
const STATUS_PANEL_NAME := "StatusPanel"
const MENU_BUTTON_NAME := VnTopHudConfigScript.MENU_BUTTON_NAME
const SETTINGS_BUTTON_NAME := VnTopHudConfigScript.SETTINGS_BUTTON_NAME
const MENU_BUTTON_TOOLTIP := VnTopHudConfigScript.MENU_BUTTON_TOOLTIP
const SETTINGS_BUTTON_TOOLTIP := VnTopHudConfigScript.SETTINGS_BUTTON_TOOLTIP

const TOP_PANEL_TEXTURE_PATH := VnTopHudConfigScript.PANEL_TEXTURE_PATH
const TOP_PANEL_POSITION := VnTopHudConfigScript.PANEL_POSITION
const TOP_PANEL_SIZE := Vector2(688, 82)

const DATE_LABEL_POSITION := VnTopHudConfigScript.DATE_LABEL_POSITION
const DATE_LABEL_SIZE := Vector2(500, VnTopHudConfigScript.DATE_LABEL_HEIGHT)
const DATE_LABEL_FONT_SIZE := VnTopHudConfigScript.DATE_FONT_SIZE
const DATE_LABEL_COLOR := Color("#4f3b32")
const DATE_LABEL_OUTLINE_COLOR := Color.TRANSPARENT
const DATE_LABEL_OUTLINE_SIZE := 0
const STATUS_BARS_POSITION := VnTopHudConfigScript.STATUS_BARS_POSITION

const TOP_BUTTONS_POSITION := Vector2(572, 24)
const TOP_BUTTONS_SIZE := VnTopHudConfigScript.BUTTON_ROW_SIZE
const TOP_BUTTONS_SEPARATION := VnTopHudConfigScript.BUTTON_ROW_SEPARATION

const STATUS_PANEL_POSITION := Vector2(22, 104)
const STATUS_PANEL_SIZE := Vector2(676, 52)
const STATUS_PANEL_COLOR := Color("#fff7e8de")
const STATUS_PANEL_BORDER_COLOR := Color("#e5a66c")
const STATUS_ROW_SEPARATION := 18
const STATUS_ROW_MARGIN_LEFT := 18
const STATUS_ROW_MARGIN_TOP := 7
const STATUS_ROW_MARGIN_RIGHT := 18
const STATUS_ROW_MARGIN_BOTTOM := 7
const STATUS_ROW_MARGIN := {
	PanelLayoutHelpersScript.KEY_LEFT: STATUS_ROW_MARGIN_LEFT,
	PanelLayoutHelpersScript.KEY_TOP: STATUS_ROW_MARGIN_TOP,
	PanelLayoutHelpersScript.KEY_RIGHT: STATUS_ROW_MARGIN_RIGHT,
	PanelLayoutHelpersScript.KEY_BOTTOM: STATUS_ROW_MARGIN_BOTTOM
}

const STATUS_LABEL_FONT_SIZE := 22
const STATUS_LABEL_COLOR := Color("#3f332e")
const STATUS_LABEL_SIZE := Vector2(315, 38)
const STATUS_CASH_LABEL_OFFSET := Vector2(10, 0)
