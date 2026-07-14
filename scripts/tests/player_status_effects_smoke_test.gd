extends "res://scripts/tests/test_scene_tree.gd"

const PlayerStatusScript := preload("res://scripts/core/player_status.gd")
const PlayerStatusEffectsScript := preload("res://scripts/core/player_status_effects.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")


func _initialize() -> void:
	_verify_effect_application_and_clamps()
	_verify_delta_ranges()
	_verify_fatigue_delta_balance()
	_verify_end_of_day_effect_selection()
	_verify_player_status_uses_effect_helper()
	_verify_seeded_effect_streams()

	print("Player status effects smoke test passed.")
	finish_test()


func _verify_effect_application_and_clamps() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var result := PlayerStatusEffectsScript.apply({
		PlayerStatusKeysScript.KEY_HEALTH: 98,
		PlayerStatusKeysScript.KEY_CASH: 1000,
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: 200,
		PlayerStatusKeysScript.KEY_MOOD: 2,
		PlayerStatusKeysScript.KEY_FATIGUE: 99
	}, {
		PlayerStatusKeysScript.KEY_CASH_DELTA: -2000,
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS_DELTA: 50,
		PlayerStatusKeysScript.KEY_HEALTH_DELTA: 10,
		PlayerStatusKeysScript.KEY_MOOD_DELTA: -5,
		PlayerStatusKeysScript.KEY_FATIGUE_DELTA: 5
	}, rng)

	_expect(int(result.get(PlayerStatusKeysScript.KEY_AFTER, {}).get(PlayerStatusKeysScript.KEY_CASH, -1)) == 0, "cash should clamp at zero")
	_expect(int(result.get(PlayerStatusKeysScript.KEY_AFTER, {}).get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, -1)) == 250, "investment assets should apply positive delta")
	_expect(int(result.get(PlayerStatusKeysScript.KEY_AFTER, {}).get(PlayerStatusKeysScript.KEY_HEALTH, -1)) == 100, "health should clamp at max")
	_expect(int(result.get(PlayerStatusKeysScript.KEY_AFTER, {}).get(PlayerStatusKeysScript.KEY_MOOD, -1)) == 0, "mood should clamp at zero")
	_expect(int(result.get(PlayerStatusKeysScript.KEY_AFTER, {}).get(PlayerStatusKeysScript.KEY_FATIGUE, -1)) == 100, "fatigue should clamp at max")
	_expect(int(result.get(PlayerStatusKeysScript.KEY_AFTER, {}).get(PlayerStatusKeysScript.KEY_NET_WORTH, -1)) == 250, "effect snapshots should include net worth")
	_expect(int(result.get(PlayerStatusKeysScript.KEY_DELTA, {}).get(PlayerStatusKeysScript.KEY_CASH, 99)) == -1000, "cash delta should reflect clamped movement")


func _verify_delta_ranges() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for _index in range(12):
		var value := PlayerStatusEffectsScript.resolve_effect_delta({PlayerStatusKeysScript.KEY_HEALTH_DELTA: [6, 3]}, PlayerStatusKeysScript.KEY_HEALTH_DELTA, rng)
		_expect(value >= 3 and value <= 6, "reversed ranges should resolve inside normalized bounds")

	var single := PlayerStatusEffectsScript.resolve_effect_delta({PlayerStatusKeysScript.KEY_MOOD_DELTA: [4]}, PlayerStatusKeysScript.KEY_MOOD_DELTA, rng)
	_expect(single == 4, "single-value ranges should resolve to the only value")

	var empty := PlayerStatusEffectsScript.resolve_effect_delta({PlayerStatusKeysScript.KEY_FATIGUE_DELTA: []}, PlayerStatusKeysScript.KEY_FATIGUE_DELTA, rng)
	_expect(empty == 0, "empty ranges should resolve to zero")


func _verify_fatigue_delta_balance() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	_expect(
		PlayerStatusEffectsScript.resolve_fatigue_delta({PlayerStatusKeysScript.KEY_FATIGUE_DELTA: 20}, rng) == 5,
		"positive fatigue should be softened"
	)
	_expect(
		PlayerStatusEffectsScript.resolve_fatigue_delta({PlayerStatusKeysScript.KEY_FATIGUE_DELTA: -10}, rng) == -20,
		"fatigue recovery should be stronger"
	)
	_expect(
		PlayerStatusEffectsScript.resolve_fatigue_delta({PlayerStatusKeysScript.KEY_FATIGUE_DELTA: 1}, rng) == 0,
		"minor positive fatigue should be ignored"
	)


func _verify_end_of_day_effect_selection() -> void:
	var tired := PlayerStatusEffectsScript.end_of_day_effects({PlayerStatusKeysScript.KEY_HEALTH: 100, PlayerStatusKeysScript.KEY_FATIGUE: 95})
	_expect(tired.has(PlayerStatusKeysScript.KEY_HEALTH_DELTA), "high fatigue should create a health penalty")
	_expect(tired.has(PlayerStatusKeysScript.KEY_MOOD_DELTA), "high fatigue should create a mood penalty")
	_expect(tired.has(PlayerStatusKeysScript.KEY_FATIGUE_DELTA), "sleep should still recover fatigue on high-fatigue days")

	var almost_tired := PlayerStatusEffectsScript.end_of_day_effects({PlayerStatusKeysScript.KEY_HEALTH: 100, PlayerStatusKeysScript.KEY_FATIGUE: 90})
	_expect(not almost_tired.has(PlayerStatusKeysScript.KEY_HEALTH_DELTA), "moderately high fatigue should not punish health immediately")
	_expect(not almost_tired.has(PlayerStatusKeysScript.KEY_MOOD_DELTA), "moderately high fatigue should not punish mood immediately")
	_expect(almost_tired.has(PlayerStatusKeysScript.KEY_FATIGUE_DELTA), "moderately high fatigue should still recover through sleep")

	var rested := PlayerStatusEffectsScript.end_of_day_effects({PlayerStatusKeysScript.KEY_HEALTH: 80, PlayerStatusKeysScript.KEY_FATIGUE: 10})
	_expect(rested.has(PlayerStatusKeysScript.KEY_HEALTH_DELTA), "low fatigue with missing health should create recovery")
	_expect(not rested.has(PlayerStatusKeysScript.KEY_MOOD_DELTA), "low fatigue recovery should not create mood effect")
	_expect(rested.has(PlayerStatusKeysScript.KEY_FATIGUE_DELTA), "sleep should recover remaining fatigue")

	var neutral := PlayerStatusEffectsScript.end_of_day_effects({PlayerStatusKeysScript.KEY_HEALTH: 100, PlayerStatusKeysScript.KEY_FATIGUE: 40})
	_expect(neutral.has(PlayerStatusKeysScript.KEY_FATIGUE_DELTA), "neutral days should still recover fatigue through sleep")


func _verify_player_status_uses_effect_helper() -> void:
	var status = PlayerStatusScript.new()
	status.rng.seed = 7
	var result: Dictionary = status.apply_effects({
		PlayerStatusKeysScript.KEY_CASH_DELTA: -6000000,
		PlayerStatusKeysScript.KEY_HEALTH_DELTA: [-2, -1],
		PlayerStatusKeysScript.KEY_MOOD_DELTA: [3, 5],
		PlayerStatusKeysScript.KEY_FATIGUE_DELTA: [12, 14]
	})

	_expect(status.cash == 0, "PlayerStatus should apply helper cash clamp")
	_expect(status.health >= 98 and status.health <= 99, "PlayerStatus should apply ranged health delta")
	_expect(status.mood >= 53 and status.mood <= 55, "PlayerStatus should apply ranged mood delta")
	_expect(status.fatigue >= 3 and status.fatigue <= 4, "PlayerStatus should apply softened ranged fatigue delta")
	_expect(int(result.get(PlayerStatusKeysScript.KEY_AFTER, {}).get(PlayerStatusKeysScript.KEY_CASH, -1)) == status.cash, "PlayerStatus result should match applied cash")
	_expect(int(result.get(PlayerStatusKeysScript.KEY_AFTER, {}).get(PlayerStatusKeysScript.KEY_NET_WORTH, -1)) == status.get_net_worth(), "PlayerStatus result should include updated net worth")


func _verify_seeded_effect_streams() -> void:
	var effects := {
		PlayerStatusKeysScript.KEY_HEALTH_DELTA: [-8, -1],
		PlayerStatusKeysScript.KEY_MOOD_DELTA: [-6, 6],
		PlayerStatusKeysScript.KEY_FATIGUE_DELTA: [4, 20]
	}
	var first = PlayerStatusScript.new()
	var repeated = PlayerStatusScript.new()
	var first_result: Dictionary = first.apply_effects(effects, "same-event-branch")
	var repeated_result: Dictionary = repeated.apply_effects(effects, "same-event-branch")
	_expect(first_result.get(PlayerStatusKeysScript.KEY_DELTA, {}) == repeated_result.get(PlayerStatusKeysScript.KEY_DELTA, {}), "the same event branch should resolve identical ranged effects")

	var changed := false
	for index in range(20):
		var branched = PlayerStatusScript.new()
		var branched_result: Dictionary = branched.apply_effects(effects, "event-branch-%d" % index)
		if branched_result.get(PlayerStatusKeysScript.KEY_DELTA, {}) != first_result.get(PlayerStatusKeysScript.KEY_DELTA, {}):
			changed = true
			break
	_expect(changed, "different event branches should be able to resolve different ranged effects")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
