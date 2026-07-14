extends "res://scripts/tests/test_scene_tree.gd"

const StandingBustLayoutConfigScript := preload("res://scripts/core/standing_bust_layout_config.gd")
const StandingBustLayoutScript := preload("res://scripts/core/standing_bust_layout.gd")


func _initialize() -> void:
	_expect(StandingBustLayoutConfigScript.DEFAULT_OVERRIDE_PATH == "res://data/game/standing_position_overrides.generated.json", "generated override path should stay stable")
	_expect(StandingBustLayoutConfigScript.USER_OVERRIDE_PATH == "user://standing_position_overrides.json", "user override path should stay stable")
	_expect(StandingBustLayoutConfigScript.BUST_SIZE == Vector2(808, 900), "bust size should stay stable")
	_expect(StandingBustLayoutConfigScript.BUST_SOURCE_HEIGHT == 430, "bust source height should stay stable")
	_expect(StandingBustLayoutConfigScript.BUST_BASE_Y == 205.0, "bust base y should stay stable")

	_expect(StandingBustLayoutScript.DEFAULT_OVERRIDE_PATH == StandingBustLayoutConfigScript.DEFAULT_OVERRIDE_PATH, "layout should expose config-backed generated override path")
	_expect(StandingBustLayoutScript.USER_OVERRIDE_PATH == StandingBustLayoutConfigScript.USER_OVERRIDE_PATH, "layout should expose config-backed user override path")
	_expect(StandingBustLayoutScript.BUST_SIZE == StandingBustLayoutConfigScript.BUST_SIZE, "layout should expose config-backed bust size")
	_expect(StandingBustLayoutScript.BUST_SOURCE_HEIGHT == StandingBustLayoutConfigScript.BUST_SOURCE_HEIGHT, "layout should expose config-backed bust source height")
	_expect(StandingBustLayoutScript.BUST_BASE_Y == StandingBustLayoutConfigScript.BUST_BASE_Y, "layout should expose config-backed bust base y")

	print("Standing bust layout config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
