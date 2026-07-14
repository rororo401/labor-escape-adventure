extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketReportStateScript := preload("res://scripts/ui/market_report_state.gd")
const MarketStatusTextConfigScript := preload("res://scripts/ui/market_status_text_config.gd")


func _initialize() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up first trading day")

	_expect(not MarketReportStateScript.should_use_close_report(game, false), "fresh trading day should use open report")
	_expect(MarketReportStateScript.should_use_close_report(game, true), "explicit close report flag should use close report")
	var open_report: Dictionary = MarketReportStateScript.valuation_report(game, false)
	var close_report: Dictionary = MarketReportStateScript.valuation_report(game, true)
	_expect(open_report.has(MarketStatusTextConfigScript.KEY_NET_WORTH), "open valuation should include net worth")
	_expect(close_report.has(MarketStatusTextConfigScript.KEY_NET_WORTH), "close valuation should include net worth")

	var status_text: Dictionary = MarketReportStateScript.status_texts(game, game.get_market_context(), false)
	_expect(String(status_text.get(MarketStatusTextConfigScript.KEY_CASH, "")).contains(MarketStatusTextConfigScript.CASH_LABEL), "status text should include cash label")
	_expect(String(status_text.get(MarketStatusTextConfigScript.KEY_NET_WORTH, "")).contains(MarketStatusTextConfigScript.NET_WORTH_LABEL), "status text should include net worth label")
	_expect(MarketReportStateScript.completed_day_message(game).is_empty(), "unfinished day should not expose a completed-day message")

	var stocks: Array = game.get_market_context().get("stocks", [])
	_expect(not stocks.is_empty(), "test game should have stocks")
	var ticker := String(Dictionary(stocks[0]).get("ticker", ""))
	_expect(game.submit_market_order(ticker, "buy", 1).get("ok", false), "test should buy one share")
	var result: Dictionary = game.complete_today("company_work", [], true)
	_expect(result.get("ok", false), "test should complete the day")
	_expect(MarketReportStateScript.should_use_close_report(game, false), "completed day should use close report")
	_expect(MarketReportStateScript.completed_day_message(game).contains("완료"), "completed day message should format the last result")

	_expect(MarketReportStateScript.valuation_report(null, false).is_empty(), "missing game should return empty valuation")
	_expect(MarketReportStateScript.status_texts(null, {}, false).has(MarketStatusTextConfigScript.KEY_CASH), "missing game should still return status text shape")
	_expect(MarketReportStateScript.completed_day_message(null).is_empty(), "missing game should not expose completed-day message")

	print("Market report state smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
