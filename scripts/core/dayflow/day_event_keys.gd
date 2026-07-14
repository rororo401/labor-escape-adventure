class_name DayEventKeys
extends RefCounted

const CalendarPayloadKeysScript := preload("res://scripts/core/calendar_payload_keys.gd")
const IdentityPayloadKeysScript := preload("res://scripts/core/identity_payload_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const KEY_DAY_ACTIONS := "day_actions"
const KEY_ACTIONS_BY_ID := "actions_by_id"
const KEY_WEEKDAY_EVENTS := "weekday_events"
const KEY_WEEKDAY_EVENTS_BY_ID := "weekday_events_by_id"
const KEY_NIGHT_EVENTS := "night_events"
const KEY_NIGHT_EVENTS_BY_ID := "night_events_by_id"
const KEY_RULES := "rules"
const KEY_CLOSED_DAY_CHOICE_LIMIT := "closed_day_choice_limit"
const KEY_SPECIAL_ANNUAL_EVENTS_PATH := "special_annual_events_path"
const KEY_MARKET_FIXED_EVENTS_PATH := "market_fixed_events_path"
const KEY_EVENT_HISTORY := "event_history"
const KEY_CONDITIONS := "conditions"
const KEY_RANDOM_EVENT_OCCURRENCE := "random_event_occurrence"
const KEY_WEEKDAY_OCCURRENCE := "weekday"
const KEY_NIGHT_OCCURRENCE := "night"

const KEY_DEFAULT_ACTION := "default_action"
const KEY_AVAILABLE_CATEGORIES := "available_categories"
const KEY_AVAILABLE_CHOICES := "available_choices"
const KEY_HAS_CHOICE := "has_choice"
const KEY_NIGHT_EVENT_PREVIEW := "night_event_preview"
const KEY_DAY_ACTION := "day_action"
const KEY_MARKET_FIXED_EVENT := "market_fixed_event"
const KEY_MARKET_FIXED_EFFECT := "market_fixed_effect"
const KEY_LEVERAGE_BONUS_EFFECT := "leverage_bonus_effect"

const KEY_ROWS := "rows"
const KEY_BY_ID := "by_id"
const KEY_ID := IdentityPayloadKeysScript.KEY_ID
const KEY_NAME_KO := VnStoryKeysScript.EVENT_KEY_NAME_KO
const KEY_SUMMARY_KO := VnStoryKeysScript.EVENT_KEY_SUMMARY_KO
const KEY_MODE := "mode"
const KEY_CATEGORY_ID := "category_id"
const KEY_CATEGORY_KO := "category_ko"
const KEY_CHANCE := "chance"
const KEY_GROUP := "group"
const KEY_TAGS := "tags"
const KEY_COOLDOWN_DAYS := "cooldown_days"
const KEY_TAG_COOLDOWN_DAYS := "tag_cooldown_days"
const KEY_CG_COOLDOWN_DAYS := "cg_cooldown_days"
const KEY_WEIGHT := "weight"
const KEY_RARITY := "rarity"
const KEY_CG_PATH := VnStoryKeysScript.EVENT_KEY_CG_PATH
const KEY_DIALOGUE := VnStoryKeysScript.EVENT_KEY_DIALOGUE
const KEY_EFFECTS := "effects"
const KEY_EVENT := "event"
const KEY_EFFECT := "effect"

const KEY_DATE := CalendarPayloadKeysScript.KEY_DATE
const KEY_IS_TRADING_DAY := CalendarPayloadKeysScript.KEY_IS_TRADING_DAY
const KEY_REASON := "reason"
const KEY_NAME := "name"
const KEY_YEAR := "year"
const KEY_MONTH := "month"
const KEY_DAY := "day"
const KEY_WEEKDAY := CalendarPayloadKeysScript.KEY_WEEKDAY
const KEY_OK := ResultKeysScript.KEY_OK
const KEY_MARKET := "market"
const KEY_IS_OPEN := "is_open"
const KEY_PHASE_AVAILABLE := "phase_available"
const KEY_END_OF_DAY_EFFECT := "end_of_day_effect"
const KEY_MARKET_CLOSE_REPORT := "market_close_report"
const KEY_STATUS := ResultKeysScript.KEY_STATUS
const KEY_GAME_FINISHED := "game_finished"
const KEY_SLEEP_REQUIRED := "sleep_required"

const KEY_HEALTH := PlayerStatusKeysScript.KEY_HEALTH
const KEY_FATIGUE := PlayerStatusKeysScript.KEY_FATIGUE
const KEY_HEALTH_MAX := "health_max"
const KEY_FATIGUE_MIN := "fatigue_min"
const KEY_EVENT_ID := "event_id"
const KEY_EVENT_ID_PATTERN := "event_id_pattern"
const KEY_COMPLETED_DAY := "completed_day"
const KEY_SELECTED := "selected"
const KEY_MONTH_RULE := "month"
const KEY_DURATION_DAYS := "duration_days"

const RULE_SICK_OVERRIDE := "sick_override"
const RULE_ANNUAL_SPECIAL_DATES := "annual_special_dates"
const RULE_MARKET_FIXED_DATES := "market_fixed_dates"
const RULE_SUMMER_VACATION := "summer_vacation"
const RULE_FAMILY_HOLIDAY_NAMES := "family_holiday_names"
const RULE_FREE_CHOICE_HOLIDAY_NAMES := "free_choice_holiday_names"
const RULE_EVENT_CONDITIONS := "event_conditions"

const MODE_CHOICE_CLOSED := "choice_closed"
const MODE_AUTO_TRADING := "auto_trading"
const MODE_ANNUAL_SPECIAL := "annual_special"
const MODE_MARKET_FIXED := "market_fixed"
const MODE_WEEKDAY_RANDOM := "weekday_random"
const REASON_HOLIDAY := "holiday"
const GROUP_COMPANY_WORK := "company_work"
const HOLIDAY_NAME_SUBSTITUTE := "대체공휴일"

const ACTION_GO_TO_WORK_ALIAS := "go_to_work"
const ACTION_COMPANY_WORK := "company_work"
const ACTION_SICK_REST := "sick_rest"
const ACTION_SUMMER_VACATION := "summer_vacation"
const ACTION_HOLIDAY_FAMILY := "holiday_family"
const ACTION_HOLIDAY_REST := "holiday_rest"
const ACTION_NAP := "nap"

const DEFAULT_CLOSED_DAY_CHOICE_LIMIT := 4
const DEFAULT_EVENT_COOLDOWN_DAYS := 60
const DEFAULT_EVENT_EXPOSURE_COOLDOWN_DAYS := 30
const DEFAULT_CG_COOLDOWN_DAYS := 30
const DEFAULT_TAG_COOLDOWN_DAYS := 30
const DEFAULT_TAG_CANDIDATE_LIMIT := 2
const DEFAULT_WEEKDAY_EVENT_OCCURRENCE := 0.30
const DEFAULT_NIGHT_EVENT_OCCURRENCE := 0.35
const DEFAULT_HEALTH := 100
const DEFAULT_FATIGUE := 0
const DEFAULT_SICK_HEALTH_MAX := 35
const DEFAULT_SICK_FATIGUE_MIN := 98
const DEFAULT_VACATION_MONTH := 8
const DEFAULT_VACATION_DURATION_DAYS := 3
