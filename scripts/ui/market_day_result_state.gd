class_name MarketDayResultState
extends RefCounted

const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")


static func completion_success_state(result: Dictionary) -> Dictionary:
	return {
		MarketDayResultStateConfigScript.KEY_IS_COMPLETING_DAY: false,
		MarketDayResultStateConfigScript.KEY_SHOWING_CLOSE_REPORT: true,
		MarketDayResultStateConfigScript.KEY_MESSAGE: MarketDayFlowTextScript.format_day_result(result)
	}


static func completion_error_state(error: String) -> Dictionary:
	return {
		MarketDayResultStateConfigScript.KEY_IS_COMPLETING_DAY: false,
		MarketDayResultStateConfigScript.KEY_CHOICE_BUTTONS_DISABLED: false,
		MarketDayResultStateConfigScript.KEY_MESSAGE: MarketDayFlowTextScript.flow_error_message(error)
	}


static func sleep_start_state() -> Dictionary:
	return {
		MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE: true
	}


static func sleep_error_state(error: String) -> Dictionary:
	return {
		MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE: false,
		MarketDayResultStateConfigScript.KEY_MESSAGE: MarketDayFlowTextScript.flow_error_message(error)
	}


static func after_sleep_transition_state() -> Dictionary:
	return {
		MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE: true,
		MarketDayResultStateConfigScript.KEY_SHOWING_CLOSE_REPORT: false,
		MarketDayResultStateConfigScript.KEY_SELECTED_STOCK: {},
		MarketDayResultStateConfigScript.KEY_SELECTED_DAY_ACTION_ID: MarketDayResultStateConfigScript.CLEAR_DAY_ACTION_ID,
		MarketDayResultStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID: MarketDayResultStateConfigScript.CLEAR_CLOSED_DAY_CATEGORY_ID,
		MarketDayResultStateConfigScript.KEY_MESSAGE: MarketDayResultStateConfigScript.CLEAR_MESSAGE
	}


static func after_sleep_morning_state() -> Dictionary:
	return {
		MarketDayResultStateConfigScript.KEY_IS_SLEEP_SEQUENCE: false
	}
