class_name GameState
extends RefCounted

const PlayerStatusScript := preload("res://scripts/core/player_status.gd")
const GameCalendarScript := preload("res://scripts/core/game_calendar.gd")
const CharacterAssetCatalogScript := preload("res://scripts/core/character_asset_catalog.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const MarketEngineScript := preload("res://scripts/core/market/market_engine.gd")
const GameMarketStateScript := preload("res://scripts/core/market/game_market_state.gd")
const GameStatePersistenceScript := preload("res://scripts/core/save/game_state_persistence.gd")
const DayEventCatalogScript := preload("res://scripts/core/dayflow/day_event_catalog.gd")
const GameDayContextScript := preload("res://scripts/core/dayflow/game_day_context.gd")
const GameDayCompletionScript := preload("res://scripts/core/dayflow/game_day_completion.gd")
const GameDayCompletionGuardScript := preload("res://scripts/core/dayflow/game_day_completion_guard.gd")
const GameDayProgressScript := preload("res://scripts/core/dayflow/game_day_progress.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const CharacterOutfitSeasonScript := preload("res://scripts/core/character_outfit_season.gd")
const GameEndingScript := preload("res://scripts/core/game_ending.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")
const LeverageGoddessEventScript := preload("res://scripts/core/dayflow/leverage_goddess_event.gd")
const GameRunStatisticsScript := preload("res://scripts/core/game_run_statistics.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")

const CALENDAR_PATH := GameStateConfigScript.CALENDAR_PATH
const DAY_EVENTS_PATH := GameStateConfigScript.DAY_EVENTS_PATH
const CHARACTER_ASSETS_PATH := GameStateConfigScript.CHARACTER_ASSETS_PATH
const COMPANIES_PATH := GameStateConfigScript.COMPANIES_PATH
const DEFAULT_START_DATE := GameStateConfigScript.DEFAULT_START_DATE
const FIRST_TUTORIAL_DATE := GameStateConfigScript.FIRST_TUTORIAL_DATE
const SIMULATION_KEY_SLEEP := "sleep"
const SIMULATION_KEY_NEXT_DAY := "next_day"
const MAX_EVENT_HISTORY_ROWS := 500

var status = PlayerStatusScript.new()
var calendar = GameCalendarScript.new()
var day_events = DayEventCatalogScript.new()
var character_assets = CharacterAssetCatalogScript.new()
var market = MarketEngineScript.new()
var day_index := 0
var completed_days := 0
var day_completed := false
var last_day_result := {}
var event_history: Array[Dictionary] = []
var shown_market_fixed_event_ids := {}
var applied_market_fixed_event_ids := {}
var health_resurrection_used := false
var leverage_goddess_used := false
var leverage_blessing_start_day_index := -1
var leverage_blessing_end_day_index := -1
var leverage_reference_net_worth := 0
# The run seed is persisted; the branch seed is deliberately runtime-only so each successful Continue load rerolls unresolved events.
var random_seed := ""
var event_branch_seed := ""
var difficulty := GameDifficultyScript.DEFAULT
var run_statistics = GameRunStatisticsScript.new()


func setup(start_date: String = DEFAULT_START_DATE, seed_override: String = "") -> bool:
	calendar.load_from_csv(CALENDAR_PATH)
	day_events.load_from_json(DAY_EVENTS_PATH)
	character_assets.load_from_json(CHARACTER_ASSETS_PATH)
	status.reset()
	if not market.setup(status.cash, COMPANIES_PATH):
		return false
	completed_days = 0
	event_history = []
	shown_market_fixed_event_ids = {}
	applied_market_fixed_event_ids = {}
	health_resurrection_used = false
	leverage_goddess_used = false
	leverage_blessing_start_day_index = -1
	leverage_blessing_end_day_index = -1
	leverage_reference_net_worth = 0
	random_seed = seed_override if not seed_override.is_empty() else _new_random_seed()
	event_branch_seed = ""
	difficulty = GameDifficultyScript.DEFAULT
	run_statistics.reset(status.get_net_worth())

	if calendar.count() == 0:
		push_error("Game calendar is empty.")
		return false

	day_index = calendar.find_index_by_date(start_date)
	if day_index < 0:
		push_error("Start date not found in calendar: %s" % start_date)
		day_index = 0
		return false

	day_completed = false
	last_day_result = {}
	return true


func get_today_context() -> Dictionary:
	return GameDayContextScript.today_context(self)


func get_available_life_actions() -> Array[Dictionary]:
	return GameDayContextScript.available_life_actions(self)


func get_day_flow_context() -> Dictionary:
	return GameDayContextScript.day_flow_context(self)


func get_closed_day_categories() -> Array[Dictionary]:
	return GameDayContextScript.closed_day_categories(self)


func get_closed_day_choices(category_id: String, limit: int = 4) -> Array[Dictionary]:
	return GameDayContextScript.closed_day_choices(self, category_id, limit)


func get_market_context(limit: int = 30) -> Dictionary:
	return GameMarketStateScript.get_market_context(self, limit)


func submit_market_order(ticker: String, side: String, quantity: int) -> Dictionary:
	var result := GameMarketStateScript.submit_market_order(self, ticker, side, quantity)
	if bool(result.get(MarketDataKeysScript.KEY_OK, false)):
		run_statistics.record_positions(market.portfolio.positions)
		run_statistics.record_net_worth(status.get_net_worth())
	return result


func get_market_close_report() -> Dictionary:
	return GameMarketStateScript.get_market_close_report(self)


func get_market_open_report() -> Dictionary:
	return GameMarketStateScript.get_market_open_report(self)


func complete_today(selected_day_action_id: String = "", forced_event_ids: Array = [], suppress_random_night_events: bool = false) -> Dictionary:
	var day := calendar.get_day(day_index)
	var guard := GameDayCompletionGuardScript.evaluate(
		day,
		day_completed,
		last_day_result,
		status,
		is_first_tutorial_day(),
		get_total_held_quantity()
	)
	if not bool(guard.get(GameDayCompletionGuardScript.KEY_ALLOWED, false)):
		return guard.get(GameDayCompletionGuardScript.KEY_RESULT, {})

	return GameDayCompletionScript.complete(
		self,
		day,
		selected_day_action_id,
		forced_event_ids,
		suppress_random_night_events
	)


func sleep_to_next_day() -> Dictionary:
	return GameDayProgressScript.sleep_to_next_day(self)


func get_previous_trading_date() -> String:
	return GameMarketStateScript.previous_trading_date(self)


func get_character_asset_context() -> Dictionary:
	return GameDayContextScript.character_asset_context(self)


func resolve_protagonist_standing(outfit_id: String, expression_id: String) -> Dictionary:
	var day := calendar.get_day(day_index)
	var date := String(day.get(GameStateContextKeysScript.KEY_DATE, ""))
	var seasonal_outfit := CharacterOutfitSeasonScript.outfit_for_date(outfit_id, date)
	return character_assets.resolve_standing_asset(GameStateConfigScript.PROTAGONIST_CHARACTER_ID, seasonal_outfit, expression_id)


func is_first_tutorial_day() -> bool:
	var day := calendar.get_day(day_index)
	return String(day.get(GameStateContextKeysScript.KEY_DATE, "")) == FIRST_TUTORIAL_DATE and completed_days == 0 and not day_completed


func get_total_held_quantity() -> int:
	return market.portfolio.get_total_quantity()


func is_final_day() -> bool:
	return GameEndingScript.is_final_day(self)


func is_game_clear() -> bool:
	return GameEndingScript.is_game_clear(self)


func is_game_over() -> bool:
	return GameEndingScript.is_game_over(self)


func is_game_finished() -> bool:
	return GameEndingScript.is_game_finished(self)


func is_leverage_blessing_active() -> bool:
	return LeverageGoddessEventScript.is_blessing_active(self)


func get_game_over_reason() -> String:
	return GameEndingScript.game_over_reason(self)


func get_clear_reason() -> String:
	return GameEndingScript.clear_reason(self)


func simulate_day(life_action_id: String) -> Dictionary:
	var result := complete_today(life_action_id)
	if not result.get(GameStateGuardResultScript.KEY_OK, false):
		return result
	if not result.get(PlayerStatusKeysScript.KEY_GAME_OVER, false) and not result.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, false):
		result[SIMULATION_KEY_SLEEP] = sleep_to_next_day()
		result[SIMULATION_KEY_NEXT_DAY] = get_today_context()
	return result


func record_completed_events(day_events: Array, weekday_events: Array, night_events: Array) -> void:
	for event in day_events:
		if _append_event_history(Dictionary(event)):
			run_statistics.record_event()
	for event in weekday_events:
		if _append_event_history(Dictionary(event)):
			run_statistics.record_event()
	for event in night_events:
		if _append_event_history(Dictionary(event)):
			run_statistics.record_event()
	while event_history.size() > MAX_EVENT_HISTORY_ROWS:
		event_history.pop_front()


func has_seen_market_fixed_event(event_id: String) -> bool:
	return not event_id.is_empty() and bool(shown_market_fixed_event_ids.get(event_id, false))


func mark_market_fixed_event_seen(event_id: String) -> void:
	if event_id.is_empty():
		return
	shown_market_fixed_event_ids[event_id] = true


func has_applied_market_fixed_event(event_id: String) -> bool:
	return not event_id.is_empty() and bool(applied_market_fixed_event_ids.get(event_id, false))


func mark_market_fixed_event_applied(event_id: String) -> void:
	if event_id.is_empty():
		return
	applied_market_fixed_event_ids[event_id] = true


func _append_event_history(event: Dictionary) -> bool:
	var event_id := String(event.get(DayEventKeysScript.KEY_ID, ""))
	if event_id.is_empty():
		return false
	if String(event.get(DayEventKeysScript.KEY_CG_PATH, "")).is_empty() and event.get(DayEventKeysScript.KEY_DIALOGUE, []).is_empty():
		return false
	event_history.append({
		DayEventKeysScript.KEY_ID: event_id,
		DayEventKeysScript.KEY_NAME_KO: String(event.get(DayEventKeysScript.KEY_NAME_KO, "")),
		DayEventKeysScript.KEY_MODE: String(event.get(DayEventKeysScript.KEY_MODE, "")),
		DayEventKeysScript.KEY_TAGS: event.get(DayEventKeysScript.KEY_TAGS, []).duplicate(true),
		DayEventKeysScript.KEY_CG_PATH: String(event.get(DayEventKeysScript.KEY_CG_PATH, "")),
		DayEventKeysScript.KEY_COMPLETED_DAY: completed_days,
		DayEventKeysScript.KEY_SELECTED: true
	})
	return true


func to_save_dict() -> Dictionary:
	return GameStatePersistenceScript.to_save_dict(self)


func load_from_save_dict(data: Dictionary) -> Dictionary:
	return GameStatePersistenceScript.load_from_save_dict(self, data, DEFAULT_START_DATE)


func refresh_status_from_current_phase() -> void:
	GameMarketStateScript.sync_status_from_report(self, GameMarketStateScript.current_phase_report(self))


func get_event_random_seed() -> String:
	if event_branch_seed.is_empty():
		return random_seed
	return "%s:event_branch:%s" % [random_seed, event_branch_seed]


func refresh_event_branch_seed() -> void:
	event_branch_seed = _new_random_seed()


static func _new_random_seed() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return "%d:%d:%d" % [Time.get_unix_time_from_system(), Time.get_ticks_usec(), rng.randi()]
