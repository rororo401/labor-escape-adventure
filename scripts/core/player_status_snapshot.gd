class_name PlayerStatusSnapshot
extends RefCounted

const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")

const MAX_HEALTH := 100
const MAX_MOOD := 100
const MAX_FATIGUE := 100
const START_HEALTH := 100
const START_CASH := 5000000
const START_INVESTMENT_ASSETS := 0
const START_MOOD := 50
const START_FATIGUE := 0
const TARGET_NET_WORTH := 1000000000


static func defaults() -> Dictionary:
	return {
		PlayerStatusKeysScript.KEY_HEALTH: START_HEALTH,
		PlayerStatusKeysScript.KEY_CASH: START_CASH,
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: START_INVESTMENT_ASSETS,
		PlayerStatusKeysScript.KEY_MOOD: START_MOOD,
		PlayerStatusKeysScript.KEY_FATIGUE: START_FATIGUE
	}


static func normalize(data: Dictionary) -> Dictionary:
	return {
		PlayerStatusKeysScript.KEY_HEALTH: clampi(int(data.get(PlayerStatusKeysScript.KEY_HEALTH, START_HEALTH)), 0, MAX_HEALTH),
		PlayerStatusKeysScript.KEY_CASH: maxi(0, int(data.get(PlayerStatusKeysScript.KEY_CASH, START_CASH))),
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: maxi(0, int(data.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, START_INVESTMENT_ASSETS))),
		PlayerStatusKeysScript.KEY_MOOD: clampi(int(data.get(PlayerStatusKeysScript.KEY_MOOD, START_MOOD)), 0, MAX_MOOD),
		PlayerStatusKeysScript.KEY_FATIGUE: clampi(int(data.get(PlayerStatusKeysScript.KEY_FATIGUE, START_FATIGUE)), 0, MAX_FATIGUE)
	}


static func to_dict(health: int, cash: int, investment_assets: int, mood: int, fatigue: int) -> Dictionary:
	var net_worth := get_net_worth(cash, investment_assets)
	return {
		PlayerStatusKeysScript.KEY_HEALTH: health,
		PlayerStatusKeysScript.KEY_CASH: cash,
		PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: investment_assets,
		PlayerStatusKeysScript.KEY_MOOD: mood,
		PlayerStatusKeysScript.KEY_FATIGUE: fatigue,
		PlayerStatusKeysScript.KEY_NET_WORTH: net_worth,
		PlayerStatusKeysScript.KEY_TARGET_NET_WORTH: TARGET_NET_WORTH,
		PlayerStatusKeysScript.KEY_TARGET_REMAINING: maxi(0, TARGET_NET_WORTH - net_worth),
		PlayerStatusKeysScript.KEY_TARGET_REACHED: is_game_clear(cash, investment_assets),
		PlayerStatusKeysScript.KEY_GAME_CLEAR: is_game_clear(cash, investment_assets),
		PlayerStatusKeysScript.KEY_CLEAR_REASON: get_clear_reason(cash, investment_assets)
	}


static func get_net_worth(cash: int, investment_assets: int) -> int:
	return cash + investment_assets


static func is_game_clear(cash: int, investment_assets: int) -> bool:
	return get_net_worth(cash, investment_assets) >= TARGET_NET_WORTH


static func get_clear_reason(cash: int, investment_assets: int) -> String:
	if is_game_clear(cash, investment_assets):
		return PlayerStatusKeysScript.CLEAR_REASON_TARGET_NET_WORTH
	return ""
