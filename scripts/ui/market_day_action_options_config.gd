class_name MarketDayActionOptionsConfig
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_SELECTED_ACTION_ID := "selected_action_id"
const KEY_SELECTED_CATEGORY_ID := "selected_category_id"
const KEY_ACTION_IDS := "action_ids"
const KEY_ACTION_LABELS := "action_labels"
const KEY_LABELS := UiPayloadKeysScript.KEY_LABELS
const KEY_SELECTED_INDEX := UiPayloadKeysScript.KEY_SELECTED_INDEX
const KEY_ACTION_SELECTED_INDEX := "action_selected_index"
const KEY_CATEGORIES := "categories"
const KEY_CHOICES := "choices"
const KEY_CATEGORIES_DISABLED := "categories_disabled"
const KEY_CHOICES_DISABLED := "choices_disabled"
const KEY_ORDER_ACTIONS_DISABLED := "order_actions_disabled"

const FLOW_DEFAULT_ACTION := DayEventKeysScript.KEY_DEFAULT_ACTION
const FLOW_AVAILABLE_CATEGORIES := DayEventKeysScript.KEY_AVAILABLE_CATEGORIES
const FLOW_AVAILABLE_CHOICES := DayEventKeysScript.KEY_AVAILABLE_CHOICES
const ACTION_ID := DayEventKeysScript.KEY_ID
const ACTION_NAME := DayEventKeysScript.KEY_NAME_KO

const DEFAULT_ACTION_LABEL := "오늘 보내기"
const EMPTY_ID := UiPayloadKeysScript.EMPTY_MESSAGE
const DEFAULT_SELECTED_INDEX := 0
