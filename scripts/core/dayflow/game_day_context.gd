class_name GameDayContext
extends RefCounted

const GameStateContextScript := preload("res://scripts/core/game_state_context.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const CharacterOutfitSeasonScript := preload("res://scripts/core/character_outfit_season.gd")
const GameEndingScript := preload("res://scripts/core/game_ending.gd")


static func today_context(game) -> Dictionary:
	var day: Dictionary = current_day(game)
	if day.is_empty():
		return {}

	return GameStateContextScript.today_context(
		day,
		game.get_market_context(),
		day_flow_context(game),
		available_life_actions(game),
		character_asset_context(game),
		GameEndingScript.status_snapshot(game),
		GameEndingScript.is_game_over(game),
		GameEndingScript.game_over_reason(game),
		GameEndingScript.is_game_clear(game),
		GameEndingScript.clear_reason(game)
	)


static func available_life_actions(game) -> Array[Dictionary]:
	var day: Dictionary = current_day(game)
	if day.is_empty():
		return []
	var actions: Array[Dictionary] = []
	actions.assign(game.day_events.get_available_life_actions(
		day,
		game.status.to_dict(),
		game.get_event_random_seed(),
		game.random_seed
	))
	return actions


static func day_flow_context(game) -> Dictionary:
	var day: Dictionary = current_day(game)
	if day.is_empty():
		return {}
	return GameStateContextScript.day_flow_context(
		game.day_events.get_day_flow_context(
			day,
			game.status.to_dict(),
			game.completed_days,
			game.event_history,
			game.get_event_random_seed(),
			game.random_seed
		),
		bool(game.day_completed),
		game.last_day_result
	)


static func closed_day_categories(game) -> Array[Dictionary]:
	var day: Dictionary = current_day(game)
	if day.is_empty():
		return []
	return game.day_events.get_available_day_categories(
		day,
		game.status.to_dict(),
		game.get_event_random_seed(),
		game.random_seed
	)


static func closed_day_choices(game, category_id: String, limit: int = 4) -> Array[Dictionary]:
	var day: Dictionary = current_day(game)
	if day.is_empty():
		return []
	return game.day_events.get_random_day_choices(
		day,
		game.status.to_dict(),
		category_id,
		game.completed_days,
		limit,
		game.event_history,
		game.get_event_random_seed(),
		game.random_seed
	)


static func character_asset_context(game) -> Dictionary:
	var day := current_day(game)
	var date := String(day.get(GameStateContextKeysScript.KEY_DATE, ""))
	var default_outfit := CharacterOutfitSeasonScript.outfit_for_date(
		GameStateConfigScript.DEFAULT_PROTAGONIST_OUTFIT_ID,
		date
	)
	return {
		GameStateConfigScript.PROTAGONIST_CHARACTER_ID: game.character_assets.get_character_asset_context(
			GameStateConfigScript.PROTAGONIST_CHARACTER_ID,
			default_outfit,
			GameStateConfigScript.DEFAULT_PROTAGONIST_EXPRESSION_ID
		)
	}


static func current_day(game) -> Dictionary:
	if game == null:
		return {}
	return game.calendar.get_day(game.day_index)
