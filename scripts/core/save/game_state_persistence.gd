class_name GameStatePersistence
extends RefCounted

const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const PlayerStatusSnapshotScript := preload("res://scripts/core/player_status_snapshot.gd")
const GameRunStatisticsScript := preload("res://scripts/core/game_run_statistics.gd")

const MAX_RANDOM_SEED_LENGTH := 512
const MAX_SAFE_JSON_INTEGER := 9007199254740991


static func to_save_dict(game) -> Dictionary:
	var day: Dictionary = game.calendar.get_day(game.day_index)
	return {
		GameSaveKeysScript.KEY_VERSION: GameSaveKeysScript.SAVE_VERSION,
		GameSaveKeysScript.KEY_CURRENT_DATE: String(day.get(GameSaveKeysScript.KEY_DATE, "")),
		GameSaveKeysScript.KEY_DAY_INDEX: game.day_index,
		GameSaveKeysScript.KEY_COMPLETED_DAYS: game.completed_days,
		GameSaveKeysScript.KEY_RANDOM_SEED: game.random_seed,
		GameSaveKeysScript.KEY_DIFFICULTY: String(game.difficulty),
		GameSaveKeysScript.KEY_DAY_COMPLETED: game.day_completed,
		GameSaveKeysScript.KEY_LAST_DAY_RESULT: game.last_day_result,
		GameSaveKeysScript.KEY_EVENT_HISTORY: game.event_history,
		GameSaveKeysScript.KEY_SHOWN_MARKET_FIXED_EVENT_IDS: game.shown_market_fixed_event_ids,
		GameSaveKeysScript.KEY_APPLIED_MARKET_FIXED_EVENT_IDS: game.applied_market_fixed_event_ids,
		GameSaveKeysScript.KEY_HEALTH_RESURRECTION_USED: game.health_resurrection_used,
		GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED: game.leverage_goddess_used,
		GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX: game.leverage_blessing_start_day_index,
		GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX: game.leverage_blessing_end_day_index,
		GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH: game.leverage_reference_net_worth,
		GameSaveKeysScript.KEY_RUN_STATISTICS: game.run_statistics.to_dict(),
		GameSaveKeysScript.KEY_STATUS: game.status.to_dict(),
		GameSaveKeysScript.KEY_MARKET: game.market.to_save_dict()
	}


static func validate_save_dict(data: Dictionary) -> Dictionary:
	var save_data := _normalized_save_dict(data)
	var required_keys: Array[String] = [
		GameSaveKeysScript.KEY_VERSION,
		GameSaveKeysScript.KEY_CURRENT_DATE,
		GameSaveKeysScript.KEY_DAY_INDEX,
		GameSaveKeysScript.KEY_COMPLETED_DAYS,
		GameSaveKeysScript.KEY_RANDOM_SEED,
		GameSaveKeysScript.KEY_DIFFICULTY,
		GameSaveKeysScript.KEY_DAY_COMPLETED,
		GameSaveKeysScript.KEY_LAST_DAY_RESULT,
		GameSaveKeysScript.KEY_EVENT_HISTORY,
		GameSaveKeysScript.KEY_SHOWN_MARKET_FIXED_EVENT_IDS,
		GameSaveKeysScript.KEY_HEALTH_RESURRECTION_USED,
		GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED,
		GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX,
		GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX,
		GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH,
		GameSaveKeysScript.KEY_RUN_STATISTICS,
		GameSaveKeysScript.KEY_STATUS,
		GameSaveKeysScript.KEY_MARKET
	]
	for key in required_keys:
		if not save_data.has(key):
			return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)

	if not _is_integer(save_data.get(GameSaveKeysScript.KEY_VERSION)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	var save_version := int(save_data.get(GameSaveKeysScript.KEY_VERSION))
	if save_version > GameSaveKeysScript.SAVE_VERSION:
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_VERSION_NEWER)
	if save_version != GameSaveKeysScript.SAVE_VERSION:
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_VERSION_UNSUPPORTED)
	if typeof(save_data.get(GameSaveKeysScript.KEY_CURRENT_DATE)) != TYPE_STRING or String(save_data.get(GameSaveKeysScript.KEY_CURRENT_DATE)).is_empty():
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _is_nonnegative_integer(save_data.get(GameSaveKeysScript.KEY_DAY_INDEX)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _is_nonnegative_integer(save_data.get(GameSaveKeysScript.KEY_COMPLETED_DAYS)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if typeof(save_data.get(GameSaveKeysScript.KEY_DAY_COMPLETED)) != TYPE_BOOL:
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if typeof(save_data.get(GameSaveKeysScript.KEY_LAST_DAY_RESULT)) != TYPE_DICTIONARY:
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)

	var random_seed = save_data.get(GameSaveKeysScript.KEY_RANDOM_SEED)
	if typeof(random_seed) != TYPE_STRING or String(random_seed).is_empty() or String(random_seed).length() > MAX_RANDOM_SEED_LENGTH:
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	var difficulty := String(save_data.get(GameSaveKeysScript.KEY_DIFFICULTY, ""))
	if not GameSaveKeysScript.DIFFICULTY_IDS.has(difficulty):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _is_dictionary_array(save_data.get(GameSaveKeysScript.KEY_EVENT_HISTORY)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _is_boolean_flag_dictionary(save_data.get(GameSaveKeysScript.KEY_SHOWN_MARKET_FIXED_EVENT_IDS)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _is_boolean_flag_dictionary(save_data.get(GameSaveKeysScript.KEY_APPLIED_MARKET_FIXED_EVENT_IDS)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if typeof(save_data.get(GameSaveKeysScript.KEY_HEALTH_RESURRECTION_USED)) != TYPE_BOOL:
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if typeof(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED)) != TYPE_BOOL:
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _is_integer(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _is_integer(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _is_nonnegative_integer(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _is_valid_run_statistics(save_data.get(GameSaveKeysScript.KEY_RUN_STATISTICS)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	var blessing_start := int(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX, -1))
	var blessing_end := int(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX, -1))
	var leverage_used := bool(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED, false))
	var valid_unused_duration := not leverage_used and blessing_start == -1 and blessing_end == -1
	var valid_used_duration := leverage_used and blessing_start >= 0 and blessing_end > blessing_start
	if not valid_unused_duration and not valid_used_duration:
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)

	var status = save_data.get(GameSaveKeysScript.KEY_STATUS)
	if typeof(status) != TYPE_DICTIONARY or not _is_valid_status(Dictionary(status)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	var market = save_data.get(GameSaveKeysScript.KEY_MARKET)
	if typeof(market) != TYPE_DICTIONARY or not _is_valid_market(Dictionary(market)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	var portfolio: Dictionary = Dictionary(market).get(MarketDataKeysScript.KEY_PORTFOLIO)
	if int(Dictionary(status).get(PlayerStatusKeysScript.KEY_CASH)) != int(Dictionary(portfolio).get(MarketDataKeysScript.KEY_CASH)):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)

	return {GameSaveKeysScript.KEY_OK: true}


static func load_from_save_dict(game, data: Dictionary, _default_start_date: String) -> Dictionary:
	var save_data := _normalized_save_dict(data)
	var validation := validate_save_dict(save_data)
	if not bool(validation.get(GameSaveKeysScript.KEY_OK, false)):
		return validation

	var date := String(save_data.get(GameSaveKeysScript.KEY_CURRENT_DATE))
	if not game.setup(date):
		return {
			GameSaveKeysScript.KEY_OK: false,
			GameSaveKeysScript.KEY_ERROR: GameSaveKeysScript.ERROR_SETUP_FAILED
		}

	var saved_index := int(save_data.get(GameSaveKeysScript.KEY_DAY_INDEX))
	if saved_index < 0 or saved_index >= game.calendar.count():
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	var indexed_day: Dictionary = game.calendar.get_day(saved_index)
	if String(indexed_day.get(GameSaveKeysScript.KEY_DATE, "")) != date:
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	var completed_days := int(save_data.get(GameSaveKeysScript.KEY_COMPLETED_DAYS))
	if completed_days > game.calendar.count():
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)
	if not _positions_exist_in_catalog(game, save_data):
		return _validation_error(GameSaveKeysScript.ERROR_SAVE_DATA_INVALID)

	game.day_index = saved_index
	game.completed_days = completed_days
	game.random_seed = String(save_data.get(GameSaveKeysScript.KEY_RANDOM_SEED, game.random_seed))
	game.difficulty = String(save_data.get(GameSaveKeysScript.KEY_DIFFICULTY, GameSaveKeysScript.DIFFICULTY_HARD))
	game.day_completed = bool(save_data.get(GameSaveKeysScript.KEY_DAY_COMPLETED))
	game.last_day_result = Dictionary(save_data.get(GameSaveKeysScript.KEY_LAST_DAY_RESULT)).duplicate(true)
	game.event_history.assign(Array(save_data.get(GameSaveKeysScript.KEY_EVENT_HISTORY, [])))
	game.shown_market_fixed_event_ids = Dictionary(save_data.get(GameSaveKeysScript.KEY_SHOWN_MARKET_FIXED_EVENT_IDS, {})).duplicate(true)
	game.applied_market_fixed_event_ids = Dictionary(save_data.get(GameSaveKeysScript.KEY_APPLIED_MARKET_FIXED_EVENT_IDS, {})).duplicate(true)
	game.health_resurrection_used = bool(save_data.get(GameSaveKeysScript.KEY_HEALTH_RESURRECTION_USED, false))
	game.leverage_goddess_used = bool(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED, false))
	game.leverage_blessing_start_day_index = int(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX, -1))
	game.leverage_blessing_end_day_index = int(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX, -1))
	game.leverage_reference_net_worth = int(save_data.get(GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH, 0))
	game.run_statistics.load_from_dict(Dictionary(save_data.get(GameSaveKeysScript.KEY_RUN_STATISTICS, {})))
	game.status.load_from_dict(Dictionary(save_data.get(GameSaveKeysScript.KEY_STATUS)))
	game.market.load_from_save_dict(Dictionary(save_data.get(GameSaveKeysScript.KEY_MARKET)))
	game.refresh_status_from_current_phase()
	# Do this after restoring the run seed. The branch must never be copied from the save payload.
	game.refresh_event_branch_seed()
	return {
		GameSaveKeysScript.KEY_OK: true,
		GameSaveKeysScript.KEY_DATE: game.calendar.get_day(game.day_index).get(GameSaveKeysScript.KEY_DATE, "")
	}


static func _normalized_save_dict(data: Dictionary) -> Dictionary:
	var normalized := data.duplicate(true)
	if not _is_integer(normalized.get(GameSaveKeysScript.KEY_VERSION)):
		return normalized
	var source_version := int(normalized.get(GameSaveKeysScript.KEY_VERSION))
	if source_version < GameSaveKeysScript.MIN_SUPPORTED_SAVE_VERSION or source_version > GameSaveKeysScript.SAVE_VERSION:
		return normalized
	if source_version == 1:
		normalized[GameSaveKeysScript.KEY_DIFFICULTY] = GameSaveKeysScript.DIFFICULTY_HARD
		source_version = 2
	if source_version == 2:
		normalized[GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED] = false
		normalized[GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX] = -1
		normalized[GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX] = -1
		normalized[GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH] = 0
		source_version = 3
	if source_version == 3:
		normalized[GameSaveKeysScript.KEY_RUN_STATISTICS] = _legacy_run_statistics(normalized)
		normalized[GameSaveKeysScript.KEY_VERSION] = GameSaveKeysScript.SAVE_VERSION

	if not normalized.has(GameSaveKeysScript.KEY_RANDOM_SEED):
		normalized[GameSaveKeysScript.KEY_RANDOM_SEED] = "legacy:%s:%d:%d" % [
			String(normalized.get(GameSaveKeysScript.KEY_CURRENT_DATE, "unknown")),
			int(normalized.get(GameSaveKeysScript.KEY_DAY_INDEX, 0)),
			int(normalized.get(GameSaveKeysScript.KEY_COMPLETED_DAYS, 0))
		]
	if not normalized.has(GameSaveKeysScript.KEY_EVENT_HISTORY):
		normalized[GameSaveKeysScript.KEY_EVENT_HISTORY] = []
	if not normalized.has(GameSaveKeysScript.KEY_SHOWN_MARKET_FIXED_EVENT_IDS):
		normalized[GameSaveKeysScript.KEY_SHOWN_MARKET_FIXED_EVENT_IDS] = {}
	if not normalized.has(GameSaveKeysScript.KEY_APPLIED_MARKET_FIXED_EVENT_IDS):
		normalized[GameSaveKeysScript.KEY_APPLIED_MARKET_FIXED_EVENT_IDS] = {}
	if not normalized.has(GameSaveKeysScript.KEY_HEALTH_RESURRECTION_USED):
		normalized[GameSaveKeysScript.KEY_HEALTH_RESURRECTION_USED] = false
	if not normalized.has(GameSaveKeysScript.KEY_DIFFICULTY):
		normalized[GameSaveKeysScript.KEY_DIFFICULTY] = GameSaveKeysScript.DIFFICULTY_HARD
	if not normalized.has(GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED):
		normalized[GameSaveKeysScript.KEY_LEVERAGE_GODDESS_USED] = false
	if not normalized.has(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX):
		normalized[GameSaveKeysScript.KEY_LEVERAGE_BLESSING_START_DAY_INDEX] = -1
	if not normalized.has(GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX):
		normalized[GameSaveKeysScript.KEY_LEVERAGE_BLESSING_END_DAY_INDEX] = -1
	if not normalized.has(GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH):
		normalized[GameSaveKeysScript.KEY_LEVERAGE_REFERENCE_NET_WORTH] = 0
	if not normalized.has(GameSaveKeysScript.KEY_RUN_STATISTICS):
		normalized[GameSaveKeysScript.KEY_RUN_STATISTICS] = _legacy_run_statistics(normalized)
	return normalized


static func _legacy_run_statistics(data: Dictionary) -> Dictionary:
	var status := Dictionary(data.get(GameSaveKeysScript.KEY_STATUS, {}))
	var highest_net_worth := maxi(0, int(status.get(PlayerStatusKeysScript.KEY_CASH, 0)) + int(status.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, 0)))
	var event_count := Array(data.get(GameSaveKeysScript.KEY_EVENT_HISTORY, [])).size()
	var most_held_ticker := ""
	var most_held_quantity := 0
	var market := Dictionary(data.get(GameSaveKeysScript.KEY_MARKET, {}))
	var portfolio := Dictionary(market.get(MarketDataKeysScript.KEY_PORTFOLIO, {}))
	for item in Array(portfolio.get(MarketDataKeysScript.KEY_POSITIONS, [])):
		var position := Dictionary(item)
		var quantity := int(position.get(MarketDataKeysScript.KEY_QUANTITY, 0))
		if quantity > most_held_quantity:
			most_held_ticker = String(position.get(MarketDataKeysScript.KEY_TICKER, ""))
			most_held_quantity = quantity
	return {
		GameRunStatisticsScript.KEY_HIGHEST_NET_WORTH: highest_net_worth,
		GameRunStatisticsScript.KEY_TOTAL_EVENT_COUNT: event_count,
		GameRunStatisticsScript.KEY_MOST_HELD_TICKER: most_held_ticker,
		GameRunStatisticsScript.KEY_MOST_HELD_QUANTITY: most_held_quantity
	}


static func _is_valid_run_statistics(value) -> bool:
	if typeof(value) != TYPE_DICTIONARY:
		return false
	var statistics := Dictionary(value)
	for key in [
		GameRunStatisticsScript.KEY_HIGHEST_NET_WORTH,
		GameRunStatisticsScript.KEY_TOTAL_EVENT_COUNT,
		GameRunStatisticsScript.KEY_MOST_HELD_QUANTITY
	]:
		if not statistics.has(key) or not _is_nonnegative_integer(statistics.get(key)):
			return false
	if typeof(statistics.get(GameRunStatisticsScript.KEY_MOST_HELD_TICKER)) != TYPE_STRING:
		return false
	var ticker := String(statistics.get(GameRunStatisticsScript.KEY_MOST_HELD_TICKER, ""))
	var quantity := int(statistics.get(GameRunStatisticsScript.KEY_MOST_HELD_QUANTITY, 0))
	return (quantity == 0 and ticker.is_empty()) or (quantity > 0 and not ticker.is_empty())


static func normalize_save_dict(data: Dictionary) -> Dictionary:
	return _normalized_save_dict(data)


static func _is_valid_status(status: Dictionary) -> bool:
	var required_keys: Array[String] = [
		PlayerStatusKeysScript.KEY_HEALTH,
		PlayerStatusKeysScript.KEY_CASH,
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS,
		PlayerStatusKeysScript.KEY_MOOD,
		PlayerStatusKeysScript.KEY_FATIGUE
	]
	for key in required_keys:
		if not status.has(key) or not _is_integer(status.get(key)):
			return false
	return (
		int(status.get(PlayerStatusKeysScript.KEY_HEALTH)) >= 0
		and int(status.get(PlayerStatusKeysScript.KEY_HEALTH)) <= PlayerStatusSnapshotScript.MAX_HEALTH
		and int(status.get(PlayerStatusKeysScript.KEY_CASH)) >= 0
		and int(status.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS)) >= 0
		and int(status.get(PlayerStatusKeysScript.KEY_MOOD)) >= 0
		and int(status.get(PlayerStatusKeysScript.KEY_MOOD)) <= PlayerStatusSnapshotScript.MAX_MOOD
		and int(status.get(PlayerStatusKeysScript.KEY_FATIGUE)) >= 0
		and int(status.get(PlayerStatusKeysScript.KEY_FATIGUE)) <= PlayerStatusSnapshotScript.MAX_FATIGUE
	)


static func _is_valid_market(market: Dictionary) -> bool:
	if not market.has(MarketDataKeysScript.KEY_REAL_NAME_MODE) or typeof(market.get(MarketDataKeysScript.KEY_REAL_NAME_MODE)) != TYPE_BOOL:
		return false
	if not market.has(MarketDataKeysScript.KEY_PORTFOLIO) or typeof(market.get(MarketDataKeysScript.KEY_PORTFOLIO)) != TYPE_DICTIONARY:
		return false
	var portfolio := Dictionary(market.get(MarketDataKeysScript.KEY_PORTFOLIO))
	if not portfolio.has(MarketDataKeysScript.KEY_CASH) or not _is_nonnegative_integer(portfolio.get(MarketDataKeysScript.KEY_CASH)):
		return false
	if not portfolio.has(MarketDataKeysScript.KEY_REALIZED_PROFIT) or not _is_integer(portfolio.get(MarketDataKeysScript.KEY_REALIZED_PROFIT)):
		return false
	if not portfolio.has(MarketDataKeysScript.KEY_POSITIONS) or typeof(portfolio.get(MarketDataKeysScript.KEY_POSITIONS)) != TYPE_ARRAY:
		return false
	var seen_tickers := {}
	for item in Array(portfolio.get(MarketDataKeysScript.KEY_POSITIONS)):
		if typeof(item) != TYPE_DICTIONARY:
			return false
		var position := Dictionary(item)
		var ticker = position.get(MarketDataKeysScript.KEY_TICKER)
		if typeof(ticker) != TYPE_STRING or String(ticker).is_empty() or seen_tickers.has(String(ticker)):
			return false
		if not _is_positive_integer(position.get(MarketDataKeysScript.KEY_QUANTITY)):
			return false
		if not _is_nonnegative_integer(position.get(MarketDataKeysScript.KEY_AVG_COST)):
			return false
		seen_tickers[String(ticker)] = true
	return true


static func _positions_exist_in_catalog(game, data: Dictionary) -> bool:
	var market := Dictionary(data.get(GameSaveKeysScript.KEY_MARKET))
	var portfolio := Dictionary(market.get(MarketDataKeysScript.KEY_PORTFOLIO))
	for item in Array(portfolio.get(MarketDataKeysScript.KEY_POSITIONS)):
		var ticker := String(Dictionary(item).get(MarketDataKeysScript.KEY_TICKER))
		if game.market.catalog.get_company(ticker).is_empty():
			return false
	return true


static func _is_dictionary_array(value) -> bool:
	if typeof(value) != TYPE_ARRAY:
		return false
	for item in Array(value):
		if typeof(item) != TYPE_DICTIONARY:
			return false
	return true


static func _is_boolean_flag_dictionary(value) -> bool:
	if typeof(value) != TYPE_DICTIONARY:
		return false
	for key in Dictionary(value):
		if typeof(key) != TYPE_STRING or String(key).is_empty() or typeof(Dictionary(value).get(key)) != TYPE_BOOL:
			return false
	return true


static func _is_integer(value) -> bool:
	if typeof(value) == TYPE_INT:
		var integer := int(value)
		return integer >= -MAX_SAFE_JSON_INTEGER and integer <= MAX_SAFE_JSON_INTEGER
	if typeof(value) != TYPE_FLOAT:
		return false
	var number := float(value)
	return is_finite(number) and number >= -MAX_SAFE_JSON_INTEGER and number <= MAX_SAFE_JSON_INTEGER and number == floor(number)


static func _is_nonnegative_integer(value) -> bool:
	return _is_integer(value) and int(value) >= 0


static func _is_positive_integer(value) -> bool:
	return _is_integer(value) and int(value) > 0


static func _validation_error(error: String) -> Dictionary:
	return {
		GameSaveKeysScript.KEY_OK: false,
		GameSaveKeysScript.KEY_ERROR: error
	}
