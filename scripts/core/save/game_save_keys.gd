class_name GameSaveKeys
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const SAVE_VERSION := 4
const MIN_SUPPORTED_SAVE_VERSION := 1

const KEY_VERSION := "version"
const KEY_CURRENT_DATE := "current_date"
const KEY_DAY_INDEX := "day_index"
const KEY_COMPLETED_DAYS := "completed_days"
const KEY_RANDOM_SEED := "random_seed"
const KEY_DIFFICULTY := "difficulty"
const KEY_DAY_COMPLETED := GameStateContextKeysScript.KEY_DAY_COMPLETED
const KEY_LAST_DAY_RESULT := GameStateContextKeysScript.KEY_LAST_DAY_RESULT
const KEY_EVENT_HISTORY := DayEventKeysScript.KEY_EVENT_HISTORY
const KEY_SHOWN_MARKET_FIXED_EVENT_IDS := "shown_market_fixed_event_ids"
const KEY_APPLIED_MARKET_FIXED_EVENT_IDS := "applied_market_fixed_event_ids"
const KEY_HEALTH_RESURRECTION_USED := "health_resurrection_used"
const KEY_LEVERAGE_GODDESS_USED := "leverage_goddess_used"
const KEY_LEVERAGE_BLESSING_START_DAY_INDEX := "leverage_blessing_start_day_index"
const KEY_LEVERAGE_BLESSING_END_DAY_INDEX := "leverage_blessing_end_day_index"
const KEY_LEVERAGE_REFERENCE_NET_WORTH := "leverage_reference_net_worth"
const KEY_STATUS := ResultKeysScript.KEY_STATUS
const KEY_MARKET := DayEventKeysScript.KEY_MARKET
const KEY_RUN_STATISTICS := "run_statistics"

const KEY_OK := ResultKeysScript.KEY_OK
const KEY_ERROR := ResultKeysScript.KEY_ERROR
const KEY_DATE := DayEventKeysScript.KEY_DATE
const KEY_PATH := ResultKeysScript.KEY_PATH
const KEY_DATA := ResultKeysScript.KEY_DATA
const KEY_SAVED_AT_UNIX := "saved_at_unix"
const KEY_SLOT_KIND := "slot_kind"
const KEY_SLOT_INDEX := "slot_index"

const DIFFICULTY_EASY := GameDifficultyScript.EASY
const DIFFICULTY_NORMAL := GameDifficultyScript.NORMAL
const DIFFICULTY_HARD := GameDifficultyScript.HARD
const DIFFICULTY_IDS := GameDifficultyScript.IDS

const ERROR_SETUP_FAILED := "setup_failed"
const ERROR_PROGRESS_FILE_MISSING := "progress_file_missing"
const ERROR_PROGRESS_INVALID_JSON := "progress_invalid_json"
const ERROR_PROGRESS_WRITE_FAILED := "progress_write_failed"
const ERROR_SAVE_DATA_INVALID := "save_data_invalid"
const ERROR_SAVE_VERSION_UNSUPPORTED := "save_version_unsupported"
const ERROR_SAVE_VERSION_NEWER := "save_version_newer"
