extends "res://scripts/tests/test_scene_tree.gd"

const MarketOrderInputConfigScript := preload("res://scripts/ui/market_order_input_config.gd")
const MarketOrderInputScript := preload("res://scripts/ui/market_order_input.gd")


func _initialize() -> void:
	_expect(MarketOrderInputScript.normalize_quantity(-10) == MarketOrderInputConfigScript.MIN_QUANTITY, "quantity should clamp to minimum")
	_expect(MarketOrderInputScript.normalize_quantity(MarketOrderInputConfigScript.MIN_QUANTITY) == MarketOrderInputConfigScript.MIN_QUANTITY, "minimum quantity should stay valid")
	_expect(MarketOrderInputScript.normalize_quantity(1200) == MarketOrderInputConfigScript.MAX_QUANTITY, "quantity should clamp to maximum")
	_expect(MarketOrderInputScript.increase_quantity(1) == 2, "increase should add one share")
	_expect(MarketOrderInputScript.increase_quantity(MarketOrderInputConfigScript.MAX_QUANTITY) == MarketOrderInputConfigScript.MAX_QUANTITY, "increase should respect maximum quantity")
	_expect(MarketOrderInputScript.decrease_quantity(2) == 1, "decrease should subtract one share")
	_expect(MarketOrderInputScript.decrease_quantity(MarketOrderInputConfigScript.MIN_QUANTITY) == MarketOrderInputConfigScript.MIN_QUANTITY, "decrease should respect minimum quantity")

	var request: Dictionary = MarketOrderInputScript.build_order_request({MarketOrderInputConfigScript.KEY_TICKER: "005930"}, "buy", 3)
	_expect(bool(request.get(MarketOrderInputConfigScript.KEY_OK, false)), "selected stock should build an order request")
	_expect(request.get(MarketOrderInputConfigScript.KEY_TICKER, "") == "005930", "order request should include ticker")
	_expect(request.get(MarketOrderInputConfigScript.KEY_SIDE, "") == "buy", "order request should include side")
	_expect(int(request.get(MarketOrderInputConfigScript.KEY_QUANTITY, 0)) == 3, "order request should include normalized quantity")

	var clamped_request: Dictionary = MarketOrderInputScript.build_order_request({MarketOrderInputConfigScript.KEY_TICKER: "005930"}, "sell", 2000)
	_expect(int(clamped_request.get(MarketOrderInputConfigScript.KEY_QUANTITY, 0)) == MarketOrderInputConfigScript.MAX_QUANTITY, "order request should clamp quantity")

	var missing_stock: Dictionary = MarketOrderInputScript.build_order_request({}, "buy", 1)
	_expect(not bool(missing_stock.get(MarketOrderInputConfigScript.KEY_OK, true)), "missing stock should fail request building")
	_expect(missing_stock.get(MarketOrderInputConfigScript.KEY_ERROR, "") == MarketOrderInputConfigScript.ERROR_STOCK_NOT_SELECTED, "missing stock should explain the request error")

	print("Market order input smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
