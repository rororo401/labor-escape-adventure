extends "res://scripts/tests/test_scene_tree.gd"

const MarketRefreshStateConfigScript := preload("res://scripts/ui/market_refresh_state_config.gd")
const MarketScreenRefreshResultConfigScript := preload("res://scripts/ui/market_screen_refresh_result_config.gd")
const MarketRefreshPresenterScript := preload("res://scripts/ui/market_refresh_presenter.gd")


class FakeHud:
	extends RefCounted

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
	extends RefCounted

	var stocks: Array = []

	func render_stocks(next_stocks: Array) -> void:
		stocks = next_stocks


class FakeOrderPanel:
	extends RefCounted

	var selected_stock := {}
	var quantity := 0

	func set_selected_stock(stock: Dictionary, next_quantity: int) -> void:
		selected_stock = stock
		quantity = next_quantity


class FakeClosedDayPanel:
	extends RefCounted

	var title := ""
	var body := ""
	var message := ""

	func set_day_text(next_title: String, next_body: String) -> void:
		title = next_title
		body = next_body

	func set_message(next_message: String) -> void:
		message = next_message


class FakeModeView:
	extends RefCounted

	var market_open := false
	var market_background_path := ""
	var closed_day_background_path := ""

	func apply_mode(next_market_open: bool, next_market_background_path: String, next_closed_day_background_path: String) -> void:
		market_open = next_market_open
		market_background_path = next_market_background_path
		closed_day_background_path = next_closed_day_background_path


func _initialize() -> void:
	_verify_market_open_refresh()
	_verify_closed_day_refresh()
	print("Market refresh presenter smoke test passed.")
	finish_test()


func _verify_market_open_refresh() -> void:
	var hud := FakeHud.new()
	var stock_list := FakeStockListPanel.new()
	var order_panel := FakeOrderPanel.new()
	var closed_day_panel := FakeClosedDayPanel.new()
	var mode_view := FakeModeView.new()
	var result: Dictionary = MarketRefreshPresenterScript.apply(
		hud,
		stock_list,
		order_panel,
		closed_day_panel,
		mode_view,
		{
			MarketRefreshStateConfigScript.KEY_DATE_TEXT: "2016-07-01 금요일 아침",
			MarketRefreshStateConfigScript.KEY_STATUS_TEXT: {
				MarketRefreshStateConfigScript.KEY_STATUS_CASH: "현금\n1,000원",
				MarketRefreshStateConfigScript.KEY_STATUS_NET_WORTH: "순자산\n1,000원"
			},
			MarketRefreshStateConfigScript.KEY_STATUS_SNAPSHOT: {"health": 90, "mood": 55, "fatigue": 12},
			MarketRefreshStateConfigScript.KEY_MARKET_OPEN: true,
			MarketRefreshStateConfigScript.KEY_STOCKS: [{"ticker": "AAA"}],
			MarketRefreshStateConfigScript.KEY_SELECTED_STOCK: {"ticker": "AAA"},
			MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE: MarketRefreshStateConfigScript.EMPTY_TEXT
		},
		"res://market.png",
		"res://closed.png",
		3
	)

	_expect(bool(result.get(MarketRefreshStateConfigScript.KEY_MARKET_OPEN, false)), "open refresh should report market-open mode")
	_expect(hud.date_text == "2016-07-01 금요일 아침", "open refresh should update date text")
	_expect(hud.cash_text.contains("1,000원"), "open refresh should update cash text")
	_expect(int(hud.status_bars.get("health", 0)) == 90, "open refresh should update HUD status bars")
	_expect(mode_view.market_open, "open refresh should apply market-open mode")
	_expect(stock_list.stocks.size() == 1, "open refresh should render stock rows")
	_expect(order_panel.selected_stock.get("ticker", "") == "AAA", "open refresh should update selected order stock")
	_expect(order_panel.quantity == 3, "open refresh should preserve current order quantity")
	_expect(closed_day_panel.title.is_empty(), "open refresh should not write closed-day copy")


func _verify_closed_day_refresh() -> void:
	var hud := FakeHud.new()
	var stock_list := FakeStockListPanel.new()
	var order_panel := FakeOrderPanel.new()
	var closed_day_panel := FakeClosedDayPanel.new()
	var mode_view := FakeModeView.new()
	var result: Dictionary = MarketRefreshPresenterScript.apply(
		hud,
		stock_list,
		order_panel,
		closed_day_panel,
		mode_view,
		{
			MarketRefreshStateConfigScript.KEY_DATE_TEXT: "2016-07-02 토요일 아침",
			MarketRefreshStateConfigScript.KEY_STATUS_TEXT: {
				MarketRefreshStateConfigScript.KEY_STATUS_CASH: "현금\n900원",
				MarketRefreshStateConfigScript.KEY_STATUS_NET_WORTH: "순자산\n900원"
			},
			MarketRefreshStateConfigScript.KEY_STATUS_SNAPSHOT: {"health": 80, "mood": 50, "fatigue": 20},
			MarketRefreshStateConfigScript.KEY_MARKET_OPEN: false,
			MarketRefreshStateConfigScript.KEY_SELECTED_STOCK: {},
			MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TEXT: {
				MarketRefreshStateConfigScript.KEY_CLOSED_DAY_TITLE: "장이 쉬는 날",
				MarketRefreshStateConfigScript.KEY_CLOSED_DAY_BODY: "오늘은 주말이다."
			},
			MarketRefreshStateConfigScript.KEY_CLOSED_DAY_MESSAGE: "할 일을 골라보자.",
			MarketRefreshStateConfigScript.KEY_COMPLETED_MESSAGE: "낮잠 완료"
		},
		"res://market.png",
		"res://closed.png",
		1
	)

	_expect(not bool(result.get(MarketRefreshStateConfigScript.KEY_MARKET_OPEN, true)), "closed refresh should report closed-day mode")
	_expect(result.get(MarketScreenRefreshResultConfigScript.KEY_COMPLETED_MESSAGE, "") == "낮잠 완료", "closed refresh should return completed message")
	_expect(int(hud.status_bars.get("fatigue", 0)) == 20, "closed refresh should update HUD status bars")
	_expect(not mode_view.market_open, "closed refresh should apply closed-day mode")
	_expect(closed_day_panel.title == "장이 쉬는 날", "closed refresh should update closed-day title")
	_expect(closed_day_panel.body == "오늘은 주말이다.", "closed refresh should update closed-day body")
	_expect(closed_day_panel.message == "할 일을 골라보자.", "closed refresh should update closed-day message")
	_expect(stock_list.stocks.is_empty(), "closed refresh should not render market rows")
	_expect(order_panel.selected_stock.is_empty(), "closed refresh should not update order panel selection")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
