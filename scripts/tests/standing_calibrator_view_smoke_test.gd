extends "res://scripts/tests/test_scene_tree.gd"

const StandingCalibratorDisplayStateScript := preload("res://scripts/dev/standing_calibrator_display_state.gd")
const StandingCalibratorViewConfigScript := preload("res://scripts/dev/standing_calibrator_view_config.gd")
const StandingCalibratorViewScript := preload("res://scripts/dev/standing_calibrator_view.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TestAssetPathsScript := preload("res://scripts/tests/test_asset_paths.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const BACKGROUND_PATH := TestAssetPathsScript.HOME_PROLOGUE_BACKGROUND

var _helpers := TestHelpersScript.new()
var _selected_index := -1
var _confirmed := false
var _reset := false
var _back := false


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var host := Control.new()
	root.add_child(host)

	var nodes := StandingCalibratorViewScript.build(host, BACKGROUND_PATH, [
		{"label": "홈웨어 미소", "outfit": "homewear", "expression": "smile"},
		{"label": "외출복 고민", "outfit": "casual_default", "expression": "thinking"}
	], StandingCalibratorViewConfigScript.callbacks(
		_select_entry,
		_confirm,
		_reset_current,
		_go_back
	))
	await process_frame

	_expect(_helpers.find_node(host, StandingCalibratorViewConfigScript.BACKGROUND_NAME) != null, "view should add calibration background")
	_expect(_helpers.find_node(host, StandingCalibratorViewConfigScript.CHARACTER_RECT_NAME) != null, "view should add character texture rect")
	var panel := _helpers.find_node(host, StandingCalibratorViewConfigScript.PANEL_NAME) as PanelContainer
	_expect(panel != null, "view should add control panel")
	_expect(panel.position == StandingCalibratorViewConfigScript.PANEL_POSITION, "panel should use configured position")
	_expect(panel.custom_minimum_size == StandingCalibratorViewConfigScript.PANEL_SIZE, "panel should use configured minimum size")
	var design_viewport := Rect2(Vector2.ZERO, Vector2(720.0, 1280.0))
	_expect(panel.get_global_rect().end.x <= design_viewport.end.x, "standing calibrator panel should fit inside the design viewport")
	var margin := panel.get_child(0) as MarginContainer
	_expect(margin != null and margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_LEFT) == int(StandingCalibratorViewConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)), "panel should use configured layout margin")
	var layout := margin.get_child(0) as VBoxContainer
	_expect(layout != null and layout.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == StandingCalibratorViewConfigScript.LAYOUT_SEPARATION, "panel should use configured layout separation")
	var button_grid := _helpers.find_node(host, StandingCalibratorViewConfigScript.BUTTON_GRID_NAME) as GridContainer
	_expect(button_grid != null and button_grid.columns == StandingCalibratorViewConfigScript.BUTTON_GRID_COLUMNS, "view should add entry button grid")
	_expect(button_grid.get_theme_constant(PanelLayoutHelpersScript.THEME_H_SEPARATION) == StandingCalibratorViewConfigScript.BUTTON_GRID_SEPARATION, "entry button grid should use configured separation")

	var entry_label := nodes.get(StandingCalibratorViewConfigScript.KEY_ENTRY_LABEL) as Label
	var offset_label := nodes.get(StandingCalibratorViewConfigScript.KEY_OFFSET_LABEL) as Label
	var save_label := nodes.get(StandingCalibratorViewConfigScript.KEY_SAVE_LABEL) as Label
	var entry_buttons: Array = nodes.get(StandingCalibratorViewConfigScript.KEY_ENTRY_BUTTONS, [])
	_expect(entry_label != null and entry_label.name == StandingCalibratorViewConfigScript.ENTRY_LABEL_NAME, "view should expose entry label")
	_expect(entry_label.text == StandingCalibratorViewConfigScript.ENTRY_LABEL_TEXT, "entry label should use configured text")
	_expect(offset_label != null and offset_label.name == StandingCalibratorViewConfigScript.OFFSET_LABEL_NAME, "view should expose offset label")
	_expect(save_label != null and save_label.text == StandingCalibratorDisplayStateScript.INITIAL_HELP_TEXT, "view should expose initial help copy")
	_expect(entry_buttons.size() == 2, "view should create one button per standing entry")
	_expect((entry_buttons[0] as Button).name == StandingCalibratorViewConfigScript.ENTRY_BUTTON_NAME_FORMAT % 1, "view should name first entry button")
	_expect((entry_buttons[0] as Button).text == "01 홈웨어 미소", "view should format first entry button text")
	for button in entry_buttons:
		var entry_button := button as Button
		_expect(entry_button.clip_text, "entry buttons should clip long labels instead of widening the panel")
		_expect(entry_button.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "entry buttons should trim long labels")
	_expect(_controls_fit_viewport(panel, design_viewport), "standing calibrator controls should stay inside the design viewport")

	(entry_buttons[1] as Button).pressed.emit()
	(_helpers.find_node(host, StandingCalibratorViewConfigScript.CONFIRM_BUTTON_NAME) as Button).pressed.emit()
	(_helpers.find_node(host, StandingCalibratorViewConfigScript.RESET_BUTTON_NAME) as Button).pressed.emit()
	(_helpers.find_node(host, StandingCalibratorViewConfigScript.BACK_BUTTON_NAME) as Button).pressed.emit()

	_expect(_selected_index == 1, "entry button should call bound select callback")
	_expect(_confirmed, "confirm button should call callback")
	_expect(_reset, "reset button should call callback")
	_expect(_back, "back button should call callback")

	print("Standing calibrator view smoke test passed.")
	finish_test()


func _select_entry(index: int) -> void:
	_selected_index = index


func _confirm() -> void:
	_confirmed = true


func _reset_current() -> void:
	_reset = true


func _go_back() -> void:
	_back = true


func _controls_fit_viewport(root_node: Node, viewport_rect: Rect2) -> bool:
	if root_node is Control:
		var control := root_node as Control
		var rect := control.get_global_rect()
		if control.visible and rect.size.x > 0.0 and rect.size.y > 0.0:
			if rect.position.x < viewport_rect.position.x - 0.5 or rect.end.x > viewport_rect.end.x + 0.5:
				return false
	for child in root_node.get_children():
		if not _controls_fit_viewport(child, viewport_rect):
			return false
	return true


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
