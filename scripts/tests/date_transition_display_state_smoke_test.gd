extends "res://scripts/tests/test_scene_tree.gd"

const DateTransitionDisplayStateScript := preload("res://scripts/ui/date_transition_display_state.gd")
const DateTransitionDisplayStateConfigScript := preload("res://scripts/ui/date_transition_display_state_config.gd")


func _initialize() -> void:
	var closing := DateTransitionDisplayStateScript.closing_state("2016-07-01")
	_expect(String(closing.get(DateTransitionDisplayStateConfigScript.KEY_DATE_TEXT, "")) == "2016.07.01", "closing state should format the previous date")
	_expect(String(closing.get(DateTransitionDisplayStateConfigScript.KEY_WEEKDAY_TEXT, "")) == DateTransitionDisplayStateConfigScript.CLOSING_TEXT, "closing state should show closing copy")
	_expect(String(closing.get(DateTransitionDisplayStateConfigScript.KEY_STAMP_TEXT, "bad")) == DateTransitionDisplayStateConfigScript.EMPTY_TEXT, "closing state should hide stamp")

	var morning := DateTransitionDisplayStateScript.morning_state("2016-07-02", "Saturday")
	_expect(String(morning.get(DateTransitionDisplayStateConfigScript.KEY_DATE_TEXT, "")) == "2016.07.02", "morning state should format the new date")
	_expect(String(morning.get(DateTransitionDisplayStateConfigScript.KEY_WEEKDAY_TEXT, "")) == "토요일 아침", "morning state should show Korean weekday morning")
	_expect(String(morning.get(DateTransitionDisplayStateConfigScript.KEY_STAMP_TEXT, "")) == DateTransitionDisplayStateConfigScript.MORNING_STAMP_TEXT, "morning state should show stamp copy")

	var malformed := DateTransitionDisplayStateScript.closing_state("D-1")
	_expect(String(malformed.get(DateTransitionDisplayStateConfigScript.KEY_DATE_TEXT, "")) == "D-1", "malformed dates should be passed through by formatter")

	print("Date transition display state smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
