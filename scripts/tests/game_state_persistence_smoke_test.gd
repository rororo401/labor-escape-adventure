extends "res://scripts/tests/test_scene_tree.gd"

const GameStatePersistenceScript := preload("res://scripts/core/save/game_state_persistence.gd")
const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameRunStatisticsScript := preload("res://scripts/core/game_run_statistics.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")


func _initialize() -> void:
	_verify_event_branch_seed_contract()
	_verify_save_payload_shape()
	_verify_load_roundtrip()
	_verify_same_payload_starts_a_new_event_branch()
	_verify_legacy_v1_defaults_safely()
	_verify_legacy_v2_defaults_leverage_state()
	_verify_legacy_v3_defaults_run_statistics()
	_verify_invalid_payloads_are_rejected()
	print("Game state persistence smoke test passed.")
	finish_test()


func _verify_event_branch_seed_contract() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01", "stable_run_seed"), "seeded game should set up")
	_expect(game.event_branch_seed.is_empty(), "fresh setup should start on the stable base event branch")
	_expect(game.get_event_random_seed() == "stable_run_seed", "fresh seeded setup should preserve the existing event seed")
	_expect(game.get_event_random_seed() == game.get_event_random_seed(), "event seed should stay stable within one session branch")

	game.refresh_event_branch_seed()
	var branched_seed := game.get_event_random_seed()
	_expect(not game.event_branch_seed.is_empty(), "refreshing the event branch should create runtime entropy")
	_expect(branched_seed != game.random_seed, "loaded event branch should compose with, not replace, the run seed")
	_expect(game.get_event_random_seed() == branched_seed, "refreshed event branch should remain stable within the session")

	var payload := game.to_save_dict()
	_expect(payload.get(GameSaveKeysScript.KEY_RANDOM_SEED, "") == "stable_run_seed", "save should keep the stable run seed")
	_expect(not payload.has("event_branch_seed"), "runtime event branch seed must not cross the save boundary")


func _verify_save_payload_shape() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up before saving")
	var payload := GameStatePersistenceScript.to_save_dict(game)
	_expect(payload.get(GameSaveKeysScript.KEY_VERSION, 0) == GameSaveKeysScript.SAVE_VERSION, "payload should include save version")
	_expect(payload.get(GameSaveKeysScript.KEY_CURRENT_DATE, "") == "2016-07-01", "payload should include current date")
	_expect(payload.get(GameSaveKeysScript.KEY_DAY_INDEX, -1) == game.day_index, "payload should include day index")
	_expect(not String(payload.get(GameSaveKeysScript.KEY_RANDOM_SEED, "")).is_empty(), "payload should include random seed")
	_expect(payload.has(GameSaveKeysScript.KEY_EVENT_HISTORY), "payload should include event history")
	_expect(payload.get(GameSaveKeysScript.KEY_DIFFICULTY, "") == GameSaveKeysScript.DIFFICULTY_HARD, "payload should include difficulty")
	_expect(payload.has(GameSaveKeysScript.KEY_SHOWN_MARKET_FIXED_EVENT_IDS), "payload should include shown market fixed event ids")
	_expect(payload.has(GameSaveKeysScript.KEY_APPLIED_MARKET_FIXED_EVENT_IDS), "payload should include applied market fixed event ids")
	_expect(payload.has(GameSaveKeysScript.KEY_HEALTH_RESURRECTION_USED), "payload should include health resurrection flag")
	_expect(payload.has(GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED), "payload should include leverage goddess flag")
	_expect(payload.has(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX), "payload should include leverage start day")
	_expect(payload.has(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX), "payload should include leverage end day")
	_expect(payload.has(GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH), "payload should include leverage reference net worth")
	_expect(payload.has(GameSaveKeysScript.KEY_RUN_STATISTICS), "payload should include run statistics")
	_expect(payload.has(GameSaveKeysScript.KEY_STATUS), "payload should include status")
	_expect(payload.has(GameSaveKeysScript.KEY_MARKET), "payload should include market")


func _verify_load_roundtrip() -> void:
	var source := GameStateScript.new()
	_expect(source.setup("2016-07-01"), "source game should set up")
	source.random_seed = "roundtrip_seed"
	_expect(source.submit_market_order("005930", "buy", 2).get("ok", false), "source game should buy stock")
	_expect(source.complete_today("company_work", [], true).get("ok", false), "source game should complete the day")
	source.health_resurrection_used = true
	source.leverage_goddess_used = true
	source.leverage_blessing_start_day_index = 10
	source.leverage_blessing_end_day_index = 375
	source.leverage_reference_net_worth = 2800000
	source.event_history.append({
		DayEventKeysScript.KEY_ID: "overtime_request",
		DayEventKeysScript.KEY_COMPLETED_DAY: 0,
		DayEventKeysScript.KEY_SELECTED: true
	})
	source.mark_market_fixed_event_seen("market_covid_circuit_breaker_2020_03_13")
	source.applied_market_fixed_event_ids["market_covid_circuit_breaker_2020_03_13"] = true
	var payload := source.to_save_dict()
	var saved_market := Dictionary(payload.get(GameSaveKeysScript.KEY_MARKET, {}))
	saved_market[MarketDataKeysScript.KEY_REAL_NAME_MODE] = true
	payload[GameSaveKeysScript.KEY_MARKET] = saved_market

	var loaded := GameStateScript.new()
	var result := GameStatePersistenceScript.load_from_save_dict(loaded, payload, GameStateScript.DEFAULT_START_DATE)
	_expect(result.get(GameSaveKeysScript.KEY_OK, false), "loaded game should accept save payload")
	_expect(result.get(GameSaveKeysScript.KEY_DATE, "") == "2016-07-01", "loaded game should restore date")
	_expect(loaded.day_completed, "loaded game should restore day-completed flag")
	_expect(loaded.completed_days == source.completed_days, "loaded game should restore completed day count")
	_expect(loaded.random_seed == source.random_seed, "loaded game should restore random seed")
	_expect(loaded.market.portfolio.get_total_quantity() == 2, "loaded game should restore portfolio quantity")
	_expect(not loaded.market.real_name_mode, "an older save must not restore real company names when the catalog requires fictional names")
	_expect(loaded.market.catalog.get_display_name_by_ticker("005930") == "새벽전자", "loaded progress should resolve the fictional company name")
	_expect(loaded.status.cash == source.status.cash, "loaded game should refresh status cash")
	_expect(loaded.health_resurrection_used, "loaded game should restore health resurrection flag")
	_expect(loaded.leverage_goddess_used, "loaded game should restore leverage goddess flag")
	_expect(loaded.leverage_blessing_start_day_index == 10, "loaded game should restore leverage start day")
	_expect(loaded.leverage_blessing_end_day_index == 375, "loaded game should restore leverage end day")
	_expect(loaded.leverage_reference_net_worth == 2800000, "loaded game should restore leverage reference net worth")
	_expect(loaded.run_statistics.most_held_ticker == "005930" and loaded.run_statistics.most_held_quantity == 2, "loaded game should restore peak holding statistics")
	_expect(loaded.run_statistics.total_event_count == source.run_statistics.total_event_count, "loaded game should restore cumulative event count")
	_expect(loaded.last_day_result.get("day_action", {}).get("event", {}).get(DayEventKeysScript.KEY_GROUP, "") == DayEventKeysScript.GROUP_COMPANY_WORK, "loaded game should restore last company work variant result")
	_expect(_history_has(loaded.event_history, "overtime_request"), "loaded game should restore event history")
	_expect(loaded.has_seen_market_fixed_event("market_covid_circuit_breaker_2020_03_13"), "loaded game should restore shown market fixed event ids")
	_expect(bool(loaded.applied_market_fixed_event_ids.get("market_covid_circuit_breaker_2020_03_13", false)), "loaded game should restore applied market fixed event ids")
	_expect(not loaded.event_branch_seed.is_empty(), "successful load should start a runtime event branch")
	_expect(loaded.get_event_random_seed() != loaded.random_seed, "loaded event random seed should include branch entropy")


func _verify_same_payload_starts_a_new_event_branch() -> void:
	var source := GameStateScript.new()
	_expect(source.setup("2016-07-05", "same_save_run_seed"), "same-payload source should set up")
	var payload := source.to_save_dict()
	var loaded := GameStateScript.new()

	var first_result := GameStatePersistenceScript.load_from_save_dict(loaded, payload, GameStateScript.DEFAULT_START_DATE)
	_expect(first_result.get(GameSaveKeysScript.KEY_OK, false), "first same-payload load should succeed")
	var first_branch_seed := loaded.event_branch_seed
	var first_event_seed := loaded.get_event_random_seed()

	var second_result := GameStatePersistenceScript.load_from_save_dict(loaded, payload, GameStateScript.DEFAULT_START_DATE)
	_expect(second_result.get(GameSaveKeysScript.KEY_OK, false), "second same-payload load should succeed")
	_expect(loaded.random_seed == "same_save_run_seed", "repeated load should preserve the saved run seed")
	_expect(not first_branch_seed.is_empty() and loaded.event_branch_seed != first_branch_seed, "each successful load should create a different event branch")
	_expect(loaded.get_event_random_seed() != first_event_seed, "same save should receive a new effective event seed after reload")


func _verify_legacy_v1_defaults_safely() -> void:
	var source := GameStateScript.new()
	_expect(source.setup(GameStateScript.DEFAULT_START_DATE), "legacy fixture game should set up")
	var payload := source.to_save_dict()
	payload[GameSaveKeysScript.KEY_VERSION] = 1
	for legacy_missing_key in [
		GameSaveKeysScript.KEY_RANDOM_SEED,
		GameSaveKeysScript.KEY_DIFFICULTY,
		GameSaveKeysScript.KEY_EVENT_HISTORY,
		GameSaveKeysScript.KEY_SHOWN_MARKET_FIXED_EVENT_IDS,
		GameSaveKeysScript.KEY_APPLIED_MARKET_FIXED_EVENT_IDS,
		GameSaveKeysScript.KEY_HEALTH_RESURRECTION_USED,
		GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED,
		GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX,
		GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX,
		GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH
	]:
		payload.erase(legacy_missing_key)

	var loaded := GameStateScript.new()
	var result := GameStatePersistenceScript.load_from_save_dict(loaded, payload, GameStateScript.DEFAULT_START_DATE)
	_expect(result.get(GameSaveKeysScript.KEY_OK, false), "original save-version 1 payloads should remain loadable")
	_expect(loaded.random_seed.begins_with("legacy:"), "legacy saves should receive a stable migrated run seed")
	_expect(loaded.event_history.is_empty(), "missing legacy event history should default to empty")
	_expect(loaded.shown_market_fixed_event_ids.is_empty(), "missing legacy shown-event flags should default to empty")
	_expect(loaded.applied_market_fixed_event_ids.is_empty(), "missing legacy applied-event flags should default to empty")
	_expect(not loaded.health_resurrection_used, "missing legacy resurrection flag should default to false")
	_expect(not loaded.leverage_goddess_used, "legacy saves should not consume the leverage event")
	_expect(loaded.leverage_blessing_start_day_index == -1 and loaded.leverage_blessing_end_day_index == -1, "legacy saves should start without a leverage duration")
	_expect(loaded.difficulty == GameSaveKeysScript.DIFFICULTY_HARD, "version 1 saves should migrate to hard difficulty")
	_expect(not loaded.event_branch_seed.is_empty(), "migrated legacy saves should still start a new event branch")
	var upgraded_payload := loaded.to_save_dict()
	_expect(upgraded_payload.has(GameSaveKeysScript.KEY_RANDOM_SEED), "saving migrated progress should write the current seed fields")
	_expect(upgraded_payload.has(GameSaveKeysScript.KEY_EVENT_HISTORY), "saving migrated progress should write the current history fields")


func _verify_legacy_v2_defaults_leverage_state() -> void:
	var source := GameStateScript.new()
	_expect(source.setup(GameStateScript.DEFAULT_START_DATE), "version 2 fixture should set up")
	var payload := source.to_save_dict()
	payload[GameSaveKeysScript.KEY_VERSION] = 2
	for leverage_key in [
		GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED,
		GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX,
		GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX,
		GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH
	]:
		payload.erase(leverage_key)
	var loaded := GameStateScript.new()
	var result := GameStatePersistenceScript.load_from_save_dict(loaded, payload, GameStateScript.DEFAULT_START_DATE)
	_expect(result.get(GameSaveKeysScript.KEY_OK, false), "version 2 saves should migrate to the leverage save schema")
	_expect(not loaded.leverage_goddess_used, "version 2 saves should retain an unused leverage event")
	_expect(loaded.leverage_blessing_start_day_index == -1 and loaded.leverage_blessing_end_day_index == -1, "version 2 saves should have no active blessing")


func _verify_legacy_v3_defaults_run_statistics() -> void:
	var source := GameStateScript.new()
	_expect(source.setup(GameStateScript.DEFAULT_START_DATE), "version 3 fixture should set up")
	_expect(source.submit_market_order("005930", "buy", 2).get("ok", false), "version 3 fixture should hold stock")
	var payload := source.to_save_dict()
	payload[GameSaveKeysScript.KEY_VERSION] = 3
	payload.erase(GameSaveKeysScript.KEY_RUN_STATISTICS)
	var loaded := GameStateScript.new()
	var result := GameStatePersistenceScript.load_from_save_dict(loaded, payload, GameStateScript.DEFAULT_START_DATE)
	_expect(result.get(GameSaveKeysScript.KEY_OK, false), "version 3 saves should migrate to run statistics")
	_expect(loaded.run_statistics.highest_net_worth == source.status.get_net_worth(), "version 3 migration should use current net worth as the known peak")
	_expect(loaded.run_statistics.most_held_ticker == "005930" and loaded.run_statistics.most_held_quantity == 2, "version 3 migration should recover the largest current holding")


func _verify_invalid_payloads_are_rejected() -> void:
	_expect_load_error({}, GameSaveKeysScript.ERROR_SAVE_DATA_INVALID, "empty payload")

	var source := GameStateScript.new()
	_expect(source.setup(GameStateScript.DEFAULT_START_DATE), "invalid-payload fixture game should set up")
	var payload := source.to_save_dict()

	var unsupported := payload.duplicate(true)
	unsupported[GameSaveKeysScript.KEY_VERSION] = GameSaveKeysScript.SAVE_VERSION + 1
	_expect_load_error(unsupported, GameSaveKeysScript.ERROR_SAVE_VERSION_NEWER, "newer version")

	var missing_status := payload.duplicate(true)
	missing_status.erase(GameSaveKeysScript.KEY_STATUS)
	_expect_load_error(missing_status, GameSaveKeysScript.ERROR_SAVE_DATA_INVALID, "missing status")

	for required_key in [
		GameSaveKeysScript.KEY_VERSION,
		GameSaveKeysScript.KEY_CURRENT_DATE,
		GameSaveKeysScript.KEY_DAY_INDEX,
		GameSaveKeysScript.KEY_COMPLETED_DAYS,
		GameSaveKeysScript.KEY_DAY_COMPLETED,
		GameSaveKeysScript.KEY_LAST_DAY_RESULT,
		GameSaveKeysScript.KEY_MARKET
	]:
		var missing_required := payload.duplicate(true)
		missing_required.erase(required_key)
		_expect_load_error(missing_required, GameSaveKeysScript.ERROR_SAVE_DATA_INVALID, "missing %s" % required_key)

	var invalid_date := payload.duplicate(true)
	invalid_date[GameSaveKeysScript.KEY_CURRENT_DATE] = ""
	_expect_load_error(invalid_date, GameSaveKeysScript.ERROR_SAVE_DATA_INVALID, "empty date")

	var mismatched_index := payload.duplicate(true)
	mismatched_index[GameSaveKeysScript.KEY_DAY_INDEX] = 1
	_expect_load_error(mismatched_index, GameSaveKeysScript.ERROR_SAVE_DATA_INVALID, "date and day-index mismatch")

	var out_of_range_status := payload.duplicate(true)
	var status := Dictionary(out_of_range_status.get(GameSaveKeysScript.KEY_STATUS)).duplicate(true)
	status["health"] = 101
	out_of_range_status[GameSaveKeysScript.KEY_STATUS] = status
	_expect_load_error(out_of_range_status, GameSaveKeysScript.ERROR_SAVE_DATA_INVALID, "out-of-range health")

	var partial_portfolio := payload.duplicate(true)
	var market := Dictionary(partial_portfolio.get(GameSaveKeysScript.KEY_MARKET)).duplicate(true)
	market["portfolio"] = {"cash": 5000000}
	partial_portfolio[GameSaveKeysScript.KEY_MARKET] = market
	_expect_load_error(partial_portfolio, GameSaveKeysScript.ERROR_SAVE_DATA_INVALID, "partial portfolio")


func _expect_load_error(payload: Dictionary, error: String, label: String) -> void:
	var loaded := GameStateScript.new()
	var result := GameStatePersistenceScript.load_from_save_dict(loaded, payload, GameStateScript.DEFAULT_START_DATE)
	_expect(not bool(result.get(GameSaveKeysScript.KEY_OK, true)), "%s should fail" % label)
	_expect(String(result.get(GameSaveKeysScript.KEY_ERROR, "")) == error, "%s should expose the expected error" % label)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _history_has(history: Array, event_id: String) -> bool:
	for row in history:
		if String(Dictionary(row).get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false
