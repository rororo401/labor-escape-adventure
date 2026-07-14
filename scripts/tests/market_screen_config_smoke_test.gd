extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenConfigScript := preload("res://scripts/ui/market_screen_config.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")


func _initialize() -> void:
	_expect(
		MarketScreenConfigScript.MARKET_BACKGROUND_PATH == UiBackgroundPathsScript.MARKET_MORNING_ROOM,
		"market-open background path should use the shared background path"
	)
	_expect(
		MarketScreenConfigScript.CLOSED_DAY_BACKGROUND_PATH == UiBackgroundPathsScript.HOME_MORNING_BRIEFING,
		"closed-day background path should use the shared background path"
	)
	_expect(ResourceLoader.exists(MarketScreenConfigScript.MARKET_BACKGROUND_PATH), "market-open background should exist")
	_expect(ResourceLoader.exists(MarketScreenConfigScript.CLOSED_DAY_BACKGROUND_PATH), "closed-day background should exist")

	print("Market screen config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
