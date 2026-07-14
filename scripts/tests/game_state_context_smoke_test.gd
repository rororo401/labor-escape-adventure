extends "res://scripts/tests/test_scene_tree.gd"

const GameStateContextScript := preload("res://scripts/core/game_state_context.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")


func _initialize() -> void:
	_expect(GameStateContextScript.day_mode(true) == GameStateContextKeysScript.DAY_MODE_MARKET_AND_LIFE, "trading days should use market_and_life mode")
	_expect(GameStateContextScript.day_mode(false) == GameStateContextKeysScript.DAY_MODE_LIFE_ONLY, "closed days should use life_only mode")
	_expect(GameStateContextScript.market_phase(true) == GameStateContextKeysScript.MARKET_PHASE_MORNING_ORDER, "trading markets should use morning_order phase")
	_expect(GameStateContextScript.market_phase(false) == GameStateContextKeysScript.MARKET_PHASE_CLOSED, "closed markets should use closed phase")
	_expect(GameStateContextScript.today_context({}, {}, {}, [], {}, {}, false, "", false, "").is_empty(), "empty day should build empty context")
	_expect(GameStateContextScript.market_context({}, {}).is_empty(), "empty day should build empty market context")

	var market_context: Dictionary = GameStateContextScript.market_context(
		{
			GameStateContextKeysScript.KEY_DATE: "2016-07-01",
			GameStateContextKeysScript.KEY_IS_TRADING_DAY: true,
			GameStateContextKeysScript.KEY_REASON: "",
			GameStateContextKeysScript.KEY_NAME: ""
		},
		{
			GameStateContextKeysScript.KEY_DATE: "2016-07-01",
			MarketDataKeysScript.KEY_PREVIOUS_TRADING_DATE: "",
			MarketDataKeysScript.KEY_STOCKS: [
				{
					MarketDataKeysScript.KEY_TICKER: "005930"
				}
			],
			MarketDataKeysScript.KEY_PORTFOLIO: {
				PlayerStatusKeysScript.KEY_CASH: 5000000
			}
		}
	)
	_expect(market_context.get(GameStateContextKeysScript.KEY_CALENDAR_DATE, "") == "2016-07-01", "market context should keep the calendar date")
	_expect(market_context.get(GameStateContextKeysScript.KEY_DATE, "") == "2016-07-01", "market context should keep the pricing date")
	_expect(market_context.get(GameStateContextKeysScript.KEY_IS_OPEN, false), "trading market context should be open")
	_expect(market_context.get(GameStateContextKeysScript.KEY_PHASE, "") == GameStateContextKeysScript.MARKET_PHASE_MORNING_ORDER, "trading market context phase mismatch")
	_expect(Array(market_context.get(MarketDataKeysScript.KEY_STOCKS, [])).size() == 1, "market context should preserve stock rows")
	_expect(market_context.get(MarketDataKeysScript.KEY_PORTFOLIO, {}).get(PlayerStatusKeysScript.KEY_CASH, 0) == 5000000, "market context should preserve portfolio data")

	var closed_market_context: Dictionary = GameStateContextScript.market_context(
		{
			GameStateContextKeysScript.KEY_DATE: "2016-07-02",
			GameStateContextKeysScript.KEY_IS_TRADING_DAY: false,
			GameStateContextKeysScript.KEY_REASON: "weekend",
			GameStateContextKeysScript.KEY_NAME: ""
		},
		{
			GameStateContextKeysScript.KEY_DATE: "2016-07-01",
			MarketDataKeysScript.KEY_STOCKS: []
		}
	)
	_expect(closed_market_context.get(GameStateContextKeysScript.KEY_CALENDAR_DATE, "") == "2016-07-02", "closed market context should keep calendar date")
	_expect(closed_market_context.get(GameStateContextKeysScript.KEY_DATE, "") == "2016-07-01", "closed market context should keep previous pricing date")
	_expect(not closed_market_context.get(GameStateContextKeysScript.KEY_IS_OPEN, true), "closed market context should be closed")
	_expect(closed_market_context.get(GameStateContextKeysScript.KEY_CLOSED_REASON, "") == "weekend", "closed market context should keep reason")
	_expect(closed_market_context.get(GameStateContextKeysScript.KEY_PHASE, "") == GameStateContextKeysScript.MARKET_PHASE_CLOSED, "closed market context phase mismatch")

	var base_flow := {
		DayEventKeysScript.KEY_DEFAULT_ACTION: {
			DayEventKeysScript.KEY_ID: DayEventKeysScript.ACTION_COMPANY_WORK
		},
		DayEventKeysScript.KEY_AVAILABLE_CHOICES: []
	}
	var last_result := {
		GameStateContextKeysScript.KEY_DATE: "2016-07-01"
	}
	var day_flow: Dictionary = GameStateContextScript.day_flow_context(base_flow, true, last_result)
	_expect(day_flow.get(GameStateContextKeysScript.KEY_DAY_COMPLETED, false), "day flow context should keep completion state")
	_expect(day_flow.get(GameStateContextKeysScript.KEY_LAST_DAY_RESULT, {}).get(GameStateContextKeysScript.KEY_DATE, "") == "2016-07-01", "day flow context should keep last result")
	_expect(day_flow.get(DayEventKeysScript.KEY_DEFAULT_ACTION, {}).get(DayEventKeysScript.KEY_ID, "") == DayEventKeysScript.ACTION_COMPANY_WORK, "day flow context should keep base fields")
	_expect(not base_flow.has(GameStateContextKeysScript.KEY_DAY_COMPLETED), "day flow context should not mutate the source flow")
	last_result[GameStateContextKeysScript.KEY_DATE] = "changed"
	_expect(day_flow.get(GameStateContextKeysScript.KEY_LAST_DAY_RESULT, {}).get(GameStateContextKeysScript.KEY_DATE, "") == "2016-07-01", "day flow context should duplicate the last result")

	var report := {
		PlayerStatusKeysScript.KEY_NET_WORTH: 5000000,
		MarketDataKeysScript.KEY_PORTFOLIO: {
			PlayerStatusKeysScript.KEY_CASH: 5000000
		}
	}
	var status_snapshot := {
		PlayerStatusKeysScript.KEY_CASH: 5000000,
		PlayerStatusKeysScript.KEY_TARGET_NET_WORTH: 1000000000
	}
	var report_with_status: Dictionary = GameStateContextScript.report_with_status(report, status_snapshot)
	_expect(report_with_status.get(PlayerStatusKeysScript.KEY_NET_WORTH, 0) == 5000000, "report context should keep valuation fields")
	_expect(report_with_status.get(GameStateContextKeysScript.KEY_STATUS, {}).get(PlayerStatusKeysScript.KEY_CASH, 0) == 5000000, "report context should attach status")
	_expect(not report.has(GameStateContextKeysScript.KEY_STATUS), "report context should not mutate the source report")
	status_snapshot[PlayerStatusKeysScript.KEY_CASH] = 0
	_expect(report_with_status.get(GameStateContextKeysScript.KEY_STATUS, {}).get(PlayerStatusKeysScript.KEY_CASH, 0) == 5000000, "report context should duplicate status")

	var trading_context: Dictionary = GameStateContextScript.today_context(
		{
			GameStateContextKeysScript.KEY_DATE: "2016-07-01",
			GameStateContextKeysScript.KEY_WEEKDAY: "Friday",
			GameStateContextKeysScript.KEY_IS_TRADING_DAY: true,
			GameStateContextKeysScript.KEY_REASON: "",
			GameStateContextKeysScript.KEY_NAME: ""
		},
		{
			GameStateContextKeysScript.KEY_IS_OPEN: true
		},
		{
			DayEventKeysScript.KEY_DEFAULT_ACTION: {
				DayEventKeysScript.KEY_ID: DayEventKeysScript.ACTION_COMPANY_WORK
			}
		},
		[
			{
				DayEventKeysScript.KEY_ID: DayEventKeysScript.ACTION_GO_TO_WORK_ALIAS
			}
		],
		{
			"protagonist": {
				"outfits": ["homewear"]
			}
		},
		{
			PlayerStatusKeysScript.KEY_CASH: 5000000
		},
		false,
		"",
		false,
		""
	)
	_expect(trading_context.get(GameStateContextKeysScript.KEY_DATE, "") == "2016-07-01", "today context should keep the date")
	_expect(trading_context.get(GameStateContextKeysScript.KEY_DAY_MODE, "") == GameStateContextKeysScript.DAY_MODE_MARKET_AND_LIFE, "trading context mode mismatch")
	_expect(trading_context.get(GameStateContextKeysScript.KEY_MARKET_PHASE_AVAILABLE, false), "trading context should expose market phase")
	_expect(trading_context.get(GameStateContextKeysScript.KEY_MARKET, {}).get(GameStateContextKeysScript.KEY_IS_OPEN, false), "trading context should keep market data")
	_expect(trading_context.get(GameStateContextKeysScript.KEY_DAY_FLOW, {}).get(DayEventKeysScript.KEY_DEFAULT_ACTION, {}).get(DayEventKeysScript.KEY_ID, "") == DayEventKeysScript.ACTION_COMPANY_WORK, "trading context should keep day flow")
	_expect(Array(trading_context.get(GameStateContextKeysScript.KEY_AVAILABLE_LIFE_ACTIONS, [])).size() == 1, "trading context should keep life actions")
	_expect(trading_context.get(GameStateContextKeysScript.KEY_CHARACTER_ASSETS, {}).has("protagonist"), "trading context should keep character assets")
	_expect(not trading_context.get(GameStateContextKeysScript.KEY_GAME_FINISHED, true), "fresh trading context should not be finished")

	var closed_context: Dictionary = GameStateContextScript.today_context(
		{
			GameStateContextKeysScript.KEY_DATE: "2016-07-02",
			GameStateContextKeysScript.KEY_WEEKDAY: "Saturday",
			GameStateContextKeysScript.KEY_IS_TRADING_DAY: false,
			GameStateContextKeysScript.KEY_REASON: "weekend",
			GameStateContextKeysScript.KEY_NAME: ""
		},
		{
			GameStateContextKeysScript.KEY_IS_OPEN: false
		},
		{},
		[],
		{},
		{
			PlayerStatusKeysScript.KEY_CASH: 0
		},
		true,
		PlayerStatusKeysScript.GAME_OVER_REASON_CASH_ZERO,
		false,
		""
	)
	_expect(closed_context.get(GameStateContextKeysScript.KEY_DAY_MODE, "") == GameStateContextKeysScript.DAY_MODE_LIFE_ONLY, "closed context mode mismatch")
	_expect(not closed_context.get(GameStateContextKeysScript.KEY_MARKET_PHASE_AVAILABLE, true), "closed context should hide market phase")
	_expect(closed_context.get(GameStateContextKeysScript.KEY_CLOSED_REASON, "") == "weekend", "closed context should keep closed reason")
	_expect(closed_context.get(GameStateContextKeysScript.KEY_GAME_OVER, false), "closed context should keep game-over flag")
	_expect(closed_context.get(GameStateContextKeysScript.KEY_GAME_OVER_REASON, "") == PlayerStatusKeysScript.GAME_OVER_REASON_CASH_ZERO, "closed context should keep game-over reason")
	_expect(closed_context.get(GameStateContextKeysScript.KEY_GAME_FINISHED, false), "game-over context should be finished")

	var clear_context: Dictionary = GameStateContextScript.today_context(
		{
			GameStateContextKeysScript.KEY_IS_TRADING_DAY: true
		},
		{},
		{},
		[],
		{},
		{},
		false,
		"",
		true,
		PlayerStatusKeysScript.CLEAR_REASON_TARGET_NET_WORTH
	)
	_expect(clear_context.get(GameStateContextKeysScript.KEY_GAME_CLEAR, false), "clear context should keep game-clear flag")
	_expect(clear_context.get(GameStateContextKeysScript.KEY_CLEAR_REASON, "") == PlayerStatusKeysScript.CLEAR_REASON_TARGET_NET_WORTH, "clear context should keep clear reason")
	_expect(clear_context.get(GameStateContextKeysScript.KEY_GAME_FINISHED, false), "clear context should be finished")

	print("Game state context smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
