extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperDayActionPreviewPanelConfigScript := preload("res://scripts/dev/developer_day_action_preview_panel_config.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(DeveloperDayActionPreviewPanelConfigScript.PANEL_NAME == "DeveloperDayActionPreviewPanel", "panel name should stay stable")
	_expect(DeveloperDayActionPreviewPanelConfigScript.PREVIEW_OPTION_NAME == "DayActionPreviewOption", "preview option name should stay stable")
	_expect(DeveloperDayActionPreviewPanelConfigScript.PREVIEW_BUTTON_NAME == "DayActionPreviewButton", "preview button name should stay stable")
	_expect(DeveloperDayActionPreviewPanelConfigScript.QUICK_ROW_NAME == "DayActionQuickPreviewRow", "quick row name should stay stable")
	_expect(DeveloperDayActionPreviewPanelConfigScript.DAY_EVENTS_PATH == GameStateConfigScript.DAY_EVENTS_PATH, "day-events path should use the shared game-state config")
	_expect(DeveloperDayActionPreviewPanelConfigScript.CHOICE_CLOSED_MODE == "choice_closed", "closed-day mode filter should stay stable")
	_expect(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_ID == DayEventKeysScript.KEY_ID, "quick-preview id key should use the day-event id contract")
	_expect(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_BUTTON_NAME == "button_name", "quick-preview button-name key should stay stable")
	_expect(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_TEXT == UiPayloadKeysScript.KEY_TEXT, "quick-preview text key should use the shared UI payload key")
	_expect(DeveloperDayActionPreviewPanelConfigScript.TITLE_TEXT == "휴장일 이벤트 미리보기", "title copy should be centralized")
	_expect(DeveloperDayActionPreviewPanelConfigScript.PREVIEW_BUTTON_TEXT == "이벤트 보기", "preview button copy should be centralized")
	_expect(DeveloperDayActionPreviewPanelConfigScript.OPTION_SIZE == Vector2(360, 54), "option size should preserve current layout")
	_expect(DeveloperDayActionPreviewPanelConfigScript.QUICK_PREVIEWS.size() == 2, "quick previews should preserve current buttons")
	_expect(String(Dictionary(DeveloperDayActionPreviewPanelConfigScript.QUICK_PREVIEWS[0]).get(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_ID, "")) == "part_time", "first quick preview should stay part-time")

	print("Developer day-action preview panel config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
