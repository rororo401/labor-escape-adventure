class_name GameDayCompletion
extends RefCounted

const DayCompletionResultScript := preload("res://scripts/core/dayflow/day_completion_result.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const GameMarketStateScript := preload("res://scripts/core/market/game_market_state.gd")
const HealthResurrectionEventScript := preload("res://scripts/core/dayflow/health_resurrection_event.gd")
const LeverageGoddessEventScript := preload("res://scripts/core/dayflow/leverage_goddess_event.gd")
const MonthlySalaryEventScript := preload("res://scripts/core/dayflow/monthly_salary_event.gd")
const GameEndingScript := preload("res://scripts/core/game_ending.gd")
const GameRunStatisticsScript := preload("res://scripts/core/game_run_statistics.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")


static func complete(
	game,
	day: Dictionary,
	selected_day_action_id: String = "",
	forced_event_ids: Array = [],
	suppress_random_night_events: bool = false
) -> Dictionary:
	var plan: Dictionary = game.day_events.build_day_result(
		day,
		game.status.to_dict(),
		game.completed_days,
		selected_day_action_id,
		forced_event_ids,
		suppress_random_night_events,
		game.event_history,
		game.get_event_random_seed(),
		game.random_seed
	)
	var day_action: Dictionary = plan.get(DayEventKeysScript.KEY_DAY_ACTION, {})
	var weekday_events: Array = plan.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, [])
	_append_monthly_salary_event(weekday_events, day, game.event_history, String(game.difficulty))
	var night_events: Array = plan.get(DayEventKeysScript.KEY_NIGHT_EVENTS, [])
	var effect_seed_root := _effect_seed_root(game, day)
	var market_fixed_effect := _apply_market_fixed_event_once(game, day, "%s:market_fixed" % effect_seed_root)
	var day_effect := apply_event_effect(game, day_action, _event_effect_seed("%s:day_action" % effect_seed_root, day_action, 0))
	var weekday_effects := build_event_effect_rows(game, weekday_events, "%s:weekday" % effect_seed_root)
	var night_effects := build_event_effect_rows(game, night_events, "%s:night" % effect_seed_root)

	var end_of_day_effect: Dictionary = DayCompletionResultScript.empty_effect(game.status.to_dict())
	if not game.status.is_game_over():
		end_of_day_effect = game.status.apply_end_of_day_condition("%s:end_of_day" % effect_seed_root)
	_append_health_resurrection_events(
		game,
		night_events,
		night_effects,
		String(day.get(DayEventKeysScript.KEY_DATE, "")),
		"%s:resurrection" % effect_seed_root
	)
	game.market.set_cash_balance(game.status.cash)
	var close_report: Dictionary = game.market.get_close_report(GameMarketStateScript.pricing_date_for_day(game, day))
	GameMarketStateScript.sync_status_from_report(game, close_report)
	var leverage_bonus := _apply_leverage_profit_bonus(
		game,
		market_fixed_effect,
		day_effect,
		weekday_effects,
		night_effects,
		end_of_day_effect,
		effect_seed_root,
		close_report
	)
	var leverage_bonus_effect: Dictionary = leverage_bonus.get(DayEventKeysScript.KEY_EFFECT, {})
	close_report = leverage_bonus.get(DayEventKeysScript.KEY_MARKET_CLOSE_REPORT, close_report)
	_append_leverage_goddess_event(game, night_events, night_effects)
	game.run_statistics.record_net_worth(game.status.get_net_worth())
	game.run_statistics.record_positions(game.market.portfolio.positions)
	var completed_day_events: Array = [day_action]
	if not market_fixed_effect.is_empty():
		completed_day_events.append(Dictionary(market_fixed_effect.get(DayEventKeysScript.KEY_EVENT, {})))
	game.record_completed_events(completed_day_events, weekday_events, night_events)
	var game_over: bool = game.status.is_game_over()
	var game_over_reason: String = game.status.get_game_over_reason()
	var game_clear := false
	var clear_reason := ""
	var ending_state: Dictionary = {}
	if GameEndingScript.is_final_day(game) and not game_over:
		ending_state = GameEndingScript.final_completion_state(game.status)
		game_over = bool(ending_state.get(PlayerStatusKeysScript.KEY_GAME_OVER, false))
		game_over_reason = String(ending_state.get(PlayerStatusKeysScript.KEY_GAME_OVER_REASON, ""))
		game_clear = bool(ending_state.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, false))
		clear_reason = String(ending_state.get(PlayerStatusKeysScript.KEY_CLEAR_REASON, ""))

	game.last_day_result = DayCompletionResultScript.payload(
		day,
		day_action,
		day_effect,
		weekday_effects,
		night_effects,
		end_of_day_effect,
		close_report,
		_status_snapshot_for_result(game, ending_state),
		game_over,
		game_over_reason,
		game_clear,
		clear_reason,
		ending_state,
		market_fixed_effect,
		leverage_bonus_effect
	)
	var most_held_name := ""
	if not game.run_statistics.most_held_ticker.is_empty():
		most_held_name = game.market.catalog.get_display_name_by_ticker(game.run_statistics.most_held_ticker)
	var total_investment_profit := int(close_report.get(MarketDataKeysScript.KEY_REALIZED_PROFIT, 0)) + int(close_report.get(MarketDataKeysScript.KEY_UNREALIZED_PROFIT, 0))
	game.last_day_result[GameRunStatisticsScript.KEY_SAVE] = game.run_statistics.ending_snapshot(total_investment_profit, most_held_name)
	game.day_completed = true
	return game.last_day_result


static func _status_snapshot_for_result(game, ending_state: Dictionary) -> Dictionary:
	var snapshot: Dictionary = game.status.to_dict()
	snapshot[PlayerStatusKeysScript.KEY_TARGET_REACHED] = GameEndingScript.is_target_reached_status(game.status)
	if ending_state.is_empty():
		snapshot[PlayerStatusKeysScript.KEY_GAME_CLEAR] = false
		snapshot[PlayerStatusKeysScript.KEY_CLEAR_REASON] = ""
	else:
		snapshot[PlayerStatusKeysScript.KEY_GAME_CLEAR] = bool(ending_state.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, false))
		snapshot[PlayerStatusKeysScript.KEY_CLEAR_REASON] = String(ending_state.get(PlayerStatusKeysScript.KEY_CLEAR_REASON, ""))
		snapshot[PlayerStatusKeysScript.KEY_GAME_OVER] = bool(ending_state.get(PlayerStatusKeysScript.KEY_GAME_OVER, false))
		snapshot[PlayerStatusKeysScript.KEY_GAME_OVER_REASON] = String(ending_state.get(PlayerStatusKeysScript.KEY_GAME_OVER_REASON, ""))
		if ending_state.has(PlayerStatusKeysScript.KEY_ENDING_ROUTE):
			snapshot[PlayerStatusKeysScript.KEY_ENDING_ROUTE] = String(ending_state.get(PlayerStatusKeysScript.KEY_ENDING_ROUTE, ""))
			snapshot[PlayerStatusKeysScript.KEY_ENDING_TIER] = int(ending_state.get(PlayerStatusKeysScript.KEY_ENDING_TIER, 0))
			snapshot[PlayerStatusKeysScript.KEY_ENDING_TITLE_KO] = String(ending_state.get(PlayerStatusKeysScript.KEY_ENDING_TITLE_KO, ""))
	return snapshot


static func build_event_effect_rows(game, events: Array, effect_seed_group: String = "") -> Array[Dictionary]:
	var effect_rows: Array[Dictionary] = []
	for index in range(events.size()):
		var event_row := Dictionary(events[index])
		if not event_row.is_empty():
			effect_rows.append(DayCompletionResultScript.event_effect_row(
				event_row,
				apply_event_effect(game, event_row, _event_effect_seed(effect_seed_group, event_row, index))
			))
	return effect_rows


static func apply_event_effect(game, event: Dictionary, effect_seed: String = "") -> Dictionary:
	if event.is_empty():
		return DayCompletionResultScript.empty_effect(game.status.to_dict())
	return game.status.apply_effects(event.get(DayEventKeysScript.KEY_EFFECTS, {}), effect_seed)


static func _apply_market_fixed_event_once(game, day: Dictionary, effect_seed_group: String = "") -> Dictionary:
	var event: Dictionary = game.day_events.get_market_fixed_event(day)
	var event_id := String(event.get(DayEventKeysScript.KEY_ID, ""))
	if event_id.is_empty() or game.has_applied_market_fixed_event(event_id):
		return {}
	var effect := apply_event_effect(game, event, _event_effect_seed(effect_seed_group, event, 0))
	game.mark_market_fixed_event_applied(event_id)
	return DayCompletionResultScript.event_effect_row(event, effect)


static func _append_monthly_salary_event(weekday_events: Array, day: Dictionary, event_history: Array, difficulty: String) -> void:
	var salary_event := MonthlySalaryEventScript.event_for_day(day, event_history, difficulty)
	if not salary_event.is_empty():
		weekday_events.append(salary_event)


static func _append_health_resurrection_events(
	game,
	night_events: Array,
	night_effects: Array,
	date: String,
	effect_seed_group: String = ""
) -> void:
	if not HealthResurrectionEventScript.can_resurrect(game.status, bool(game.health_resurrection_used)):
		return

	var ghost_event := HealthResurrectionEventScript.ghost_event(date)
	var goddess_event := HealthResurrectionEventScript.goddess_event(date, game.status.to_dict())
	night_events.append(ghost_event)
	night_effects.append(DayCompletionResultScript.event_effect_row(
		ghost_event,
		DayCompletionResultScript.empty_effect(game.status.to_dict())
	))
	night_events.append(goddess_event)
	night_effects.append(DayCompletionResultScript.event_effect_row(
		goddess_event,
		apply_event_effect(game, goddess_event, _event_effect_seed(effect_seed_group, goddess_event, 1))
	))
	game.health_resurrection_used = true


static func _append_leverage_goddess_event(game, night_events: Array, night_effects: Array) -> void:
	if not LeverageGoddessEventScript.can_trigger(game):
		return
	var goddess_event := LeverageGoddessEventScript.event()
	night_events.append(goddess_event)
	night_effects.append(DayCompletionResultScript.event_effect_row(
		goddess_event,
		DayCompletionResultScript.empty_effect(game.status.to_dict())
	))
	LeverageGoddessEventScript.trigger(game)


static func _apply_leverage_profit_bonus(
	game,
	market_fixed_effect: Dictionary,
	day_effect: Dictionary,
	weekday_effects: Array,
	night_effects: Array,
	end_of_day_effect: Dictionary,
	effect_seed_root: String,
	close_report: Dictionary
) -> Dictionary:
	var empty_effect := DayCompletionResultScript.empty_effect(game.status.to_dict())
	if not LeverageGoddessEventScript.is_blessing_active(game):
		return {
			DayEventKeysScript.KEY_EFFECT: empty_effect,
			DayEventKeysScript.KEY_MARKET_CLOSE_REPORT: close_report
		}

	var external_delta := _effect_net_worth_delta(Dictionary(market_fixed_effect.get(DayEventKeysScript.KEY_EFFECT, {})))
	external_delta += _effect_net_worth_delta(day_effect)
	for row in weekday_effects:
		external_delta += _effect_net_worth_delta(Dictionary(Dictionary(row).get(DayEventKeysScript.KEY_EFFECT, {})))
	for row in night_effects:
		external_delta += _effect_net_worth_delta(Dictionary(Dictionary(row).get(DayEventKeysScript.KEY_EFFECT, {})))
	external_delta += _effect_net_worth_delta(end_of_day_effect)

	var bonus_amount := LeverageGoddessEventScript.profit_bonus(
		game.status.get_net_worth(),
		int(game.leverage_reference_net_worth),
		external_delta
	)
	var bonus_effect := empty_effect
	if bonus_amount > 0:
		bonus_effect = game.status.apply_effects(
			{PlayerStatusKeysScript.KEY_CASH_DELTA: bonus_amount},
			"%s:leverage_bonus" % effect_seed_root
		)
		game.market.set_cash_balance(game.status.cash)
		close_report = game.market.get_close_report(
			GameMarketStateScript.pricing_date_for_day(game, game.calendar.get_day(game.day_index))
		)
		GameMarketStateScript.sync_status_from_report(game, close_report)
	game.leverage_reference_net_worth = game.status.get_net_worth()
	return {
		DayEventKeysScript.KEY_EFFECT: bonus_effect,
		DayEventKeysScript.KEY_MARKET_CLOSE_REPORT: close_report
	}


static func _effect_net_worth_delta(effect: Dictionary) -> int:
	var delta: Dictionary = effect.get(PlayerStatusKeysScript.KEY_DELTA, {})
	return (
		int(delta.get(PlayerStatusKeysScript.KEY_CASH, 0))
		+ int(delta.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, 0))
	)


static func _effect_seed_root(game, day: Dictionary) -> String:
	var random_seed := String(game.random_seed)
	if game.has_method("get_event_random_seed"):
		random_seed = String(game.get_event_random_seed())
	return "%s:%s:%d:effects" % [
		random_seed,
		String(day.get(DayEventKeysScript.KEY_DATE, "")),
		int(game.completed_days)
	]


static func _event_effect_seed(effect_seed_group: String, event: Dictionary, index: int) -> String:
	if effect_seed_group.is_empty():
		return ""
	return "%s:%d:%s" % [
		effect_seed_group,
		index,
		String(event.get(DayEventKeysScript.KEY_ID, ""))
	]
