class_name StandingCalibratorDisplayState
extends RefCounted

const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")

const INITIAL_HELP_TEXT := "방향키: 1px 이동 / Q,E: 이전,다음 / 숫자 1-9: 빠른 선택 / Enter: 현재 확정"
const SELECTED_HELP_TEXT := "방향키: 1px 이동 / Q,E: 이전,다음 / Enter: 현재 확정"


static func selected_index(requested_index: int, entry_count: int) -> int:
	if entry_count <= 0:
		return 0
	return clampi(requested_index, 0, entry_count - 1)


static func relative_index(current_index: int, delta: int, entry_count: int) -> int:
	if entry_count <= 0:
		return 0
	return (current_index + delta + entry_count) % entry_count


static func entry_label(index: int, entry_count: int, entry: Dictionary) -> String:
	return "%02d/%02d  %s  %s/%s" % [
		index + 1,
		entry_count,
		entry.get(CharacterAssetKeysScript.ENTRY_LABEL, ""),
		entry.get(CharacterAssetKeysScript.ENTRY_OUTFIT, ""),
		entry.get(CharacterAssetKeysScript.ENTRY_EXPRESSION, "")
	]


static func offset_label(offset: Vector2) -> String:
	return "x %d  y %d" % [int(offset.x), int(offset.y)]


static func reset_message() -> String:
	return "현재 스탠딩 오프셋을 0, 0으로 되돌렸다."


static func save_message(key: String, user_path: String, default_path: String) -> String:
	return "%s 저장 완료: %s / %s" % [key, user_path, default_path]
