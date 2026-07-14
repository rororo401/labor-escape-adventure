class_name VnInputHelper
extends RefCounted


static func is_advance_event(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_accept") or is_primary_click(event)


static func is_primary_click(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if event is InputEventScreenTouch:
		return event.pressed
	return false
