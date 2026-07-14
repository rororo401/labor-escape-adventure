extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenRuntimeStateScript := preload("res://scripts/ui/market_screen_runtime_state.gd")
const MarketScreenSelectionPresenterScript := preload("res://scripts/ui/market_screen_selection_presenter.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")


func _initialize() -> void:
	var runtime_state = MarketScreenRuntimeStateScript.new()
	runtime_state.selected_stock = {"ticker": "AAA", "name": "첫 종목"}
	runtime_state.quantity = 1
	var order_panel = FakeOrderPanel.new()
	var market_context := {
		"stocks": [
			{"ticker": "AAA", "name": "첫 종목"},
			{"ticker": "BBB", "name": "둘째 종목"}
		]
	}

	var select_patch := MarketScreenSelectionPresenterScript.select_stock(
		runtime_state,
		order_panel,
		market_context,
		"BBB"
	)
	_expect(String(select_patch.get(MarketScreenStateConfigScript.KEY_SELECTED_STOCK, {}).get("ticker", "")) == "BBB", "stock selection should return selected-stock patch")
	_expect(String(runtime_state.selected_stock.get("ticker", "")) == "BBB", "stock selection should update runtime state")
	_expect(String(order_panel.stock.get("ticker", "")) == "BBB", "stock selection should refresh order panel stock")
	_expect(order_panel.quantity == 1, "stock selection should preserve quantity in panel")

	var increase_patch := MarketScreenSelectionPresenterScript.increase_quantity(runtime_state, order_panel)
	_expect(int(increase_patch.get(MarketScreenStateConfigScript.KEY_QUANTITY, 0)) == 2, "quantity increase should return quantity patch")
	_expect(runtime_state.quantity == 2, "quantity increase should update runtime state")
	_expect(order_panel.quantity == 2, "quantity increase should refresh order panel quantity")

	var decrease_patch := MarketScreenSelectionPresenterScript.decrease_quantity(runtime_state, order_panel)
	_expect(int(decrease_patch.get(MarketScreenStateConfigScript.KEY_QUANTITY, 0)) == 1, "quantity decrease should return quantity patch")
	_expect(runtime_state.quantity == 1, "quantity decrease should update runtime state")
	_expect(order_panel.quantity == 1, "quantity decrease should refresh order panel quantity")

	runtime_state.quantity = 999
	MarketScreenSelectionPresenterScript.increase_quantity(runtime_state, null)
	_expect(runtime_state.quantity == 999, "quantity increase should tolerate missing order panel and clamp max")

	MarketScreenSelectionPresenterScript.refresh_selected_panel(null, order_panel)
	MarketScreenSelectionPresenterScript.select_stock(null, null, market_context, "AAA")

	print("Market screen selection presenter smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakeOrderPanel:
	var stock := {}
	var quantity := 0

	func set_selected_stock(next_stock: Dictionary, next_quantity: int) -> void:
		stock = next_stock.duplicate(true)
		quantity = next_quantity
