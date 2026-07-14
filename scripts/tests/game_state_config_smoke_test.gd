extends "res://scripts/tests/test_scene_tree.gd"

const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")


func _initialize() -> void:
	_expect(GameStateConfigScript.CALENDAR_PATH == "res://data/market/trading_calendar.csv", "calendar path should stay stable")
	_expect(GameStateConfigScript.DAY_EVENTS_PATH == "res://data/game/day_events.json", "day events path should stay stable")
	_expect(GameStateConfigScript.VN_STORIES_PATH == "res://data/game/vn_stories.json", "VN stories path should stay stable")
	_expect(GameStateConfigScript.NPC_NAMES_PATH == "res://data/game/npc_names.json", "NPC names path should stay stable")
	_expect(GameStateConfigScript.CHARACTER_ASSETS_PATH == "res://data/game/character_assets.json", "character assets path should stay stable")
	_expect(GameStateConfigScript.COMPANIES_PATH == "res://data/market/companies.json", "companies path should stay stable")
	_expect(GameStateConfigScript.DEFAULT_START_DATE == "2016-07-01", "default start date should stay stable")
	_expect(GameStateConfigScript.FIRST_TUTORIAL_DATE == "2016-07-01", "first tutorial date should stay stable")
	_expect(GameStateConfigScript.PROTAGONIST_CHARACTER_ID == "protagonist", "protagonist character id should stay stable")
	_expect(GameStateConfigScript.DEFAULT_PROTAGONIST_OUTFIT_ID == "casual_default", "default protagonist outfit should stay stable")
	_expect(GameStateConfigScript.DEFAULT_PROTAGONIST_EXPRESSION_ID == "neutral", "default protagonist expression should stay stable")

	_expect(GameStateScript.CALENDAR_PATH == GameStateConfigScript.CALENDAR_PATH, "GameState should expose config-backed calendar path")
	_expect(GameStateScript.DEFAULT_START_DATE == GameStateConfigScript.DEFAULT_START_DATE, "GameState should expose config-backed default start date")
	_expect(GameStateScript.FIRST_TUTORIAL_DATE == GameStateConfigScript.FIRST_TUTORIAL_DATE, "GameState should expose config-backed first tutorial date")
	_expect(GameStateScript.SIMULATION_KEY_SLEEP == "sleep", "GameState simulate-day sleep key should stay stable")
	_expect(GameStateScript.SIMULATION_KEY_NEXT_DAY == "next_day", "GameState simulate-day next-day key should stay stable")
	_expect(ResourceLoader.exists(GameStateConfigScript.DAY_EVENTS_PATH), "day events resource should exist")
	_expect(ResourceLoader.exists(GameStateConfigScript.VN_STORIES_PATH), "VN stories resource should exist")
	_expect(ResourceLoader.exists(GameStateConfigScript.NPC_NAMES_PATH), "NPC names resource should exist")
	_expect(ResourceLoader.exists(GameStateConfigScript.CHARACTER_ASSETS_PATH), "character assets resource should exist")
	_expect(ResourceLoader.exists(GameStateConfigScript.COMPANIES_PATH), "companies resource should exist")

	print("Game state config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
