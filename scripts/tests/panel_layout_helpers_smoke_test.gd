extends "res://scripts/tests/test_scene_tree.gd"

const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")


func _initialize() -> void:
	var host := Control.new()
	root.add_child(host)

	var layout := PanelLayoutHelpersScript.add_margin_layout(
		host,
		Vector2(320, 180),
		{
			PanelLayoutHelpersScript.KEY_LEFT: 11,
			PanelLayoutHelpersScript.KEY_TOP: 12,
			PanelLayoutHelpersScript.KEY_RIGHT: 13,
			PanelLayoutHelpersScript.KEY_BOTTOM: 14
		},
		17
	)
	_expect(PanelLayoutHelpersScript.KEY_LEFT == "left", "left margin key should stay stable")
	_expect(PanelLayoutHelpersScript.THEME_MARGIN_LEFT == "margin_left", "theme left margin key should stay stable")
	_expect(host.get_child_count() == 1, "helper should add one margin container")
	var margin := host.get_child(0) as MarginContainer
	_expect(margin != null, "helper should create a margin container")
	_expect(margin.size == Vector2(320, 180), "helper should size the margin container")
	_expect(margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_LEFT) == 11, "helper should apply left margin")
	_expect(margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_TOP) == 12, "helper should apply top margin")
	_expect(margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_RIGHT) == 13, "helper should apply right margin")
	_expect(margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_BOTTOM) == 14, "helper should apply bottom margin")
	_expect(layout != null and layout.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == 17, "helper should create configured VBox layout")

	var row := PanelLayoutHelpersScript.make_row(9, "ActionRow")
	_expect(row.name == "ActionRow", "row helper should keep the configured name")
	_expect(row.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == 9, "row helper should apply separation")
	PanelLayoutHelpersScript.apply_theme_margins(row, {
		PanelLayoutHelpersScript.KEY_LEFT: 21,
		PanelLayoutHelpersScript.KEY_TOP: 22
	})
	_expect(row.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_LEFT) == 21, "helper should apply left margin to generic controls")
	_expect(row.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_TOP) == 22, "helper should apply top margin to generic controls")
	_expect(row.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_RIGHT) == PanelLayoutHelpersScript.DEFAULT_MARGIN, "helper should default missing right margin")

	var grid := PanelLayoutHelpersScript.make_grid(3, 8, "ChoiceGrid")
	_expect(grid.name == "ChoiceGrid", "grid helper should keep the configured name")
	_expect(grid.columns == 3, "grid helper should apply columns")
	_expect(grid.get_theme_constant(PanelLayoutHelpersScript.THEME_H_SEPARATION) == 8, "grid helper should apply horizontal separation")
	_expect(grid.get_theme_constant(PanelLayoutHelpersScript.THEME_V_SEPARATION) == 8, "grid helper should apply vertical separation")

	host.free()
	row.free()
	grid.free()

	print("Panel layout helpers smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
