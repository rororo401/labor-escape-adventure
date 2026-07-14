extends "res://scripts/tests/test_scene_tree.gd"

const ClosedDayButtonItemStateConfigScript := preload("res://scripts/ui/closed_day_button_item_state_config.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(ClosedDayButtonItemStateConfigScript.KEY_ID == UiPayloadKeysScript.KEY_ID, "state id key should use the shared UI payload key")
	_expect(ClosedDayButtonItemStateConfigScript.KEY_LABEL == UiPayloadKeysScript.KEY_LABEL, "state label key should use the shared UI payload key")
	_expect(ClosedDayButtonItemStateConfigScript.KEY_TOOLTIP == UiPayloadKeysScript.KEY_TOOLTIP, "state tooltip key should use the shared UI payload key")
	_expect(ClosedDayButtonItemStateConfigScript.ROW_ID == DayEventKeysScript.KEY_ID, "row id key should use the shared day-event key")
	_expect(ClosedDayButtonItemStateConfigScript.ROW_NAME == DayEventKeysScript.KEY_NAME_KO, "row name key should use the shared day-event key")
	_expect(ClosedDayButtonItemStateConfigScript.ROW_SUMMARY == DayEventKeysScript.KEY_SUMMARY_KO, "row summary key should use the shared day-event key")
	_expect(ClosedDayButtonItemStateConfigScript.EMPTY_ID == UiPayloadKeysScript.EMPTY_MESSAGE, "empty id should use the shared blank UI default")
	_expect(ClosedDayButtonItemStateConfigScript.EMPTY_LABEL == UiPayloadKeysScript.EMPTY_MESSAGE, "empty label should use the shared blank UI default")
	_expect(ClosedDayButtonItemStateConfigScript.CHOICE_LABEL_SEPARATOR == "\n", "choice label separator should stay a newline")

	print("Closed-day button item state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
