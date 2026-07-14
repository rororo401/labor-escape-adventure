extends "res://scripts/tests/test_scene_tree.gd"

const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const CalendarPayloadKeysScript := preload("res://scripts/core/calendar_payload_keys.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_verify_today_context_keys()
	_verify_market_context_keys()
	_verify_modes_and_phases()

	print("Game state context keys smoke test passed.")
	finish_test()


func _verify_today_context_keys() -> void:
	_expect(GameStateContextKeysScript.KEY_DATE == CalendarPayloadKeysScript.KEY_DATE, "date key should use the shared calendar payload key")
	_expect(GameStateContextKeysScript.KEY_WEEKDAY == CalendarPayloadKeysScript.KEY_WEEKDAY, "weekday key should use the shared calendar payload key")
	_expect(GameStateContextKeysScript.KEY_IS_TRADING_DAY == CalendarPayloadKeysScript.KEY_IS_TRADING_DAY, "trading-day key should use the shared calendar payload key")
	_expect(GameStateContextKeysScript.KEY_REASON == DayEventKeysScript.KEY_REASON, "reason key should use the shared day-event key")
	_expect(GameStateContextKeysScript.KEY_NAME == DayEventKeysScript.KEY_NAME, "name key should use the shared day-event key")
	_expect(GameStateContextKeysScript.KEY_CLOSED_REASON == "closed_reason", "closed reason key should stay stable")
	_expect(GameStateContextKeysScript.KEY_CLOSED_NAME == "closed_name", "closed name key should stay stable")
	_expect(GameStateContextKeysScript.KEY_DAY_MODE == "day_mode", "day mode key should stay stable")
	_expect(GameStateContextKeysScript.KEY_MARKET == DayEventKeysScript.KEY_MARKET, "market key should use the shared day-event key")
	_expect(GameStateContextKeysScript.KEY_DAY_FLOW == "day_flow", "day flow key should stay stable")
	_expect(GameStateContextKeysScript.KEY_CHARACTER_ASSETS == "character_assets", "character assets key should stay stable")
	_expect(GameStateContextKeysScript.KEY_GAME_OVER == PlayerStatusKeysScript.KEY_GAME_OVER, "game-over key should use the shared player-status key")
	_expect(GameStateContextKeysScript.KEY_GAME_OVER_REASON == PlayerStatusKeysScript.KEY_GAME_OVER_REASON, "game-over reason key should use the shared player-status key")
	_expect(GameStateContextKeysScript.KEY_GAME_CLEAR == PlayerStatusKeysScript.KEY_GAME_CLEAR, "game-clear key should use the shared player-status key")
	_expect(GameStateContextKeysScript.KEY_CLEAR_REASON == PlayerStatusKeysScript.KEY_CLEAR_REASON, "clear reason key should use the shared player-status key")


func _verify_market_context_keys() -> void:
	_expect(GameStateContextKeysScript.KEY_CALENDAR_DATE == "calendar_date", "calendar date key should stay stable")
	_expect(GameStateContextKeysScript.KEY_IS_OPEN == DayEventKeysScript.KEY_IS_OPEN, "market-open key should use the shared day-event key")
	_expect(GameStateContextKeysScript.KEY_PHASE == "phase", "phase key should stay stable")
	_expect(GameStateContextKeysScript.KEY_DAY_COMPLETED == "day_completed", "day completed key should stay stable")
	_expect(GameStateContextKeysScript.KEY_LAST_DAY_RESULT == "last_day_result", "last result key should stay stable")
	_expect(GameStateContextKeysScript.KEY_STATUS == ResultKeysScript.KEY_STATUS, "status key should use the shared result key")
	_expect(GameStateContextKeysScript.KEY_GAME_FINISHED == DayEventKeysScript.KEY_GAME_FINISHED, "game finished key should use the shared day-event key")


func _verify_modes_and_phases() -> void:
	_expect(GameStateContextKeysScript.DAY_MODE_MARKET_AND_LIFE == "market_and_life", "trading day mode should stay stable")
	_expect(GameStateContextKeysScript.DAY_MODE_LIFE_ONLY == "life_only", "closed day mode should stay stable")
	_expect(GameStateContextKeysScript.MARKET_PHASE_MORNING_ORDER == "morning_order", "morning market phase should stay stable")
	_expect(GameStateContextKeysScript.MARKET_PHASE_CLOSED == "closed", "closed market phase should stay stable")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
