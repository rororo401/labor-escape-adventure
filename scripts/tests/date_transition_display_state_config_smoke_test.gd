extends "res://scripts/tests/test_scene_tree.gd"

const DateTransitionDisplayStateConfigScript := preload("res://scripts/ui/date_transition_display_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")
const DisplayPayloadKeysScript := preload("res://scripts/core/display_payload_keys.gd")


func _initialize() -> void:
	_expect(DateTransitionDisplayStateConfigScript.KEY_DATE_TEXT == DisplayPayloadKeysScript.KEY_DATE_TEXT, "date text key should use the shared display payload key")
	_expect(DateTransitionDisplayStateConfigScript.KEY_WEEKDAY_TEXT == "weekday_text", "weekday text key should stay stable")
	_expect(DateTransitionDisplayStateConfigScript.KEY_STAMP_TEXT == "stamp_text", "stamp text key should stay stable")
	_expect(DateTransitionDisplayStateConfigScript.CLOSING_TEXT == "하루를 마무리하는 중", "closing copy should stay stable")
	_expect(DateTransitionDisplayStateConfigScript.MORNING_STAMP_TEXT == "새로운 하루!", "morning stamp copy should stay stable")
	_expect(DateTransitionDisplayStateConfigScript.EMPTY_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "empty text should use the shared UI payload default")

	print("Date transition display state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
