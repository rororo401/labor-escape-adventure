class_name MarketModeView
extends RefCounted

const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var background_rect: TextureRect
var market_panel_nodes: Array[CanvasItem] = []
var closed_panel_nodes: Array[CanvasItem] = []


func build_background(parent: Control, texture_path: String, node_name: String = "MarketBackground") -> TextureRect:
	background_rect = TextureRect.new()
	background_rect.name = node_name
	UiHelpers.apply_cover_texture(background_rect, texture_path)
	parent.add_child(background_rect)
	return background_rect


func set_panels(market_panels: Array[CanvasItem], closed_panels: Array[CanvasItem]) -> void:
	market_panel_nodes = market_panels.duplicate()
	closed_panel_nodes = closed_panels.duplicate()


func apply_mode(market_open: bool, market_background_path: String, closed_background_path: String) -> void:
	if background_rect != null:
		background_rect.texture = UiHelpers.load_texture(market_background_path if market_open else closed_background_path)
	for panel in market_panel_nodes:
		if panel != null:
			panel.visible = market_open
	for panel in closed_panel_nodes:
		if panel != null:
			panel.visible = not market_open
