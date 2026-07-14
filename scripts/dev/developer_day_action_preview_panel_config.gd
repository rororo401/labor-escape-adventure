class_name DeveloperDayActionPreviewPanelConfig
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const PANEL_NAME := "DeveloperDayActionPreviewPanel"
const PREVIEW_ROW_NAME := "DayActionPreviewRow"
const PREVIEW_OPTION_NAME := "DayActionPreviewOption"
const PREVIEW_BUTTON_NAME := "DayActionPreviewButton"
const QUICK_ROW_NAME := "DayActionQuickPreviewRow"

const DAY_EVENTS_PATH := GameStateConfigScript.DAY_EVENTS_PATH
const CHOICE_CLOSED_MODE := DayEventKeysScript.MODE_CHOICE_CLOSED
const QUICK_KEY_ID := DayEventKeysScript.KEY_ID
const QUICK_KEY_BUTTON_NAME := "button_name"
const QUICK_KEY_TEXT := UiPayloadKeysScript.KEY_TEXT
const TITLE_TEXT := "휴장일 이벤트 미리보기"
const TITLE_FONT_SIZE := 22
const TITLE_COLOR := Color("#3f332e")
const PREVIEW_BUTTON_TEXT := "이벤트 보기"
const OPTION_SIZE := Vector2(360, 54)
const OPTION_FONT_SIZE := 20
const PANEL_SEPARATION := 18
const ROW_SEPARATION := 10

const QUICK_PREVIEWS := [
	{
		QUICK_KEY_ID: "part_time",
		QUICK_KEY_BUTTON_NAME: "PartTimePreviewButton",
		QUICK_KEY_TEXT: "알바 바로보기"
	},
	{
		QUICK_KEY_ID: "river_walk",
		QUICK_KEY_BUTTON_NAME: "RiverWalkPreviewButton",
		QUICK_KEY_TEXT: "한강 바로보기"
	}
]
