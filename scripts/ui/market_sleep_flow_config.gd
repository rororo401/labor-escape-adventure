class_name MarketSleepFlowConfig
extends RefCounted

const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_OK := ResultKeysScript.KEY_OK
const KEY_START_STATE := "start_state"
const KEY_ERROR_STATE := "error_state"
const KEY_TRANSITION_STATE := "transition_state"
const KEY_RESULT := UiPayloadKeysScript.KEY_RESULT

const CALLBACK_APPLY_STATE := "apply_state"
const CALLBACK_SET_MESSAGE := "set_message"
const CALLBACK_REFRESH_FLOW_CONTROLS := "refresh_flow_controls"
const CALLBACK_REFRESH_MARKET := "refresh_market"
const CALLBACK_MARKET_REVEAL_READY := "market_reveal_ready"

const DEFAULT_MISSING_GAME_ERROR := GameStateGuardResultScript.ERROR_GAME_NOT_STARTED


static func screen_callbacks(
	apply_state: Callable,
	set_message: Callable,
	refresh_flow_controls: Callable,
	refresh_market: Callable,
	market_reveal_ready: Callable
) -> Dictionary:
	return {
		CALLBACK_APPLY_STATE: apply_state,
		CALLBACK_SET_MESSAGE: set_message,
		CALLBACK_REFRESH_FLOW_CONTROLS: refresh_flow_controls,
		CALLBACK_REFRESH_MARKET: refresh_market,
		CALLBACK_MARKET_REVEAL_READY: market_reveal_ready
	}


static func sleep_error_result(start_state: Dictionary, error_state: Dictionary, result: Dictionary = {}) -> Dictionary:
	var payload := {
		KEY_OK: false,
		KEY_START_STATE: start_state,
		KEY_ERROR_STATE: error_state
	}
	if not result.is_empty():
		payload[KEY_RESULT] = result
	return payload


static func sleep_transition_result(start_state: Dictionary, transition_state: Dictionary, result: Dictionary) -> Dictionary:
	return {
		KEY_OK: true,
		KEY_START_STATE: start_state,
		KEY_TRANSITION_STATE: transition_state,
		KEY_RESULT: result
	}
