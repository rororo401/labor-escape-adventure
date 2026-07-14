extends "res://scripts/tests/test_scene_tree.gd"

const PortfolioScript := preload("res://scripts/core/market/portfolio.gd")


func _initialize() -> void:
	var portfolio = PortfolioScript.new()
	portfolio.reset(5000)
	_expect(portfolio.cash == 5000, "portfolio reset should set starting cash")

	var invalid_buy := portfolio.buy("AAA", 0, 1000)
	_expect(String(invalid_buy.get("error", "")) == "invalid_quantity", "buy should reject invalid quantity")
	var cash_error := portfolio.buy("AAA", 99, 1000)
	_expect(String(cash_error.get("error", "")) == "not_enough_cash", "buy should reject cash shortage")
	var all_in_error := portfolio.buy("AAA", 5, 1000)
	_expect(String(all_in_error.get("error", "")) == "not_enough_cash", "buy should reject an order that would leave zero cash")
	_expect(portfolio.cash == 5000, "rejected all-in order should preserve cash")
	_expect(portfolio.get_total_quantity() == 0, "rejected all-in order should not create a position")

	var buy := portfolio.buy("AAA", 2, 1000)
	_expect(bool(buy.get("ok", false)), "buy should succeed")
	_expect(int(buy.get("cash_delta", 0)) == -2000, "buy should expose result cash delta")
	_expect(portfolio.cash == 3000, "buy should reduce cash")
	_expect(portfolio.get_total_quantity() == 2, "buy should increase total quantity")

	var oversell := portfolio.sell("AAA", 3, 1100)
	_expect(String(oversell.get("error", "")) == "not_enough_shares", "sell should reject oversell")
	var sell := portfolio.sell("AAA", 1, 1300)
	_expect(bool(sell.get("ok", false)), "sell should succeed")
	_expect(int(sell.get("cash_delta", 0)) == 1300, "sell should expose result cash delta")
	_expect(int(sell.get("realized_profit_delta", 0)) == 300, "sell should expose realized profit delta")
	_expect(portfolio.cash == 4300, "sell should increase cash")
	_expect(portfolio.get_total_quantity() == 1, "sell should reduce total quantity")

	var suspended_report := portfolio.mark_to_market(FakePriceRepository.new(), "2021-10-26", "open", "close")
	_expect(int(suspended_report.get("investment_assets", 0)) == 53400, "open valuation should fall back to the reference close when trading is suspended")

	print("Portfolio smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakePriceRepository:
	extends RefCounted

	func get_price(_ticker: String, _date: String) -> Dictionary:
		return {"open": 0, "close": 53400}
