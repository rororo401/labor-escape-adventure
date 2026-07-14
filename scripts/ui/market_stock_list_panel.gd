class_name MarketStockListPanel
extends PanelContainer

signal stock_selected(ticker: String)

const MarketUiFormat := preload("res://scripts/ui/market_ui_format.gd")
const MarketStockListPanelConfigScript := preload("res://scripts/ui/market_stock_list_panel_config.gd")
const MarketStockDisplayTextScript := preload("res://scripts/ui/market_stock_display_text.gd")
const MarketStockRowConfigScript := preload("res://scripts/ui/market_stock_row_config.gd")
const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var _stock_list: VBoxContainer


func build() -> void:
	name = MarketStockListPanelConfigScript.PANEL_NAME
	position = MarketStockListPanelConfigScript.PANEL_POSITION
	size = MarketStockListPanelConfigScript.PANEL_SIZE
	custom_minimum_size = MarketStockListPanelConfigScript.PANEL_SIZE
	StyleboxThemeHelpersScript.apply_panel_style(
		self,
		MarketUiStyleScript.make_panel_style(MarketStockListPanelConfigScript.PANEL_COLOR, MarketStockListPanelConfigScript.PANEL_BORDER_COLOR)
	)

	var layout := PanelLayoutHelpersScript.add_margin_layout(
		self,
		size,
		MarketStockListPanelConfigScript.PANEL_MARGIN,
		MarketStockListPanelConfigScript.LAYOUT_SEPARATION
	)

	var title := MarketUiStyleScript.make_label(MarketStockListPanelConfigScript.TITLE_FONT_SIZE, MarketStockListPanelConfigScript.TITLE_COLOR)
	title.text = MarketStockListPanelConfigScript.TITLE_TEXT
	layout.add_child(title)

	layout.add_child(_make_stock_header())

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = MarketStockListPanelConfigScript.SCROLL_SIZE
	UiHelpers.disable_horizontal_scroll(scroll)
	layout.add_child(scroll)

	_stock_list = VBoxContainer.new()
	PanelLayoutHelpersScript.apply_separation(_stock_list, MarketStockListPanelConfigScript.STOCK_LIST_SEPARATION)
	scroll.add_child(_stock_list)


func render_stocks(stocks: Array, limit: int = MarketStockListPanelConfigScript.DEFAULT_RENDER_LIMIT) -> void:
	if _stock_list == null:
		return

	for child in _stock_list.get_children():
		child.free()

	for index in mini(stocks.size(), limit):
		var stock: Dictionary = stocks[index]
		_stock_list.add_child(_make_stock_row(stock))


func _make_stock_header() -> GridContainer:
	var header := PanelLayoutHelpersScript.make_grid(
		MarketStockListPanelConfigScript.HEADER_COLUMNS,
		MarketStockListPanelConfigScript.HEADER_SEPARATION
	)
	header.custom_minimum_size = MarketStockListPanelConfigScript.HEADER_SIZE
	for index in MarketStockListPanelConfigScript.HEADER_LABELS.size():
		var align := HORIZONTAL_ALIGNMENT_LEFT if index == 0 else HORIZONTAL_ALIGNMENT_RIGHT
		header.add_child(_make_stock_cell(
			String(MarketStockListPanelConfigScript.HEADER_LABELS[index]),
			float(MarketStockListPanelConfigScript.STOCK_COL_WIDTHS[index]),
			align,
			MarketStockListPanelConfigScript.HEADER_FONT_SIZE,
			MarketStockListPanelConfigScript.HEADER_COLOR
		))
	return header


func _make_stock_row(stock: Dictionary) -> Button:
	var button := MarketUiStyleScript.make_stock_row_button()
	button.name = "Stock_%s" % stock.get(MarketStockRowConfigScript.KEY_TICKER, MarketStockRowConfigScript.EMPTY_TEXT)
	var ticker := String(stock.get(MarketStockRowConfigScript.KEY_TICKER, MarketStockRowConfigScript.EMPTY_TEXT))
	button.pressed.connect(func() -> void:
		stock_selected.emit(ticker)
	)

	var grid := PanelLayoutHelpersScript.make_grid(
		MarketStockListPanelConfigScript.ROW_GRID_COLUMNS,
		MarketStockListPanelConfigScript.ROW_GRID_SEPARATION,
		"Columns"
	)
	UiHelpers.ignore_mouse(grid)
	grid.position = MarketStockListPanelConfigScript.ROW_GRID_POSITION
	grid.size = MarketStockListPanelConfigScript.ROW_GRID_SIZE
	button.add_child(grid)

	grid.add_child(_make_stock_cell(MarketStockDisplayTextScript.display_name(stock), MarketStockListPanelConfigScript.STOCK_COL_WIDTHS[0], HORIZONTAL_ALIGNMENT_LEFT, MarketStockListPanelConfigScript.ROW_FONT_SIZE, MarketStockListPanelConfigScript.ROW_TEXT_COLOR))
	grid.add_child(_make_stock_cell(MarketStockDisplayTextScript.open_price(stock), MarketStockListPanelConfigScript.STOCK_COL_WIDTHS[1], HORIZONTAL_ALIGNMENT_RIGHT, MarketStockListPanelConfigScript.ROW_FONT_SIZE, MarketStockListPanelConfigScript.ROW_TEXT_COLOR))
	grid.add_child(_make_stock_cell(MarketStockDisplayTextScript.change_rate(stock), MarketStockListPanelConfigScript.STOCK_COL_WIDTHS[2], HORIZONTAL_ALIGNMENT_RIGHT, MarketStockListPanelConfigScript.ROW_FONT_SIZE, MarketUiFormat.stock_change_color(float(stock.get(MarketStockRowConfigScript.KEY_CHANGE_RATE, MarketStockRowConfigScript.DEFAULT_RATE)))))
	grid.add_child(_make_stock_cell(MarketStockDisplayTextScript.quantity(int(stock.get(MarketStockRowConfigScript.KEY_HELD_QUANTITY, MarketStockRowConfigScript.DEFAULT_NUMBER))), MarketStockListPanelConfigScript.STOCK_COL_WIDTHS[3], HORIZONTAL_ALIGNMENT_RIGHT, MarketStockListPanelConfigScript.ROW_FONT_SIZE, MarketStockListPanelConfigScript.ROW_TEXT_COLOR))
	return button


func _make_stock_cell(text: String, width: float, align: HorizontalAlignment, font_size: int, color: Color) -> Label:
	return MarketUiStyleScript.make_table_cell(text, width, align, font_size, color)
