class_name PanelLayoutHelpers
extends RefCounted

const KEY_LEFT := "left"
const KEY_TOP := "top"
const KEY_RIGHT := "right"
const KEY_BOTTOM := "bottom"

const THEME_MARGIN_LEFT := "margin_left"
const THEME_MARGIN_TOP := "margin_top"
const THEME_MARGIN_RIGHT := "margin_right"
const THEME_MARGIN_BOTTOM := "margin_bottom"
const THEME_SEPARATION := "separation"
const THEME_H_SEPARATION := "h_separation"
const THEME_V_SEPARATION := "v_separation"

const DEFAULT_MARGIN := 0


static func add_margin_layout(parent: Control, panel_size: Vector2, margin_values: Dictionary, separation: int) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.position = Vector2.ZERO
	margin.size = panel_size
	apply_margins(margin, margin_values)
	parent.add_child(margin)

	var layout := VBoxContainer.new()
	apply_separation(layout, separation)
	margin.add_child(layout)
	return layout


static func make_row(separation: int, node_name: String = "") -> HBoxContainer:
	var row := HBoxContainer.new()
	if not node_name.is_empty():
		row.name = node_name
	apply_separation(row, separation)
	return row


static func make_grid(columns: int, separation: int, node_name: String = "") -> GridContainer:
	var grid := GridContainer.new()
	if not node_name.is_empty():
		grid.name = node_name
	grid.columns = columns
	apply_grid_separation(grid, separation)
	return grid


static func apply_margins(margin: MarginContainer, margin_values: Dictionary) -> void:
	apply_theme_margins(margin, margin_values)


static func apply_theme_margins(control: Control, margin_values: Dictionary) -> void:
	control.add_theme_constant_override(THEME_MARGIN_LEFT, int(margin_values.get(KEY_LEFT, DEFAULT_MARGIN)))
	control.add_theme_constant_override(THEME_MARGIN_TOP, int(margin_values.get(KEY_TOP, DEFAULT_MARGIN)))
	control.add_theme_constant_override(THEME_MARGIN_RIGHT, int(margin_values.get(KEY_RIGHT, DEFAULT_MARGIN)))
	control.add_theme_constant_override(THEME_MARGIN_BOTTOM, int(margin_values.get(KEY_BOTTOM, DEFAULT_MARGIN)))


static func apply_separation(control: Control, separation: int) -> void:
	control.add_theme_constant_override(THEME_SEPARATION, separation)


static func apply_grid_separation(grid: GridContainer, separation: int) -> void:
	grid.add_theme_constant_override(THEME_H_SEPARATION, separation)
	grid.add_theme_constant_override(THEME_V_SEPARATION, separation)
