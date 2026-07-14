class_name ClosedDayPanelConfig
extends RefCounted

const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")

const PANEL_NAME := "ClosedDayPanel"
const PANEL_POSITION := Vector2(30, 226)
const PANEL_SIZE := Vector2(660, 520)
const PANEL_MARGIN := {
	PanelLayoutHelpersScript.KEY_LEFT: 28,
	PanelLayoutHelpersScript.KEY_TOP: 26,
	PanelLayoutHelpersScript.KEY_RIGHT: 28,
	PanelLayoutHelpersScript.KEY_BOTTOM: 26
}
const PANEL_COLOR := Color("#fff8eadd")
const PANEL_BORDER_COLOR := Color("#e5a66c")
const LAYOUT_SEPARATION := 18
const ROW_SEPARATION := 12
const GRID_COLUMNS := 2

const DEFAULT_TITLE := "오늘은 장이 쉬는 날"
const CATEGORY_ROW_NAME := "ClosedDayCategoryRow"
const CHOICE_GRID_NAME := "ClosedDayChoiceGrid"
const FLOW_BUTTON_NAME := "ClosedDayFlowButton"

const BODY_LABEL_SIZE := Vector2(604, 128)
const FLOW_BUTTON_SIZE := Vector2(604, 58)
const MESSAGE_LABEL_SIZE := Vector2(604, 96)

const TITLE_FONT_SIZE := 30
const BODY_FONT_SIZE := 24
const MESSAGE_FONT_SIZE := 22
const TITLE_COLOR := Color("#3f332e")
const BODY_COLOR := Color("#46362f")
