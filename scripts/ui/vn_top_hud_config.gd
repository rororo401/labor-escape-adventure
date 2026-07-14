class_name VnTopHudConfig
extends RefCounted

const UiCommonNodeNamesScript := preload("res://scripts/ui/ui_common_node_names.gd")

const DATE_LABEL_NAME := UiCommonNodeNamesScript.DATE_LABEL_NAME
const PANEL_IMAGE_NAME := "TopStatusPanelImage"
const BUTTON_ROW_NAME := "TopButtons"
const MENU_BUTTON_NAME := "MenuButton"
const SETTINGS_BUTTON_NAME := "SettingsButton"
const AUTO_BUTTON_NAME := "AutoAdvanceButton"

const KEY_PANEL_IMAGE := "panel_image"
const KEY_DATE_LABEL := "date_label"
const KEY_STATUS_BARS := "status_bars"
const KEY_BUTTON_ROW := "button_row"
const KEY_MENU_BUTTON := "menu_button"
const KEY_SETTINGS_BUTTON := "settings_button"
const KEY_AUTO_BUTTON := "auto_button"

const OPTION_STATUS := "status"
const OPTION_SHOW_STATUS_BARS := "show_status_bars"
const OPTION_DATE_LABEL_NAME := "date_label_name"
const OPTION_DATE_POSITION := "date_position"
const OPTION_DATE_WIDTH := "date_width"
const OPTION_DATE_FONT_SIZE := "date_font_size"
const OPTION_PANEL_POSITION := "panel_position"
const OPTION_STATUS_BARS_POSITION := "status_bars_position"
const OPTION_BUTTON_ROW_NAME := "button_row_name"
const OPTION_BUTTON_ROW_POSITION := "button_row_position"

const PANEL_TEXTURE_PATH := "res://assets/ui/top_status_panel_v2.png"
const MENU_BUTTON_NORMAL_TEXTURE_PATH := "res://assets/ui/top_buttons/menu_symbol_normal.png"
const MENU_BUTTON_HOVER_TEXTURE_PATH := "res://assets/ui/top_buttons/menu_symbol_hover.png"
const MENU_BUTTON_PRESSED_TEXTURE_PATH := "res://assets/ui/top_buttons/menu_symbol_pressed.png"
const SETTINGS_BUTTON_NORMAL_TEXTURE_PATH := "res://assets/ui/top_buttons/settings_symbol_normal.png"
const SETTINGS_BUTTON_HOVER_TEXTURE_PATH := "res://assets/ui/top_buttons/settings_symbol_hover.png"
const SETTINGS_BUTTON_PRESSED_TEXTURE_PATH := "res://assets/ui/top_buttons/settings_symbol_pressed.png"
const PANEL_POSITION := Vector2(16, 14)
const PANEL_SIZE := Vector2(688, 82)

const DATE_LABEL_POSITION := Vector2(44, 26)
const DATE_LABEL_WIDTH := 500.0
const DATE_LABEL_HEIGHT := 28.0
const DATE_FONT_SIZE := 20
const DATE_TEXT_COLOR := Color("#4f3b32")
const DATE_OUTLINE_COLOR := Color("#fff8e9")
const DATE_OUTLINE_SIZE := 1
const STATUS_BARS_POSITION := Vector2(44, 54)

const BUTTON_ROW_POSITION := Vector2(480, 24)
const BUTTON_ROW_SIZE := Vector2(224, 62)
const BUTTON_ROW_SEPARATION := 8

const TOP_BUTTON_SIZE := Vector2(62, 62)
const AUTO_BUTTON_SIZE := Vector2(76, 62)
const AUTO_BUTTON_TEXT := "자동"
const AUTO_BUTTON_ON_TEXT := "자동 켬"
const AUTO_BUTTON_FONT_SIZE := 15
const AUTO_BUTTON_TEXT_COLOR := Color("#5f443b")
const AUTO_BUTTON_ON_TEXT_COLOR := Color("#fffaf2")
const AUTO_BUTTON_NORMAL_COLOR := Color("#fff8eacc")
const AUTO_BUTTON_HOVER_COLOR := Color("#fffdf6ee")
const AUTO_BUTTON_PRESSED_COLOR := Color("#527a79")
const AUTO_BUTTON_BORDER_COLOR := Color("#d89c68")
const AUTO_BUTTON_TOOLTIP := "대사가 끝나면 다음 줄로 자동 진행"
const MENU_BUTTON_TOOLTIP := "상태 보기"
const SETTINGS_BUTTON_TOOLTIP := "설정 열기"
