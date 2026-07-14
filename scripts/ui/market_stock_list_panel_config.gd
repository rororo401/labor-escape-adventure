class_name MarketStockListPanelConfig
extends RefCounted

const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")

const PANEL_NAME := "StockListPanel"
const PANEL_POSITION := Vector2(22, 194)
const PANEL_SIZE := Vector2(676, 455)
const PANEL_COLOR := Color("#fffaf0e8")
const PANEL_BORDER_COLOR := Color("#efbd87")

const PANEL_MARGIN_LEFT := 16
const PANEL_MARGIN_TOP := 14
const PANEL_MARGIN_RIGHT := 16
const PANEL_MARGIN_BOTTOM := 14
const PANEL_MARGIN := {
	PanelLayoutHelpersScript.KEY_LEFT: PANEL_MARGIN_LEFT,
	PanelLayoutHelpersScript.KEY_TOP: PANEL_MARGIN_TOP,
	PanelLayoutHelpersScript.KEY_RIGHT: PANEL_MARGIN_RIGHT,
	PanelLayoutHelpersScript.KEY_BOTTOM: PANEL_MARGIN_BOTTOM
}
const LAYOUT_SEPARATION := 10

const TITLE_TEXT := "오늘의 종목"
const TITLE_FONT_SIZE := 24
const TITLE_COLOR := Color("#4b362f")

const SCROLL_SIZE := Vector2(644, 336)
const STOCK_LIST_SEPARATION := 8

const HEADER_COLUMNS := 4
const HEADER_SIZE := Vector2(620, 26)
const HEADER_SEPARATION := 8
const HEADER_FONT_SIZE := 17
const HEADER_COLOR := Color("#7a5b50")
const HEADER_LABELS := ["종목", "시가", "등락", "보유"]

const ROW_GRID_COLUMNS := 4
const ROW_GRID_POSITION := Vector2(16, 10)
const ROW_GRID_SIZE := Vector2(588, 44)
const ROW_GRID_SEPARATION := 8
const ROW_FONT_SIZE := 20
const ROW_TEXT_COLOR := Color("#3a2f2c")

const STOCK_COL_WIDTHS := [188.0, 152.0, 118.0, 102.0]
const DEFAULT_RENDER_LIMIT := 10
