class_name IntroScreenConfig
extends RefCounted

const ProjectSettingKeysScript := preload("res://scripts/core/project_setting_keys.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")

const BACKGROUND_PATH := "res://assets/ui/title_background.png"
const TITLE_LOGO_PATH := "res://assets/ui/title_logo.png"
const START_BUTTON_PATH := "res://assets/ui/title_buttons/title_button_start.png"
const CONTINUE_BUTTON_PATH := "res://assets/ui/title_buttons/title_button_continue.png"
const GALLERY_BUTTON_PATH := "res://assets/ui/title_buttons/title_button_gallery.png"

const PROFILE_SCENE_PATH := UiScenePathsScript.PROFILE_SETUP
const DEVELOPER_MODE_SCENE_PATH := UiScenePathsScript.DEVELOPER_MODE
const MARKET_SCENE_PATH := UiScenePathsScript.MARKET_SCREEN

const DEFAULT_DEVELOPER_RUN_DATE := "2016-07-02"
const DEV_SESSION_STORE_PATH_SETTING := ProjectSettingKeysScript.DEV_SESSION_STORE_PATH
const SHOW_DEVELOPER_QUICK_LAUNCH_SETTING := ProjectSettingKeysScript.SHOW_DEVELOPER_QUICK_LAUNCH
const DEVELOPER_QUICK_TEXT_PREFIX := "개발: 마지막 날짜로 실행  "
const CONTINUE_TEXT := "이어하기"
const GALLERY_TEXT := "앨범"
const CONTINUE_FAILED_TEXT := "저장 데이터를 불러오지 못했어"

const LOGO_FLOAT_UP_OFFSET := 14.0
const LOGO_FLOAT_DOWN_OFFSET := 10.0
const LOGO_FLOAT_DURATION := 1.8

const START_BUTTON_PRESSED_SCALE := Vector2(0.92, 0.92)
const START_BUTTON_PRESS_DOWN_DURATION := 0.08
const START_BUTTON_PRESS_UP_DURATION := 0.18
const START_SCENE_CHANGE_DELAY := 0.24
