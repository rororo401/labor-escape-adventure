extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperModeSceneConfigScript := preload("res://scripts/dev/developer_mode_scene_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const ProjectSettingKeysScript := preload("res://scripts/core/project_setting_keys.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")


func _initialize() -> void:
	_expect(DeveloperModeSceneConfigScript.BACKGROUND_NAME == "DeveloperModeBackground", "background node name should stay stable")
	_expect(DeveloperModeSceneConfigScript.PANEL_NAME == "DeveloperModePanel", "panel node name should stay stable")
	_expect(DeveloperModeSceneConfigScript.MESSAGE_LABEL_NAME == "DeveloperModeMessage", "message label node name should stay stable")
	_expect(DeveloperModeSceneConfigScript.BACK_BUTTON_NAME == "DeveloperBackButton", "back button node name should stay stable")
	_expect(DeveloperModeSceneConfigScript.BACKGROUND_PATH == UiBackgroundPathsScript.HOME_MORNING_BRIEFING, "background path should use the shared background path")
	_expect(DeveloperModeSceneConfigScript.CLOSED_DAY_BACKGROUND_PATH == UiBackgroundPathsScript.HOME_MORNING_BRIEFING, "closed-day preview background path should use the shared background path")
	_expect(DeveloperModeSceneConfigScript.INTRO_SCENE_PATH == UiScenePathsScript.INTRO_SCREEN, "intro scene path should use the shared scene path")
	_expect(DeveloperModeSceneConfigScript.MARKET_SCENE_PATH == UiScenePathsScript.MARKET_SCREEN, "market scene path should use the shared scene path")
	_expect(DeveloperModeSceneConfigScript.STANDING_CALIBRATOR_SCENE_PATH == UiScenePathsScript.STANDING_POSITION_CALIBRATOR, "standing calibrator scene path should use the shared scene path")
	_expect(DeveloperModeSceneConfigScript.RESULT_POPUP_CALIBRATOR_SCENE_PATH == UiScenePathsScript.RESULT_POPUP_LAYOUT_CALIBRATOR, "result-popup calibrator scene path should use the shared scene path")
	_expect(DeveloperModeSceneConfigScript.DEV_SESSION_STORE_PATH_SETTING == ProjectSettingKeysScript.DEV_SESSION_STORE_PATH, "developer session setting key should use the shared project setting key")
	_expect(DeveloperModeSceneConfigScript.PANEL_POSITION == Vector2(42, 72), "panel position should preserve current layout")
	_expect(DeveloperModeSceneConfigScript.PANEL_SIZE == Vector2(636, 1018), "panel size should preserve current layout")
	_expect(DeveloperModeSceneConfigScript.DESIGN_VIEWPORT_WIDTH == 720.0, "developer mode should stay aligned to the portrait design width")
	_expect(DeveloperModeSceneConfigScript.PANEL_SAFE_MARGIN_X == 42, "panel safe margin should preserve current layout")
	_expect(int(DeveloperModeSceneConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_TOP, 0)) == 30, "panel top margin should preserve current layout")
	_expect(DeveloperModeSceneConfigScript.LAYOUT_SEPARATION == 18, "layout separation should preserve current layout")
	_expect(DeveloperModeSceneConfigScript.TITLE_TEXT == "개발자 모드", "title copy should stay centralized")
	_expect(DeveloperModeSceneConfigScript.SUBTITLE_TEXT.contains("제작/검수"), "subtitle copy should stay centralized")
	_expect(DeveloperModeSceneConfigScript.BACK_BUTTON_TEXT == "인트로로 돌아가기", "back button copy should stay centralized")
	_expect(DeveloperModeSceneConfigScript.MESSAGE_LABEL_SIZE == Vector2(572, 58), "message size should leave room for wrapped status text")
	_expect(ResourceLoader.exists(DeveloperModeSceneConfigScript.BACKGROUND_PATH), "configured background should exist")
	_expect(ResourceLoader.exists(DeveloperModeSceneConfigScript.INTRO_SCENE_PATH), "configured intro scene should exist")
	_expect(ResourceLoader.exists(DeveloperModeSceneConfigScript.MARKET_SCENE_PATH), "configured market scene should exist")
	_expect(ResourceLoader.exists(DeveloperModeSceneConfigScript.STANDING_CALIBRATOR_SCENE_PATH), "configured standing calibrator scene should exist")
	_expect(ResourceLoader.exists(DeveloperModeSceneConfigScript.RESULT_POPUP_CALIBRATOR_SCENE_PATH), "configured result-popup calibrator scene should exist")

	print("Developer mode scene config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
