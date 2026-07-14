extends "res://scripts/tests/test_scene_tree.gd"

const FirstDayWorkSceneConfigScript := preload("res://scripts/ui/first_day_work_scene_config.gd")
const DayCompletionResultScript := preload("res://scripts/core/dayflow/day_completion_result.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")


func _initialize() -> void:
	_expect(FirstDayWorkSceneConfigScript.NPC_NAMES_PATH == GameStateConfigScript.NPC_NAMES_PATH, "NPC name path should use the shared game-state config")
	_expect(FirstDayWorkSceneConfigScript.VN_STORIES_PATH == GameStateConfigScript.VN_STORIES_PATH, "VN story path should use the shared game-state config")
	_expect(FirstDayWorkSceneConfigScript.MARKET_SCENE_PATH == UiScenePathsScript.MARKET_SCREEN, "market scene path should use the shared scene path")
	_expect(FirstDayWorkSceneConfigScript.STORY_ID == "first_day_work", "story id should stay stable")
	_expect(FirstDayWorkSceneConfigScript.NPC_BOX_TRADING_MANAGER == "box_trading_manager", "manager NPC key should stay stable")
	_expect(FirstDayWorkSceneConfigScript.FALLBACK_BOX_TRADING_MANAGER_NAME == "강민석 부장", "fallback manager name should stay stable")
	_expect(FirstDayWorkSceneConfigScript.DAY_ACTION_ID == "company_work", "day action id should stay stable")
	_expect(FirstDayWorkSceneConfigScript.DIALOGUE_NAME_WIDTH == 190.0, "dialogue name width should stay stable")
	_expect(
		FirstDayWorkSceneConfigScript.flow_error_message(DayCompletionResultScript.ERROR_FIRST_DAY_STOCK_REQUIRED) == MarketDayFlowTextScript.flow_error_message(DayCompletionResultScript.ERROR_FIRST_DAY_STOCK_REQUIRED),
		"first-day stock-required error copy should delegate to market day-flow text"
	)
	_expect(
		FirstDayWorkSceneConfigScript.flow_error_message("missing") == MarketDayFlowTextScript.flow_error_message("missing"),
		"unknown flow errors should delegate to market day-flow text"
	)

	print("First-day work scene config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
