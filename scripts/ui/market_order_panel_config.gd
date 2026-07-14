class_name MarketOrderPanelConfig
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketFlowCopyScript := preload("res://scripts/ui/market_flow_copy.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")

const PANEL_NAME := "OrderPanel"
const PANEL_POSITION := Vector2(30, 703)
const PANEL_SIZE := Vector2(660, 506)
const PANEL_MARGIN := {
	PanelLayoutHelpersScript.KEY_LEFT: 22,
	PanelLayoutHelpersScript.KEY_TOP: 24,
	PanelLayoutHelpersScript.KEY_RIGHT: 22,
	PanelLayoutHelpersScript.KEY_BOTTOM: 22
}
const LAYOUT_SEPARATION := 15
const ROW_SEPARATION := 12

const TODAY_LABEL := "오늘"
const SIDE_BUY := MarketDataKeysScript.SIDE_BUY
const SIDE_SELL := MarketDataKeysScript.SIDE_SELL
const BUY_LABEL := "매수"
const SELL_LABEL := "매도"
const DECREASE_LABEL := "-"
const INCREASE_LABEL := "+"
const DEFAULT_FLOW_TEXT := MarketFlowCopyScript.DEFAULT_READY_TEXT

const QUANTITY_BUTTON_SIZE := Vector2(70, 54)
const QUANTITY_LABEL_SIZE := Vector2(170, 54)
const ORDER_BUTTON_SIZE := Vector2(300, 62)
const ACTION_LABEL_SIZE := Vector2(74, 50)
const ACTION_OPTION_SIZE := Vector2(526, 50)
const FLOW_BUTTON_SIZE := Vector2(612, 58)
const MESSAGE_LABEL_SIZE := Vector2(612, 86)

const TITLE_FONT_SIZE := 30
const PRICE_FONT_SIZE := 24
const HELD_FONT_SIZE := 23
const QUANTITY_FONT_SIZE := 26
const ACTION_LABEL_FONT_SIZE := 22
const MESSAGE_FONT_SIZE := 23
const TITLE_COLOR := Color("#3f332e")
const BODY_COLOR := Color("#46362f")
