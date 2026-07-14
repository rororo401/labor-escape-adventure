extends "res://scripts/tests/test_scene_tree.gd"

const PortfolioOrderMathScript := preload("res://scripts/core/market/portfolio_order_math.gd")


func _initialize() -> void:
	_verify_buy_update()
	_verify_sell_update()

	print("Portfolio order math smoke test passed.")
	finish_test()


func _verify_buy_update() -> void:
	var first_buy := PortfolioOrderMathScript.buy_update({}, "AAA", 2, 1000)
	_expect(int(first_buy.get("cost", 0)) == 2000, "first buy should calculate cost")
	_expect(int(first_buy.get("position", {}).get("quantity", 0)) == 2, "first buy should set quantity")
	_expect(int(first_buy.get("position", {}).get("avg_cost", 0)) == 1000, "first buy should set average cost")

	var second_buy := PortfolioOrderMathScript.buy_update({
		"ticker": "AAA",
		"quantity": 2,
		"avg_cost": 1000
	}, "AAA", 1, 1601)
	_expect(int(second_buy.get("cost", 0)) == 1601, "second buy should calculate cost")
	_expect(int(second_buy.get("position", {}).get("quantity", 0)) == 3, "second buy should add quantity")
	_expect(int(second_buy.get("position", {}).get("avg_cost", 0)) == 1200, "second buy should round weighted average cost")


func _verify_sell_update() -> void:
	var partial_sell := PortfolioOrderMathScript.sell_update({
		"ticker": "AAA",
		"quantity": 5,
		"avg_cost": 1000
	}, "AAA", 2, 1300)
	_expect(int(partial_sell.get("proceeds", 0)) == 2600, "partial sell should calculate proceeds")
	_expect(int(partial_sell.get("profit", 0)) == 600, "partial sell should calculate realized profit")
	_expect(not bool(partial_sell.get("remove_position", true)), "partial sell should keep position")
	_expect(int(partial_sell.get("position", {}).get("quantity", 0)) == 3, "partial sell should reduce quantity")
	_expect(int(partial_sell.get("position", {}).get("avg_cost", 0)) == 1000, "partial sell should preserve average cost")

	var full_sell := PortfolioOrderMathScript.sell_update({
		"ticker": "AAA",
		"quantity": 2,
		"avg_cost": 1000
	}, "AAA", 2, 900)
	_expect(int(full_sell.get("profit", 0)) == -200, "full sell should calculate realized loss")
	_expect(bool(full_sell.get("remove_position", false)), "full sell should remove position")
	_expect(int(full_sell.get("position", {}).get("quantity", 999)) == 0, "full sell should expose zero quantity result")
	_expect(int(full_sell.get("position", {}).get("avg_cost", 999)) == 0, "full sell should clear average cost")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
