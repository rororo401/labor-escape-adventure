extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayFlowTextConfigScript := preload("res://scripts/ui/market_day_flow_text_config.gd")
const DayCompletionResultScript := preload("res://scripts/core/dayflow/day_completion_result.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const TextBlockPayloadKeysScript := preload("res://scripts/core/text_block_payload_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketDayFlowTextConfigScript.KEY_MARKET_CLOSE_REPORT == DayEventKeysScript.KEY_MARKET_CLOSE_REPORT, "close-report key should use the shared day-event key")
	_expect(MarketDayFlowTextConfigScript.KEY_GAME_CLEAR == PlayerStatusKeysScript.KEY_GAME_CLEAR, "game-clear key should use the shared player-status key")
	_expect(MarketDayFlowTextConfigScript.KEY_DAY_ACTION == DayEventKeysScript.KEY_DAY_ACTION, "day-action key should use the shared day-event key")
	_expect(MarketDayFlowTextConfigScript.KEY_NIGHT_EVENTS == DayEventKeysScript.KEY_NIGHT_EVENTS, "night-events key should use the shared day-event key")
	_expect(MarketDayFlowTextConfigScript.KEY_EVENT == DayEventKeysScript.KEY_EVENT, "event key should use the shared day-event key")
	_expect(MarketDayFlowTextConfigScript.KEY_UNREALIZED_PROFIT == MarketDataKeysScript.KEY_UNREALIZED_PROFIT, "unrealized-profit key should use the shared market data key")
	_expect(MarketDayFlowTextConfigScript.KEY_CLOSED_NAME == GameStateContextKeysScript.KEY_CLOSED_NAME, "closed-name key should use the shared context key")
	_expect(MarketDayFlowTextConfigScript.KEY_CLOSED_REASON == GameStateContextKeysScript.KEY_CLOSED_REASON, "closed-reason key should use the shared context key")
	_expect(MarketDayFlowTextConfigScript.KEY_TITLE == TextBlockPayloadKeysScript.KEY_TITLE, "title key should use the shared text-block key")
	_expect(MarketDayFlowTextConfigScript.KEY_BODY == TextBlockPayloadKeysScript.KEY_BODY, "body key should use the shared text-block key")
	_expect(MarketDayFlowTextConfigScript.CLOSED_REASON_WEEKEND == "weekend", "weekend reason should stay stable")
	_expect(MarketDayFlowTextConfigScript.WEEKEND_LABEL == "주말", "weekend label should stay stable")
	_expect(MarketDayFlowTextConfigScript.HOLIDAY_LABEL == "휴장일", "holiday label should stay stable")
	_expect(MarketDayFlowTextConfigScript.DEFAULT_DAY_ACTION_NAME == "하루", "default day-action name should stay stable")
	_expect(MarketDayFlowTextConfigScript.EMPTY_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "empty text should use the shared UI payload default")
	_expect(MarketDayFlowTextConfigScript.ORDER_ERROR_MARKET_CLOSED == MarketDataKeysScript.ERROR_MARKET_CLOSED, "market-closed order error should use the shared market error id")
	_expect(MarketDayFlowTextConfigScript.ORDER_ERROR_NOT_ENOUGH_CASH == MarketDataKeysScript.ERROR_NOT_ENOUGH_CASH, "cash order error should use the shared market error id")
	_expect(MarketDayFlowTextConfigScript.ORDER_ERROR_NOT_ENOUGH_SHARES == MarketDataKeysScript.ERROR_NOT_ENOUGH_SHARES, "shares order error should use the shared market error id")
	_expect(MarketDayFlowTextConfigScript.ORDER_ERROR_PRICE_MISSING == MarketDataKeysScript.ERROR_PRICE_MISSING, "price-missing order error should use the shared market error id")
	_expect(MarketDayFlowTextConfigScript.ORDER_ERROR_INVALID_QUANTITY == MarketDataKeysScript.ERROR_INVALID_QUANTITY, "invalid-quantity order error should use the shared market error id")
	_expect(MarketDayFlowTextConfigScript.FLOW_ERROR_DAY_ALREADY_COMPLETED == DayCompletionResultScript.ERROR_DAY_ALREADY_COMPLETED, "already-completed flow error should use the shared day-completion error id")
	_expect(MarketDayFlowTextConfigScript.FLOW_ERROR_DAY_NOT_COMPLETED == DayCompletionResultScript.ERROR_DAY_NOT_COMPLETED, "day-not-completed flow error should use the shared day-completion error id")
	_expect(MarketDayFlowTextConfigScript.FLOW_ERROR_FIRST_DAY_STOCK_REQUIRED == DayCompletionResultScript.ERROR_FIRST_DAY_STOCK_REQUIRED, "first-day-stock flow error should use the shared day-completion error id")
	_expect(MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_OVER == GameStateGuardResultScript.ERROR_GAME_OVER, "game-over flow error should use the shared game-state guard error id")
	_expect(MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_CLEAR == GameStateGuardResultScript.ERROR_GAME_CLEAR, "game-clear flow error should use the shared game-state guard error id")
	_expect(MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_NOT_STARTED == GameStateGuardResultScript.ERROR_GAME_NOT_STARTED, "game-not-started flow error should use the shared game-state guard error id")

	print("Market day-flow text config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
