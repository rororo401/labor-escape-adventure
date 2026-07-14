extends "res://scripts/tests/test_scene_tree.gd"

const ResultPopupCalibratorScene := preload("res://scenes/dev/ResultPopupLayoutCalibrator.tscn")
const ResultPopupOverlayConfigScript := preload("res://scripts/ui/result_popup_overlay_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var scene := ResultPopupCalibratorScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var preview := _helpers.find_node(scene, "ResultPopupCalibratorPreview")
	var input := _helpers.find_node(scene, "panel_xInput") as LineEdit
	var calibrator_panel := _helpers.find_node(scene, "ResultPopupCalibratorPanel") as PanelContainer
	var panel := _helpers.find_node(scene, ResultPopupOverlayConfigScript.PANEL_IMAGE_NAME) as TextureRect
	var save_button := _helpers.find_button_containing(scene, "저장")
	var back_button := _helpers.find_button_containing(scene, "뒤로")
	_expect(preview != null, "calibrator should render a result popup preview")
	_expect(input != null, "calibrator should expose numeric position inputs")
	var design_viewport := Rect2(Vector2.ZERO, Vector2(720.0, 1280.0))
	_expect(calibrator_panel != null and calibrator_panel.get_global_rect().end.x <= design_viewport.end.x, "calibrator panel should fit inside the design viewport")
	_expect(calibrator_panel != null and _controls_fit_viewport(calibrator_panel, design_viewport), "calibrator controls should stay inside the design viewport")
	_expect(panel != null, "calibrator preview should expose receipt panel")
	_expect(save_button != null, "calibrator should expose save button")
	_expect(back_button != null, "calibrator should expose back button")

	input.text = "120"
	input.text_changed.emit("120")
	await process_frame
	_expect(int(panel.position.x) == 120, "calibrator input should apply to preview panel position")

	var right_key := InputEventKey.new()
	right_key.keycode = KEY_RIGHT
	right_key.pressed = true
	input.grab_focus()
	input.gui_input.emit(right_key)
	await process_frame
	_expect(input.text == "121", "right arrow should nudge focused x input by 1 pixel")
	_expect(int(panel.position.x) == 121, "right arrow nudge should apply to preview panel position")

	scene.queue_free()
	await process_frame
	print("Result popup layout calibrator smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


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
