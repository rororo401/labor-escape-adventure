class_name HudStatusBarsConfig
extends RefCounted

const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")

const ROOT_NAME := "HudStatusBars"
const ROW_NAME_FORMAT := "HudStatusBarRow%d"
const LABEL_NAME_FORMAT := "HudStatusBarLabel%d"
const SEPARATOR_NAME_FORMAT := "HudStatusBarSeparator%d"
const BAR_BACKGROUND_NAME_FORMAT := "HudStatusBarBackground%d"
const BAR_FILL_NAME_FORMAT := "HudStatusBarFill%d"
const VALUE_NAME_FORMAT := "HudStatusBarValue%d"

const STATUS_KEYS := [
	PlayerStatusKeysScript.KEY_HEALTH,
	PlayerStatusKeysScript.KEY_MOOD,
	PlayerStatusKeysScript.KEY_FATIGUE
]
const STATUS_LABELS := ["건강", "기분", "피로"]
const STATUS_COLORS := [
	Color("#ee8f94"),
	Color("#f1bf5e"),
	Color("#86b8df")
]
const DEFAULT_VALUES := [100, 50, 0]

const POSITION := Vector2(250, 33)
const ITEM_GAP := 120
const LABEL_SIZE := Vector2(40, 22)
const BAR_OFFSET := Vector2(42, 8)
const BAR_SIZE := Vector2(30, 8)
const VALUE_OFFSET := Vector2(74, 0)
const VALUE_SIZE := Vector2(32, 22)
const SEPARATOR_OFFSET := Vector2(110, 0)
const SEPARATOR_SIZE := Vector2(10, 22)
const SEPARATOR_TEXT := "|"
const FONT_SIZE := 18
const LABEL_COLOR := Color("#60453a")
const VALUE_COLOR := Color("#60453a")
const SEPARATOR_COLOR := Color("#b18768")
const BAR_BACKGROUND_COLOR := Color("#fff6e800")
const TEXT_OUTLINE_COLOR := Color("#fff8e9")
const TEXT_OUTLINE_SIZE := 1
