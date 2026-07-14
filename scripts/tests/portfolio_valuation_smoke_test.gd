extends "res://scripts/tests/test_scene_tree.gd"

const PortfolioValuationScript := preload("res://scripts/core/market/portfolio_valuation.gd")


func _initialize() -> void:
	_verify_position_row()
	_verify_summary()

	print("Portfolio valuation smoke test passed.")
	finish_test()


func _verify_position_row() -> void:
	var row := PortfolioValuationScript.position_row("AAA", {
		"quantity": 3,
		"avg_cost": 1000
	}, 1200)
	_expect(row.get("ticker", "") == "AAA", "valuation row should keep ticker")
	_expect(int(row.get("quantity", 0)) == 3, "valuation row should keep quantity")
	_expect(int(row.get("avg_cost", 0)) == 1000, "valuation row should keep average cost")
	_expect(int(row.get("close", 0)) == 1200, "valuation row should use provided price")
	_expect(int(row.get("market_value", 0)) == 3600, "valuation row should calculate market value")
	_expect(int(row.get("cost_basis", 0)) == 3000, "valuation row should calculate cost basis")
	_expect(int(row.get("unrealized_profit", 0)) == 600, "valuation row should calculate unrealized profit")


func _verify_summary() -> void:
	var rows: Array[Dictionary] = [
		{
			"ticker": "AAA",
			"market_value": 3600,
			"cost_basis": 3000,
			"unrealized_profit": 600
		},
		{
			"ticker": "BBB",
			"market_value": 2000,
			"cost_basis": 2500,
			"unrealized_profit": -500
		}
	]
	var summary := PortfolioValuationScript.summary(10000, 700, rows)
	_expect(int(summary.get("cash", 0)) == 10000, "valuation summary should keep cash")
	_expect(int(summary.get("investment_assets", 0)) == 5600, "valuation summary should sum market value")
	_expect(int(summary.get("cost_basis", 0)) == 5500, "valuation summary should sum cost basis")
	_expect(int(summary.get("unrealized_profit", 0)) == 100, "valuation summary should calculate total unrealized profit")
	_expect(int(summary.get("realized_profit", 0)) == 700, "valuation summary should keep realized profit")
	_expect(int(summary.get("net_worth", 0)) == 15600, "valuation summary should calculate net worth")
	_expect(Array(summary.get("positions", [])).size() == 2, "valuation summary should preserve position rows")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
