extends "res://scripts/tests/test_scene_tree.gd"

const GameEndingScript := preload("res://scripts/core/game_ending.gd")
const GameProgressStoreScript := preload("res://scripts/core/save/game_progress_store.gd")
const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")

const START_DATE := "2016-07-01"
const FINAL_DATE := "2026-06-30"
const EXPECTED_PLAYABLE_DAY_COUNT := 3652
const EXPECTED_ANNUAL_EVENT_COUNT := 100
const EXPECTED_SAVE_ROUNDTRIP_COUNT := 10
const TUTORIAL_TICKER := "005930"
const TEST_SEED := "ten_year_sequential_completion"
const TEST_SAVE_PATH := "user://ten_year_sequential_completion.test.json"


func _initialize() -> void:
	_remove_test_save_files()
	var started_usec := Time.get_ticks_usec()
	var game = GameStateScript.new()
	if not _require(game.setup(START_DATE, TEST_SEED), "10-year game should start on %s" % START_DATE):
		return
	if not _require(game.calendar.count() == EXPECTED_PLAYABLE_DAY_COUNT, "calendar should contain the complete 3,652-day playable range"):
		return
	if not _require(String(game.calendar.get_day(0).get(DayEventKeysScript.KEY_DATE, "")) == START_DATE, "calendar should begin on the configured start date"):
		return
	if not _require(String(game.calendar.get_day(game.calendar.count() - 1).get(DayEventKeysScript.KEY_DATE, "")) == FINAL_DATE, "calendar should end on the configured final date"):
		return

	var expected_annual_ids := _expected_annual_event_ids(game)
	if not _require(expected_annual_ids.size() == EXPECTED_ANNUAL_EVENT_COUNT, "catalog should expose all 100 annual special events"):
		return

	var tutorial_order: Dictionary = game.submit_market_order(TUTORIAL_TICKER, "buy", 1)
	if not _require(bool(tutorial_order.get(DayEventKeysScript.KEY_OK, false)), "first-day tutorial purchase should succeed before the sequential run"):
		return

	var seen_annual_ids := {}
	var processed_days := 0
	var save_roundtrips := 0
	var final_result := {}
	var store = GameProgressStoreScript.new()
	store.save_path = TEST_SAVE_PATH

	while processed_days < game.calendar.count():
		if not _require(game.day_index == processed_days, "day index should advance exactly once before day %d" % processed_days):
			return
		var day: Dictionary = game.calendar.get_day(game.day_index)
		var date := String(day.get(DayEventKeysScript.KEY_DATE, ""))
		if not _require(not date.is_empty(), "every sequential calendar row should have a date"):
			return

		# Nap is the safest deliberate closed-day choice. Trading days and forced events
		# ignore this id and resolve through their normal company/annual rules.
		var completion: Dictionary = game.complete_today(DayEventKeysScript.ACTION_NAP)
		if not _require(bool(completion.get(DayEventKeysScript.KEY_OK, false)), "day completion should succeed on %s" % date):
			return
		if not _require(String(completion.get(DayEventKeysScript.KEY_DATE, "")) == date, "completion result should preserve the current date on %s" % date):
			return

		var action: Dictionary = Dictionary(completion.get(DayEventKeysScript.KEY_DAY_ACTION, {})).get(DayEventKeysScript.KEY_EVENT, {})
		if String(action.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_ANNUAL_SPECIAL:
			var annual_id := String(action.get(DayEventKeysScript.KEY_ID, ""))
			if not _require(expected_annual_ids.has(annual_id), "unexpected annual event %s on %s" % [annual_id, date]):
				return
			if not _require(not seen_annual_ids.has(annual_id), "annual event %s should occur only once" % annual_id):
				return
			seen_annual_ids[annual_id] = date

		processed_days += 1
		if processed_days == game.calendar.count():
			final_result = completion
			break

		if not _require(not bool(completion.get(DayEventKeysScript.KEY_GAME_FINISHED, false)), "run should not terminate early on %s (%s)" % [date, completion.get(PlayerStatusKeysScript.KEY_GAME_OVER_REASON, "")]):
			return
		var sleep_result: Dictionary = game.sleep_to_next_day()
		if not _require(bool(sleep_result.get(GameDayProgressKeysScript.KEY_OK, false)), "sleep should advance after %s" % date):
			return
		if not _require(String(sleep_result.get(GameDayProgressKeysScript.KEY_FROM_DATE, "")) == date, "sleep should report the correct from-date after %s" % date):
			return
		if not _require(game.day_index == processed_days and game.completed_days == processed_days, "sleep should keep day index and completed count aligned after %s" % date):
			return

		var next_date := String(sleep_result.get(GameDayProgressKeysScript.KEY_TO_DATE, ""))
		if next_date.ends_with("-01-01"):
			var loaded_game = _save_and_reload_checkpoint(game, store, next_date)
			if loaded_game == null:
				return
			game = loaded_game
			save_roundtrips += 1

	if not _require(processed_days == EXPECTED_PLAYABLE_DAY_COUNT, "the run should process every playable date exactly once"):
		return
	if not _require(save_roundtrips == EXPECTED_SAVE_ROUNDTRIP_COUNT, "the run should survive ten New Year save/load checkpoints"):
		return
	if not _require(seen_annual_ids.size() == expected_annual_ids.size(), "the sequential run should play all 100 annual special events"):
		return
	for annual_id in expected_annual_ids:
		if not _require(seen_annual_ids.has(annual_id), "annual event %s should occur during the ten-year run" % annual_id):
			return

	if not _require(String(final_result.get(DayEventKeysScript.KEY_DATE, "")) == FINAL_DATE, "final completion should occur on %s" % FINAL_DATE):
		return
	if not _require(bool(final_result.get(DayEventKeysScript.KEY_GAME_FINISHED, false)), "final day should produce a terminal ending"):
		return
	if not _require(not String(final_result.get(PlayerStatusKeysScript.KEY_ENDING_ROUTE, "")).is_empty(), "final result should include an ending route"):
		return
	if not _require(game.day_completed and GameEndingScript.is_game_finished(game), "game state should remain finished after the final day"):
		return
	if not _require(game.completed_days == EXPECTED_PLAYABLE_DAY_COUNT - 1, "completed-day counter should represent every transition before the terminal day"):
		return

	var elapsed_ms := float(Time.get_ticks_usec() - started_usec) / 1000.0
	_remove_test_save_files()
	print("Ten-year sequential completion test passed: %d days, %d annual events, %d save/load checkpoints, %.1f ms." % [
		processed_days,
		seen_annual_ids.size(),
		save_roundtrips,
		elapsed_ms
	])
	finish_test()


func _expected_annual_event_ids(game) -> Dictionary:
	var ids := {}
	for row in game.day_events.day_actions:
		var action := Dictionary(row)
		if String(action.get(DayEventKeysScript.KEY_MODE, "")) != DayEventKeysScript.MODE_ANNUAL_SPECIAL:
			continue
		var event_id := String(action.get(DayEventKeysScript.KEY_ID, ""))
		if not event_id.is_empty():
			ids[event_id] = true
	return ids


func _save_and_reload_checkpoint(game, store, expected_date: String):
	var before_status: Dictionary = game.status.to_dict()
	var before_history_size: int = game.event_history.size()
	var before_applied_fixed_count: int = game.applied_market_fixed_event_ids.size()
	var before_quantity: int = game.get_total_held_quantity()
	var before_seed := String(game.random_seed)
	var before_day_index := int(game.day_index)
	var before_completed_days := int(game.completed_days)

	var save_result: Dictionary = store.save_game(game)
	if not _require(bool(save_result.get(GameSaveKeysScript.KEY_OK, false)), "checkpoint save should succeed on %s" % expected_date):
		return null

	var loaded = GameStateScript.new()
	var load_result: Dictionary = store.load_game(loaded)
	if not _require(bool(load_result.get(GameSaveKeysScript.KEY_OK, false)), "checkpoint load should succeed on %s" % expected_date):
		return null
	if not _require(String(load_result.get(GameSaveKeysScript.KEY_DATE, "")) == expected_date, "checkpoint should restore %s" % expected_date):
		return null
	if not _require(loaded.day_index == before_day_index and loaded.completed_days == before_completed_days, "checkpoint should preserve progress counters on %s" % expected_date):
		return null
	if not _require(not loaded.day_completed and loaded.last_day_result.is_empty(), "post-sleep checkpoint should restore an unresolved new day on %s" % expected_date):
		return null
	if not _require(loaded.status.health == int(before_status.get(PlayerStatusKeysScript.KEY_HEALTH, -1)), "checkpoint should preserve health on %s" % expected_date):
		return null
	if not _require(loaded.status.cash == int(before_status.get(PlayerStatusKeysScript.KEY_CASH, -1)), "checkpoint should preserve cash on %s" % expected_date):
		return null
	if not _require(loaded.status.mood == int(before_status.get(PlayerStatusKeysScript.KEY_MOOD, -1)), "checkpoint should preserve mood on %s" % expected_date):
		return null
	if not _require(loaded.status.fatigue == int(before_status.get(PlayerStatusKeysScript.KEY_FATIGUE, -1)), "checkpoint should preserve fatigue on %s" % expected_date):
		return null
	if not _require(loaded.event_history.size() == before_history_size, "checkpoint should preserve bounded event history on %s" % expected_date):
		return null
	if not _require(loaded.applied_market_fixed_event_ids.size() == before_applied_fixed_count, "checkpoint should preserve applied fixed-event flags on %s" % expected_date):
		return null
	if not _require(loaded.get_total_held_quantity() == before_quantity, "checkpoint should preserve portfolio positions on %s" % expected_date):
		return null
	if not _require(loaded.random_seed == before_seed, "checkpoint should preserve the stable run seed on %s" % expected_date):
		return null
	if not _require(not loaded.event_branch_seed.is_empty(), "checkpoint load should create a fresh unresolved-event branch on %s" % expected_date):
		return null
	return loaded


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	_remove_test_save_files()
	fail_test()
	return false


func _remove_test_save_files() -> void:
	for suffix in [
		"",
		GameProgressStoreScript.TEMP_SUFFIX,
		GameProgressStoreScript.BACKUP_SUFFIX,
		GameProgressStoreScript.REPLACEMENT_SUFFIX,
		GameProgressStoreScript.BACKUP_SUFFIX + GameProgressStoreScript.TEMP_SUFFIX
	]:
		var path := TEST_SAVE_PATH + String(suffix)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
