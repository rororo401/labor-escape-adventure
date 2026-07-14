class_name MorningBriefingLayerConfig
extends RefCounted

const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")

const BACKGROUND_PATH := UiBackgroundPathsScript.HOME_MORNING_BRIEFING
const VN_STORIES_PATH := GameStateConfigScript.VN_STORIES_PATH
const STORY_ID := "morning_briefing"
const TRADING_DAY_STORY_ID := "morning_briefing"
const CLOSED_DAY_STORY_ID := "morning_briefing_closed"

const BACKGROUND_NAME := "MorningBackground"
const SHOW_TOP_BUTTONS := false
const CHARACTER_NAME := "MorningProtagonistBust"
const DEFAULT_OUTFIT := "homewear"
const DEFAULT_EXPRESSION := GameStateConfigScript.DEFAULT_PROTAGONIST_EXPRESSION_ID

const MONTHLY_SALARY_EVENT_ID_PREFIX := "monthly_salary"
const LOW_HEALTH_THRESHOLD := 30
const HIGH_FATIGUE_THRESHOLD := 90

const FADE_OUT_DURATION := 0.16
