class_name FirstDayWorkSceneConfig
extends RefCounted

const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")

const NPC_NAMES_PATH := GameStateConfigScript.NPC_NAMES_PATH
const VN_STORIES_PATH := GameStateConfigScript.VN_STORIES_PATH
const MARKET_SCENE_PATH := UiScenePathsScript.MARKET_SCREEN

const STORY_ID := "first_day_work"
const NPC_BOX_TRADING_MANAGER := "box_trading_manager"
const FALLBACK_BOX_TRADING_MANAGER_NAME := "강민석 부장"
const DAY_ACTION_ID := "company_work"

const DIALOGUE_NAME_WIDTH := 190.0


static func flow_error_message(error: String) -> String:
	return MarketDayFlowTextScript.flow_error_message(error)
