extends "res://scripts/tests/test_scene_tree.gd"

const PortfolioOrderResultScript := preload("res://scripts/core/market/portfolio_order_result.gd")


func _initialize() -> void:
	_verify_buy_success_payload()
	_verify_sell_success_payload()
	_verify_error_payload()

	print("Portfolio order result smoke test passed.")
	finish_test()


func _verify_buy_success_payload() -> void:
	var position := {
		"ticker": "AAA",
		"quantity": 2,
		"avg_cost": 1000
	}
	var result := PortfolioOrderResultScript.buy_success("AAA", 2, 1000, 2000, 3000, position)
	_expect(bool(result.get("ok", false)), "buy result should be ok")
	_expect(String(result.get("side", "")) == "buy", "buy result should preserve side")
	_expect(int(result.get("cash_delta", 0)) == -2000, "buy result should expose negative cash delta")
	_expect(int(result.get("cash_after", 0)) == 3000, "buy result should expose cash after")
	_expect(int(result.get("position", {}).get("quantity", 0)) == 2, "buy result should duplicate position")

	position["quantity"] = 99
	_expect(int(result.get("position", {}).get("quantity", 0)) == 2, "buy result position should not mutate with source")


func _verify_sell_success_payload() -> void:
	var position := {
		"ticker": "AAA",
		"quantity": 1,
		"avg_cost": 1000
	}
	var result := PortfolioOrderResultScript.sell_success("AAA", 1, 1200, 1200, 6200, 200, 500, position)
	_expect(bool(result.get("ok", false)), "sell result should be ok")
	_expect(String(result.get("side", "")) == "sell", "sell result should preserve side")
	_expect(int(result.get("cash_delta", 0)) == 1200, "sell result should expose positive cash delta")
	_expect(int(result.get("realized_profit_delta", 0)) == 200, "sell result should expose realized profit delta")
	_expect(int(result.get("realized_profit", 0)) == 500, "sell result should expose cumulative realized profit")


func _verify_error_payload() -> void:
	var result := PortfolioOrderResultScript.error("not_enough_cash", 1000)
	_expect(not bool(result.get("ok", true)), "error result should not be ok")
	_expect(String(result.get("error", "")) == "not_enough_cash", "error result should preserve code")
	_expect(int(result.get("cash_after", 0)) == 1000, "error result should expose cash after")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
