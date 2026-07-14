extends "res://scripts/tests/test_scene_tree.gd"

const TestAssetPathsScript := preload("res://scripts/tests/test_asset_paths.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")


func _initialize() -> void:
	_expect(TestAssetPathsScript.HOME_PROLOGUE_BACKGROUND == UiBackgroundPathsScript.HOME_PROLOGUE_LIVING_ROOM, "test prologue background should reuse shared UI background path")
	_expect(TestAssetPathsScript.HOME_MORNING_BACKGROUND == UiBackgroundPathsScript.HOME_MORNING_BRIEFING, "test morning background should reuse shared UI background path")
	_expect(TestAssetPathsScript.MARKET_MORNING_BACKGROUND == UiBackgroundPathsScript.MARKET_MORNING_ROOM, "test market background should reuse shared UI background path")
	_expect(ResourceLoader.exists(TestAssetPathsScript.HOME_PROLOGUE_BACKGROUND), "test prologue background should exist")
	_expect(ResourceLoader.exists(TestAssetPathsScript.HOME_MORNING_BACKGROUND), "test morning background should exist")
	_expect(ResourceLoader.exists(TestAssetPathsScript.MARKET_MORNING_BACKGROUND), "test market background should exist")

	print("Test asset paths smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
