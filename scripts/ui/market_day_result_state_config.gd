class_name MarketDayResultStateConfig
extends RefCounted

const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_IS_COMPLETING_DAY := "is_completing_day"
const KEY_SHOWING_CLOSE_REPORT := "showing_close_report"
const KEY_CHOICE_BUTTONS_DISABLED := "choice_buttons_disabled"
const KEY_IS_SLEEP_SEQUENCE := "is_sleep_sequence"
const KEY_SELECTED_STOCK := "selected_stock"
const KEY_SELECTED_DAY_ACTION_ID := "selected_day_action_id"
const KEY_SELECTED_CLOSED_DAY_CATEGORY_ID := "selected_closed_day_category_id"
const KEY_MESSAGE := UiPayloadKeysScript.KEY_MESSAGE

const CLEAR_MESSAGE := UiPayloadKeysScript.EMPTY_MESSAGE
const CLEAR_DAY_ACTION_ID := ""
const CLEAR_CLOSED_DAY_CATEGORY_ID := ""
