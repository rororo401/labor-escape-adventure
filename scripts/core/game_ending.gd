class_name GameEnding
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const PlayerStatusSnapshotScript := preload("res://scripts/core/player_status_snapshot.gd")

const CLEAR_ENDING_ROUTE := "clear_ending_target_net_worth"
const BAD_ENDING_01_ROUTE := "bad_ending_01_barely_left"
const BAD_ENDING_02_ROUTE := "bad_ending_02_small_savings"
const BAD_ENDING_03_ROUTE := "bad_ending_03_stable_worker"
const BAD_ENDING_04_ROUTE := "bad_ending_04_almost_free"
const BAD_ENDING_05_ROUTE := "bad_ending_05_near_miss"

const BAD_ENDING_01_TITLE := "거의 남지 않은 통장"
const BAD_ENDING_02_TITLE := "작은 저축의 끝"
const BAD_ENDING_03_TITLE := "버텨낸 생활"
const BAD_ENDING_04_TITLE := "꽤 가까웠던 자유"
const BAD_ENDING_05_TITLE := "한 발 모자란 탈출"

const BAD_ENDING_02_MIN_NET_WORTH := 10000000
const BAD_ENDING_03_MIN_NET_WORTH := 50000000
const BAD_ENDING_04_MIN_NET_WORTH := 200000000
const BAD_ENDING_05_MIN_NET_WORTH := 500000000


static func is_final_day(game) -> bool:
	if game == null or game.calendar == null:
		return false
	return game.calendar.count() > 0 and int(game.day_index) >= game.calendar.count() - 1


static func is_final_result_ready(game) -> bool:
	return is_final_day(game) and bool(game.day_completed)


static func is_target_reached_status(status) -> bool:
	return status != null and status.get_net_worth() >= PlayerStatusSnapshotScript.TARGET_NET_WORTH


static func is_game_clear(game) -> bool:
	return is_final_result_ready(game) and is_target_reached_status(game.status)


static func is_final_bad_ending(game) -> bool:
	return is_final_result_ready(game) and not is_target_reached_status(game.status) and not game.status.is_game_over()


static func is_game_over(game) -> bool:
	if game == null:
		return false
	return game.status.is_game_over() or is_final_bad_ending(game)


static func is_game_finished(game) -> bool:
	return is_game_clear(game) or is_game_over(game)


static func clear_reason(game) -> String:
	return PlayerStatusKeysScript.CLEAR_REASON_TARGET_NET_WORTH if is_game_clear(game) else ""


static func game_over_reason(game) -> String:
	if game == null:
		return ""
	if game.status.is_game_over():
		return game.status.get_game_over_reason()
	if is_final_bad_ending(game):
		return PlayerStatusKeysScript.GAME_OVER_REASON_FINAL_BAD_ENDING
	return ""


static func final_completion_state(status) -> Dictionary:
	var snapshot: Dictionary = status.to_dict()
	var net_worth := int(snapshot.get(PlayerStatusKeysScript.KEY_NET_WORTH, 0))
	var target_reached := net_worth >= PlayerStatusSnapshotScript.TARGET_NET_WORTH
	if target_reached:
		return {
			PlayerStatusKeysScript.KEY_GAME_CLEAR: true,
			PlayerStatusKeysScript.KEY_CLEAR_REASON: PlayerStatusKeysScript.CLEAR_REASON_TARGET_NET_WORTH,
			PlayerStatusKeysScript.KEY_GAME_OVER: false,
			PlayerStatusKeysScript.KEY_GAME_OVER_REASON: "",
			DayEventKeysScript.KEY_GAME_FINISHED: true,
			PlayerStatusKeysScript.KEY_ENDING_ROUTE: CLEAR_ENDING_ROUTE,
			PlayerStatusKeysScript.KEY_ENDING_TIER: 0,
			PlayerStatusKeysScript.KEY_ENDING_TITLE_KO: "10억, 진짜 찍었다!"
		}

	var bad_route := bad_ending_route(net_worth)
	return {
		PlayerStatusKeysScript.KEY_GAME_CLEAR: false,
		PlayerStatusKeysScript.KEY_CLEAR_REASON: "",
		PlayerStatusKeysScript.KEY_GAME_OVER: true,
		PlayerStatusKeysScript.KEY_GAME_OVER_REASON: PlayerStatusKeysScript.GAME_OVER_REASON_FINAL_BAD_ENDING,
		DayEventKeysScript.KEY_GAME_FINISHED: true,
		PlayerStatusKeysScript.KEY_ENDING_ROUTE: bad_route,
		PlayerStatusKeysScript.KEY_ENDING_TIER: bad_ending_tier(net_worth),
		PlayerStatusKeysScript.KEY_ENDING_TITLE_KO: bad_ending_title(bad_route)
	}


static func active_ending_state(game) -> Dictionary:
	if game == null:
		return {}
	if game.status.is_game_over():
		return {
			PlayerStatusKeysScript.KEY_GAME_CLEAR: false,
			PlayerStatusKeysScript.KEY_CLEAR_REASON: "",
			PlayerStatusKeysScript.KEY_GAME_OVER: true,
			PlayerStatusKeysScript.KEY_GAME_OVER_REASON: game.status.get_game_over_reason(),
			DayEventKeysScript.KEY_GAME_FINISHED: true
		}
	if not is_final_result_ready(game):
		return {
			PlayerStatusKeysScript.KEY_GAME_CLEAR: false,
			PlayerStatusKeysScript.KEY_CLEAR_REASON: "",
			PlayerStatusKeysScript.KEY_GAME_OVER: false,
			PlayerStatusKeysScript.KEY_GAME_OVER_REASON: "",
			DayEventKeysScript.KEY_GAME_FINISHED: false
		}
	return final_completion_state(game.status)


static func status_snapshot(game) -> Dictionary:
	if game == null:
		return {}
	var snapshot: Dictionary = game.status.to_dict()
	var ending := active_ending_state(game)
	snapshot[PlayerStatusKeysScript.KEY_TARGET_REACHED] = is_target_reached_status(game.status)
	snapshot[PlayerStatusKeysScript.KEY_GAME_CLEAR] = bool(ending.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, false))
	snapshot[PlayerStatusKeysScript.KEY_CLEAR_REASON] = String(ending.get(PlayerStatusKeysScript.KEY_CLEAR_REASON, ""))
	snapshot[PlayerStatusKeysScript.KEY_GAME_OVER] = bool(ending.get(PlayerStatusKeysScript.KEY_GAME_OVER, false))
	snapshot[PlayerStatusKeysScript.KEY_GAME_OVER_REASON] = String(ending.get(PlayerStatusKeysScript.KEY_GAME_OVER_REASON, ""))
	if ending.has(PlayerStatusKeysScript.KEY_ENDING_ROUTE):
		snapshot[PlayerStatusKeysScript.KEY_ENDING_ROUTE] = String(ending.get(PlayerStatusKeysScript.KEY_ENDING_ROUTE, ""))
		snapshot[PlayerStatusKeysScript.KEY_ENDING_TIER] = int(ending.get(PlayerStatusKeysScript.KEY_ENDING_TIER, 0))
		snapshot[PlayerStatusKeysScript.KEY_ENDING_TITLE_KO] = String(ending.get(PlayerStatusKeysScript.KEY_ENDING_TITLE_KO, ""))
	return snapshot


static func bad_ending_route(net_worth: int) -> String:
	if net_worth >= BAD_ENDING_05_MIN_NET_WORTH:
		return BAD_ENDING_05_ROUTE
	if net_worth >= BAD_ENDING_04_MIN_NET_WORTH:
		return BAD_ENDING_04_ROUTE
	if net_worth >= BAD_ENDING_03_MIN_NET_WORTH:
		return BAD_ENDING_03_ROUTE
	if net_worth >= BAD_ENDING_02_MIN_NET_WORTH:
		return BAD_ENDING_02_ROUTE
	return BAD_ENDING_01_ROUTE


static func bad_ending_tier(net_worth: int) -> int:
	match bad_ending_route(net_worth):
		BAD_ENDING_05_ROUTE:
			return 5
		BAD_ENDING_04_ROUTE:
			return 4
		BAD_ENDING_03_ROUTE:
			return 3
		BAD_ENDING_02_ROUTE:
			return 2
		_:
			return 1


static func bad_ending_title(route: String) -> String:
	match route:
		BAD_ENDING_05_ROUTE:
			return BAD_ENDING_05_TITLE
		BAD_ENDING_04_ROUTE:
			return BAD_ENDING_04_TITLE
		BAD_ENDING_03_ROUTE:
			return BAD_ENDING_03_TITLE
		BAD_ENDING_02_ROUTE:
			return BAD_ENDING_02_TITLE
		_:
			return BAD_ENDING_01_TITLE
