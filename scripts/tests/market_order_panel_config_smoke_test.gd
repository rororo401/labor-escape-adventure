extends "res://scripts/tests/test_scene_tree.gd"

const MarketOrderPanelConfigScript := preload("res://scripts/ui/market_order_panel_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")


func _initialize() -> void:
	_expect(MarketOrderPanelConfigScript.PANEL_NAME == "OrderPanel", "panel name should stay stable for tests and lookup")
	_expect(MarketOrderPanelConfigScript.PANEL_SIZE == Vector2(660, 506), "panel size should preserve current layout")
	_expect(int(MarketOrderPanelConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)) == 22, "left margin should preserve current layout")
	_expect(MarketOrderPanelConfigScript.TODAY_LABEL == "오늘", "today label should be centralized")
	_expect(MarketOrderPanelConfigScript.SIDE_BUY == MarketDataKeysScript.SIDE_BUY, "buy side should use market data keys")
	_expect(MarketOrderPanelConfigScript.SIDE_SELL == MarketDataKeysScript.SIDE_SELL, "sell side should use market data keys")
	_expect(MarketOrderPanelConfigScript.BUY_LABEL == "매수", "buy label should be centralized")
	_expect(MarketOrderPanelConfigScript.SELL_LABEL == "매도", "sell label should be centralized")
	_expect(MarketOrderPanelConfigScript.DEFAULT_FLOW_TEXT == "오늘 하루 보내기", "default flow text should be centralized")
	_expect(MarketOrderPanelConfigScript.ACTION_OPTION_SIZE == Vector2(526, 50), "action option size should preserve current layout")
	_expect(MarketOrderPanelConfigScript.MESSAGE_LABEL_SIZE == Vector2(612, 86), "message label size should preserve current layout")
	_expect(MarketOrderPanelConfigScript.TITLE_FONT_SIZE == 30, "title font size should stay stable")
	_expect(MarketOrderPanelConfigScript.PRICE_FONT_SIZE == 24, "price font size should stay stable")
	_expect(MarketOrderPanelConfigScript.BODY_COLOR == Color("#46362f"), "body label color should stay stable")

	print("Market order panel config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
