extends "res://scripts/tests/test_scene_tree.gd"

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventRecencyIndexScript := preload("res://scripts/core/dayflow/day_event_recency_index.gd")


func _initialize() -> void:
	var history := [
		_event("event_01", "res://events/shared.png", ["money"], 3),
		_event("event_02", "res://events/shared.png", ["health"], 8),
		_event("event_03", "res://events/other.png", ["money"], 6),
		_event("ignored", "res://events/ignored.png", ["stress"], 9, false),
		_event("future_01", "res://events/future.png", ["mood"], 12)
	]
	var index := DayEventRecencyIndexScript.build(history, 10)

	_expect(DayEventRecencyIndexScript.last_event_day(index, "event_01") == 3, "event id should keep its own latest day")
	_expect(DayEventRecencyIndexScript.last_cg_day(index, "res://events/shared.png") == 8, "CG index should keep the latest matching day")
	_expect(DayEventRecencyIndexScript.last_family_day(index, "event") == 8, "numeric suffix family should keep the latest variant day")
	_expect(DayEventRecencyIndexScript.last_tag_day(index, "money") == 6, "tag index should keep the latest matching day")
	_expect(DayEventRecencyIndexScript.last_event_day(index, "ignored") < 0, "unselected history should not enter the index")
	_expect(DayEventRecencyIndexScript.last_event_day(index, "future_01") < 0, "future history should not shadow valid past rows")
	_expect(DayEventRecencyIndexScript.numeric_suffix_family("company_handoff_08") == "company_handoff", "underscore numeric suffix should resolve its family")
	_expect(DayEventRecencyIndexScript.numeric_suffix_family("company-handoff-08") == "company-handoff", "dash numeric suffix should resolve its family")
	_expect(DayEventRecencyIndexScript.numeric_suffix_family("company_handoff") == "", "non-numeric ids should not create a family")

	print("Day event recency index smoke test passed.")
	finish_test()


func _event(event_id: String, cg_path: String, tags: Array, completed_day: int, selected: bool = true) -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: event_id,
		DayEventKeysScript.KEY_CG_PATH: cg_path,
		DayEventKeysScript.KEY_TAGS: tags,
		DayEventKeysScript.KEY_COMPLETED_DAY: completed_day,
		DayEventKeysScript.KEY_SELECTED: selected
	}


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
