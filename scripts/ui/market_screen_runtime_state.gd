class_name MarketScreenRuntimeState
extends RefCounted

const MarketScreenStateScript := preload("res://scripts/ui/market_screen_state.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")

var selected_stock := {}
var quantity := 1
var selected_day_action_id := ""
var selected_closed_day_category_id := ""
var showing_close_report := false
var is_sleep_sequence := false
var is_completing_day := false


func apply(patch: Dictionary) -> Dictionary:
	var next := MarketScreenStateScript.apply(to_dict(), patch)
	load_from_dict(next)
	return next


func to_dict() -> Dictionary:
	return {
		MarketScreenStateConfigScript.KEY_IS_SLEEP_SEQUENCE: is_sleep_sequence,
		MarketScreenStateConfigScript.KEY_IS_COMPLETING_DAY: is_completing_day,
		MarketScreenStateConfigScript.KEY_SHOWING_CLOSE_REPORT: showing_close_report,
		MarketScreenStateConfigScript.KEY_SELECTED_STOCK: Dictionary(selected_stock).duplicate(true),
		MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID: selected_day_action_id,
		MarketScreenStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID: selected_closed_day_category_id,
		MarketScreenStateConfigScript.KEY_QUANTITY: quantity
	}


func load_from_dict(state: Dictionary) -> void:
	is_sleep_sequence = bool(state.get(MarketScreenStateConfigScript.KEY_IS_SLEEP_SEQUENCE, MarketScreenStateConfigScript.DEFAULT_FLAG))
	is_completing_day = bool(state.get(MarketScreenStateConfigScript.KEY_IS_COMPLETING_DAY, MarketScreenStateConfigScript.DEFAULT_FLAG))
	showing_close_report = bool(state.get(MarketScreenStateConfigScript.KEY_SHOWING_CLOSE_REPORT, MarketScreenStateConfigScript.DEFAULT_FLAG))
	selected_stock = Dictionary(state.get(MarketScreenStateConfigScript.KEY_SELECTED_STOCK, MarketScreenStateConfigScript.DEFAULT_SELECTED_STOCK)).duplicate(true)
	selected_day_action_id = String(state.get(MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID, MarketScreenStateConfigScript.DEFAULT_SELECTED_DAY_ACTION_ID))
	selected_closed_day_category_id = String(state.get(MarketScreenStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID, MarketScreenStateConfigScript.DEFAULT_SELECTED_CLOSED_DAY_CATEGORY_ID))
	quantity = int(state.get(MarketScreenStateConfigScript.KEY_QUANTITY, MarketScreenStateConfigScript.DEFAULT_QUANTITY))
