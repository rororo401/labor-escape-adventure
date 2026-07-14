class_name StandingCalibratorViewConfig
extends RefCounted

const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")

const BACKGROUND_NAME := "CalibrationBackground"
const CHARACTER_RECT_NAME := "CalibratedStandingBust"
const PANEL_NAME := "CalibrationPanel"
const ENTRY_LABEL_NAME := "StandingEntryLabel"
const BUTTON_SCROLL_NAME := "StandingButtonScroll"
const BUTTON_GRID_NAME := "StandingButtonGrid"
const CONFIRM_BUTTON_NAME := "StandingConfirmButton"
const RESET_BUTTON_NAME := "StandingResetButton"
const BACK_BUTTON_NAME := "StandingBackButton"
const OFFSET_LABEL_NAME := "StandingOffsetLabel"
const SAVE_LABEL_NAME := "StandingSaveLabel"
const ENTRY_BUTTON_NAME_FORMAT := "StandingEntryButton%02d"

const KEY_CHARACTER_RECT := "character_rect"
const KEY_ENTRY_LABEL := "entry_label"
const KEY_OFFSET_LABEL := "offset_label"
const KEY_SAVE_LABEL := "save_label"
const KEY_ENTRY_BUTTONS := "entry_buttons"
const KEY_PANEL := "panel"

const CALLBACK_SELECT_ENTRY := "select_entry"
const CALLBACK_CONFIRM := "confirm"
const CALLBACK_RESET := "reset"
const CALLBACK_BACK := "back"

const PANEL_POSITION := Vector2(18, 18)
const PANEL_SIZE := Vector2(684, 286)
const PANEL_MARGIN := {
	PanelLayoutHelpersScript.KEY_LEFT: 18,
	PanelLayoutHelpersScript.KEY_TOP: 14,
	PanelLayoutHelpersScript.KEY_RIGHT: 18,
	PanelLayoutHelpersScript.KEY_BOTTOM: 14
}
const PANEL_COLOR := Color("#fff8e8e8")
const PANEL_BORDER_COLOR := Color("#d8925c")
const LAYOUT_SEPARATION := 8
const ACTION_ROW_SEPARATION := 8
const BUTTON_GRID_COLUMNS := 4
const BUTTON_GRID_SEPARATION := 8
const BUTTON_SCROLL_SIZE := Vector2(648, 104)

const ENTRY_LABEL_TEXT := "스탠딩 위치 보정"
const ENTRY_LABEL_FONT_SIZE := 24
const ENTRY_LABEL_COLOR := Color("#33231e")
const OFFSET_LABEL_FONT_SIZE := 20
const OFFSET_LABEL_COLOR := Color("#4b362f")
const SAVE_LABEL_FONT_SIZE := 18
const SAVE_LABEL_COLOR := Color("#6c5248")

const ENTRY_BUTTON_SIZE := Vector2(152, 42)
const CONFIRM_BUTTON_SIZE := Vector2(150, 42)
const RESET_BUTTON_SIZE := Vector2(96, 42)
const BACK_BUTTON_SIZE := Vector2(96, 42)
const CONFIRM_BUTTON_TEXT := "현재 확정"
const RESET_BUTTON_TEXT := "0으로"
const BACK_BUTTON_TEXT := "뒤로"


static func callbacks(select_entry: Callable, confirm: Callable, reset: Callable, back: Callable) -> Dictionary:
	return {
		CALLBACK_SELECT_ENTRY: select_entry,
		CALLBACK_CONFIRM: confirm,
		CALLBACK_RESET: reset,
		CALLBACK_BACK: back
	}
