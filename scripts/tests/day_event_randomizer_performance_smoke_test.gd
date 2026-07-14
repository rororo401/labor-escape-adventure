extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")

const HISTORY_ROWS := 500
const SAMPLE_COUNT := 3
const MAX_AVERAGE_MILLISECONDS := 100.0


func _initialize() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2026-06-29", "randomizer-performance"), "late-game fixture should set up")
	var history := _history_fixture()
	var day: Dictionary = game.calendar.get_day(game.day_index)
	var total_microseconds := 0
	for sample in SAMPLE_COUNT:
		var started := Time.get_ticks_usec()
		game.day_events.build_day_result(
			day,
			game.status.to_dict(),
			3600 + sample,
			"company_work",
			[],
			false,
			history,
			"randomizer-performance",
			"randomizer-performance"
		)
		total_microseconds += Time.get_ticks_usec() - started

	var average_milliseconds := float(total_microseconds) / float(SAMPLE_COUNT) / 1000.0
	_expect(
		average_milliseconds <= MAX_AVERAGE_MILLISECONDS,
		"500-row event history should not restore candidate-by-history scanning: %.3fms" % average_milliseconds
	)
	print("Day event randomizer performance passed: history=%d average=%.3fms" % [HISTORY_ROWS, average_milliseconds])
	finish_test()


func _history_fixture() -> Array:
	var rows: Array = []
	for index in HISTORY_ROWS:
		rows.append({
			DayEventKeysScript.KEY_ID: "old_event_%d" % index,
			DayEventKeysScript.KEY_COMPLETED_DAY: index / 2,
			DayEventKeysScript.KEY_SELECTED: true,
			DayEventKeysScript.KEY_TAGS: ["money"] if index % 4 == 0 else ["routine"],
			DayEventKeysScript.KEY_CG_PATH: "res://events/old_%d.png" % index
		})
	return rows


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
