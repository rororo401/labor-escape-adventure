class_name HealthResurrectionEvent
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const PlayerStatusSnapshotScript := preload("res://scripts/core/player_status_snapshot.gd")
const CharacterOutfitSeasonScript := preload("res://scripts/core/character_outfit_season.gd")

const GHOST_EVENT_ID := "health_resurrection_ghost"
const GODDESS_EVENT_ID := "health_resurrection_goddess"
const GHOST_CG_PATH_SUMMER := "res://assets/events/special/health_resurrection/health_zero_ghost_summer.png"
const GHOST_CG_PATH_WINTER := "res://assets/events/special/health_resurrection/health_zero_ghost_winter.png"
const GODDESS_CG_PATH_SUMMER := "res://assets/events/special/health_resurrection/goddess_second_chance_summer.png"
const GODDESS_CG_PATH_WINTER := "res://assets/events/special/health_resurrection/goddess_second_chance_winter.png"

const REVIVE_HEALTH_PERCENT_NUMERATOR := 1
const REVIVE_HEALTH_PERCENT_DENOMINATOR := 2
const REVIVE_MOOD_DELTA := 8
const REVIVE_FATIGUE_DELTA := -45


static func can_resurrect(status, already_used: bool) -> bool:
	return (
		not already_used
		and status != null
		and status.get_game_over_reason() == PlayerStatusKeysScript.GAME_OVER_REASON_HEALTH_ZERO
	)


static func ghost_event(date: String = "") -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: GHOST_EVENT_ID,
		DayEventKeysScript.KEY_NAME_KO: "건강 악화",
		DayEventKeysScript.KEY_SUMMARY_KO: "무리한 생활 끝에 몸이 버티지 못하고, 영혼이 잠깐 몸 밖으로 빠져나온다.",
		DayEventKeysScript.KEY_MODE: "special_forced",
		DayEventKeysScript.KEY_TAGS: ["special", "health", "resurrection"],
		DayEventKeysScript.KEY_RARITY: "once",
		DayEventKeysScript.KEY_CG_PATH: ghost_cg_path_for_date(date),
		DayEventKeysScript.KEY_DIALOGUE: [
			"책상 위의 불빛이 멀어지고, 몸이 납처럼 무거워졌다.",
			"다음 순간 나는 내 등을 내려다보고 있었다. 말도 안 되게 투명한 손끝이 떨렸다.",
			"건강을 숫자로만 보던 대가가, 생각보다 훨씬 가까운 곳에 와 있었다."
		],
		DayEventKeysScript.KEY_EFFECTS: {}
	}


static func goddess_event(date: String = "", current_status: Dictionary = {}) -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: GODDESS_EVENT_ID,
		DayEventKeysScript.KEY_NAME_KO: "여신님의 한 번뿐인 경고",
		DayEventKeysScript.KEY_SUMMARY_KO: "여신님이 한 번만 기회를 주며 앞으로는 건강하게 지내라고 당부한다.",
		DayEventKeysScript.KEY_MODE: "special_forced",
		DayEventKeysScript.KEY_TAGS: ["special", "health", "resurrection"],
		DayEventKeysScript.KEY_RARITY: "once",
		DayEventKeysScript.KEY_CG_PATH: goddess_cg_path_for_date(date),
		DayEventKeysScript.KEY_DIALOGUE: [
			"빛 속에서 누군가가 손을 내밀었다. 이상하게도 무섭지 않았다.",
			"\"아직 끝낼 때는 아니란다. 하지만 다음에는 내가 붙잡아줄 수 없어.\"",
			"\"돈도 목표도 중요하지만, 네 몸이 먼저야. 앞으로는 건강하게 지내렴.\"",
			"눈을 뜨자 방의 공기가 다시 폐 안으로 들어왔다. 큰일 날 뻔했다. 이제는 정말 조심하자."
		],
		DayEventKeysScript.KEY_EFFECTS: revive_effects(current_status)
	}


static func ghost_cg_path_for_date(date: String) -> String:
	return GHOST_CG_PATH_SUMMER if CharacterOutfitSeasonScript.is_summer_date(date) else GHOST_CG_PATH_WINTER


static func goddess_cg_path_for_date(date: String) -> String:
	return GODDESS_CG_PATH_SUMMER if CharacterOutfitSeasonScript.is_summer_date(date) else GODDESS_CG_PATH_WINTER


static func revive_health_target() -> int:
	return int(PlayerStatusSnapshotScript.MAX_HEALTH * REVIVE_HEALTH_PERCENT_NUMERATOR / REVIVE_HEALTH_PERCENT_DENOMINATOR)


static func revive_effects(current_status: Dictionary = {}) -> Dictionary:
	var current_health := clampi(
		int(current_status.get(PlayerStatusKeysScript.KEY_HEALTH, 0)),
		0,
		PlayerStatusSnapshotScript.MAX_HEALTH
	)
	return {
		PlayerStatusKeysScript.KEY_HEALTH_DELTA: maxi(0, revive_health_target() - current_health),
		PlayerStatusKeysScript.KEY_MOOD_DELTA: REVIVE_MOOD_DELTA,
		PlayerStatusKeysScript.KEY_FATIGUE_DELTA: REVIVE_FATIGUE_DELTA
	}
