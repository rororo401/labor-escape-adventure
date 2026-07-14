class_name PlayerStatusEffects
extends RefCounted

const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const PlayerStatusSnapshotScript := preload("res://scripts/core/player_status_snapshot.gd")

const FATIGUE_GAIN_MULTIPLIER := 0.25
const FATIGUE_RECOVERY_MULTIPLIER := 2.0
const MINOR_FATIGUE_GAIN_MAX := 2
const SLEEP_FATIGUE_RECOVERY_DELTA := [-2, -1]
const HIGH_FATIGUE_PENALTY_THRESHOLD := 95
const LOW_FATIGUE_RECOVERY_THRESHOLD := 35


static func apply(current: Dictionary, effects: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var before := PlayerStatusSnapshotScript.normalize(current)
	var after := {
		PlayerStatusKeysScript.KEY_CASH: maxi(0, int(before.get(PlayerStatusKeysScript.KEY_CASH, 0)) + int(effects.get(PlayerStatusKeysScript.KEY_CASH_DELTA, 0))),
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: maxi(0, int(before.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, 0)) + int(effects.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS_DELTA, 0))),
		PlayerStatusKeysScript.KEY_HEALTH: clampi(int(before.get(PlayerStatusKeysScript.KEY_HEALTH, 0)) + resolve_effect_delta(effects, PlayerStatusKeysScript.KEY_HEALTH_DELTA, rng), 0, PlayerStatusSnapshotScript.MAX_HEALTH),
		PlayerStatusKeysScript.KEY_MOOD: clampi(int(before.get(PlayerStatusKeysScript.KEY_MOOD, 0)) + resolve_effect_delta(effects, PlayerStatusKeysScript.KEY_MOOD_DELTA, rng), 0, PlayerStatusSnapshotScript.MAX_MOOD),
		PlayerStatusKeysScript.KEY_FATIGUE: clampi(int(before.get(PlayerStatusKeysScript.KEY_FATIGUE, 0)) + resolve_fatigue_delta(effects, rng), 0, PlayerStatusSnapshotScript.MAX_FATIGUE)
	}

	return result(_snapshot(before), _snapshot(after))


static func end_of_day_effects(current: Dictionary) -> Dictionary:
	var fatigue := int(current.get(PlayerStatusKeysScript.KEY_FATIGUE, PlayerStatusSnapshotScript.START_FATIGUE))
	var health := int(current.get(PlayerStatusKeysScript.KEY_HEALTH, PlayerStatusSnapshotScript.START_HEALTH))
	var effects := {}
	if fatigue > 0:
		effects[PlayerStatusKeysScript.KEY_FATIGUE_DELTA] = SLEEP_FATIGUE_RECOVERY_DELTA
	if fatigue >= HIGH_FATIGUE_PENALTY_THRESHOLD:
		effects[PlayerStatusKeysScript.KEY_HEALTH_DELTA] = [-3, -1]
		effects[PlayerStatusKeysScript.KEY_MOOD_DELTA] = [-2, -1]
		return effects
	if fatigue <= LOW_FATIGUE_RECOVERY_THRESHOLD and health < PlayerStatusSnapshotScript.MAX_HEALTH:
		effects[PlayerStatusKeysScript.KEY_HEALTH_DELTA] = [1, 2]
	return effects


static func result(before: Dictionary, after: Dictionary) -> Dictionary:
	var normalized_before := PlayerStatusSnapshotScript.normalize(before)
	var normalized_after := PlayerStatusSnapshotScript.normalize(after)
	return {
		PlayerStatusKeysScript.KEY_BEFORE: _snapshot(normalized_before),
		PlayerStatusKeysScript.KEY_AFTER: _snapshot(normalized_after),
		PlayerStatusKeysScript.KEY_DELTA: {
			PlayerStatusKeysScript.KEY_CASH: int(normalized_after.get(PlayerStatusKeysScript.KEY_CASH, 0)) - int(normalized_before.get(PlayerStatusKeysScript.KEY_CASH, 0)),
			PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: int(normalized_after.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, 0)) - int(normalized_before.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, 0)),
			PlayerStatusKeysScript.KEY_HEALTH: int(normalized_after.get(PlayerStatusKeysScript.KEY_HEALTH, 0)) - int(normalized_before.get(PlayerStatusKeysScript.KEY_HEALTH, 0)),
			PlayerStatusKeysScript.KEY_MOOD: int(normalized_after.get(PlayerStatusKeysScript.KEY_MOOD, 0)) - int(normalized_before.get(PlayerStatusKeysScript.KEY_MOOD, 0)),
			PlayerStatusKeysScript.KEY_FATIGUE: int(normalized_after.get(PlayerStatusKeysScript.KEY_FATIGUE, 0)) - int(normalized_before.get(PlayerStatusKeysScript.KEY_FATIGUE, 0))
		}
	}


static func resolve_effect_delta(effects: Dictionary, key: String, rng: RandomNumberGenerator) -> int:
	var value = effects.get(key, 0)
	if typeof(value) != TYPE_ARRAY:
		return int(value)

	var range: Array = value
	if range.is_empty():
		return 0
	if range.size() == 1:
		return int(range[0])

	var minimum := int(range[0])
	var maximum := int(range[1])
	if minimum > maximum:
		var swapped := minimum
		minimum = maximum
		maximum = swapped
	return rng.randi_range(minimum, maximum)


static func resolve_fatigue_delta(effects: Dictionary, rng: RandomNumberGenerator) -> int:
	var raw_delta := resolve_effect_delta(effects, PlayerStatusKeysScript.KEY_FATIGUE_DELTA, rng)
	if raw_delta > 0:
		if raw_delta <= MINOR_FATIGUE_GAIN_MAX:
			return 0
		return maxi(1, int(round(float(raw_delta) * FATIGUE_GAIN_MULTIPLIER)))
	if raw_delta < 0:
		return mini(-1, int(round(float(raw_delta) * FATIGUE_RECOVERY_MULTIPLIER)))
	return 0


static func _snapshot(status: Dictionary) -> Dictionary:
	return PlayerStatusSnapshotScript.to_dict(
		int(status.get(PlayerStatusKeysScript.KEY_HEALTH, PlayerStatusSnapshotScript.START_HEALTH)),
		int(status.get(PlayerStatusKeysScript.KEY_CASH, PlayerStatusSnapshotScript.START_CASH)),
		int(status.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, PlayerStatusSnapshotScript.START_INVESTMENT_ASSETS)),
		int(status.get(PlayerStatusKeysScript.KEY_MOOD, PlayerStatusSnapshotScript.START_MOOD)),
		int(status.get(PlayerStatusKeysScript.KEY_FATIGUE, PlayerStatusSnapshotScript.START_FATIGUE))
	)
