extends "res://scripts/tests/test_scene_tree.gd"

const MorningBriefingLayerConfigScript := preload("res://scripts/ui/morning_briefing_layer_config.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")


func _initialize() -> void:
	_expect(MorningBriefingLayerConfigScript.BACKGROUND_PATH == UiBackgroundPathsScript.HOME_MORNING_BRIEFING, "morning briefing background path should use the shared background path")
	_expect(MorningBriefingLayerConfigScript.VN_STORIES_PATH == GameStateConfigScript.VN_STORIES_PATH, "VN stories path should use the shared game-state config")
	_expect(MorningBriefingLayerConfigScript.STORY_ID == "morning_briefing", "morning briefing story id should stay stable")
	_expect(MorningBriefingLayerConfigScript.TRADING_DAY_STORY_ID == "morning_briefing", "trading-day morning story id should stay stable")
	_expect(MorningBriefingLayerConfigScript.CLOSED_DAY_STORY_ID == "morning_briefing_closed", "closed-day morning story id should stay stable")
	_expect(MorningBriefingLayerConfigScript.BACKGROUND_NAME == "MorningBackground", "background node name should stay stable")
	_expect(not MorningBriefingLayerConfigScript.SHOW_TOP_BUTTONS, "morning briefing should hide top buttons")
	_expect(MorningBriefingLayerConfigScript.CHARACTER_NAME == "MorningProtagonistBust", "character node name should stay stable")
	_expect(MorningBriefingLayerConfigScript.DEFAULT_OUTFIT == "homewear", "default outfit should stay stable")
	_expect(MorningBriefingLayerConfigScript.DEFAULT_EXPRESSION == GameStateConfigScript.DEFAULT_PROTAGONIST_EXPRESSION_ID, "default expression should use the shared protagonist default")
	_expect(MorningBriefingLayerConfigScript.MONTHLY_SALARY_EVENT_ID_PREFIX == "monthly_salary", "monthly salary prefix should stay stable")
	_expect(MorningBriefingLayerConfigScript.LOW_HEALTH_THRESHOLD == 30, "low health threshold should stay stable")
	_expect(MorningBriefingLayerConfigScript.HIGH_FATIGUE_THRESHOLD == 90, "high fatigue threshold should stay stable")
	_expect(MorningBriefingLayerConfigScript.FADE_OUT_DURATION == 0.16, "fade-out duration should stay stable")

	print("Morning briefing layer config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
