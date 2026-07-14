extends "res://scripts/tests/test_scene_tree.gd"

const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")
const IdentityPayloadKeysScript := preload("res://scripts/core/identity_payload_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")
const TextPayloadKeysScript := preload("res://scripts/core/text_payload_keys.gd")


func _initialize() -> void:
	_expect(UiPayloadKeysScript.KEY_MESSAGE == "message", "UI message payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_RESULT == ResultKeysScript.KEY_RESULT, "UI result payload key should use the shared result key")
	_expect(UiPayloadKeysScript.KEY_STATE == "state", "UI state payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_ACTION == "action", "UI action payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_TEXT == TextPayloadKeysScript.KEY_TEXT, "UI text payload key should use the shared text key")
	_expect(UiPayloadKeysScript.KEY_DISABLED == "disabled", "UI disabled payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_HANDLED == "handled", "UI handled payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_REQUEST == "request", "UI request payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_ID == IdentityPayloadKeysScript.KEY_ID, "UI id payload key should use the shared identity key")
	_expect(UiPayloadKeysScript.KEY_LABEL == "label", "UI label payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_LABELS == "labels", "UI labels payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_TOOLTIP == "tooltip", "UI tooltip payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_SELECTED_INDEX == "selected_index", "UI selected-index payload key should stay stable")
	_expect(UiPayloadKeysScript.KEY_HAS_SELECTION == "has_selection", "UI has-selection payload key should stay stable")
	_expect(UiPayloadKeysScript.EMPTY_MESSAGE == "", "empty UI message should stay blank")

	print("UI payload keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
