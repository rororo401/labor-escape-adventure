extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperDateJumpPanelConfigScript := preload("res://scripts/dev/developer_date_jump_panel_config.gd")
const DeveloperDateJumpPanelScript := preload("res://scripts/dev/developer_date_jump_panel.gd")


func _initialize() -> void:
	_expect(DeveloperDateJumpPanelConfigScript.PANEL_NAME == "DeveloperDateJumpPanel", "panel name should stay stable")
	_expect(DeveloperDateJumpPanelConfigScript.STANDING_BUTTON_NAME == "StandingCalibratorButton", "standing button name should stay stable")
	_expect(DeveloperDateJumpPanelConfigScript.RESULT_POPUP_BUTTON_NAME == "ResultPopupCalibratorButton", "result-popup button name should stay stable")
	_expect(DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_BUTTON_NAME == "FirstFridayJumpButton", "first Friday button name should stay stable")
	_expect(DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_BUTTON_NAME == "FirstSaturdayJumpButton", "first Saturday button name should stay stable")
	_expect(DeveloperDateJumpPanelConfigScript.DATE_INPUT_NAME == "DateJumpInput", "date input name should stay stable")
	_expect(DeveloperDateJumpPanelConfigScript.DATE_BUTTON_NAME == "DateJumpButton", "date button name should stay stable")
	_expect(DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_DATE == "2016-07-01", "first Friday date should stay stable")
	_expect(DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_DATE == "2016-07-02", "first Saturday date should stay stable")
	_expect(DeveloperDateJumpPanelScript.FIRST_SATURDAY_DATE == DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_DATE, "panel should expose legacy Saturday constant from config")
	_expect(DeveloperDateJumpPanelConfigScript.RESULT_POPUP_BUTTON_TEXT == "오늘의 변화 위치조정", "result-popup button copy should be centralized")
	_expect(DeveloperDateJumpPanelConfigScript.BASELINE_TEXT.contains("새 게임"), "baseline copy should be centralized")
	_expect(DeveloperDateJumpPanelConfigScript.DATE_INPUT_SIZE == Vector2(360, 54), "date input size should preserve current layout")

	print("Developer date jump panel config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
