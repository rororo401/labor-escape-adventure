class_name PlayerStatus
extends RefCounted

const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const PlayerStatusSnapshotScript := preload("res://scripts/core/player_status_snapshot.gd")
const PlayerStatusEffectsScript := preload("res://scripts/core/player_status_effects.gd")
const RandomSeedMixerScript := preload("res://scripts/core/random_seed_mixer.gd")

const MAX_HEALTH := PlayerStatusSnapshotScript.MAX_HEALTH
const MAX_MOOD := PlayerStatusSnapshotScript.MAX_MOOD
const MAX_FATIGUE := PlayerStatusSnapshotScript.MAX_FATIGUE
const START_HEALTH := PlayerStatusSnapshotScript.START_HEALTH
const START_CASH := PlayerStatusSnapshotScript.START_CASH
const START_INVESTMENT_ASSETS := PlayerStatusSnapshotScript.START_INVESTMENT_ASSETS
const START_MOOD := PlayerStatusSnapshotScript.START_MOOD
const START_FATIGUE := PlayerStatusSnapshotScript.START_FATIGUE
const TARGET_NET_WORTH := PlayerStatusSnapshotScript.TARGET_NET_WORTH

var health := START_HEALTH
var cash := START_CASH
var investment_assets := START_INVESTMENT_ASSETS
var mood := START_MOOD
var fatigue := START_FATIGUE
var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()


func reset() -> void:
	health = START_HEALTH
	cash = START_CASH
	investment_assets = START_INVESTMENT_ASSETS
	mood = START_MOOD
	fatigue = START_FATIGUE


func apply_effects(effects: Dictionary, effect_seed: String = "") -> Dictionary:
	var effect_rng := rng
	if not effect_seed.is_empty():
		effect_rng = RandomSeedMixerScript.rng_from_text(effect_seed)
	var result := PlayerStatusEffectsScript.apply(to_dict(), effects, effect_rng)
	_apply_effect_result(result)
	return result


func apply_end_of_day_condition(effect_seed: String = "") -> Dictionary:
	return apply_effects(PlayerStatusEffectsScript.end_of_day_effects(to_dict()), effect_seed)


func is_game_over() -> bool:
	return _is_insolvent() or health <= 0


func is_game_clear() -> bool:
	return PlayerStatusSnapshotScript.is_game_clear(cash, investment_assets)


func get_game_over_reason() -> String:
	if _is_insolvent():
		return PlayerStatusKeysScript.GAME_OVER_REASON_CASH_ZERO
	if health <= 0:
		return PlayerStatusKeysScript.GAME_OVER_REASON_HEALTH_ZERO
	return ""


func get_clear_reason() -> String:
	return PlayerStatusSnapshotScript.get_clear_reason(cash, investment_assets)


func get_net_worth() -> int:
	return PlayerStatusSnapshotScript.get_net_worth(cash, investment_assets)


func to_dict() -> Dictionary:
	return PlayerStatusSnapshotScript.to_dict(health, cash, investment_assets, mood, fatigue)


func load_from_dict(data: Dictionary) -> void:
	var normalized := PlayerStatusSnapshotScript.normalize(data)
	health = int(normalized.get(PlayerStatusKeysScript.KEY_HEALTH, START_HEALTH))
	cash = int(normalized.get(PlayerStatusKeysScript.KEY_CASH, START_CASH))
	investment_assets = int(normalized.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, START_INVESTMENT_ASSETS))
	mood = int(normalized.get(PlayerStatusKeysScript.KEY_MOOD, START_MOOD))
	fatigue = int(normalized.get(PlayerStatusKeysScript.KEY_FATIGUE, START_FATIGUE))


func _apply_effect_result(result: Dictionary) -> void:
	var after: Dictionary = result.get(PlayerStatusKeysScript.KEY_AFTER, {})
	health = int(after.get(PlayerStatusKeysScript.KEY_HEALTH, health))
	cash = int(after.get(PlayerStatusKeysScript.KEY_CASH, cash))
	investment_assets = int(after.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, investment_assets))
	mood = int(after.get(PlayerStatusKeysScript.KEY_MOOD, mood))
	fatigue = int(after.get(PlayerStatusKeysScript.KEY_FATIGUE, fatigue))


func _is_insolvent() -> bool:
	return cash <= 0 and investment_assets <= 0
