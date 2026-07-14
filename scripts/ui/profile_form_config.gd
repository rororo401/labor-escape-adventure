class_name ProfileFormConfig
extends RefCounted

const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")

const PANEL_NAME := "ProfilePanel"
const PANEL_POSITION := Vector2(52, 202)
const PANEL_SIZE := Vector2(616, 766)
const PANEL_MARGIN := {
	PanelLayoutHelpersScript.KEY_LEFT: 32,
	PanelLayoutHelpersScript.KEY_TOP: 34,
	PanelLayoutHelpersScript.KEY_RIGHT: 32,
	PanelLayoutHelpersScript.KEY_BOTTOM: 30
}
const PANEL_COLOR := Color("#fff8eadf")
const PANEL_BORDER_COLOR := Color("#efb077")
const LAYOUT_SEPARATION := 16

const NAME_INPUT_NAME := "PlayerNameInput"
const DIFFICULTY_OPTION_NAME := "DifficultyOption"
const DIFFICULTY_DESCRIPTION_NAME := "DifficultyDescription"
const CONFIRM_BUTTON_NAME := "ProfileConfirmButton"
const NAME_MAX_LENGTH := 8

const CONTROL_WIDTH := 552
const NAME_INPUT_SIZE := Vector2(CONTROL_WIDTH, 62)
const PROFILE_SUMMARY_SIZE := Vector2(CONTROL_WIDTH, 76)
const DIFFICULTY_OPTION_SIZE := Vector2(CONTROL_WIDTH, 58)
const DIFFICULTY_DESCRIPTION_SIZE := Vector2(CONTROL_WIDTH, 56)
const MESSAGE_LABEL_SIZE := Vector2(CONTROL_WIDTH, 32)
const SUBMIT_BUTTON_SIZE := Vector2(CONTROL_WIDTH, 62)

const NAME_INPUT_FONT_SIZE := 28
const SUMMARY_FONT_SIZE := 24
const DIFFICULTY_LABEL_FONT_SIZE := 22
const DIFFICULTY_OPTION_FONT_SIZE := 22
const DIFFICULTY_DESCRIPTION_FONT_SIZE := 16
const MESSAGE_FONT_SIZE := 20
const SUBMIT_BUTTON_FONT_SIZE := 28

const DEFAULT_LABEL_COLOR := Color("#46362f")
const HEADER_OUTLINE_COLOR := Color("#fff7e9")
const HEADER_OUTLINE_SIZE := 3
const PANEL_SHADOW_COLOR := Color("#00000030")
const PANEL_SHADOW_SIZE := 10
const PANEL_SHADOW_OFFSET := Vector2(0, 4)
const TEXT_COLOR := Color("#33231e")
const PLACEHOLDER_COLOR := Color("#9b8376")
const SUMMARY_COLOR := Color("#4b3a34")
const MESSAGE_COLOR := Color("#b5534b")
const SUBMIT_TEXT_COLOR := Color("#ffffff")

const LINE_EDIT_NORMAL_COLOR := Color("#fffdf7ee")
const LINE_EDIT_NORMAL_BORDER := Color("#e4a36d")
const LINE_EDIT_FOCUS_COLOR := Color("#ffffff")
const LINE_EDIT_FOCUS_BORDER := Color("#cf7653")
const LINE_EDIT_CONTENT_MARGIN_LEFT := 18
const LINE_EDIT_CONTENT_MARGIN_RIGHT := 18
const LINE_EDIT_CONTENT_MARGIN_TOP := 8
const LINE_EDIT_CONTENT_MARGIN_BOTTOM := 8
const SUBMIT_NORMAL_COLOR := Color("#42656a")
const SUBMIT_NORMAL_BORDER := Color("#dbe9da")
const SUBMIT_HOVER_COLOR := Color("#4d777d")
const SUBMIT_HOVER_BORDER := Color("#ffffff")
const SUBMIT_PRESSED_COLOR := Color("#2f4d52")
const SUBMIT_PRESSED_BORDER := Color("#ffffff")
