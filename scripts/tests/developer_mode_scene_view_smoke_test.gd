extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperModeSceneConfigScript := preload("res://scripts/dev/developer_mode_scene_config.gd")
const DeveloperModeScene := preload("res://scenes/dev/DeveloperModeScene.tscn")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var scene := DeveloperModeScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var background := _helpers.find_node(scene, DeveloperModeSceneConfigScript.BACKGROUND_NAME)
	var panel := _helpers.find_node(scene, DeveloperModeSceneConfigScript.PANEL_NAME) as PanelContainer
	var message := _helpers.find_node(scene, DeveloperModeSceneConfigScript.MESSAGE_LABEL_NAME) as Label
	var back_button := _helpers.find_node(scene, DeveloperModeSceneConfigScript.BACK_BUTTON_NAME) as Button
	_expect(background != null, "developer mode should render configured background")
	_expect(panel != null, "developer mode should render configured panel")
	_expect(panel.position == DeveloperModeSceneConfigScript.PANEL_POSITION, "developer panel should use configured position")
	_expect(panel.custom_minimum_size == DeveloperModeSceneConfigScript.PANEL_SIZE, "developer panel should use configured minimum size")
	_expect(panel.size.x >= DeveloperModeSceneConfigScript.PANEL_SIZE.x and panel.size.y >= DeveloperModeSceneConfigScript.PANEL_SIZE.y, "developer panel should not shrink below configured size")
	var design_viewport := Rect2(Vector2.ZERO, Vector2(DeveloperModeSceneConfigScript.DESIGN_VIEWPORT_WIDTH, 1280.0))
	_expect(panel.get_global_rect().end.x <= design_viewport.end.x, "developer panel should fit inside the design viewport width")
	var margin := panel.get_child(0) as MarginContainer
	_expect(margin != null and margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_TOP) == int(DeveloperModeSceneConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_TOP, 0)), "developer panel should use configured layout margin")
	var layout := margin.get_child(0) as VBoxContainer
	_expect(layout != null and layout.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == DeveloperModeSceneConfigScript.LAYOUT_SEPARATION, "developer panel should use configured layout separation")
	_expect(_find_label_with_text(scene, DeveloperModeSceneConfigScript.TITLE_TEXT) != null, "developer mode should render configured title")
	_expect(_find_label_with_text(scene, DeveloperModeSceneConfigScript.SUBTITLE_TEXT) != null, "developer mode should render configured subtitle")
	_expect(message != null and message.custom_minimum_size == DeveloperModeSceneConfigScript.MESSAGE_LABEL_SIZE, "developer mode should render configured message label")
	_expect(message.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "developer message should wrap long status text")
	_expect(back_button != null and back_button.text == DeveloperModeSceneConfigScript.BACK_BUTTON_TEXT, "developer mode should render configured back button")
	_expect(_controls_fit_viewport(panel, design_viewport), "developer mode controls should stay inside the design viewport")

	print("Developer mode scene view smoke test passed.")
	finish_test()


func _find_label_with_text(root_node: Node, text: String) -> Label:
	if root_node is Label:
		var label := root_node as Label
		if label.text == text:
			return label
	for child in root_node.get_children():
		var found := _find_label_with_text(child, text)
		if found != null:
			return found
	return null


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
