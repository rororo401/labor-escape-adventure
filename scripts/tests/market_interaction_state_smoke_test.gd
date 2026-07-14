extends "res://scripts/tests/test_scene_tree.gd"

const MarketInteractionStateScript := preload("res://scripts/ui/market_interaction_state.gd")
const MarketOrderInputConfigScript := preload("res://scripts/ui/market_order_input_config.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")


func _initialize() -> void:
	var market_context := {
		"stocks": [
			{
				"ticker": "AAA",
				"name": "첫 종목"
			},
			{
				"ticker": "BBB",
				"name": "둘째 종목"
			}
		]
	}

	var selected := MarketInteractionStateScript.stock_selected(market_context, "BBB")
	_expect(String(selected.get(MarketScreenStateConfigScript.KEY_SELECTED_STOCK, {}).get(MarketOrderInputConfigScript.KEY_TICKER, "")) == "BBB", "selected ticker should become selected stock")
	_expect(Dictionary(MarketInteractionStateScript.stock_selected(market_context, "ZZZ").get(MarketScreenStateConfigScript.KEY_SELECTED_STOCK, {"bad": true})).is_empty(), "missing ticker should clear selected stock")

	_expect(int(MarketInteractionStateScript.quantity_increased(MarketOrderInputConfigScript.MIN_QUANTITY).get(MarketScreenStateConfigScript.KEY_QUANTITY, 0)) == 2, "quantity increase should add one")
	_expect(int(MarketInteractionStateScript.quantity_increased(MarketOrderInputConfigScript.MAX_QUANTITY).get(MarketScreenStateConfigScript.KEY_QUANTITY, 0)) == MarketOrderInputConfigScript.MAX_QUANTITY, "quantity increase should clamp at maximum")
	_expect(int(MarketInteractionStateScript.quantity_decreased(2).get(MarketScreenStateConfigScript.KEY_QUANTITY, 0)) == MarketOrderInputConfigScript.MIN_QUANTITY, "quantity decrease should subtract one")
	_expect(int(MarketInteractionStateScript.quantity_decreased(MarketOrderInputConfigScript.MIN_QUANTITY).get(MarketScreenStateConfigScript.KEY_QUANTITY, 0)) == MarketOrderInputConfigScript.MIN_QUANTITY, "quantity decrease should clamp at minimum")

	print("Market interaction state smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
