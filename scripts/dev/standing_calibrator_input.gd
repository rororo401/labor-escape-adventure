class_name StandingCalibratorInput
extends RefCounted

const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")

const KEY_ACTION := UiPayloadKeysScript.KEY_ACTION
const KEY_DELTA := "delta"
const KEY_INDEX := "index"

const ACTION_NONE := "none"
const ACTION_MOVE := "move"
const ACTION_SELECT_RELATIVE := "select_relative"
const ACTION_SELECT_INDEX := "select_index"
const ACTION_CONFIRM := "confirm"
const ACTION_BACK := "back"


static func action_from_event(event: InputEvent) -> Dictionary:
	if not _is_pressed_key(event):
		return action(ACTION_NONE)

	match (event as InputEventKey).keycode:
		KEY_LEFT:
			return move(Vector2(-1, 0))
		KEY_RIGHT:
			return move(Vector2(1, 0))
		KEY_UP:
			return move(Vector2(0, -1))
		KEY_DOWN:
			return move(Vector2(0, 1))
		KEY_Q:
			return select_relative(-1)
		KEY_E:
			return select_relative(1)
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			return select_index(int((event as InputEventKey).keycode) - KEY_1)
		KEY_ENTER, KEY_KP_ENTER:
			return action(ACTION_CONFIRM)
		KEY_ESCAPE:
			return action(ACTION_BACK)
		_:
			return action(ACTION_NONE)


static func action(action_id: String) -> Dictionary:
	return {
		KEY_ACTION: action_id
	}


static func move(delta: Vector2) -> Dictionary:
	return {
		KEY_ACTION: ACTION_MOVE,
		KEY_DELTA: delta
	}


static func select_relative(delta: int) -> Dictionary:
	return {
		KEY_ACTION: ACTION_SELECT_RELATIVE,
		KEY_DELTA: delta
	}


static func select_index(index: int) -> Dictionary:
	return {
		KEY_ACTION: ACTION_SELECT_INDEX,
		KEY_INDEX: index
	}


static func _is_pressed_key(event: InputEvent) -> bool:
	return event is InputEventKey and event.pressed and not event.echo
