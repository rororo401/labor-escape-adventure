class_name PrologueSceneConfig
extends RefCounted

const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")

const BACKGROUND_PATH := UiBackgroundPathsScript.HOME_PROLOGUE_LIVING_ROOM
const MARKET_SCENE_PATH := UiScenePathsScript.MARKET_SCREEN
const VN_STORIES_PATH := GameStateConfigScript.VN_STORIES_PATH

const STORY_ID := "prologue"
const PROLOGUE_DATE := "2016-06-30"
const FIRST_MARKET_DATE := "2016-07-01"
const FIRST_MARKET_WEEKDAY := "Friday"

const BACKGROUND_NAME := "LivingRoomBackground"
const SLEEP_SEQUENCE_NAME := "PrologueSleepSequence"
const DATE_TEXT := "D-1  프롤로그  ·  2016-06-30 밤"
const CHARACTER_NAME := "ProtagonistHomewearBust"
const HOMEWEAR_OUTFIT := "homewear"
const DEFAULT_EXPRESSION := GameStateConfigScript.DEFAULT_PROTAGONIST_EXPRESSION_ID
const CHARACTERS_PER_SECOND := 76.0

const HUD_DATE_WIDTH := 200.0
const DIALOGUE_POSITION := Vector2(42, 84)
const DIALOGUE_SIZE := Vector2(632, 124)
const DIALOGUE_FONT_SIZE := 26
