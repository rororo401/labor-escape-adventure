extends "res://scripts/tests/test_scene_tree.gd"

const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")


func _initialize() -> void:
	_expect(UiScenePathsScript.INTRO_SCREEN == "res://scenes/intro/IntroScreen.tscn", "intro scene path should stay stable")
	_expect(UiScenePathsScript.PROFILE_SETUP == "res://scenes/profile/ProfileSetupScene.tscn", "profile scene path should stay stable")
	_expect(UiScenePathsScript.PROLOGUE == "res://scenes/prologue/PrologueScene.tscn", "prologue scene path should stay stable")
	_expect(UiScenePathsScript.MARKET_SCREEN == "res://scenes/market/MarketScreen.tscn", "market scene path should stay stable")
	_expect(UiScenePathsScript.FIRST_DAY_WORK == "res://scenes/day/FirstDayWorkScene.tscn", "first-day work scene path should stay stable")
	_expect(UiScenePathsScript.DEVELOPER_MODE == "res://scenes/dev/DeveloperModeScene.tscn", "developer mode scene path should stay stable")
	_expect(UiScenePathsScript.STANDING_POSITION_CALIBRATOR == "res://scenes/dev/StandingPositionCalibrator.tscn", "standing calibrator scene path should stay stable")
	_expect(UiScenePathsScript.RESULT_POPUP_LAYOUT_CALIBRATOR == "res://scenes/dev/ResultPopupLayoutCalibrator.tscn", "result-popup calibrator scene path should stay stable")

	_expect(ResourceLoader.exists(UiScenePathsScript.INTRO_SCREEN), "intro scene should exist")
	_expect(ResourceLoader.exists(UiScenePathsScript.PROFILE_SETUP), "profile scene should exist")
	_expect(ResourceLoader.exists(UiScenePathsScript.PROLOGUE), "prologue scene should exist")
	_expect(ResourceLoader.exists(UiScenePathsScript.MARKET_SCREEN), "market scene should exist")
	_expect(ResourceLoader.exists(UiScenePathsScript.FIRST_DAY_WORK), "first-day work scene should exist")
	_expect(ResourceLoader.exists(UiScenePathsScript.DEVELOPER_MODE), "developer mode scene should exist")
	_expect(ResourceLoader.exists(UiScenePathsScript.STANDING_POSITION_CALIBRATOR), "standing calibrator scene should exist")
	_expect(ResourceLoader.exists(UiScenePathsScript.RESULT_POPUP_LAYOUT_CALIBRATOR), "result-popup calibrator scene should exist")

	print("UI scene paths smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
