extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketDayFlowTextConfigScript := preload("res://scripts/ui/market_day_flow_text_config.gd")
const MarketStatusTextConfigScript := preload("res://scripts/ui/market_status_text_config.gd")


func _initialize() -> void:
	var game = GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should start on the first tutorial day")

	_expect(MarketDayFlowTextScript.ready_text(null) == "오늘 하루 보내기", "missing game should use default flow text")
	_expect(MarketDayFlowTextScript.ready_text(game) == "1주 매수 필요", "first tutorial day should require one share")

	var stocks: Array = game.get_market_context().get("stocks", [])
	_expect(not stocks.is_empty(), "first market day should have stocks")
	var ticker := String(Dictionary(stocks[0]).get("ticker", ""))
	_expect(game.submit_market_order(ticker, "buy", 1).get("ok", false), "tutorial buy should succeed")
	_expect(MarketDayFlowTextScript.ready_text(game) == "회사 출근하기", "first tutorial day should allow work after buying")

	var day_result: Dictionary = game.complete_today("company_work", [], true)
	_expect(day_result.get("ok", false), "day completion should succeed after tutorial buy")
	var result_text := MarketDayFlowTextScript.format_day_result(day_result)
	_expect(result_text.contains("완료"), "result text should include the completed day action")
	_expect(result_text.contains("평가손익"), "result text should include valuation change")
	_expect(MarketDayFlowTextScript.ready_text(game) == "오늘 하루 보내기", "completed day should use default ready text")

	var night_result := {
		MarketDayFlowTextConfigScript.KEY_MARKET_CLOSE_REPORT: {
			MarketDayFlowTextConfigScript.KEY_UNREALIZED_PROFIT: 1234
		},
		MarketDayFlowTextConfigScript.KEY_DAY_ACTION: {
			MarketDayFlowTextConfigScript.KEY_EVENT: {
				MarketDayActionOptionsConfigScript.ACTION_NAME: "산책하기"
			}
		},
		MarketDayFlowTextConfigScript.KEY_NIGHT_EVENTS: [
			{
				MarketDayFlowTextConfigScript.KEY_EVENT: {
					MarketDayActionOptionsConfigScript.ACTION_NAME: "일찍 잠들기"
				}
			}
		]
	}
	_expect(MarketDayFlowTextScript.format_day_result(night_result).contains("밤: 일찍 잠들기"), "result text should include the first night event")

	var clear_result := {
		MarketDayFlowTextConfigScript.KEY_GAME_CLEAR: true,
		MarketDayFlowTextConfigScript.KEY_MARKET_CLOSE_REPORT: {
			MarketStatusTextConfigScript.KEY_NET_WORTH: 1000000000
		}
	}
	_expect(MarketDayFlowTextScript.format_day_result(clear_result).contains("10억, 진짜 찍었다!"), "clear result should show the clear message")

	var bad_ending_result := {
		MarketDayFlowTextConfigScript.KEY_GAME_OVER: true,
		MarketDayFlowTextConfigScript.KEY_GAME_OVER_REASON: "final_bad_ending",
		MarketDayFlowTextConfigScript.KEY_ENDING_TITLE_KO: "한 발 모자란 탈출",
		MarketDayFlowTextConfigScript.KEY_MARKET_CLOSE_REPORT: {
			MarketStatusTextConfigScript.KEY_NET_WORTH: 500000000
		}
	}
	_expect(MarketDayFlowTextScript.format_day_result(bad_ending_result).contains("배드엔딩"), "bad ending result should show bad-ending label")
	_expect(MarketDayFlowTextScript.format_day_result(bad_ending_result).contains("한 발 모자란 탈출"), "bad ending result should show route title")

	var weekend_text: Dictionary = MarketDayFlowTextScript.closed_day_text({
		MarketDayFlowTextConfigScript.KEY_CLOSED_REASON: MarketDayFlowTextConfigScript.CLOSED_REASON_WEEKEND
	})
	_expect(String(weekend_text.get(MarketDayFlowTextConfigScript.KEY_TITLE, "")) == "주말, 장이 열리지 않는다", "weekend closed day should use weekend title")
	_expect(String(weekend_text.get(MarketDayFlowTextConfigScript.KEY_BODY, "")).contains("주식 매매를 할 수 없다"), "closed day body should explain unavailable trading")

	var holiday_text: Dictionary = MarketDayFlowTextScript.closed_day_text({
		MarketDayFlowTextConfigScript.KEY_CLOSED_NAME: "광복절"
	})
	_expect(String(holiday_text.get(MarketDayFlowTextConfigScript.KEY_TITLE, "")) == "광복절, 장이 열리지 않는다", "named closed day should use the calendar name")
	var generic_text: Dictionary = MarketDayFlowTextScript.closed_day_text({
		MarketDayFlowTextConfigScript.KEY_CLOSED_REASON: "holiday"
	})
	_expect(String(generic_text.get(MarketDayFlowTextConfigScript.KEY_TITLE, "")) == "휴장일, 장이 열리지 않는다", "unnamed holiday should use the generic title")

	var action_flow := {
		MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CHOICES: [
			{
				MarketDayActionOptionsConfigScript.ACTION_ID: "river_walk",
				MarketDayActionOptionsConfigScript.ACTION_NAME: "한강 산책하기"
			}
		],
		MarketDayActionOptionsConfigScript.FLOW_DEFAULT_ACTION: {
			MarketDayActionOptionsConfigScript.ACTION_ID: "company_work",
			MarketDayActionOptionsConfigScript.ACTION_NAME: "회사 업무"
		}
	}
	_expect(MarketDayFlowTextScript.day_action_name(action_flow, "river_walk") == "한강 산책하기", "day action name should resolve available choices")
	_expect(MarketDayFlowTextScript.day_action_name(action_flow, "company_work") == "회사 업무", "day action name should resolve default action")
	_expect(MarketDayFlowTextScript.day_action_name(action_flow, "missing") == "missing", "missing action name should fall back to id")

	_expect(MarketDayFlowTextScript.order_success_message(MarketDataKeysScript.SIDE_BUY, 3, 12345) == "매수 3주 체결  12,345원", "buy success message should include side, quantity, and price")
	_expect(MarketDayFlowTextScript.order_success_message(MarketDataKeysScript.SIDE_SELL, 2, 5000) == "매도 2주 체결  5,000원", "sell success message should include side, quantity, and price")
	var status_texts: Dictionary = MarketDayFlowTextScript.status_texts({
		MarketStatusTextConfigScript.KEY_CASH: 1234567
	}, {
		MarketStatusTextConfigScript.KEY_NET_WORTH: 7654321
	})
	_expect(status_texts.get(MarketStatusTextConfigScript.KEY_CASH, "") == "현금\n1,234,567원", "status text should format cash")
	_expect(status_texts.get(MarketStatusTextConfigScript.KEY_NET_WORTH, "") == "순자산\n7,654,321원", "status text should format net worth")
	var fallback_status_texts: Dictionary = MarketDayFlowTextScript.status_texts({}, {
		MarketStatusTextConfigScript.KEY_CASH: 3210,
		MarketStatusTextConfigScript.KEY_NET_WORTH: 6540
	})
	_expect(fallback_status_texts.get(MarketStatusTextConfigScript.KEY_CASH, "") == "현금\n3,210원", "status text should fall back to valuation cash")

	_expect(MarketDayFlowTextScript.order_error_message(MarketDayFlowTextConfigScript.ORDER_ERROR_NOT_ENOUGH_CASH) == "현금이 부족하다.", "order error text should cover cash shortage")
	_expect(MarketDayFlowTextScript.order_error_message("unknown") == "주문을 처리하지 못했다.", "unknown order error should fall back")
	_expect(MarketDayFlowTextScript.flow_error_message(MarketDayFlowTextConfigScript.FLOW_ERROR_DAY_NOT_COMPLETED) == "아직 잠들기엔 오늘 일이 남았다.", "flow error text should cover unfinished day")
	_expect(MarketDayFlowTextScript.flow_error_message(MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_NOT_STARTED) == "게임 세션을 찾지 못했다.", "flow error text should cover missing game sessions")
	_expect(MarketDayFlowTextScript.flow_error_message("unknown") == "하루 진행을 처리하지 못했다.", "unknown flow error should fall back")

	print("Market day flow text smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
