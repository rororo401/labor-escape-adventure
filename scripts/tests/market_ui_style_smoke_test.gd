extends "res://scripts/tests/test_scene_tree.gd"

const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const MarketUiStyleConfigScript := preload("res://scripts/ui/market_ui_style_config.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")


func _initialize() -> void:
	var title := MarketUiStyleScript.make_label(24, Color("#4b362f"))
	_expect(title.get_theme_font_size(TextThemeHelpersScript.THEME_FONT_SIZE) == 24, "market style label should apply font size")
	_expect(title.get_theme_color(TextThemeHelpersScript.THEME_FONT_COLOR) == Color("#4b362f"), "market style label should apply color")

	var cell := MarketUiStyleScript.make_table_cell("종목", 188.0, HORIZONTAL_ALIGNMENT_LEFT, 17, Color("#7a5b50"))
	_expect(cell.text == "종목", "table cell should set text")
	_expect(cell.custom_minimum_size == Vector2(188.0, MarketUiStyleConfigScript.TABLE_CELL_HEIGHT), "table cell should set stable column size")
	_expect(cell.clip_text, "table cell should clip overflow text")

	var row_button := MarketUiStyleScript.make_stock_row_button()
	_expect(row_button.custom_minimum_size == MarketUiStyleConfigScript.STOCK_ROW_BUTTON_SIZE, "stock row button should keep stock row dimensions")
	_expect(StyleboxThemeHelpersScript.get_style(row_button, StyleboxThemeHelpersScript.STYLE_NORMAL) != null, "stock row button should have normal style")
	_expect(StyleboxThemeHelpersScript.get_style(row_button, StyleboxThemeHelpersScript.STYLE_HOVER) != null, "stock row button should have hover style")
	_expect(StyleboxThemeHelpersScript.get_style(row_button, StyleboxThemeHelpersScript.STYLE_PRESSED) != null, "stock row button should have pressed style")
	_expect(_style_matches(row_button, StyleboxThemeHelpersScript.STYLE_FOCUS, MarketUiStyleConfigScript.STOCK_ROW_NORMAL_COLOR, MarketUiStyleConfigScript.STOCK_ROW_NORMAL_BORDER), "stock row focus style should not fall back to default blue focus")

	var top_button := MarketUiStyleScript.make_top_icon_button("MenuButton")
	_expect(top_button.name == "MenuButton", "top icon button should preserve node name")
	_expect(top_button.custom_minimum_size == MarketUiStyleConfigScript.TOP_ICON_BUTTON_SIZE, "top icon button should keep touch target size")
	_expect(top_button.texture_normal != null and top_button.texture_hover != null and top_button.texture_pressed != null, "top icon button should use image textures")

	var option := MarketUiStyleScript.make_option_button(Vector2(526.0, 50.0))
	_expect(option.custom_minimum_size == Vector2(526.0, 50.0), "option button should keep action selector size")
	_expect(StyleboxThemeHelpersScript.get_style(option, StyleboxThemeHelpersScript.STYLE_NORMAL) != null, "option button should have normal style")
	_expect(_style_matches(option, StyleboxThemeHelpersScript.STYLE_FOCUS, MarketUiStyleConfigScript.OPTION_BUTTON_NORMAL_COLOR, MarketUiStyleConfigScript.OPTION_BUTTON_NORMAL_BORDER), "option focus style should not fall back to default blue focus")

	var buy_button := MarketUiStyleScript.make_order_button("매수", MarketDataKeysScript.SIDE_BUY, Vector2(300.0, 62.0))
	_expect(buy_button.name == MarketUiStyleConfigScript.ORDER_BUY_BUTTON_NAME, "buy order button should use the expected node name")
	_expect(buy_button.custom_minimum_size == Vector2(300.0, 62.0), "order button should keep trade button size")
	_expect(_style_matches(buy_button, StyleboxThemeHelpersScript.STYLE_FOCUS, MarketUiStyleConfigScript.ORDER_BUY_COLOR, MarketUiStyleConfigScript.ORDER_BUTTON_BORDER), "buy order focus style should not fall back to default blue focus")
	var sell_button := MarketUiStyleScript.make_order_button("매도", MarketDataKeysScript.SIDE_SELL, Vector2(300.0, 62.0))
	_expect(sell_button.name == MarketUiStyleConfigScript.ORDER_SELL_BUTTON_NAME, "sell order button should use the expected node name")
	_expect(_style_matches(sell_button, StyleboxThemeHelpersScript.STYLE_FOCUS, MarketUiStyleConfigScript.ORDER_SELL_COLOR, MarketUiStyleConfigScript.ORDER_BUTTON_BORDER), "sell order focus style should not fall back to default blue focus")

	var stepper := MarketUiStyleScript.make_stepper_button("+", Vector2(70.0, 54.0))
	_expect(stepper.text == "+", "stepper button should preserve label")
	_expect(stepper.custom_minimum_size == Vector2(70.0, 54.0), "stepper button should keep quantity button size")
	_expect(_style_matches(stepper, StyleboxThemeHelpersScript.STYLE_FOCUS, MarketUiStyleConfigScript.STEPPER_NORMAL_COLOR, MarketUiStyleConfigScript.STEPPER_NORMAL_BORDER), "stepper focus style should not fall back to default blue focus")

	title.free()
	cell.free()
	row_button.free()
	top_button.free()
	option.free()
	buy_button.free()
	sell_button.free()
	stepper.free()

	print("Market UI style smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _style_matches(control: Control, state: String, color: Color, border: Color) -> bool:
	var style := StyleboxThemeHelpersScript.get_style(control, state) as StyleBoxFlat
	return style != null and style.bg_color == color and style.border_color == border
