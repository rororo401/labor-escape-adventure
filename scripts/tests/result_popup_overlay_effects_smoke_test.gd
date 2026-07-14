extends "res://scripts/tests/test_scene_tree.gd"

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultPopupOverlayScript := preload("res://scripts/ui/result_popup_overlay.gd")


func _initialize() -> void:
	var overlay = ResultPopupOverlayScript.new()
	var result := {
		DayEventKeysScript.KEY_MARKET_FIXED_EFFECT: _event_effect("시장 충격 뉴스", -5, 7),
		DayEventKeysScript.KEY_DAY_ACTION: _event_effect("회사 업무", 2, 3),
		DayEventKeysScript.KEY_WEEKDAY_EVENTS: [],
		DayEventKeysScript.KEY_NIGHT_EVENTS: [],
		DayEventKeysScript.KEY_END_OF_DAY_EFFECT: {
			PlayerStatusKeysScript.KEY_DELTA: {
				PlayerStatusKeysScript.KEY_MOOD: -1,
				PlayerStatusKeysScript.KEY_FATIGUE: 4
			}
		}
	}

	var total: Dictionary = overlay.call("_total_delta", result)
	_expect(int(total.get(PlayerStatusKeysScript.KEY_MOOD, 0)) == -4, "result popup should include fixed-market mood effects")
	_expect(int(total.get(PlayerStatusKeysScript.KEY_FATIGUE, 0)) == 14, "result popup should include fixed-market fatigue effects")
	var event_name := String(overlay.call("_event_name", result))
	_expect(event_name.contains("시장 충격 뉴스"), "result popup should name the fixed-market event whose effect it totals")

	overlay.free()
	print("Result popup fixed-market effect smoke test passed.")
	finish_test()


func _event_effect(name_ko: String, mood_delta: int, fatigue_delta: int) -> Dictionary:
	return {
		DayEventKeysScript.KEY_EVENT: {
			DayEventKeysScript.KEY_NAME_KO: name_ko
		},
		DayEventKeysScript.KEY_EFFECT: {
			PlayerStatusKeysScript.KEY_DELTA: {
				PlayerStatusKeysScript.KEY_MOOD: mood_delta,
				PlayerStatusKeysScript.KEY_FATIGUE: fatigue_delta
			}
		}
	}


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
