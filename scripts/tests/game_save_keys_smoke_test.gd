extends "res://scripts/tests/test_scene_tree.gd"

const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_verify_save_payload_keys()
	_verify_result_keys()
	_verify_error_codes()

	print("Game save keys smoke test passed.")
	finish_test()


func _verify_save_payload_keys() -> void:
	_expect(GameSaveKeysScript.SAVE_VERSION == 4, "save version should include persistent run statistics")
	_expect(GameSaveKeysScript.MIN_SUPPORTED_SAVE_VERSION == 1, "save migration should retain version 1 support")
	_expect(GameSaveKeysScript.KEY_VERSION == "version", "version key should stay stable")
	_expect(GameSaveKeysScript.KEY_CURRENT_DATE == "current_date", "current date key should stay stable")
	_expect(GameSaveKeysScript.KEY_DAY_INDEX == "day_index", "day index key should stay stable")
	_expect(GameSaveKeysScript.KEY_COMPLETED_DAYS == "completed_days", "completed days key should stay stable")
	_expect(GameSaveKeysScript.KEY_RANDOM_SEED == "random_seed", "random seed key should stay stable")
	_expect(GameSaveKeysScript.KEY_DIFFICULTY == "difficulty", "difficulty key should stay stable")
	_expect(GameSaveKeysScript.KEY_DAY_COMPLETED == GameStateContextKeysScript.KEY_DAY_COMPLETED, "day completed key should use the shared game-state context key")
	_expect(GameSaveKeysScript.KEY_LAST_DAY_RESULT == GameStateContextKeysScript.KEY_LAST_DAY_RESULT, "last day result key should use the shared game-state context key")
	_expect(GameSaveKeysScript.KEY_SHOWN_MARKET_FIXED_EVENT_IDS == "shown_market_fixed_event_ids", "shown market fixed event ids key should stay stable")
	_expect(GameSaveKeysScript.KEY_APPLIED_MARKET_FIXED_EVENT_IDS == "applied_market_fixed_event_ids", "applied market fixed event ids key should stay stable")
	_expect(GameSaveKeysScript.KEY_HEALTH_RESURRECTION_USED == "health_resurrection_used", "health resurrection key should stay stable")
	_expect(GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED == "leverage_goddess_used", "leverage goddess flag should stay stable")
	_expect(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX == "leverage_blessing_start_day_index", "leverage start key should stay stable")
	_expect(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX == "leverage_blessing_end_day_index", "leverage end key should stay stable")
	_expect(GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH == "leverage_reference_net_worth", "leverage reference key should stay stable")
	_expect(GameSaveKeysScript.KEY_STATUS == ResultKeysScript.KEY_STATUS, "status key should use the shared result key")
	_expect(GameSaveKeysScript.KEY_MARKET == DayEventKeysScript.KEY_MARKET, "market key should use the shared day-event key")
	_expect(GameSaveKeysScript.KEY_SAVED_AT_UNIX == "saved_at_unix", "saved-at metadata key should stay stable")
	_expect(GameSaveKeysScript.KEY_SLOT_KIND == "slot_kind", "slot-kind metadata key should stay stable")
	_expect(GameSaveKeysScript.KEY_SLOT_INDEX == "slot_index", "slot-index metadata key should stay stable")


func _verify_result_keys() -> void:
	_expect(GameSaveKeysScript.KEY_OK == ResultKeysScript.KEY_OK, "ok key should use the shared result key")
	_expect(GameSaveKeysScript.KEY_ERROR == ResultKeysScript.KEY_ERROR, "error key should use the shared result key")
	_expect(GameSaveKeysScript.KEY_DATE == DayEventKeysScript.KEY_DATE, "date key should use the shared day-event key")
	_expect(GameSaveKeysScript.KEY_PATH == ResultKeysScript.KEY_PATH, "path key should use the shared result key")
	_expect(GameSaveKeysScript.KEY_DATA == ResultKeysScript.KEY_DATA, "data key should use the shared result key")


func _verify_error_codes() -> void:
	_expect(GameSaveKeysScript.ERROR_SETUP_FAILED == "setup_failed", "setup error should stay stable")
	_expect(GameSaveKeysScript.ERROR_PROGRESS_FILE_MISSING == "progress_file_missing", "missing progress error should stay stable")
	_expect(GameSaveKeysScript.ERROR_PROGRESS_INVALID_JSON == "progress_invalid_json", "invalid progress error should stay stable")
	_expect(GameSaveKeysScript.ERROR_PROGRESS_WRITE_FAILED == "progress_write_failed", "write progress error should stay stable")
	_expect(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID == "save_data_invalid", "invalid save-data error should stay stable")
	_expect(GameSaveKeysScript.ERROR_SAVE_VERSION_UNSUPPORTED == "save_version_unsupported", "unsupported save-version error should stay stable")
	_expect(GameSaveKeysScript.ERROR_SAVE_VERSION_NEWER == "save_version_newer", "newer save-version error should stay stable")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
