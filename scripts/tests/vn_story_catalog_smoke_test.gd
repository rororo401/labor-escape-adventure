extends "res://scripts/tests/test_scene_tree.gd"

const VnStoryCatalogScript := preload("res://scripts/core/vn_story_catalog.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	var catalog = VnStoryCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.VN_STORIES_PATH)

	_expect(catalog.has_story("prologue"), "catalog should load the prologue story")
	_expect(catalog.has_story("morning_briefing"), "catalog should load the morning briefing story")
	_expect(catalog.has_story("morning_briefing_closed"), "catalog should load the closed-day morning briefing story")
	_expect(catalog.has_story("first_day_work"), "catalog should load the first-day work story")
	_expect(catalog.get_default_visual_mode("first_day_work") == "office", "first-day story should expose its default visual mode")

	var prologue := catalog.get_steps("prologue")
	_expect(prologue.size() >= 8, "prologue should keep its full opening sequence")
	_expect(String(prologue[0].get(VnStoryKeysScript.KEY_EXPRESSION, "")) == "tired", "prologue should preserve expressions")
	_expect(String(prologue[0].get(VnStoryKeysScript.KEY_TEXT, "")).contains("D-1"), "prologue should preserve text")

	var closed_morning := catalog.get_steps("morning_briefing_closed")
	_expect(closed_morning.size() >= 2, "closed-day morning briefing should keep its short sequence")
	_expect(_contains_text(closed_morning, "장이 쉬는 날"), "closed-day morning briefing should acknowledge market closure")
	_expect(not _contains_text(closed_morning, "계좌는 어제보다"), "closed-day morning briefing should avoid trading-day account copy")

	var first_day := catalog.get_steps("first_day_work", {
		"box_trading_manager": "테스트 부장"
	})
	_expect(first_day.size() >= 9, "first-day story should keep all tutorial beats")
	_expect(_contains_text(first_day, "테스트 부장"), "story substitutions should replace NPC placeholders")
	_expect(not _contains_text(first_day, "{box_trading_manager}"), "story substitutions should not leave raw tokens")

	var first_day_again := catalog.get_steps("first_day_work", {
		"box_trading_manager": "다른 부장"
	})
	_expect(_contains_text(first_day_again, "다른 부장"), "story steps should be copied per request")
	_expect(not _contains_text(first_day, "다른 부장"), "substitution should not mutate cached raw story data")

	var office_visual := catalog.get_visual_mode("first_day_work", "office")
	_expect(String(office_visual.get(VnStoryKeysScript.KEY_BACKGROUND_PATH, "")).ends_with("startup_office_morning.png"), "office visual should define an office background")
	_expect(String(office_visual.get(VnStoryKeysScript.KEY_DATE_TEXT, "")).contains("첫 출근"), "office visual should define HUD text")
	_expect(bool(office_visual.get(VnStoryKeysScript.KEY_CHARACTER_VISIBLE, false)), "office visual should show the standing character")

	var event_visual := catalog.get_visual_mode("first_day_work", "event")
	_expect(String(event_visual.get(VnStoryKeysScript.KEY_BACKGROUND_PATH, "")).ends_with("office_phone_call_event.png"), "event visual should define event CG background")
	_expect(not bool(event_visual.get(VnStoryKeysScript.KEY_CHARACTER_VISIBLE, true)), "event visual should hide the standing character")

	var fallback_visual := catalog.get_visual_mode("first_day_work", "missing_mode")
	_expect(fallback_visual == office_visual, "unknown visual mode should fall back to the default visual mode")

	print("VN story catalog smoke test passed.")
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
