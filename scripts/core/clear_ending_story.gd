class_name ClearEndingStory
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")

const EVENT_DATE := "2026-06-30"
const MODE_ENDING_SPECIAL := "ending_special"
const GROUP_ENDING := "ending"

const TARGET_REACHED_CG := "res://assets/events/special/ending/clear/clear_ending_target_reached.png"
const SMALL_CELEBRATION_CG := "res://assets/events/special/ending/clear/clear_ending_small_celebration.png"
const WEEKDAY_OFF_CG := "res://assets/events/special/ending/clear/clear_ending_weekday_off.png"


static func steps() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	_append_scene(result, TARGET_REACHED_CG, [
		"하루를 모두 마치고 습관처럼 계좌를 다시 열었다.",
		"어?",
		"일, 십, 백, 천, 만... 손가락으로 자릿수를 짚다가 중간에 멈췄다.",
		"잠깐. 다시 세어보자.",
		"십억? 내가? 내가 10억을 모았다고?",
		"앱을 닫았다가 다시 열고, 새로고침하고, 계산기까지 두드려봤다.",
		"그래도 숫자는 사라지지 않았다. 잘못 본 것도 아니었다.",
		"뭔가 엄청난 사람이 된 것 같은데, 방은 어제와 똑같았다.",
		"싱크대에는 아침에 놓고 간 컵도 그대로였다. 그 평범함이 괜히 웃겼다."
	])
	_append_scene(result, SMALL_CELEBRATION_CG, [
		"신이 나서 10억으로 은퇴할 수 있는지 검색해봤다.",
		"가능하다는 글과 어렵다는 글, 세금과 물가와 보험료 이야기가 한꺼번에 쏟아졌다.",
		"인터넷은 축하보다 계산이 빨랐다.",
		"퇴사는... 조금 더 생각해보기로 했다.",
		"그래도 오늘만큼은 축하해야 한다. 작은 케이크와 평소보다 비싼 저녁을 주문했다.",
		"결제 직전 배달비 삼천 원에서 손가락이 잠깐 멈췄다.",
		"10억을 모은 날에도 배달비는 아깝다. 그래도 오늘은 시킨다.",
		"오래된 투자 노트 마지막 장에 오늘 날짜와 목표 달성이라는 말을 크게 적었다.",
		"그 아래에 그래서 이제 뭐 하지, 하고 적었다가 한참 바라봤다.",
		"모르겠다. 하지만 모르는 건 내일 생각해도 된다.",
		"오늘은 그냥 신나도 되는 날이다. 내가 10억을 모았으니까!"
	])
	_append_scene(result, WEEKDAY_OFF_CG, [
		"다음 날 아침, 알람이 울리자 몸은 평소처럼 먼저 출근 준비를 시작했다.",
		"옷장 앞까지 갔다가 문득 멈췄다.",
		"노동탈출까지는 아직 잘 모르겠다. 그래도 오늘 하루 정도는 탈출해도 되겠지.",
		"휴대폰으로 연차를 내고, 출근복 대신 가벼운 원피스를 꺼냈다.",
		"평일 오전의 동네 카페는 생각보다 한산했다.",
		"휴대폰을 뒤집어 놓자 주식창도 회사 메신저도 잠깐 조용해졌다.",
		"10억이 모든 걱정을 없애주지는 않을 것이다.",
		"그래도 10년 동안 세운 목표를 진짜로 이뤘다는 사실은 누구도 가져갈 수 없다.",
		"내가 10억을 모으다니. 진짜 열심히 살았네.",
		"내일은... 내일 생각하자."
	])
	return result


static func gallery_events() -> Array[Dictionary]:
	return [
		_gallery_event("clear_ending_target_reached", "10억, 진짜 찍었다!", TARGET_REACHED_CG),
		_gallery_event("clear_ending_small_celebration", "오늘만큼은 축하", SMALL_CELEBRATION_CG),
		_gallery_event("clear_ending_weekday_off", "일단 오늘은 쉽니다", WEEKDAY_OFF_CG)
	]


static func cg_paths() -> Array[String]:
	return [TARGET_REACHED_CG, SMALL_CELEBRATION_CG, WEEKDAY_OFF_CG]


static func _append_scene(result: Array[Dictionary], background_path: String, lines: Array[String]) -> void:
	for index in range(lines.size()):
		var step: Dictionary = {VnStoryKeysScript.KEY_TEXT: lines[index]}
		if index == 0:
			step[VnStoryKeysScript.KEY_BACKGROUND_PATH] = background_path
			step[VnStoryKeysScript.KEY_CHARACTER_VISIBLE] = false
		result.append(step)


static func _gallery_event(event_id: String, name_ko: String, cg_path: String) -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: event_id,
		DayEventKeysScript.KEY_NAME_KO: name_ko,
		DayEventKeysScript.KEY_SUMMARY_KO: "10억 목표를 달성한 뒤 맞이한 작은 클리어 엔딩 장면.",
		DayEventKeysScript.KEY_GROUP: GROUP_ENDING,
		DayEventKeysScript.KEY_MODE: MODE_ENDING_SPECIAL,
		DayEventKeysScript.KEY_TAGS: ["ending", "clear", "premium_cg"],
		DayEventKeysScript.KEY_CG_PATH: cg_path
	}
