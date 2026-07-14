extends "res://scripts/tests/test_scene_tree.gd"

const DayEventCatalogScript := preload("res://scripts/core/dayflow/day_event_catalog.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventPlaybackRequestScript := preload("res://scripts/ui/day_event_playback_request.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const GameDayCompletionScript := preload("res://scripts/core/dayflow/game_day_completion.gd")

const EXPECTED_COUNT := 14


func _initialize() -> void:
	var catalog = DayEventCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.DAY_EVENTS_PATH)

	var market_events: Array[Dictionary] = []
	for row in catalog.day_actions:
		var action := Dictionary(row)
		if String(action.get("series_id", "")) == "market_fixed":
			market_events.append(action)

	_expect(market_events.size() == EXPECTED_COUNT, "market fixed event count should match the planned event list")
	for event in market_events:
		_expect(String(event.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_MARKET_FIXED, "market fixed event should use market_fixed mode")
		_expect(String(event.get("playback_mode", "")) == "cg_then_standing", "market fixed event should use CG then standing playback")
		_expect(Array(event.get(DayEventKeysScript.KEY_DIALOGUE, [])).size() >= 5, "market fixed event should include enough dialogue lines")
		_expect(not Array(event.get(DayEventKeysScript.KEY_TAGS, [])).has("cg_pending"), "market fixed event should clear cg_pending after CG import")
		_expect(Array(event.get(DayEventKeysScript.KEY_TAGS, [])).has("no_protagonist_cg"), "market fixed CG should be marked as no-protagonist art")
		_expect(not Dictionary(event.get(DayEventKeysScript.KEY_EFFECTS, {})).is_empty(), "every market fixed event should define an effect payload")
		_expect(String(event.get(DayEventKeysScript.KEY_CG_PATH, "")) == String(event.get("planned_cg_path", "")), "market fixed event should use its planned CG path after image generation")
		_expect(ResourceLoader.exists(String(event.get(DayEventKeysScript.KEY_CG_PATH, ""))), "market fixed event CG should exist")
		var steps := DayEventPlaybackRequestScript.playback_steps(event, "", String(event.get(DayEventKeysScript.KEY_DATE, "")))
		_expect(steps.size() == Array(event.get(DayEventKeysScript.KEY_DIALOGUE, [])).size(), "market fixed playback should create one step per line")
		_expect(not bool(Dictionary(steps[0]).get("character_visible", true)), "first market fixed line should hide the standing character")
		_expect(bool(Dictionary(steps[1]).get("character_visible", false)), "second market fixed line should show the standing character")

	_verify_market_context_side_event()
	_verify_market_event_does_not_consume_workday()
	_verify_market_event_seen_state()

	print("Market fixed event smoke test passed.")
	finish_test()


func _verify_market_context_side_event() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2020-03-13"), "game should set up a fixed market event date")
	var context := game.get_market_context()
	var event := Dictionary(context.get(DayEventKeysScript.KEY_MARKET_FIXED_EVENT, {}))
	_expect(String(event.get(DayEventKeysScript.KEY_ID, "")) == "market_covid_circuit_breaker_2020_03_13", "market context should expose the fixed market news event")
	_expect(bool(context.get(DayEventKeysScript.KEY_IS_OPEN, false)), "fixed market event day should still keep the market open")


func _verify_market_event_does_not_consume_workday() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2020-03-13"), "game should set up a fixed market event date before completion")
	var flow := game.get_day_flow_context()
	_expect(Dictionary(flow.get(DayEventKeysScript.KEY_DEFAULT_ACTION, {})).get(DayEventKeysScript.KEY_ID, "") == DayEventKeysScript.ACTION_COMPANY_WORK, "fixed market event day should still default to company work")
	var result := game.complete_today(DayEventKeysScript.ACTION_COMPANY_WORK, [], true)
	_expect(bool(result.get(DayEventKeysScript.KEY_OK, false)), "fixed market event day should still complete normally")
	var action_event := Dictionary(Dictionary(result.get(DayEventKeysScript.KEY_DAY_ACTION, {})).get(DayEventKeysScript.KEY_EVENT, {}))
	_expect(String(action_event.get(DayEventKeysScript.KEY_ID, "")) != "market_covid_circuit_breaker_2020_03_13", "fixed market event should not be recorded as the completed day action")
	_expect(String(action_event.get(DayEventKeysScript.KEY_GROUP, "")) == DayEventKeysScript.GROUP_COMPANY_WORK, "fixed market event day should still complete company work")
	var market_effect_row := Dictionary(result.get(DayEventKeysScript.KEY_MARKET_FIXED_EFFECT, {}))
	var market_event := Dictionary(market_effect_row.get(DayEventKeysScript.KEY_EVENT, {}))
	var market_delta := Dictionary(Dictionary(market_effect_row.get(DayEventKeysScript.KEY_EFFECT, {})).get("delta", {}))
	var event_id := "market_covid_circuit_breaker_2020_03_13"
	_expect(String(market_event.get(DayEventKeysScript.KEY_ID, "")) == event_id, "fixed market event effect should be reported separately from the day action")
	_expect(int(market_delta.get("mood", 0)) < 0, "fixed crash news should apply its negative mood effect")
	_expect(int(market_delta.get("fatigue", 0)) > 0, "fixed crash news should apply its fatigue effect")
	_expect(game.has_applied_market_fixed_event(event_id), "fixed market effect should be marked applied")
	_expect(_history_has(game.event_history, event_id), "applied fixed market event should be recorded in history")

	var status_after_first_apply := game.status.to_dict()
	var duplicate_effect := GameDayCompletionScript._apply_market_fixed_event_once(game, game.calendar.get_day(game.day_index))
	_expect(duplicate_effect.is_empty(), "fixed market effect should not apply twice")
	_expect(game.status.to_dict() == status_after_first_apply, "duplicate fixed market application should not mutate status")

	var loaded := GameStateScript.new()
	var load_result := loaded.load_from_save_dict(game.to_save_dict())
	_expect(bool(load_result.get(DayEventKeysScript.KEY_OK, false)), "completed fixed-event day should load from save")
	var loaded_status := loaded.status.to_dict()
	var reentry_effect := GameDayCompletionScript._apply_market_fixed_event_once(
		loaded, loaded.calendar.get_day(loaded.day_index)
	)
	_expect(reentry_effect.is_empty(), "fixed market effect should remain applied after save/load re-entry")
	_expect(loaded.status.to_dict() == loaded_status, "save/load re-entry must not duplicate the fixed market effect")


func _verify_market_event_seen_state() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2020-03-13"), "game should set up a fixed market event date for seen-state test")
	var event_id := "market_covid_circuit_breaker_2020_03_13"
	_expect(not game.has_seen_market_fixed_event(event_id), "market fixed event should start unseen")
	game.mark_market_fixed_event_seen(event_id)
	_expect(game.has_seen_market_fixed_event(event_id), "market fixed event should be marked seen")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _history_has(history: Array, event_id: String) -> bool:
	for row in history:
		if String(Dictionary(row).get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false
