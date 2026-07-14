extends "res://scripts/tests/test_scene_tree.gd"

const DayEventPlaybackRequestScript := preload("res://scripts/ui/day_event_playback_request.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const TestAssetPathsScript := preload("res://scripts/tests/test_asset_paths.gd")

const DEFAULT_BACKGROUND_PATH := TestAssetPathsScript.HOME_PROLOGUE_BACKGROUND
const EVENT_BACKGROUND_PATH := TestAssetPathsScript.HOME_MORNING_BACKGROUND
const EVENT_BASE_CG_PATH := "res://assets/events/company_work/phase5/company_communication_01.png"
const EVENT_SUMMER_CG_PATH := "res://assets/events_summer/company_work/phase5/company_communication_01.png"
const SLEEP_EVENT_CG_PATH := "res://assets/backgrounds/home/sleeping_night_event.png"
const SLEEP_EVENT_SUMMER_CG_PATH := "res://assets/backgrounds/home/sleeping_night_event_summer.png"


func _initialize() -> void:
	var event := {
		DayEventKeysScript.KEY_NAME_KO: "테스트 이벤트",
		DayEventKeysScript.KEY_CG_PATH: EVENT_BACKGROUND_PATH,
		DayEventKeysScript.KEY_DIALOGUE: ["첫 줄", "", "둘째 줄"],
		DayEventKeysScript.KEY_SUMMARY_KO: "요약"
	}

	_expect(DayEventPlaybackRequestScript.background_path(event, DEFAULT_BACKGROUND_PATH) == EVENT_BACKGROUND_PATH, "event background should prefer cg_path")
	_expect(DayEventPlaybackRequestScript.speaker_name(event) == "테스트 이벤트", "event speaker should use name_ko")
	_expect(DayEventPlaybackRequestScript.dialogue_lines(event) == ["첫 줄", "둘째 줄"], "dialogue lines should keep non-empty explicit lines")
	_expect(FileAccess.file_exists(EVENT_SUMMER_CG_PATH), "summer event CG fixture should exist")

	var fallback_event := {
		DayEventKeysScript.KEY_NAME_KO: "요약 이벤트",
		DayEventKeysScript.KEY_SUMMARY_KO: "요약만 있는 이벤트"
	}
	_expect(DayEventPlaybackRequestScript.background_path(fallback_event, DEFAULT_BACKGROUND_PATH) == DEFAULT_BACKGROUND_PATH, "event background should use fallback path when cg_path is missing")
	_expect(DayEventPlaybackRequestScript.dialogue_lines(fallback_event) == ["요약만 있는 이벤트"], "summary should be used as fallback dialogue")

	var empty_event := {
		DayEventKeysScript.KEY_DIALOGUE: ["", ""],
		DayEventKeysScript.KEY_SUMMARY_KO: ""
	}
	_expect(DayEventPlaybackRequestScript.speaker_name(empty_event) == "", "missing event speaker should fall back to blank")
	_expect(DayEventPlaybackRequestScript.dialogue_lines(empty_event).is_empty(), "empty dialogue and summary should produce no playback lines")

	var seasonal_event := {
		DayEventKeysScript.KEY_CG_PATH: EVENT_BASE_CG_PATH
	}
	_expect(
		DayEventPlaybackRequestScript.background_path(seasonal_event, DEFAULT_BACKGROUND_PATH, "2016-07-01") == EVENT_SUMMER_CG_PATH,
		"summer date should prefer matching events_summer CG"
	)
	_expect(
		DayEventPlaybackRequestScript.background_path(seasonal_event, DEFAULT_BACKGROUND_PATH, "2016-12-01") == EVENT_BASE_CG_PATH,
		"winter date should keep base event CG"
	)
	_expect(
		DayEventPlaybackRequestScript.background_path({DayEventKeysScript.KEY_CG_PATH: EVENT_BACKGROUND_PATH}, DEFAULT_BACKGROUND_PATH, "2016-07-01") == EVENT_BACKGROUND_PATH,
		"non-event CG path should not be seasonally rewritten"
	)
	_expect(
		DayEventPlaybackRequestScript.background_path({DayEventKeysScript.KEY_CG_PATH: SLEEP_EVENT_CG_PATH}, DEFAULT_BACKGROUND_PATH, "2016-07-01") == SLEEP_EVENT_SUMMER_CG_PATH,
		"summer date should use summer sleep event CG"
	)

	print("Day event playback request smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
