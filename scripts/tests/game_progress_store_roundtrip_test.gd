extends "res://scripts/tests/test_scene_tree.gd"

const GameProgressStoreScript := preload("res://scripts/core/save/game_progress_store.gd")
const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")

const TEST_PROGRESS_PATH := "user://game_progress_roundtrip.test.json"


func _initialize() -> void:
	_remove_test_files(TEST_PROGRESS_PATH)

	_verify_missing_and_invalid_load_errors()
	_remove_test_files(TEST_PROGRESS_PATH)

	var source := GameStateScript.new()
	_expect(source.setup("2016-07-01"), "source game should start")
	_expect(source.submit_market_order("005930", "buy", 2).get("ok", false), "source game should buy shares before saving")
	var complete_result := source.complete_today("company_work", [], true)
	_expect(complete_result.get("ok", false), "source game should complete the day before saving")

	var store = GameProgressStoreScript.new()
	store.save_path = TEST_PROGRESS_PATH
	var save_result := store.save_game(source)
	_expect(save_result.get(GameSaveKeysScript.KEY_OK, false), "game progress store should save the game")
	_expect(store.has_saved_progress(), "game progress store should find the saved file")

	var loaded := GameStateScript.new()
	var load_result := store.load_game(loaded)
	_expect(load_result.get(GameSaveKeysScript.KEY_OK, false), "game progress store should load the game")
	_expect(loaded.get_today_context().get(GameSaveKeysScript.KEY_DATE, "") == "2016-07-01", "loaded game should restore the current date")
	_expect(loaded.day_completed, "loaded game should restore day completion state")
	_expect(loaded.completed_days == source.completed_days, "loaded game should restore completed day count")
	_expect(loaded.last_day_result.get("day_action", {}).get("event", {}).get(DayEventKeysScript.KEY_GROUP, "") == DayEventKeysScript.GROUP_COMPANY_WORK, "loaded game should restore the last company work variant result")
	_expect(loaded.market.portfolio.get_total_quantity() == 2, "loaded game should restore held share quantity")
	_expect(loaded.market.portfolio.cash == source.market.portfolio.cash, "loaded game should restore portfolio cash")
	_expect(loaded.status.cash == source.status.cash, "loaded game should restore status cash")
	_expect(loaded.get_market_close_report().get("net_worth", 0) == source.get_market_close_report().get("net_worth", 0), "loaded game should restore market valuation")
	var first_loaded_branch := loaded.event_branch_seed
	var first_loaded_event_seed := loaded.get_event_random_seed()
	_expect(not first_loaded_branch.is_empty(), "progress load should start a runtime event branch")

	var reloaded := GameStateScript.new()
	var reload_result := store.load_game(reloaded)
	_expect(reload_result.get(GameSaveKeysScript.KEY_OK, false), "the same progress file should load again")
	_expect(reloaded.random_seed == loaded.random_seed, "reloading progress should preserve the saved run seed")
	_expect(reloaded.event_branch_seed != first_loaded_branch, "reloading the same progress should start a different event branch")
	_expect(reloaded.get_event_random_seed() != first_loaded_event_seed, "reloading the same progress should change the effective event seed")

	_verify_backup_recovery(store, source)
	_remove_test_files(TEST_PROGRESS_PATH)
	print("Game progress store roundtrip test passed.")
	finish_test()


func _verify_missing_and_invalid_load_errors() -> void:
	var store = GameProgressStoreScript.new()
	store.save_path = TEST_PROGRESS_PATH
	var game := GameStateScript.new()

	var missing := store.load_game(game)
	_expect(not bool(missing.get(GameSaveKeysScript.KEY_OK, true)), "missing progress file should fail")
	_expect(String(missing.get(GameSaveKeysScript.KEY_ERROR, "")) == GameProgressStoreScript.ERROR_FILE_MISSING, "missing progress should keep file-missing error")

	_write_text(TEST_PROGRESS_PATH, "not json")
	var invalid := store.load_game(game)
	_expect(not bool(invalid.get(GameSaveKeysScript.KEY_OK, true)), "invalid progress file should fail")
	_expect(String(invalid.get(GameSaveKeysScript.KEY_ERROR, "")) == GameProgressStoreScript.ERROR_INVALID_JSON, "invalid progress should keep invalid-json error")

	_write_text(TEST_PROGRESS_PATH, "[1,2,3]")
	var array_payload := store.load_game(game)
	_expect(not bool(array_payload.get(GameSaveKeysScript.KEY_OK, true)), "non-dictionary progress file should fail")
	_expect(String(array_payload.get(GameSaveKeysScript.KEY_ERROR, "")) == GameProgressStoreScript.ERROR_INVALID_JSON, "non-dictionary progress should keep invalid-json error")

	_write_text(TEST_PROGRESS_PATH, "{}")
	var partial_payload := store.load_game(game)
	_expect(not bool(partial_payload.get(GameSaveKeysScript.KEY_OK, true)), "partial progress payload should fail")
	_expect(String(partial_payload.get(GameSaveKeysScript.KEY_ERROR, "")) == GameSaveKeysScript.ERROR_SAVE_DATA_INVALID, "partial progress should expose invalid-save-data error")


func _verify_backup_recovery(store, source) -> void:
	var previous_seed: String = source.random_seed
	source.random_seed = "newer_primary_seed"
	var replacement: Dictionary = store.save_game(source)
	_expect(replacement.get(GameSaveKeysScript.KEY_OK, false), "replacing a save should succeed")
	_expect(FileAccess.file_exists(TEST_PROGRESS_PATH + GameProgressStoreScript.BACKUP_SUFFIX), "replacing a save should retain the previous verified save as backup")

	_write_text(TEST_PROGRESS_PATH, "truncated")
	var recovered := GameStateScript.new()
	var result: Dictionary = store.load_game(recovered)
	_expect(result.get(GameSaveKeysScript.KEY_OK, false), "a corrupt primary save should recover from the backup")
	_expect(String(result.get(GameSaveKeysScript.KEY_PATH, "")) == TEST_PROGRESS_PATH + GameProgressStoreScript.BACKUP_SUFFIX, "backup recovery should report the path that was loaded")
	_expect(recovered.random_seed == previous_seed, "backup recovery should restore the previous verified payload")

	recovered.random_seed = "recovered_primary_seed"
	var recovered_save: Dictionary = store.save_game(recovered)
	_expect(recovered_save.get(GameSaveKeysScript.KEY_OK, false), "saving recovered progress should replace the corrupt primary")
	var backup_store = GameProgressStoreScript.new()
	backup_store.save_path = TEST_PROGRESS_PATH + GameProgressStoreScript.BACKUP_SUFFIX
	var preserved_backup := GameStateScript.new()
	var backup_result: Dictionary = backup_store.load_game(preserved_backup)
	_expect(backup_result.get(GameSaveKeysScript.KEY_OK, false), "saving recovered progress should preserve the last verified backup")
	_expect(preserved_backup.random_seed == previous_seed, "a corrupt primary must not overwrite the verified backup during recovery save")

	var unsupported_payload := recovered.to_save_dict()
	unsupported_payload[GameSaveKeysScript.KEY_VERSION] = GameSaveKeysScript.SAVE_VERSION + 1
	_write_text(TEST_PROGRESS_PATH, JSON.stringify(unsupported_payload))
	var unsupported_result: Dictionary = store.load_game(GameStateScript.new())
	_expect(not bool(unsupported_result.get(GameSaveKeysScript.KEY_OK, true)), "an unsupported primary save should not silently fall back to an older backup")
	_expect(String(unsupported_result.get(GameSaveKeysScript.KEY_ERROR, "")) == GameSaveKeysScript.ERROR_SAVE_VERSION_NEWER, "a newer primary save should preserve its version error")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write test progress file: %s" % path)
		fail_test()
	file.store_string(text)
	file.close()


func _remove_test_files(path: String) -> void:
	for suffix in ["", GameProgressStoreScript.TEMP_SUFFIX, GameProgressStoreScript.BACKUP_SUFFIX, GameProgressStoreScript.REPLACEMENT_SUFFIX]:
		var candidate := path + String(suffix)
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))
