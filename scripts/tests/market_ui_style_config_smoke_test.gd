extends "res://scripts/tests/test_scene_tree.gd"

const MarketUiStyleConfigScript := preload("res://scripts/ui/market_ui_style_config.gd")


func _initialize() -> void:
	_expect(MarketUiStyleConfigScript.DEFAULT_LABEL_COLOR == Color("#46362f"), "default label color should stay stable")
	_expect(MarketUiStyleConfigScript.TABLE_CELL_HEIGHT == 36.0, "table cell height should stay stable")
	_expect(MarketUiStyleConfigScript.PRIMARY_BUTTON_FONT_SIZE == 24, "primary button font size should stay stable")
	_expect(MarketUiStyleConfigScript.PRIMARY_BUTTON_NORMAL_COLOR == Color("#42656a"), "primary button normal color should stay stable")
	_expect(MarketUiStyleConfigScript.OPTION_BUTTON_FONT_SIZE == 22, "option button font size should stay stable")
	_expect(MarketUiStyleConfigScript.ORDER_BUY_BUTTON_NAME == "BuyButton", "buy button node name should stay stable")
	_expect(MarketUiStyleConfigScript.ORDER_SELL_BUTTON_NAME == "SellButton", "sell button node name should stay stable")
	_expect(MarketUiStyleConfigScript.ORDER_BUY_COLOR == Color("#d0655b"), "buy button color should stay stable")
	_expect(MarketUiStyleConfigScript.ORDER_SELL_COLOR == Color("#5579a5"), "sell button color should stay stable")
	_expect(MarketUiStyleConfigScript.STEPPER_BUTTON_FONT_SIZE == 28, "stepper font size should stay stable")
	_expect(MarketUiStyleConfigScript.STOCK_ROW_BUTTON_SIZE == Vector2(620, 64), "stock row button size should stay stable")
	_expect(MarketUiStyleConfigScript.TOP_ICON_BUTTON_SIZE == Vector2(52, 52), "top icon button size should stay stable")
	_expect(MarketUiStyleConfigScript.SOFT_BUTTON_FONT_SIZE == 22, "soft button font size should stay stable")

	print("Market UI style config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
