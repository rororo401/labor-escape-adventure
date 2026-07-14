class_name DateTransitionLayerConfig
extends RefCounted

const UiCommonNodeNamesScript := preload("res://scripts/ui/ui_common_node_names.gd")

const BACKGROUND_PATH := "res://assets/backgrounds/transition/date_change_bg.png"
const BACKGROUND_NAME := "DateChangeBackground"
const DATE_LABEL_NAME := UiCommonNodeNamesScript.DATE_LABEL_NAME
const WEEKDAY_LABEL_NAME := "WeekdayLabel"
const STAMP_LABEL_NAME := "StampLabel"
const FALLBACK_SIZE := Vector2(720, 1280)

const DATE_LABEL_POSITION := Vector2(70, 448)
const DATE_LABEL_SIZE := Vector2(580, 116)
const DATE_LABEL_PIVOT := Vector2(290, 58)
const DATE_FONT_SIZE := 54
const DATE_TEXT_COLOR := Color("#4b352f")
const DATE_OUTLINE_COLOR := Color("#fff7e9")
const DATE_OUTLINE_SIZE := 4

const WEEKDAY_LABEL_POSITION := Vector2(70, 565)
const WEEKDAY_LABEL_SIZE := Vector2(580, 62)
const WEEKDAY_FONT_SIZE := 28
const WEEKDAY_TEXT_COLOR := Color("#6a524a")

const STAMP_LABEL_POSITION := Vector2(420, 390)
const STAMP_LABEL_SIZE := Vector2(244, 70)
const STAMP_ROTATION_DEGREES := -8
const STAMP_FONT_SIZE := 32
const STAMP_TEXT_COLOR := Color("#d8655b")
const STAMP_OUTLINE_COLOR := Color("#fff7e9")
const STAMP_OUTLINE_SIZE := 3

const FADE_IN_DURATION := 0.18
const COVERED_HOLD_DURATION := 0.28
const DATE_POP_SCALE := Vector2(1.08, 1.08)
const DATE_POP_UP_DURATION := 0.08
const DATE_POP_DOWN_DURATION := 0.12
const FADE_OUT_DURATION := 0.20
