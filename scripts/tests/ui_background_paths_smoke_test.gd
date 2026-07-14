extends "res://scripts/tests/test_scene_tree.gd"

const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")


func _initialize() -> void:
	_expect(UiBackgroundPathsScript.HOME_PROLOGUE_LIVING_ROOM == "res://assets/backgrounds/home/prologue_living_room_lovely.png", "home prologue background path should stay stable")
	_expect(UiBackgroundPathsScript.HOME_MORNING_BRIEFING == "res://assets/backgrounds/home/morning_room_briefing.png", "home morning briefing background path should stay stable")
	_expect(UiBackgroundPathsScript.MARKET_MORNING_ROOM == "res://assets/backgrounds/market/morning_market_room.png", "market morning background path should stay stable")
	_expect(ResourceLoader.exists(UiBackgroundPathsScript.HOME_PROLOGUE_LIVING_ROOM), "home prologue background should exist")
	_expect(ResourceLoader.exists(UiBackgroundPathsScript.HOME_MORNING_BRIEFING), "home morning briefing background should exist")
	_expect(ResourceLoader.exists(UiBackgroundPathsScript.MARKET_MORNING_ROOM), "market morning background should exist")

	print("UI background paths smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
