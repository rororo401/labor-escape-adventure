class_name MarketDayCompletionFlow
extends RefCounted

const MarketDayCompletionFlowConfigScript := preload("res://scripts/ui/market_day_completion_flow_config.gd")
const MarketDayResultStateScript := preload("res://scripts/ui/market_day_result_state.gd")
const MarketFlowStateScript := preload("res://scripts/ui/market_flow_state.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")

const SUMMER_VACATION_ID_PREFIX := "summer_vacation_"
const SUMMER_VACATION_DAY_1_SUFFIX := "_day_1"
const SUMMER_VACATION_DAY_3_SUFFIX := "_day_3"
const SUMMER_VACATION_COMMON_DEPARTURE_ID := "summer_vacation_common_departure"
const SUMMER_VACATION_COMMON_RETURN_ID := "summer_vacation_common_return"
const SUMMER_VACATION_COMMON_DEPARTURE_CG := "res://assets/events/special/annual/summer_vacation/common_departure.png"
const SUMMER_VACATION_COMMON_RETURN_CG := "res://assets/events/special/annual/summer_vacation/common_return.png"
const WORKDAY_DEPARTURE_ID := "workday_departure_transition"
const WORKDAY_DEPARTURE_CG := "res://assets/events/transition/leave_work_evening.png"


static func complete(game, selected_day_action_id: String, market_context: Dictionary) -> Dictionary:
	if game == null:
		return _error_state(MarketDayCompletionFlowConfigScript.DEFAULT_MISSING_GAME_ERROR)

	var result: Dictionary = game.complete_today(selected_day_action_id)
	if not result.get(MarketDayCompletionFlowConfigScript.KEY_OK, false):
		return _error_state(String(result.get(MarketDayCompletionFlowConfigScript.KEY_ERROR, "")), result)

	var day_action: Dictionary = result.get(MarketDayCompletionFlowConfigScript.KEY_DAY_ACTION, {}).get(MarketDayCompletionFlowConfigScript.KEY_EVENT, {})
	var playback_events := _playback_events(
		day_action,
		result.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []),
		result.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []),
		MarketFlowStateScript.should_play_day_event_after_completion(market_context)
	)
	return {
		MarketDayCompletionFlowConfigScript.KEY_OK: true,
		MarketDayCompletionFlowConfigScript.KEY_RESULT: result,
		MarketDayCompletionFlowConfigScript.KEY_DAY_ACTION: day_action,
		MarketDayCompletionFlowConfigScript.KEY_SHOULD_PLAY_DAY_EVENT: not playback_events.is_empty(),
		MarketDayCompletionFlowConfigScript.KEY_PLAYBACK_EVENTS: playback_events
	}


static func _error_state(error: String, result: Dictionary = {}) -> Dictionary:
	return {
		MarketDayCompletionFlowConfigScript.KEY_OK: false,
		MarketDayCompletionFlowConfigScript.KEY_RESULT: result,
		MarketDayCompletionFlowConfigScript.KEY_STATE: MarketDayResultStateScript.completion_error_state(error)
	}


static func _playback_events(day_action: Dictionary, weekday_event_rows: Array, night_event_rows: Array, should_play_day_action: bool) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if should_play_day_action and not day_action.is_empty():
		if _is_summer_vacation_day(day_action, SUMMER_VACATION_DAY_1_SUFFIX):
			events.append(_summer_vacation_common_departure_event())
		events.append(day_action)
		if _is_summer_vacation_day(day_action, SUMMER_VACATION_DAY_3_SUFFIX):
			events.append(_summer_vacation_common_return_event())

	for row in weekday_event_rows:
		var weekday_event := Dictionary(Dictionary(row).get(DayEventKeysScript.KEY_EVENT, {}))
		if not weekday_event.is_empty():
			events.append(weekday_event)

	var night_events: Array[Dictionary] = []
	for row in night_event_rows:
		var night_event := Dictionary(Dictionary(row).get(DayEventKeysScript.KEY_EVENT, {}))
		if not night_event.is_empty():
			night_events.append(night_event)

	if should_play_day_action and _is_company_work(day_action) and not night_events.is_empty():
		events.append(_workday_departure_event())
	events.append_array(night_events)
	return events


static func _is_summer_vacation_day(event: Dictionary, suffix: String) -> bool:
	var event_id := String(event.get(DayEventKeysScript.KEY_ID, ""))
	return event_id.begins_with(SUMMER_VACATION_ID_PREFIX) and event_id.ends_with(suffix)


static func _is_company_work(event: Dictionary) -> bool:
	return (
		String(event.get(DayEventKeysScript.KEY_ID, "")) == DayEventKeysScript.ACTION_COMPANY_WORK
		or String(event.get(DayEventKeysScript.KEY_GROUP, "")) == DayEventKeysScript.GROUP_COMPANY_WORK
	)


static func _workday_departure_event() -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: WORKDAY_DEPARTURE_ID,
		DayEventKeysScript.KEY_NAME_KO: "퇴근길",
		DayEventKeysScript.KEY_SUMMARY_KO: "오늘 업무는 여기까지. 저녁 공기를 따라 집으로 돌아갈 시간이다.",
		DayEventKeysScript.KEY_MODE: DayEventKeysScript.MODE_AUTO_TRADING,
		DayEventKeysScript.KEY_GROUP: DayEventKeysScript.GROUP_COMPANY_WORK,
		DayEventKeysScript.KEY_CG_PATH: WORKDAY_DEPARTURE_CG,
		DayEventKeysScript.KEY_DIALOGUE: [
			"오늘 업무는 여기까지. 저녁 공기를 따라 집으로 돌아갈 시간이다."
		]
	}


static func _summer_vacation_common_departure_event() -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: SUMMER_VACATION_COMMON_DEPARTURE_ID,
		DayEventKeysScript.KEY_NAME_KO: "여름휴가 출발",
		DayEventKeysScript.KEY_SUMMARY_KO: "캐리어 손잡이를 잡자, 회사와 차트에서 잠깐 멀어질 시간이 시작됐다.",
		DayEventKeysScript.KEY_MODE: DayEventKeysScript.MODE_ANNUAL_SPECIAL,
		DayEventKeysScript.KEY_CG_PATH: SUMMER_VACATION_COMMON_DEPARTURE_CG,
		DayEventKeysScript.KEY_DIALOGUE: [
			"공항 유리창 너머로 아침빛이 길게 들어왔다.",
			"핸드폰에는 주식 앱 알림이 몇 개 떠 있었지만, 오늘은 열지 않기로 했다.",
			"캐리어 손잡이를 고쳐 잡자, 정말로 휴가가 시작되는 느낌이 났다."
		]
	}


static func _summer_vacation_common_return_event() -> Dictionary:
	return {
		DayEventKeysScript.KEY_ID: SUMMER_VACATION_COMMON_RETURN_ID,
		DayEventKeysScript.KEY_NAME_KO: "여름휴가 귀국",
		DayEventKeysScript.KEY_SUMMARY_KO: "문 앞에 캐리어를 세우자 여행의 공기와 일상의 조명이 조용히 섞였다.",
		DayEventKeysScript.KEY_MODE: DayEventKeysScript.MODE_ANNUAL_SPECIAL,
		DayEventKeysScript.KEY_CG_PATH: SUMMER_VACATION_COMMON_RETURN_CG,
		DayEventKeysScript.KEY_DIALOGUE: [
			"집 문을 여는 순간, 익숙한 공기가 천천히 돌아왔다.",
			"가방 안에는 영수증과 기념품, 아직 정리하지 못한 마음이 같이 들어 있었다.",
			"내일부터는 다시 일상이지만, 이번 여름의 몇 장면은 오래 버틸 힘이 되어줄 것 같다."
		]
	}
