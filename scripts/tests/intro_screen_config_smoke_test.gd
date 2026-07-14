extends "res://scripts/tests/test_scene_tree.gd"

const IntroScreenConfigScript := preload("res://scripts/ui/intro_screen_config.gd")
const ProjectSettingKeysScript := preload("res://scripts/core/project_setting_keys.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")


func _initialize() -> void:
	_expect(IntroScreenConfigScript.BACKGROUND_PATH == "res://assets/ui/title_background.png", "intro background path should stay stable")
	_expect(IntroScreenConfigScript.TITLE_LOGO_PATH == "res://assets/ui/title_logo.png", "title logo path should stay stable")
	_expect(IntroScreenConfigScript.START_BUTTON_PATH == "res://assets/ui/title_buttons/title_button_start.png", "start button image path should use the title button set")
	_expect(IntroScreenConfigScript.CONTINUE_BUTTON_PATH == "res://assets/ui/title_buttons/title_button_continue.png", "continue button image path should use the title button set")
	_expect(IntroScreenConfigScript.GALLERY_BUTTON_PATH == "res://assets/ui/title_buttons/title_button_gallery.png", "gallery button image path should use the title button set")
	_expect(IntroScreenConfigScript.PROFILE_SCENE_PATH == UiScenePathsScript.PROFILE_SETUP, "profile scene path should use the shared scene path")
	_expect(IntroScreenConfigScript.DEVELOPER_MODE_SCENE_PATH == UiScenePathsScript.DEVELOPER_MODE, "developer mode scene path should use the shared scene path")
	_expect(IntroScreenConfigScript.MARKET_SCENE_PATH == UiScenePathsScript.MARKET_SCREEN, "market scene path should use the shared scene path")
	_expect(IntroScreenConfigScript.DEFAULT_DEVELOPER_RUN_DATE == "2016-07-02", "default developer run date should stay stable")
	_expect(IntroScreenConfigScript.DEV_SESSION_STORE_PATH_SETTING == ProjectSettingKeysScript.DEV_SESSION_STORE_PATH, "dev-session setting key should use the shared project setting key")
	_expect(IntroScreenConfigScript.SHOW_DEVELOPER_QUICK_LAUNCH_SETTING == ProjectSettingKeysScript.SHOW_DEVELOPER_QUICK_LAUNCH, "developer quick-launch setting key should use the shared project setting key")
	_expect(IntroScreenConfigScript.DEVELOPER_QUICK_TEXT_PREFIX.contains("개발"), "developer quick-launch copy should stay centralized")
	_expect(IntroScreenConfigScript.CONTINUE_TEXT == "이어하기", "continue copy should stay centralized")
	_expect(IntroScreenConfigScript.GALLERY_TEXT == "앨범", "gallery copy should stay centralized")
	_expect(IntroScreenConfigScript.CONTINUE_FAILED_TEXT.contains("불러오지 못했어"), "continue failure copy should stay centralized")
	_expect(IntroScreenConfigScript.LOGO_FLOAT_UP_OFFSET == 14.0, "logo float up offset should stay stable")
	_expect(IntroScreenConfigScript.LOGO_FLOAT_DOWN_OFFSET == 10.0, "logo float down offset should stay stable")
	_expect(IntroScreenConfigScript.LOGO_FLOAT_DURATION == 1.8, "logo float duration should stay stable")
	_expect(IntroScreenConfigScript.START_BUTTON_PRESSED_SCALE == Vector2(0.92, 0.92), "start button pressed scale should stay stable")
	_expect(IntroScreenConfigScript.START_SCENE_CHANGE_DELAY == 0.24, "start scene-change delay should stay stable")

	print("Intro screen config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
