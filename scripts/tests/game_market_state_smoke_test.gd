extends "res://scripts/tests/test_scene_tree.gd"

const GameMarketStateScript := preload("res://scripts/core/market/game_market_state.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")


func _initialize() -> void:
	_verify_trading_market_context()
	_verify_closed_day_pricing_date()
	_verify_summer_vacation_market_closed()
	_verify_order_status_sync()
	_verify_cash_zero_with_holdings_is_recoverable()
	_verify_failed_suspended_order_preserves_solvency()
	print("Game market state smoke test passed.")
	finish_test()


func _verify_trading_market_context() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up first trading day")
	var context := GameMarketStateScript.get_market_context(game)
	_expect(context.get("date", "") == "2016-07-01", "market context should keep current date")
	_expect(bool(context.get("is_open", false)), "first trading day should be open")
	_expect(Array(context.get("stocks", [])).size() == 30, "market context should include 30 stocks")
	_expect(GameMarketStateScript.previous_trading_date(game).is_empty(), "first day should not have a previous trading date")


func _verify_closed_day_pricing_date() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-02"), "game should set up first closed day")
	var day: Dictionary = game.calendar.get_day(game.day_index)
	_expect(GameMarketStateScript.previous_trading_date(game) == "2016-07-01", "closed Saturday should use Friday as previous trading day")
	_expect(GameMarketStateScript.pricing_date_for_day(game, day) == "2016-07-01", "closed day pricing should use previous trading date")
	var context := GameMarketStateScript.get_market_context(game)
	_expect(not bool(context.get("is_open", true)), "closed day market context should be closed")
	_expect(Array(context.get("stocks", [])).size() == 30, "closed day context should still expose last market snapshot")


func _verify_summer_vacation_market_closed() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-08-01"), "game should set up first summer vacation day")
	var day: Dictionary = game.calendar.get_day(game.day_index)
	var context := GameMarketStateScript.get_market_context(game)
	_expect(not bool(context.get("is_open", true)), "summer vacation market context should be closed")
	_expect(context.get("closed_reason", "") == "summer_vacation", "summer vacation closed reason mismatch")
	_expect(context.get("closed_name", "") == "여름휴가", "summer vacation closed name mismatch")
	_expect(GameMarketStateScript.pricing_date_for_day(game, day) == "2016-07-29", "summer vacation pricing should use the previous trading date")
	_expect(Dictionary(context.get("market_fixed_event", {})).is_empty(), "summer vacation should suppress market fixed events")
	var result := GameMarketStateScript.submit_market_order(game, "005930", "buy", 1)
	_expect(not bool(result.get("ok", true)), "summer vacation order should fail")
	_expect(String(result.get("error", "")) == "market_closed", "summer vacation order should be market closed")


func _verify_order_status_sync() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up order day")
	var result := GameMarketStateScript.submit_market_order(game, "005930", "buy", 1)
	_expect(result.get("ok", false), "market order should succeed")
	_expect(game.status.cash == 4971460, "submit order should sync status cash")
	var close_report := GameMarketStateScript.get_market_close_report(game)
	_expect(int(close_report.get("investment_assets", 0)) == 29320, "close report should value holdings at close")
	_expect(game.status.investment_assets == 29320, "close report should sync investment assets")


func _verify_cash_zero_with_holdings_is_recoverable() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "recoverable cash-zero game should set up")
	_expect(GameMarketStateScript.submit_market_order(game, "005930", "buy", 1).get("ok", false), "recovery fixture should buy one share")
	game.market.set_cash_balance(0)
	game.status.cash = 0
	_expect(game.status.investment_assets > 0, "recovery fixture should retain investment assets")
	_expect(not game.is_game_over(), "cash zero with a valued holding should not be game over")
	var sell := GameMarketStateScript.submit_market_order(game, "005930", "sell", 1)
	_expect(sell.get("ok", false), "cash-zero player should be able to liquidate a holding")
	_expect(game.status.cash == 28540, "successful liquidation should restore cash")

	var completion_game := GameStateScript.new()
	_expect(completion_game.setup("2016-07-01"), "cash-zero completion game should set up")
	_expect(GameMarketStateScript.submit_market_order(completion_game, "005930", "buy", 1).get("ok", false), "completion fixture should buy one share")
	completion_game.market.set_cash_balance(0)
	completion_game.status.cash = 0
	_expect(completion_game.complete_today("company_work", [], true).get("ok", false), "cash zero with a valued holding should still allow day completion")


func _verify_failed_suspended_order_preserves_solvency() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2021-10-26"), "suspended-stock game should set up")
	game.market.portfolio.positions["017670"] = {
		"ticker": "017670",
		"quantity": 1,
		"avg_cost": 53400
	}
	game.market.set_cash_balance(0)
	game.status.cash = 0
	game.refresh_status_from_current_phase()
	_expect(game.status.investment_assets == 53400, "suspended holding should retain its last reference valuation")
	_expect(not game.is_game_over(), "suspended holding with reference value should remain solvent")
	var failed_sell := GameMarketStateScript.submit_market_order(game, "017670", "sell", 1)
	_expect(not failed_sell.get("ok", true), "suspended stock should reject an order without an opening price")
	_expect(failed_sell.get("error", "") == "price_missing", "suspended stock should report a missing executable price")
	_expect(game.status.investment_assets == 53400, "failed order must not erase the last known investment valuation")
	_expect(not game.is_game_over(), "failed suspended order must not manufacture a cash-zero game over")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
