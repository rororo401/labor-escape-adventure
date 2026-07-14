extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketScreenRefreshResultConfigScript := preload("res://scripts/ui/market_screen_refresh_result_config.gd")
const MarketScreenRefreshCoordinatorScript := preload("res://scripts/ui/market_screen_refresh_coordinator.gd")
const MarketScreenRuntimeStateScript := preload("res://scripts/ui/market_screen_runtime_state.gd")


func _initialize() -> void:
	_verify_market_open_refresh()
	_verify_closed_day_refresh()
	_verify_null_game_refresh()
	print("Market screen refresh coordinator smoke test passed.")
	finish_test()


func _verify_market_open_refresh() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up an open market day")
	var runtime_state = MarketScreenRuntimeStateScript.new()
	runtime_state.quantity = 3
	var hud := FakeHud.new()
	var stock_list := FakeStockListPanel.new()
	var order_panel := FakeOrderPanel.new()
	var closed_panel := FakeClosedDayPanel.new()
	var mode_view := FakeModeView.new()

	var result := MarketScreenRefreshCoordinatorScript.refresh(
		game,
		runtime_state,
		hud,
		stock_list,
		order_panel,
		closed_panel,
		mode_view,
		"res://market.png",
		"res://closed.png"
	)

	_expect(bool(result.get(MarketScreenRefreshResultConfigScript.KEY_MARKET_CONTEXT, {}).get("is_open", false)), "open refresh should return market context")
	_expect(not runtime_state.selected_stock.is_empty(), "open refresh should resolve runtime selected stock")
	_expect(order_panel.quantity == 3, "open refresh should preserve runtime quantity in order panel")
	_expect(not stock_list.stocks.is_empty(), "open refresh should render stock rows")
	_expect(mode_view.market_open, "open refresh should apply market mode")
	_expect(mode_view.market_background_path == "res://market.png", "open refresh should forward market background")
	_expect(hud.date_text.contains("2016-07-01"), "open refresh should update date text")
	_expect(int(hud.status_bars.get("health", 0)) == 100, "open refresh should update status bars")
	_expect(String(result.get(MarketScreenRefreshResultConfigScript.KEY_COMPLETED_MESSAGE, "")).is_empty(), "fresh open refresh should not show completed message")


func _verify_closed_day_refresh() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-02"), "game should set up a closed market day")
	var runtime_state = MarketScreenRuntimeStateScript.new()
	runtime_state.selected_stock = {"ticker": "STALE"}
	var closed_panel := FakeClosedDayPanel.new()
	var mode_view := FakeModeView.new()

	var result := MarketScreenRefreshCoordinatorScript.refresh(
		game,
		runtime_state,
		null,
		null,
		null,
		closed_panel,
		mode_view,
		"res://market.png",
		"res://closed.png"
	)

	_expect(not bool(result.get(MarketScreenRefreshResultConfigScript.KEY_MARKET_CONTEXT, {}).get("is_open", true)), "closed refresh should return closed market context")
	_expect(runtime_state.selected_stock.is_empty(), "closed refresh should clear runtime selected stock")
	_expect(not mode_view.market_open, "closed refresh should apply closed-day mode")
	_expect(mode_view.closed_day_background_path == "res://closed.png", "closed refresh should forward closed-day background")
	_expect(not closed_panel.title.is_empty(), "closed refresh should update closed-day title")


func _verify_null_game_refresh() -> void:
	var runtime_state = MarketScreenRuntimeStateScript.new()
	runtime_state.selected_stock = {"ticker": "STALE"}
	var result := MarketScreenRefreshCoordinatorScript.refresh(
		null,
		runtime_state,
		null,
		null,
		null,
		null,
		null,
		"res://market.png",
		"res://closed.png"
	)
	_expect(Dictionary(result.get(MarketScreenRefreshResultConfigScript.KEY_MARKET_CONTEXT, {"bad": true})).is_empty(), "null game refresh should return empty context")
	_expect(runtime_state.selected_stock.is_empty(), "null game refresh should clear selected stock")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakeHud:
	var date_text := ""
	var cash_text := ""
	var net_worth_text := ""
	var status_bars := {}

	func set_date_text(text: String) -> void:
		date_text = text

	func set_status_text(cash: String, net_worth: String) -> void:
		cash_text = cash
		net_worth_text = net_worth

	func set_status_bars(status: Dictionary) -> void:
		status_bars = status


class FakeStockListPanel:
	var stocks: Array = []

	func render_stocks(next_stocks: Array) -> void:
		stocks = next_stocks.duplicate(true)


class FakeOrderPanel:
	var selected_stock := {}
	var quantity := 0

	func set_selected_stock(stock: Dictionary, next_quantity: int) -> void:
		selected_stock = stock.duplicate(true)
		quantity = next_quantity


class FakeClosedDayPanel:
	var title := ""
	var body := ""
	var message := ""

	func set_day_text(next_title: String, next_body: String) -> void:
		title = next_title
		body = next_body

	func set_message(next_message: String) -> void:
		message = next_message


class FakeModeView:
	var market_open := false
	var market_background_path := ""
	var closed_day_background_path := ""

	func apply_mode(next_market_open: bool, next_market_background_path: String, next_closed_day_background_path: String) -> void:
		market_open = next_market_open
		market_background_path = next_market_background_path
		closed_day_background_path = next_closed_day_background_path
