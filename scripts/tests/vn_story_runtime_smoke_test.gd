extends "res://scripts/tests/test_scene_tree.gd"

const VnStoryRuntimeScript := preload("res://scripts/core/vn_story_runtime.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	var runtime = VnStoryRuntimeScript.new()
	runtime.load(GameStateConfigScript.VN_STORIES_PATH, GameStateConfigScript.NPC_NAMES_PATH)

	_expect(not runtime.player_name().is_empty(), "runtime should load a player name")
	_expect(runtime.speaker_name({}) == runtime.player_name(), "empty story speaker should fall back to player name")
	_expect(runtime.speaker_name({VnStoryKeysScript.KEY_SPEAKER: "AA부장"}) == "AA부장", "explicit story speaker should be preserved")

	var substitutions := runtime.npc_substitutions({
		"box_trading_manager": "기본 부장"
	})
	_expect(String(substitutions.get("box_trading_manager", "")) != "기본 부장", "known NPC id should use catalog display name")

	var first_day := runtime.get_steps("first_day_work", substitutions)
	_expect(_contains_text(first_day, String(substitutions.get("box_trading_manager", ""))), "runtime should apply NPC substitutions to story steps")
	_expect(not _contains_text(first_day, "{box_trading_manager}"), "runtime should not leave raw NPC tokens")

	var default_mode := runtime.get_default_visual_mode("first_day_work")
	_expect(default_mode == "office", "runtime should expose default visual mode")
	var office_visual := runtime.get_visual_mode("first_day_work", default_mode)
	var fallback_visual := runtime.get_visual_mode("first_day_work", "missing_mode")
	_expect(fallback_visual == office_visual, "runtime should forward visual fallback behavior")

	print("VN story runtime smoke test passed.")
	finish_test()


func _contains_text(steps: Array[Dictionary], needle: String) -> bool:
	for step in steps:
		for key in step.keys():
			if typeof(step[key]) == TYPE_STRING and String(step[key]).contains(needle):
				return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
