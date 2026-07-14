extends "res://scripts/tests/test_scene_tree.gd"

const DayEventCatalogScript := preload("res://scripts/core/dayflow/day_event_catalog.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameCalendarScript := preload("res://scripts/core/game_calendar.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")

const RUN_COUNT := 200
const DAYS_PER_RUN := 14


func _initialize() -> void:
	var catalog = DayEventCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.DAY_EVENTS_PATH)
	var calendar = GameCalendarScript.new()
	calendar.load_from_csv(GameStateConfigScript.CALENDAR_PATH)
	var status := {"cash": 5000000, "health": 100, "mood": 50, "fatigue": 0}
	var signatures := {}
	var repeat_runs := 0

	for run_index in RUN_COUNT:
		var history: Array = []
		var signature_parts: Array[String] = []
		var seen_random_ids := {}
		var repeated := false
		var run_seed := "short-horizon-%d" % run_index
		for day_offset in DAYS_PER_RUN:
			var day: Dictionary = calendar.get_day(day_offset)
			var plan: Dictionary = catalog.build_day_result(
				day,
				status,
				day_offset,
				"",
				[],
				false,
				history,
				run_seed,
				run_seed
			)
			var event_ids := _plan_event_ids(plan)
			for event_id in _random_event_ids(plan):
				if seen_random_ids.has(event_id):
					repeated = true
				seen_random_ids[event_id] = true
			signature_parts.append("+".join(event_ids))
			_append_plan_history(history, plan, day_offset)
		var signature := "|".join(signature_parts)
		signatures[signature] = int(signatures.get(signature, 0)) + 1
		if repeated:
			repeat_runs += 1

	_expect(signatures.size() >= 190, "short runs should remain strongly differentiated across run seeds")
	_expect(repeat_runs == 0, "random event ids should not repeat inside the first fourteen days")
	print("Short-horizon diversity passed: runs=%d unique=%d repeat_runs=%d" % [RUN_COUNT, signatures.size(), repeat_runs])
	finish_test()


func _plan_event_ids(plan: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	var day_action := Dictionary(plan.get(DayEventKeysScript.KEY_DAY_ACTION, {}))
	var day_action_id := String(day_action.get(DayEventKeysScript.KEY_ID, ""))
	if not day_action_id.is_empty():
		ids.append(day_action_id)
	ids.append_array(_random_event_ids(plan))
	return ids


func _random_event_ids(plan: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for key in [DayEventKeysScript.KEY_WEEKDAY_EVENTS, DayEventKeysScript.KEY_NIGHT_EVENTS]:
		for event in plan.get(key, []):
			var event_id := String(Dictionary(event).get(DayEventKeysScript.KEY_ID, ""))
			if not event_id.is_empty():
				ids.append(event_id)
	return ids


func _append_plan_history(history: Array, plan: Dictionary, completed_day: int) -> void:
	var events: Array = [plan.get(DayEventKeysScript.KEY_DAY_ACTION, {})]
	events.append_array(plan.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []))
	events.append_array(plan.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []))
	for event in events:
		var event_row := Dictionary(event)
		var event_id := String(event_row.get(DayEventKeysScript.KEY_ID, ""))
		if event_id.is_empty():
			continue
		history.append({
			DayEventKeysScript.KEY_ID: event_id,
			DayEventKeysScript.KEY_TAGS: event_row.get(DayEventKeysScript.KEY_TAGS, []).duplicate(true),
			DayEventKeysScript.KEY_CG_PATH: String(event_row.get(DayEventKeysScript.KEY_CG_PATH, "")),
			DayEventKeysScript.KEY_COMPLETED_DAY: completed_day,
			DayEventKeysScript.KEY_SELECTED: true
		})


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
