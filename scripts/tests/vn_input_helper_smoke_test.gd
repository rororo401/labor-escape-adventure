extends "res://scripts/tests/test_scene_tree.gd"

const VnInputHelperScript := preload("res://scripts/ui/vn_input_helper.gd")


func _initialize() -> void:
	var left_click := InputEventMouseButton.new()
	left_click.button_index = MOUSE_BUTTON_LEFT
	left_click.pressed = true
	_expect(VnInputHelperScript.is_primary_click(left_click), "pressed left mouse button should be a primary click")
	_expect(VnInputHelperScript.is_advance_event(left_click), "pressed left mouse button should advance VN text")

	var released_left_click := InputEventMouseButton.new()
	released_left_click.button_index = MOUSE_BUTTON_LEFT
	released_left_click.pressed = false
	_expect(not VnInputHelperScript.is_primary_click(released_left_click), "released left mouse button should not advance")

	var right_click := InputEventMouseButton.new()
	right_click.button_index = MOUSE_BUTTON_RIGHT
	right_click.pressed = true
	_expect(not VnInputHelperScript.is_primary_click(right_click), "right mouse button should not be a primary click")
	_expect(not VnInputHelperScript.is_advance_event(right_click), "right mouse button should not advance VN text")

	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	_expect(VnInputHelperScript.is_primary_click(touch), "pressed screen touch should be a primary click")
	_expect(VnInputHelperScript.is_advance_event(touch), "pressed screen touch should advance VN text")

	var released_touch := InputEventScreenTouch.new()
	released_touch.pressed = false
	_expect(not VnInputHelperScript.is_primary_click(released_touch), "released screen touch should not advance")

	print("VN input helper smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
