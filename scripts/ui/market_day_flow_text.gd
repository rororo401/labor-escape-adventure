class_name MarketDayFlowText
extends RefCounted

const MarketUiFormat := preload("res://scripts/ui/market_ui_format.gd")
const MarketFlowCopyScript := preload("res://scripts/ui/market_flow_copy.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")
const MarketDayFlowTextConfigScript := preload("res://scripts/ui/market_day_flow_text_config.gd")
const MarketStatusTextConfigScript := preload("res://scripts/ui/market_status_text_config.gd")


static func ready_text(game) -> String:
	if game == null:
		return MarketFlowCopyScript.DEFAULT_READY_TEXT
	if game.is_first_tutorial_day() and not game.day_completed:
		return "회사 출근하기" if game.get_total_held_quantity() >= 1 else "1주 매수 필요"
	return MarketFlowCopyScript.DEFAULT_READY_TEXT


static func format_day_result(result: Dictionary) -> String:
	var report: Dictionary = result.get(MarketDayFlowTextConfigScript.KEY_MARKET_CLOSE_REPORT, {})
	if bool(result.get(MarketDayFlowTextConfigScript.KEY_GAME_CLEAR, false)):
		return "목표 달성! 순자산 %s  10억, 진짜 찍었다!" % MarketUiFormat.format_won(int(report.get(MarketStatusTextConfigScript.KEY_NET_WORTH, MarketStatusTextConfigScript.DEFAULT_AMOUNT)))
	if String(result.get(MarketDayFlowTextConfigScript.KEY_GAME_OVER_REASON, "")) == MarketDayFlowTextConfigScript.GAME_OVER_REASON_FINAL_BAD_ENDING:
		return "배드엔딩: %s  최종 순자산 %s" % [
			String(result.get(MarketDayFlowTextConfigScript.KEY_ENDING_TITLE_KO, "목표 미달")),
			MarketUiFormat.format_won(int(report.get(MarketStatusTextConfigScript.KEY_NET_WORTH, MarketStatusTextConfigScript.DEFAULT_AMOUNT)))
		]

	var day_action: Dictionary = result.get(MarketDayFlowTextConfigScript.KEY_DAY_ACTION, {}).get(MarketDayFlowTextConfigScript.KEY_EVENT, {})
	var weekday_events: Array = result.get(MarketDayFlowTextConfigScript.KEY_WEEKDAY_EVENTS, [])
	var night_events: Array = result.get(MarketDayFlowTextConfigScript.KEY_NIGHT_EVENTS, [])
	var weekday_text := ""
	if not weekday_events.is_empty():
		weekday_text = " / 사건: %s" % weekday_events[0].get(MarketDayFlowTextConfigScript.KEY_EVENT, {}).get(MarketDayActionOptionsConfigScript.ACTION_NAME, MarketDayFlowTextConfigScript.EMPTY_TEXT)
	var night_text := ""
	if not night_events.is_empty():
		night_text = " / 밤: %s" % night_events[0].get(MarketDayFlowTextConfigScript.KEY_EVENT, {}).get(MarketDayActionOptionsConfigScript.ACTION_NAME, MarketDayFlowTextConfigScript.EMPTY_TEXT)
	return "%s 완료%s%s  평가손익 %s" % [
		day_action.get(MarketDayActionOptionsConfigScript.ACTION_NAME, MarketDayFlowTextConfigScript.DEFAULT_DAY_ACTION_NAME),
		weekday_text,
		night_text,
		MarketUiFormat.format_won(int(report.get(MarketDayFlowTextConfigScript.KEY_UNREALIZED_PROFIT, MarketStatusTextConfigScript.DEFAULT_AMOUNT)))
	]


static func closed_day_text(market_context: Dictionary) -> Dictionary:
	var reason := String(market_context.get(MarketDayFlowTextConfigScript.KEY_CLOSED_NAME, MarketDayFlowTextConfigScript.EMPTY_TEXT))
	if reason.is_empty():
		reason = MarketDayFlowTextConfigScript.WEEKEND_LABEL if String(market_context.get(MarketDayFlowTextConfigScript.KEY_CLOSED_REASON, MarketDayFlowTextConfigScript.EMPTY_TEXT)) == MarketDayFlowTextConfigScript.CLOSED_REASON_WEEKEND else MarketDayFlowTextConfigScript.HOLIDAY_LABEL
	return {
		MarketDayFlowTextConfigScript.KEY_TITLE: "%s, 장이 열리지 않는다" % reason,
		MarketDayFlowTextConfigScript.KEY_BODY: "오늘은 주식 매매를 할 수 없다. 집에 있을지, 밖으로 나갈지 먼저 정해보자."
	}


static func day_action_name(flow: Dictionary, action_id: String) -> String:
	for action in flow.get(MarketDayActionOptionsConfigScript.FLOW_AVAILABLE_CHOICES, []):
		if String(action.get(MarketDayActionOptionsConfigScript.ACTION_ID, "")) == action_id:
			return String(action.get(MarketDayActionOptionsConfigScript.ACTION_NAME, action_id))
	var default_action: Dictionary = Dictionary(flow.get(MarketDayActionOptionsConfigScript.FLOW_DEFAULT_ACTION, {}))
	if String(default_action.get(MarketDayActionOptionsConfigScript.ACTION_ID, "")) == action_id:
		return String(default_action.get(MarketDayActionOptionsConfigScript.ACTION_NAME, action_id))
	return action_id


static func order_success_message(side: String, quantity: int, price: int) -> String:
	return "%s %d주 체결  %s" % [
		"매수" if side == MarketDataKeysScript.SIDE_BUY else "매도",
		quantity,
		MarketUiFormat.format_won(price)
	]


static func status_texts(portfolio: Dictionary, valuation: Dictionary) -> Dictionary:
	return {
		MarketStatusTextConfigScript.KEY_CASH: "%s\n%s" % [
			MarketStatusTextConfigScript.CASH_LABEL,
			MarketUiFormat.format_won(int(portfolio.get(
				MarketStatusTextConfigScript.KEY_CASH,
				valuation.get(MarketStatusTextConfigScript.KEY_CASH, MarketStatusTextConfigScript.DEFAULT_AMOUNT)
			)))
		],
		MarketStatusTextConfigScript.KEY_NET_WORTH: "%s\n%s" % [
			MarketStatusTextConfigScript.NET_WORTH_LABEL,
			MarketUiFormat.format_won(int(valuation.get(
				MarketStatusTextConfigScript.KEY_NET_WORTH,
				MarketStatusTextConfigScript.DEFAULT_AMOUNT
			)))
		]
	}


static func order_error_message(error: String) -> String:
	match error:
		MarketDayFlowTextConfigScript.ORDER_ERROR_MARKET_CLOSED:
			return "오늘은 장이 열리지 않는다."
		MarketDayFlowTextConfigScript.ORDER_ERROR_NOT_ENOUGH_CASH:
			return "현금이 부족하다."
		MarketDayFlowTextConfigScript.ORDER_ERROR_NOT_ENOUGH_SHARES:
			return "보유 수량이 부족하다."
		MarketDayFlowTextConfigScript.ORDER_ERROR_PRICE_MISSING:
			return "가격 데이터가 없다."
		MarketDayFlowTextConfigScript.ORDER_ERROR_INVALID_QUANTITY:
			return "수량이 맞지 않는다."
		_:
			return "주문을 처리하지 못했다."


static func flow_error_message(error: String) -> String:
	match error:
		MarketDayFlowTextConfigScript.FLOW_ERROR_DAY_ALREADY_COMPLETED:
			return "오늘은 이미 마무리했다."
		MarketDayFlowTextConfigScript.FLOW_ERROR_DAY_NOT_COMPLETED:
			return "아직 잠들기엔 오늘 일이 남았다."
		MarketDayFlowTextConfigScript.FLOW_ERROR_FIRST_DAY_STOCK_REQUIRED:
			return "첫날에는 최소 1주를 매수해야 출근할 수 있다."
		MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_OVER:
			return "더는 하루를 진행할 수 없다."
		MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_CLEAR:
			return "최종일 목표금액을 달성했다."
		MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_NOT_STARTED:
			return "게임 세션을 찾지 못했다."
		_:
			return "하루 진행을 처리하지 못했다."
