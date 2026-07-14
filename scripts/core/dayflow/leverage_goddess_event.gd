class_name LeverageGoddessEvent
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")

const EVENT_ID := "easy_leverage_goddess"
const CG_PATH := "res://assets/events/special/leverage_goddess/leverage_goddess_blessing.png"
const NET_WORTH_TRIGGER_MAX := 3000000
const BLESSING_DURATION_DAYS := 365


static func can_trigger(game) -> bool:
	return (
		game != null
		and String(game.difficulty) == GameDifficultyScript.EASY
		and not bool(game.leverage_goddess_used)
		and not game.status.is_game_over()
		and game.status.get_net_worth() <= NET_WORTH_TRIGGER_MAX
	)


static func trigger(game) -> void:
	game.leverage_goddess_used = true
	game.leverage_blessing_start_day_index = int(game.day_index) + 1
	game.leverage_blessing_end_day_index = int(game.leverage_blessing_start_day_index) + BLESSING_DURATION_DAYS
	game.leverage_reference_net_worth = game.status.get_net_worth()


static func is_blessing_active(game) -> bool:
	if (
		game == null
		or String(game.difficulty) != GameDifficultyScript.EASY
		or not bool(game.leverage_goddess_used)
	):
		return false
	var day_index := int(game.day_index)
	return (
		day_index >= int(game.leverage_blessing_start_day_index)
		and day_index < int(game.leverage_blessing_end_day_index)
	)


static func profit_bonus(current_net_worth: int, reference_net_worth: int, external_net_worth_delta: int) -> int:
	var market_profit := current_net_worth - reference_net_worth - external_net_worth_delta
	return maxi(0, market_profit)


static func event() -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: EVENT_ID,
		DayEventKeysScript.KEY_NAME_KO: "레버리지의 여신",
		DayEventKeysScript.KEY_SUMMARY_KO: "바닥까지 내려온 계좌 앞에 여신이 나타나, 한동안 오른 수익의 결실을 두 겹으로 만들어주겠다고 속삭인다.",
		DayEventKeysScript.KEY_MODE: "special_forced",
		DayEventKeysScript.KEY_TAGS: ["special", "easy", "leverage", "once"],
		DayEventKeysScript.KEY_RARITY: "once",
		DayEventKeysScript.KEY_CG_PATH: CG_PATH,
		DayEventKeysScript.KEY_DIALOGUE: [
			"계좌의 숫자가 삼백만 원 아래로 내려앉자, 화면의 빛이 이상하게 길어졌다.",
			"금빛 선 두 가닥 사이에서 낯선 여신이 웃었다. \"많이 지쳤구나. 잠시 내 힘을 빌려주마.\"",
			"\"앞으로 한동안, 네 자산이 벌어들인 좋은 결실에는 똑같은 그림자가 하나 더 따라붙을 거야.\"",
			"얼마나 오래냐고 묻자 여신은 대답 대신 창밖의 계절을 바라봤다. 꽤 긴 숨을 돌릴 시간은 생긴 것 같다."
		],
		DayEventKeysScript.KEY_EFFECTS: {}
	}
