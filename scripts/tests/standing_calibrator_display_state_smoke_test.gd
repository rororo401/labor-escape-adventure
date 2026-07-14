extends "res://scripts/tests/test_scene_tree.gd"

const StandingCalibratorDisplayStateScript := preload("res://scripts/dev/standing_calibrator_display_state.gd")


func _initialize() -> void:
	_expect(StandingCalibratorDisplayStateScript.selected_index(-4, 3) == 0, "selected index should clamp low")
	_expect(StandingCalibratorDisplayStateScript.selected_index(9, 3) == 2, "selected index should clamp high")
	_expect(StandingCalibratorDisplayStateScript.selected_index(2, 0) == 0, "selected index should handle empty entries")

	_expect(StandingCalibratorDisplayStateScript.relative_index(0, -1, 4) == 3, "relative index should wrap backward")
	_expect(StandingCalibratorDisplayStateScript.relative_index(3, 1, 4) == 0, "relative index should wrap forward")
	_expect(StandingCalibratorDisplayStateScript.relative_index(2, 1, 0) == 0, "relative index should handle empty entries")

	var entry := {
		"label": "홈웨어 기본",
		"outfit": "homewear",
		"expression": "neutral"
	}
	_expect(
		StandingCalibratorDisplayStateScript.entry_label(0, 8, entry) == "01/08  홈웨어 기본  homewear/neutral",
		"entry label should format one-based index and identifiers"
	)
	_expect(
		StandingCalibratorDisplayStateScript.offset_label(Vector2(-3.2, 4.9)) == "x -3  y 4",
		"offset label should format integer pixel offsets"
	)
	_expect(
		StandingCalibratorDisplayStateScript.reset_message().contains("0, 0"),
		"reset message should describe zero offset"
	)
	_expect(
		StandingCalibratorDisplayStateScript.save_message("homewear:neutral", "user://a.json", "res://b.json") == "homewear:neutral 저장 완료: user://a.json / res://b.json",
		"save message should include key and both paths"
	)
	_expect(
		StandingCalibratorDisplayStateScript.INITIAL_HELP_TEXT.contains("숫자 1-9"),
		"initial help text should include number-key selection"
	)
	_expect(
		not StandingCalibratorDisplayStateScript.SELECTED_HELP_TEXT.contains("숫자 1-9"),
		"selected help text should stay compact after selection"
	)

	print("Standing calibrator display state smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
