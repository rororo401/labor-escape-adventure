extends "res://scripts/tests/test_scene_tree.gd"

const StandingCalibratorInputScript := preload("res://scripts/dev/standing_calibrator_input.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_verify_keys()
	_verify_movement_keys()
	_verify_selection_keys()
	_verify_commit_and_back_keys()
	_verify_ignored_keys()

	print("Standing calibrator input smoke test passed.")
	finish_test()


func _verify_keys() -> void:
	_expect(StandingCalibratorInputScript.KEY_ACTION == UiPayloadKeysScript.KEY_ACTION, "action key should use the shared UI payload key")
	_expect(StandingCalibratorInputScript.KEY_DELTA == "delta", "delta key should stay stable")
	_expect(StandingCalibratorInputScript.KEY_INDEX == "index", "index key should stay stable")
	_expect(StandingCalibratorInputScript.action(StandingCalibratorInputScript.ACTION_NONE).get(StandingCalibratorInputScript.KEY_ACTION, "") == StandingCalibratorInputScript.ACTION_NONE, "action helper should return action payload")


func _verify_movement_keys() -> void:
	_expect_action(_key_action(KEY_LEFT), StandingCalibratorInputScript.ACTION_MOVE, "left should move")
	_expect(_key_action(KEY_LEFT).get(StandingCalibratorInputScript.KEY_DELTA, Vector2.ZERO) == Vector2(-1, 0), "left should move one pixel left")
	_expect(_key_action(KEY_RIGHT).get(StandingCalibratorInputScript.KEY_DELTA, Vector2.ZERO) == Vector2(1, 0), "right should move one pixel right")
	_expect(_key_action(KEY_UP).get(StandingCalibratorInputScript.KEY_DELTA, Vector2.ZERO) == Vector2(0, -1), "up should move one pixel up")
	_expect(_key_action(KEY_DOWN).get(StandingCalibratorInputScript.KEY_DELTA, Vector2.ZERO) == Vector2(0, 1), "down should move one pixel down")


func _verify_selection_keys() -> void:
	_expect_action(_key_action(KEY_Q), StandingCalibratorInputScript.ACTION_SELECT_RELATIVE, "Q should select previous")
	_expect(int(_key_action(KEY_Q).get(StandingCalibratorInputScript.KEY_DELTA, 0)) == -1, "Q should select previous entry")
	_expect(int(_key_action(KEY_E).get(StandingCalibratorInputScript.KEY_DELTA, 0)) == 1, "E should select next entry")
	_expect_action(_key_action(KEY_1), StandingCalibratorInputScript.ACTION_SELECT_INDEX, "1 should quick-select first entry")
	_expect(int(_key_action(KEY_1).get(StandingCalibratorInputScript.KEY_INDEX, -1)) == 0, "1 should map to index 0")
	_expect(int(_key_action(KEY_9).get(StandingCalibratorInputScript.KEY_INDEX, -1)) == 8, "9 should map to index 8")


func _verify_commit_and_back_keys() -> void:
	_expect_action(_key_action(KEY_ENTER), StandingCalibratorInputScript.ACTION_CONFIRM, "Enter should confirm")
	_expect_action(_key_action(KEY_KP_ENTER), StandingCalibratorInputScript.ACTION_CONFIRM, "keypad Enter should confirm")
	_expect_action(_key_action(KEY_ESCAPE), StandingCalibratorInputScript.ACTION_BACK, "Escape should go back")


func _verify_ignored_keys() -> void:
	_expect_action(_key_action(KEY_A), StandingCalibratorInputScript.ACTION_NONE, "unmapped key should be ignored")
	var echo_event := _key_event(KEY_RIGHT)
	echo_event.echo = true
	_expect_action(StandingCalibratorInputScript.action_from_event(echo_event), StandingCalibratorInputScript.ACTION_NONE, "echo key should be ignored")
	var released_event := _key_event(KEY_RIGHT)
	released_event.pressed = false
	_expect_action(StandingCalibratorInputScript.action_from_event(released_event), StandingCalibratorInputScript.ACTION_NONE, "released key should be ignored")


func _key_action(keycode: int) -> Dictionary:
	return StandingCalibratorInputScript.action_from_event(_key_event(keycode))


func _key_event(keycode: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	event.echo = false
	return event


func _expect_action(action: Dictionary, expected: String, message: String) -> void:
	_expect(String(action.get(StandingCalibratorInputScript.KEY_ACTION, "")) == expected, message)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
