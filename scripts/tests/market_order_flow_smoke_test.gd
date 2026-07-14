extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketOrderFlowConfigScript := preload("res://scripts/ui/market_order_flow_config.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")
const MarketOrderFlowScript := preload("res://scripts/ui/market_order_flow.gd")


func _initialize() -> void:
	var missing_stock := MarketOrderFlowScript.submit(null, {}, "buy", 1)
	_expect(not bool(missing_stock.get(MarketOrderFlowConfigScript.KEY_HANDLED, true)), "missing stock should not submit an order")
	_expect(String(missing_stock.get(MarketOrderFlowConfigScript.KEY_REQUEST, {}).get(MarketOrderFlowConfigScript.KEY_ERROR, "")) == "stock_not_selected", "missing stock should preserve request error")

	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up a trading day")
	var stock: Dictionary = Dictionary(game.get_market_context().get("stocks", [])[0])
	var buy_flow := MarketOrderFlowScript.submit(game, stock, "buy", 1)
	_expect(bool(buy_flow.get(MarketOrderFlowConfigScript.KEY_HANDLED, false)), "valid stock should submit an order")
	_expect(bool(buy_flow.get(MarketOrderFlowConfigScript.KEY_RESULT, {}).get(MarketOrderFlowConfigScript.KEY_OK, false)), "buy order should succeed")
	_expect(String(buy_flow.get(MarketOrderFlowConfigScript.KEY_MESSAGE, "")).contains("매수 1주 체결"), "buy order should expose a success message")
	_expect(not bool(buy_flow.get(MarketOrderFlowConfigScript.KEY_STATE, {}).get(MarketScreenStateConfigScript.KEY_SHOWING_CLOSE_REPORT, true)), "order flow should hide close report")
	_expect(game.get_total_held_quantity() == 1, "buy order should update holdings")

	var expensive_quantity := 999
	var cash_error := MarketOrderFlowScript.submit(game, stock, "buy", expensive_quantity)
	_expect(bool(cash_error.get(MarketOrderFlowConfigScript.KEY_HANDLED, false)), "cash shortage should still be handled")
	_expect(not bool(cash_error.get(MarketOrderFlowConfigScript.KEY_RESULT, {}).get(MarketOrderFlowConfigScript.KEY_OK, true)), "cash shortage should fail backend order")
	_expect(String(cash_error.get(MarketOrderFlowConfigScript.KEY_RESULT, {}).get(MarketOrderFlowConfigScript.KEY_ERROR, "")) == "not_enough_cash", "cash shortage should preserve backend error")
	_expect(String(cash_error.get(MarketOrderFlowConfigScript.KEY_MESSAGE, "")) == "현금이 부족하다.", "cash shortage should expose a user-facing message")

	print("Market order flow smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
