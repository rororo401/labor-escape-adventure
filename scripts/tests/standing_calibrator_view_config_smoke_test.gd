extends "res://scripts/tests/test_scene_tree.gd"

const StandingCalibratorViewConfigScript := preload("res://scripts/dev/standing_calibrator_view_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")


func _initialize() -> void:
	_expect(StandingCalibratorViewConfigScript.BACKGROUND_NAME == "CalibrationBackground", "background name should stay stable")
	_expect(StandingCalibratorViewConfigScript.CHARACTER_RECT_NAME == "CalibratedStandingBust", "character rect name should stay stable")
	_expect(StandingCalibratorViewConfigScript.PANEL_NAME == "CalibrationPanel", "panel name should stay stable")
	_expect(StandingCalibratorViewConfigScript.PANEL_POSITION == Vector2(18, 18), "panel position should stay stable")
	_expect(StandingCalibratorViewConfigScript.PANEL_SIZE == Vector2(684, 286), "panel size should stay stable")
	_expect(int(StandingCalibratorViewConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)) == 18, "panel left margin should stay stable")
	_expect(StandingCalibratorViewConfigScript.LAYOUT_SEPARATION == 8, "layout separation should stay stable")
	_expect(StandingCalibratorViewConfigScript.BUTTON_GRID_COLUMNS == 4, "button grid columns should stay stable")
	_expect(StandingCalibratorViewConfigScript.BUTTON_SCROLL_SIZE == Vector2(648, 104), "button scroll size should stay stable")
	_expect(StandingCalibratorViewConfigScript.ENTRY_LABEL_TEXT == "스탠딩 위치 보정", "entry label text should stay stable")
	_expect(StandingCalibratorViewConfigScript.CONFIRM_BUTTON_TEXT == "현재 확정", "confirm button text should stay stable")
	_expect(StandingCalibratorViewConfigScript.RESET_BUTTON_TEXT == "0으로", "reset button text should stay stable")
	_expect(StandingCalibratorViewConfigScript.BACK_BUTTON_TEXT == "뒤로", "back button text should stay stable")
	_expect(StandingCalibratorViewConfigScript.KEY_CHARACTER_RECT == "character_rect", "character rect key should stay stable")
	_expect(StandingCalibratorViewConfigScript.KEY_ENTRY_LABEL == "entry_label", "entry label key should stay stable")
	_expect(StandingCalibratorViewConfigScript.KEY_OFFSET_LABEL == "offset_label", "offset label key should stay stable")
	_expect(StandingCalibratorViewConfigScript.KEY_SAVE_LABEL == "save_label", "save label key should stay stable")
	_expect(StandingCalibratorViewConfigScript.KEY_ENTRY_BUTTONS == "entry_buttons", "entry buttons key should stay stable")
	_expect(StandingCalibratorViewConfigScript.KEY_PANEL == "panel", "panel key should stay stable")
	_expect(StandingCalibratorViewConfigScript.CALLBACK_SELECT_ENTRY == "select_entry", "select callback key should stay stable")
	_expect(StandingCalibratorViewConfigScript.CALLBACK_CONFIRM == "confirm", "confirm callback key should stay stable")
	_expect(StandingCalibratorViewConfigScript.CALLBACK_RESET == "reset", "reset callback key should stay stable")
	_expect(StandingCalibratorViewConfigScript.CALLBACK_BACK == "back", "back callback key should stay stable")
	var callbacks := StandingCalibratorViewConfigScript.callbacks(_noop, _noop, _noop, _noop)
	_expect(callbacks.has(StandingCalibratorViewConfigScript.CALLBACK_SELECT_ENTRY), "callback helper should include select callback")
	_expect(callbacks.has(StandingCalibratorViewConfigScript.CALLBACK_CONFIRM), "callback helper should include confirm callback")
	_expect(callbacks.has(StandingCalibratorViewConfigScript.CALLBACK_RESET), "callback helper should include reset callback")
	_expect(callbacks.has(StandingCalibratorViewConfigScript.CALLBACK_BACK), "callback helper should include back callback")
	_expect(Callable(callbacks.get(StandingCalibratorViewConfigScript.CALLBACK_BACK, Callable())).is_valid(), "callback helper should store valid callables")

	print("Standing calibrator view config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _noop(_value = null) -> void:
	pass
