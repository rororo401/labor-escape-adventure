class_name BadEndingStory
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameEndingScript := preload("res://scripts/core/game_ending.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")

const EVENT_DATE := "2026-06-30"
const MODE_ENDING_SPECIAL := "ending_special"
const GROUP_ENDING := "ending"

const BARELY_LEFT_CG := "res://assets/events/special/ending/bad/bad_ending_01_barely_left.png"
const SMALL_SAVINGS_CG := "res://assets/events/special/ending/bad/bad_ending_02_small_savings.png"
const STABLE_WORKER_CG := "res://assets/events/special/ending/bad/bad_ending_03_stable_worker.png"
const ALMOST_FREE_CG := "res://assets/events/special/ending/bad/bad_ending_04_almost_free.png"
const NEAR_MISS_CG := "res://assets/events/special/ending/bad/bad_ending_05_near_miss.png"


static func has_route(route: String) -> bool:
	return route in [
		GameEndingScript.BAD_ENDING_01_ROUTE,
		GameEndingScript.BAD_ENDING_02_ROUTE,
		GameEndingScript.BAD_ENDING_03_ROUTE,
		GameEndingScript.BAD_ENDING_04_ROUTE,
		GameEndingScript.BAD_ENDING_05_ROUTE
	]


static func cg_path(route: String) -> String:
	match route:
		GameEndingScript.BAD_ENDING_02_ROUTE:
			return SMALL_SAVINGS_CG
		GameEndingScript.BAD_ENDING_03_ROUTE:
			return STABLE_WORKER_CG
		GameEndingScript.BAD_ENDING_04_ROUTE:
			return ALMOST_FREE_CG
		GameEndingScript.BAD_ENDING_05_ROUTE:
			return NEAR_MISS_CG
		_:
			return BARELY_LEFT_CG


static func steps(route: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var lines := _lines(route)
	for index in range(lines.size()):
		var step: Dictionary = {VnStoryKeysScript.KEY_TEXT: lines[index]}
		if index == 0:
			step[VnStoryKeysScript.KEY_BACKGROUND_PATH] = cg_path(route)
			step[VnStoryKeysScript.KEY_CHARACTER_VISIBLE] = false
		result.append(step)
	return result


static func gallery_event(route: String) -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: route,
		DayEventKeysScript.KEY_NAME_KO: GameEndingScript.bad_ending_title(route),
		DayEventKeysScript.KEY_SUMMARY_KO: _gallery_summary(route),
		DayEventKeysScript.KEY_GROUP: GROUP_ENDING,
		DayEventKeysScript.KEY_MODE: MODE_ENDING_SPECIAL,
		DayEventKeysScript.KEY_TAGS: ["ending", "bad", "epilogue", "premium_cg"],
		DayEventKeysScript.KEY_CG_PATH: cg_path(route),
		DayEventKeysScript.KEY_DATE: EVENT_DATE
	}


static func gallery_events() -> Array[Dictionary]:
	return [
		gallery_event(GameEndingScript.BAD_ENDING_01_ROUTE),
		gallery_event(GameEndingScript.BAD_ENDING_02_ROUTE),
		gallery_event(GameEndingScript.BAD_ENDING_03_ROUTE),
		gallery_event(GameEndingScript.BAD_ENDING_04_ROUTE),
		gallery_event(GameEndingScript.BAD_ENDING_05_ROUTE)
	]


static func cg_paths() -> Array[String]:
	return [BARELY_LEFT_CG, SMALL_SAVINGS_CG, STABLE_WORKER_CG, ALMOST_FREE_CG, NEAR_MISS_CG]


static func summary_body(route: String, net_worth_text: String) -> String:
	match route:
		GameEndingScript.BAD_ENDING_02_ROUTE:
			return "10억에는 멀리 못 미쳤다.\n\n그래도 %s은 다음 위기를 막아 줄 작은 생활의 방어선이 됐다.\n\n탈출은 못 했지만 빈손으로 끝난 10년은 아니다." % net_worth_text
		GameEndingScript.BAD_ENDING_03_ROUTE:
			return "회사를 벗어나지는 못했다.\n\n하지만 %s과 10년의 습관은 예전보다 단단한 생활을 남겼다.\n\n이제 버티는 것 말고 다른 선택도 천천히 생각할 수 있다." % net_worth_text
		GameEndingScript.BAD_ENDING_04_ROUTE:
			return "자유라고 부르기에는 부족하고 실패라고 부르기에는 큰 %s.\n\n목표는 놓쳤지만 선택지를 만들 만큼은 걸어왔다.\n\n다음 결정은 조급함이 아니라 여유에서 시작할 수 있다." % net_worth_text
		GameEndingScript.BAD_ENDING_05_ROUTE:
			return "10억 바로 앞에서 멈췄다.\n\n아쉬움은 크지만 %s까지 온 시간이 사라지는 것은 아니다.\n\n게임의 마지막 날은 삶의 마지막 거래일이 아니다." % net_worth_text
		_:
			return "통장에 남은 것은 %s.\n\n목표도 돈도 많이 놓쳤지만, 무너진 숫자가 10년의 전부는 아니다.\n\n다음 생활은 더 작은 약속부터 다시 세우기로 했다." % net_worth_text


static func _lines(route: String) -> Array[String]:
	match route:
		GameEndingScript.BAD_ENDING_02_ROUTE:
			return [
				"마지막 정산을 끝내고 남은 돈을 한참 바라봤다.",
				"10억이라는 숫자와 나란히 놓으니 너무 작아 보였다.",
				"큰 수익을 꿈꾸며 시작한 10년의 결론치고는 초라한가 싶었다.",
				"그때 냉장고에 붙여 둔 수리비 영수증과 병원비 봉투가 눈에 들어왔다.",
				"이 작은 저축이 없었다면 그런 날마다 다시 빚을 냈을 것이다.",
				"노동탈출 자금은 되지 못했지만, 생활이 무너지는 걸 몇 번이나 막아 준 돈이었다.",
				"나는 투자 노트 맨 뒤에 다음 목표를 아주 작게 나눠 적었다.",
				"한 번에 인생을 바꾸는 숫자 말고, 다음 달의 나를 지켜 줄 숫자부터.",
				"화려한 결말은 아니었다. 그래도 빈손으로 끝난 10년은 아니었다.",
				"작은 저축의 끝에서, 나는 다시 시작할 수 있는 바닥을 확인했다."
			]
		GameEndingScript.BAD_ENDING_03_ROUTE:
			return [
				"십 년 전 첫 출근 날에 받았던 사원증을 서랍에서 꺼냈다.",
				"모서리는 닳았고 사진 속 나는 지금보다 훨씬 긴장한 얼굴이었다.",
				"결국 회사를 벗어나지는 못했다.",
				"내일도 알람을 맞추고 출근 준비를 해야 한다는 사실은 그대로였다.",
				"하지만 월급이 끊기면 바로 무너질 것 같던 예전과 지금은 조금 달랐다.",
				"급한 병원비와 갑작스러운 이사에도 버틸 돈, 싫은 일을 잠시 거절할 틈이 생겼다.",
				"10억은 아니지만 이 돈에는 내가 버틴 월요일과 참아 낸 손실이 들어 있었다.",
				"나는 낡은 사원증을 다시 넣고, 다음 휴가 날짜를 달력에 표시했다.",
				"당장 탈출하지 못해도 계속 갇혀 있기만 한 것은 아니다.",
				"버텨낸 생활은 끝이 아니라, 다음 선택을 준비할 수 있는 자리였다."
			]
		GameEndingScript.BAD_ENDING_04_ROUTE:
			return [
				"최종 자산을 확인한 뒤 퇴사 메일 초안을 열었다.",
				"보낼 수 있을 것 같다가도, 앞으로의 생활비를 계산하면 손가락이 멈췄다.",
				"10억은 멀었지만 그렇다고 아무것도 이루지 못한 숫자는 아니었다.",
				"몇 년은 쉴 수 있고, 덜 버는 일을 선택할 수도 있는 돈이었다.",
				"완전한 자유는 아니어도 숨을 고를 공간 정도는 내 손으로 만들었다.",
				"나는 퇴사 메일을 지우지 않고 임시 저장함에 남겨 두었다.",
				"오늘 당장 보내지 않는 것과 영원히 보내지 못하는 것은 다르다.",
				"목표에 못 미친 숫자만 보느라 생긴 선택지를 놓칠 뻔했다.",
				"창밖의 퇴근 인파를 보며 처음으로 서두르지 않고 다음 계획을 세웠다.",
				"꽤 가까웠던 자유는, 앞으로 어디로 갈지 고를 여유를 남겼다."
			]
		GameEndingScript.BAD_ENDING_05_ROUTE:
			return [
				"숫자를 다시 세어 봐도 10억에는 조금 모자랐다.",
				"마지막 해의 매도 버튼과 놓친 상승장이 차례로 떠올랐다.",
				"그때 한 번만 달랐더라면, 며칠만 더 기다렸더라면 하는 생각이 멈추지 않았다.",
				"계산기는 몇 번을 두드려도 지나간 선택을 바꿔 주지 않았다.",
				"나는 노트 첫 장에 적힌 10년 전의 자산을 다시 펼쳤다.",
				"지금의 숫자는 실패라고 한 줄로 지워 버리기에는 너무 멀리 와 있었다.",
				"게임의 달력은 오늘로 끝나지만 내 통장과 생활까지 멈추는 것은 아니다.",
				"아쉬움을 핑계로 무리한 마지막 승부를 하지 않은 것도 하나의 결말이었다.",
				"나는 계산기를 끄고 다음 달 적립식 주문만 그대로 남겨 두었다.",
				"한 발 모자란 탈출. 그래도 다음 한 발을 내디딜 자리는 충분했다."
			]
		_:
			return [
				"마지막 날의 계좌를 열었을 때 한동안 화면을 넘기지 못했다.",
				"10년 동안 벌고 잃고 다시 모았는데, 남은 숫자는 너무 작았다.",
				"사라진 돈과 잘못 눌렀던 매수 버튼이 한꺼번에 떠올랐다.",
				"다 잘못 살았다는 생각이 목까지 올라왔다.",
				"그러다 책상 구석에 쌓인 월세 영수증과 병원 기록, 오래된 출근표를 보았다.",
				"숫자는 많이 잃었어도 그동안 먹고 자고 아픈 날을 견디며 여기까지 왔다.",
				"잃은 돈이 내 10년 전부를 설명하게 두고 싶지는 않았다.",
				"나는 빈 종이에 다음 달 생활비와 갚아야 할 금액부터 다시 적었다.",
				"이번에는 한 번에 뒤집으려 하지 않고, 무너지지 않는 순서부터 세우기로 했다.",
				"거의 남지 않은 통장 앞에서, 아주 작은 다음 시작이 만들어졌다."
			]


static func _gallery_summary(route: String) -> String:
	match route:
		GameEndingScript.BAD_ENDING_02_ROUTE:
			return "목표에는 멀었지만 생활을 지켜 준 작은 저축의 의미를 돌아본 결말."
		GameEndingScript.BAD_ENDING_03_ROUTE:
			return "회사를 벗어나지 못했어도 이전보다 단단해진 생활을 확인한 결말."
		GameEndingScript.BAD_ENDING_04_ROUTE:
			return "완전한 자유에는 못 미쳤지만 선택할 여유를 얻은 결말."
		GameEndingScript.BAD_ENDING_05_ROUTE:
			return "10억 바로 앞에서 멈췄지만 다음 한 발을 남겨 둔 결말."
		_:
			return "거의 남지 않은 통장 앞에서 작은 생활부터 다시 세우는 결말."
