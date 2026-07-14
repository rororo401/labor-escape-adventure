extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const HealthResurrectionEventScript := preload("res://scripts/core/dayflow/health_resurrection_event.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")


func _initialize() -> void:
	_verify_event_payloads()
	_verify_health_zero_resurrects_once()
	print("Health resurrection event smoke test passed.")
	finish_test()


func _verify_event_payloads() -> void:
	var ghost := HealthResurrectionEventScript.ghost_event("2016-12-01")
	var goddess := HealthResurrectionEventScript.goddess_event("2016-12-01")
	var summer_ghost := HealthResurrectionEventScript.ghost_event("2016-07-01")
	var summer_goddess := HealthResurrectionEventScript.goddess_event("2016-07-01")
	_expect(String(ghost.get(DayEventKeysScript.KEY_ID, "")) == HealthResurrectionEventScript.GHOST_EVENT_ID, "ghost event id should stay stable")
	_expect(String(goddess.get(DayEventKeysScript.KEY_ID, "")) == HealthResurrectionEventScript.GODDESS_EVENT_ID, "goddess event id should stay stable")
	_expect(ResourceLoader.exists(String(ghost.get(DayEventKeysScript.KEY_CG_PATH, ""))), "ghost CG should exist")
	_expect(ResourceLoader.exists(String(goddess.get(DayEventKeysScript.KEY_CG_PATH, ""))), "goddess CG should exist")
	_expect(ResourceLoader.exists(String(summer_ghost.get(DayEventKeysScript.KEY_CG_PATH, ""))), "summer ghost CG should exist")
	_expect(ResourceLoader.exists(String(summer_goddess.get(DayEventKeysScript.KEY_CG_PATH, ""))), "summer goddess CG should exist")
	_expect(
		String(ghost.get(DayEventKeysScript.KEY_CG_PATH, "")) == HealthResurrectionEventScript.GHOST_CG_PATH_WINTER,
		"winter ghost event should use winter CG"
	)
	_expect(
		String(goddess.get(DayEventKeysScript.KEY_CG_PATH, "")) == HealthResurrectionEventScript.GODDESS_CG_PATH_WINTER,
		"winter goddess event should use winter CG"
	)
	_expect(
		String(summer_ghost.get(DayEventKeysScript.KEY_CG_PATH, "")) == HealthResurrectionEventScript.GHOST_CG_PATH_SUMMER,
		"summer ghost event should use summer CG"
	)
	_expect(
		String(summer_goddess.get(DayEventKeysScript.KEY_CG_PATH, "")) == HealthResurrectionEventScript.GODDESS_CG_PATH_SUMMER,
		"summer goddess event should use summer CG"
	)
	_expect(
		int(Dictionary(goddess.get(DayEventKeysScript.KEY_EFFECTS, {})).get(PlayerStatusKeysScript.KEY_HEALTH_DELTA, 0)) == HealthResurrectionEventScript.revive_health_target(),
		"goddess event should restore health to the 50 percent target from zero"
	)
	_expect(Array(ghost.get(DayEventKeysScript.KEY_DIALOGUE, [])).size() >= 3, "ghost event should include dialogue")
	_expect(Array(goddess.get(DayEventKeysScript.KEY_DIALOGUE, [])).size() >= 4, "goddess event should include dialogue")


func _verify_health_zero_resurrects_once() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-25"), "game should set up after tutorial day")
	game.status.health = 1
	var first_result := game.complete_today(DayEventKeysScript.ACTION_COMPANY_WORK, [], true)
	_expect(first_result.get(DayEventKeysScript.KEY_OK, false), "first health-zero completion should return ok")
	_expect(not bool(first_result.get(PlayerStatusKeysScript.KEY_GAME_OVER, true)), "first health-zero completion should be rescued")
	_expect(bool(game.health_resurrection_used), "resurrection flag should be used")
	_expect(game.status.health == HealthResurrectionEventScript.revive_health_target(), "resurrection should restore health to 50 percent")
	_expect(_has_event(first_result.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []), HealthResurrectionEventScript.GHOST_EVENT_ID), "resurrection should include ghost event")
	_expect(_has_event(first_result.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []), HealthResurrectionEventScript.GODDESS_EVENT_ID), "resurrection should include goddess event")
	_expect(_history_has(game.event_history, HealthResurrectionEventScript.GHOST_EVENT_ID), "ghost event should be recorded")
	_expect(_history_has(game.event_history, HealthResurrectionEventScript.GODDESS_EVENT_ID), "goddess event should be recorded")

	_expect(game.sleep_to_next_day().get(DayEventKeysScript.KEY_OK, false), "game should sleep after rescued day")
	game.status.health = 1
	var second_result := game.complete_today(DayEventKeysScript.ACTION_COMPANY_WORK, [], true)
	_expect(second_result.get(DayEventKeysScript.KEY_OK, false), "second health-zero completion should still complete")
	_expect(bool(second_result.get(PlayerStatusKeysScript.KEY_GAME_OVER, false)), "second health-zero completion should become game over")
	_expect(String(second_result.get(PlayerStatusKeysScript.KEY_GAME_OVER_REASON, "")) == PlayerStatusKeysScript.GAME_OVER_REASON_HEALTH_ZERO, "second game over should be health zero")
	_expect(not _has_event(second_result.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []), HealthResurrectionEventScript.GODDESS_EVENT_ID), "second health-zero should not replay goddess event")


func _has_event(rows: Array, event_id: String) -> bool:
	for row in rows:
		var event := Dictionary(Dictionary(row).get(DayEventKeysScript.KEY_EVENT, {}))
		if String(event.get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false


func _history_has(history: Array, event_id: String) -> bool:
	for row in history:
		if String(Dictionary(row).get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
