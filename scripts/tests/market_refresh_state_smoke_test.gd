extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketRefreshStateConfigScript := preload("res://scripts/ui/market_refresh_state_config.gd")
const MarketRefreshStateScript := preload("res://scripts/ui/market_refresh_state.gd")


func _initialize() -> void:
	var missing_game := MarketRefreshStateScript.build(null, {}, {}, false)
	_expect(not bool(missing_game.get(MarketRefreshStateConfigScript.KEY_MARKET_OPEN, true)), "missing game should be treated as closed")
	_expect(Dictionary(missing_game.get(MarketRefreshStateConfigScript.KEY_STATUS_TEXT, {})).has(MarketRefreshStateConfigScript.KEY_STATUS_CASH), "missing game should still expose status text")
	_expect(Dictionary(missing_game.get(MarketRefreshStateConfigScript.KEY_STATUS_SNAPSHOT, {"bad": true})).is_empty(), "missing game should expose an empty status snapshot")

	var trading_game := GameStateScript.new()
	_expect(trading_game.setup("2016-07-01"), "trading game should set up")
	var market_context: Dictionary = trading_game.get_market_context()
	var stocks: Array = market_context.get("stocks", [])
	_expect(not stocks.is_empty(), "trading refresh should have stock rows")

	var initial_state := MarketRefreshStateScript.build(trading_game, market_context, {}, false)
	_expect(bool(initial_state.get(MarketRefreshStateConfigScript.KEY_MARKET_OPEN, false)), "trading day should be open")
	_expect(String(initial_state.get(MarketRefreshStateConfigScript.KEY_DATE_TEXT, "")).contains("금요일 아침"), "trading refresh should include date label")
	_expect(int(Dictionary(initial_state.get(MarketRefreshStateConfigScript.KEY_STATUS_SNAPSHOT, {})).get("health", 0)) == 100, "trading refresh should expose status snapshot")
	_expect(Array(initial_state.get(MarketRefreshStateConfigScript.KEY_STOCKS, [])).size() == stocks.size(), "trading refresh should preserve stock rows")
	_expect(not Dictionary(initial_state.get(MarketRefreshStateConfigScript.KEY_SELECTED_STOCK, {})).is_empty(), "trading refresh should select a default stock")
	_expect(String(initial_state.get(MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE, "")).is_empty(), "unfinished trading day should not show completed message")

	var second_stock := Dictionary(stocks[min(1, stocks.size() - 1)])
	var kept_state := MarketRefreshStateScript.build(trading_game, market_context, second_stock, false)
	_expect(
		String(kept_state.get(MarketRefreshStateConfigScript.KEY_SELECTED_STOCK, {}).get("ticker", "")) == String(second_stock.get("ticker", "")),
		"trading refresh should preserve a still-visible selected stock"
	)

	var ticker := String(Dictionary(stocks[0]).get("ticker", ""))
	_expect(trading_game.submit_market_order(ticker, "buy", 1).get("ok", false), "test should buy one share")
	_expect(trading_game.complete_today("company_work", [], true).get("ok", false), "test should complete the trading day")
	var completed_state := MarketRefreshStateScript.build(trading_game, trading_game.get_market_context(), kept_state.get(MarketRefreshStateConfigScript.KEY_SELECTED_STOCK, {}), false)
	_expect(String(completed_state.get(MarketRefreshStateConfigScript.KEY_DATE_TEXT, "")).contains("장마감"), "completed trading refresh should use market-close date label")
	_expect(String(completed_state.get(MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE, "")).contains("완료"), "completed trading refresh should expose completion message")

	var closed_game := GameStateScript.new()
	_expect(closed_game.setup("2016-07-02"), "closed game should set up")
	var closed_state := MarketRefreshStateScript.build(closed_game, closed_game.get_market_context(), second_stock, false)
	_expect(not bool(closed_state.get(MarketRefreshStateConfigScript.KEY_MARKET_OPEN, true)), "closed day should not be open")
	_expect(Dictionary(closed_state.get(MarketRefreshStateConfigScript.KEY_SELECTED_STOCK, {"bad": true})).is_empty(), "closed day should clear selected stock")
	_expect(String(closed_state.get(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TEXT, {}).get(MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TITLE, "")).contains("장이 열리지 않는다"), "closed day should expose closed-day title")

	print("Market refresh state smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
