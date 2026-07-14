extends "res://scripts/tests/test_scene_tree.gd"

const PlayerStatusScript := preload("res://scripts/core/player_status.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const PlayerStatusSnapshotScript := preload("res://scripts/core/player_status_snapshot.gd")


func _initialize() -> void:
	_verify_defaults_and_normalization()
	_verify_snapshot_goal_fields()
	_verify_player_status_uses_snapshot_rules()

	print("Player status snapshot smoke test passed.")
	finish_test()


func _verify_defaults_and_normalization() -> void:
	var defaults := PlayerStatusSnapshotScript.defaults()
	_expect(int(defaults.get(PlayerStatusKeysScript.KEY_HEALTH, 0)) == 100, "default health should be full")
	_expect(int(defaults.get(PlayerStatusKeysScript.KEY_CASH, 0)) == 5000000, "default cash should be seed money")

	var normalized := PlayerStatusSnapshotScript.normalize({
		PlayerStatusKeysScript.KEY_HEALTH: 150,
		PlayerStatusKeysScript.KEY_CASH: -10,
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: -20,
		PlayerStatusKeysScript.KEY_MOOD: -5,
		PlayerStatusKeysScript.KEY_FATIGUE: 200
	})
	_expect(int(normalized.get(PlayerStatusKeysScript.KEY_HEALTH, 0)) == 100, "health should clamp to max")
	_expect(int(normalized.get(PlayerStatusKeysScript.KEY_CASH, 99)) == 0, "cash should not restore below zero")
	_expect(int(normalized.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, 99)) == 0, "investment assets should not restore below zero")
	_expect(int(normalized.get(PlayerStatusKeysScript.KEY_MOOD, 99)) == 0, "mood should clamp to min")
	_expect(int(normalized.get(PlayerStatusKeysScript.KEY_FATIGUE, 0)) == 100, "fatigue should clamp to max")


func _verify_snapshot_goal_fields() -> void:
	var snapshot := PlayerStatusSnapshotScript.to_dict(80, 999999000, 1000, 55, 10)
	_expect(int(snapshot.get(PlayerStatusKeysScript.KEY_NET_WORTH, 0)) == 1000000000, "snapshot should calculate net worth")
	_expect(int(snapshot.get(PlayerStatusKeysScript.KEY_TARGET_REMAINING, -1)) == 0, "snapshot should clamp target remaining at zero")
	_expect(bool(snapshot.get(PlayerStatusKeysScript.KEY_TARGET_REACHED, false)), "snapshot should mark target reached at 1 billion")
	_expect(bool(snapshot.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, false)), "snapshot should mark clear at 1 billion")
	_expect(snapshot.get(PlayerStatusKeysScript.KEY_CLEAR_REASON, "") == PlayerStatusKeysScript.CLEAR_REASON_TARGET_NET_WORTH, "snapshot should include clear reason")

	var not_clear := PlayerStatusSnapshotScript.to_dict(80, 1000, 2000, 55, 10)
	_expect(not bool(not_clear.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, true)), "snapshot should not clear below target")
	_expect(not_clear.get(PlayerStatusKeysScript.KEY_CLEAR_REASON, "bad") == "", "snapshot should omit clear reason below target")


func _verify_player_status_uses_snapshot_rules() -> void:
	var status = PlayerStatusScript.new()
	status.load_from_dict({
		PlayerStatusKeysScript.KEY_HEALTH: -10,
		PlayerStatusKeysScript.KEY_CASH: -1,
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: 1000000000,
		PlayerStatusKeysScript.KEY_MOOD: 120,
		PlayerStatusKeysScript.KEY_FATIGUE: -3
	})

	_expect(status.health == 0, "PlayerStatus load should clamp health")
	_expect(status.cash == 0, "PlayerStatus load should clamp cash")
	_expect(status.investment_assets == 1000000000, "PlayerStatus load should keep positive investment assets")
	_expect(status.mood == 100, "PlayerStatus load should clamp mood")
	_expect(status.fatigue == 0, "PlayerStatus load should clamp fatigue")
	_expect(status.is_game_clear(), "PlayerStatus should use snapshot clear rule")
	_expect(status.to_dict().get(PlayerStatusKeysScript.KEY_CLEAR_REASON, "") == PlayerStatusKeysScript.CLEAR_REASON_TARGET_NET_WORTH, "PlayerStatus snapshot should include clear reason")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
