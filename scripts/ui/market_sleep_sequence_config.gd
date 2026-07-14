class_name MarketSleepSequenceConfig
extends RefCounted

const CharacterOutfitSeasonScript := preload("res://scripts/core/character_outfit_season.gd")

const SLEEP_LAYER_NAME := "SleepEventLayer"
const SLEEP_EVENT_CG_NAME := "SleepEventCG"
const SLEEP_EVENT_CG_PATH := "res://assets/backgrounds/home/sleeping_night_event.png"
const SLEEP_EVENT_CG_PATH_SUMMER := "res://assets/backgrounds/home/sleeping_night_event_summer.png"
const FALLBACK_SIZE := Vector2(720, 1280)

const SLEEP_FADE_IN_DURATION := 0.22
const SLEEP_HOLD_DURATION := 1.85
const CANCEL_FADE_DURATION := 0.20


static func sleep_event_cg_path_for_date(date: String) -> String:
	return SLEEP_EVENT_CG_PATH_SUMMER if CharacterOutfitSeasonScript.is_summer_date(date) else SLEEP_EVENT_CG_PATH
