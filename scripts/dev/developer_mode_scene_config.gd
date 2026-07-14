class_name DeveloperModeSceneConfig
extends RefCounted

const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const ProjectSettingKeysScript := preload("res://scripts/core/project_setting_keys.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")

const BACKGROUND_NAME := "DeveloperModeBackground"
const PANEL_NAME := "DeveloperModePanel"
const MESSAGE_LABEL_NAME := "DeveloperModeMessage"
const BACK_BUTTON_NAME := "DeveloperBackButton"

const BACKGROUND_PATH := UiBackgroundPathsScript.HOME_MORNING_BRIEFING
const CLOSED_DAY_BACKGROUND_PATH := UiBackgroundPathsScript.HOME_MORNING_BRIEFING
const INTRO_SCENE_PATH := UiScenePathsScript.INTRO_SCREEN
const MARKET_SCENE_PATH := UiScenePathsScript.MARKET_SCREEN
const STANDING_CALIBRATOR_SCENE_PATH := UiScenePathsScript.STANDING_POSITION_CALIBRATOR
const RESULT_POPUP_CALIBRATOR_SCENE_PATH := UiScenePathsScript.RESULT_POPUP_LAYOUT_CALIBRATOR
const DEV_SESSION_STORE_PATH_SETTING := ProjectSettingKeysScript.DEV_SESSION_STORE_PATH

const PANEL_POSITION := Vector2(42, 72)
const PANEL_SIZE := Vector2(636, 1018)
const DESIGN_VIEWPORT_WIDTH := 720.0
const PANEL_SAFE_MARGIN_X := 42
const PANEL_MARGIN := {
	PanelLayoutHelpersScript.KEY_LEFT: 32,
	PanelLayoutHelpersScript.KEY_TOP: 30,
	PanelLayoutHelpersScript.KEY_RIGHT: 32,
	PanelLayoutHelpersScript.KEY_BOTTOM: 30
}
const PANEL_COLOR := Color("#fff8e8e8")
const PANEL_BORDER_COLOR := Color("#d8925c")
const LAYOUT_SEPARATION := 18
const HEADER_SPACER_SIZE := Vector2(1, 8)
const MESSAGE_LABEL_SIZE := Vector2(572, 58)

const TITLE_TEXT := "개발자 모드"
const TITLE_FONT_SIZE := 36
const TITLE_COLOR := Color("#33231e")
const SUBTITLE_TEXT := "임시 제작/검수 도구를 골라 실행한다."
const SUBTITLE_FONT_SIZE := 21
const SUBTITLE_COLOR := Color("#6c5248")
const MESSAGE_FONT_SIZE := 18
const MESSAGE_COLOR := Color("#8b4b3f")
const BACK_BUTTON_TEXT := "인트로로 돌아가기"
