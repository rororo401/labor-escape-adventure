extends "res://scripts/tests/test_scene_tree.gd"

const FlowButtonStateConfigScript := preload("res://scripts/ui/flow_button_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(FlowButtonStateConfigScript.KEY_TEXT == UiPayloadKeysScript.KEY_TEXT, "text key should use the shared UI payload key")
	_expect(FlowButtonStateConfigScript.KEY_DISABLED == UiPayloadKeysScript.KEY_DISABLED, "disabled key should use the shared UI payload key")
	_expect(FlowButtonStateConfigScript.EMPTY_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "empty text should use the shared UI payload default")
	_expect(FlowButtonStateConfigScript.DEFAULT_DISABLED, "default disabled should stay true")

	print("Flow button state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
