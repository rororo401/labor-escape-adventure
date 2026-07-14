extends "res://scripts/tests/test_scene_tree.gd"

const PrologueSceneConfigScript := preload("res://scripts/ui/prologue_scene_config.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")


func _initialize() -> void:
	_expect(PrologueSceneConfigScript.BACKGROUND_PATH == UiBackgroundPathsScript.HOME_PROLOGUE_LIVING_ROOM, "prologue background path should use the shared background path")
	_expect(PrologueSceneConfigScript.MARKET_SCENE_PATH == UiScenePathsScript.MARKET_SCREEN, "market scene path should use the shared scene path")
	_expect(PrologueSceneConfigScript.VN_STORIES_PATH == GameStateConfigScript.VN_STORIES_PATH, "VN stories path should use the shared game-state config")
	_expect(PrologueSceneConfigScript.STORY_ID == "prologue", "prologue story id should stay stable")
	_expect(PrologueSceneConfigScript.PROLOGUE_DATE == "2016-06-30", "prologue date should stay stable")
	_expect(PrologueSceneConfigScript.FIRST_MARKET_DATE == "2016-07-01", "first market date should stay stable")
	_expect(PrologueSceneConfigScript.FIRST_MARKET_WEEKDAY == "Friday", "first market weekday should stay stable")
	_expect(PrologueSceneConfigScript.BACKGROUND_NAME == "LivingRoomBackground", "background node name should stay stable")
	_expect(PrologueSceneConfigScript.SLEEP_SEQUENCE_NAME == "PrologueSleepSequence", "sleep sequence node name should stay stable")
	_expect(PrologueSceneConfigScript.DATE_TEXT.contains("프롤로그"), "date text should keep the prologue label")
	_expect(PrologueSceneConfigScript.CHARACTER_NAME == "ProtagonistHomewearBust", "character node name should stay stable")
	_expect(PrologueSceneConfigScript.HOMEWEAR_OUTFIT == "homewear", "prologue outfit should stay stable")
	_expect(PrologueSceneConfigScript.DEFAULT_EXPRESSION == GameStateConfigScript.DEFAULT_PROTAGONIST_EXPRESSION_ID, "default expression should use the shared protagonist default")
	_expect(PrologueSceneConfigScript.CHARACTERS_PER_SECOND == 76.0, "prologue typewriter speed should stay stable")
	_expect(PrologueSceneConfigScript.HUD_DATE_WIDTH == 200.0, "HUD date width should stay stable")
	_expect(PrologueSceneConfigScript.DIALOGUE_POSITION == Vector2(42, 84), "dialogue position should use the wider dialogue frame")
	_expect(PrologueSceneConfigScript.DIALOGUE_SIZE == Vector2(632, 124), "dialogue size should use the wider dialogue frame")
	_expect(PrologueSceneConfigScript.DIALOGUE_FONT_SIZE == 26, "dialogue font size should stay stable")

	print("Prologue scene config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
