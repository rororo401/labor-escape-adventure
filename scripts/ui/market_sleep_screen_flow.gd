class_name MarketSleepScreenFlow
extends RefCounted

const MarketDayResultStateScript := preload("res://scripts/ui/market_day_result_state.gd")
const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketSleepFlowConfigScript := preload("res://scripts/ui/market_sleep_flow_config.gd")
const MarketSleepFlowScript := preload("res://scripts/ui/market_sleep_flow.gd")


func play(parent: Node, game, callbacks: Dictionary) -> void:
	var sleep_flow = _make_sleep_flow()
	_call_state(callbacks, MarketDayResultStateScript.sleep_start_state())
	_call_void(callbacks, MarketSleepFlowConfigScript.CALLBACK_REFRESH_FLOW_CONTROLS)

	var flow_result: Dictionary = await sleep_flow.play_until_transition(parent, game)
	if not bool(flow_result.get(MarketSleepFlowConfigScript.KEY_OK, false)):
		var error_state: Dictionary = flow_result.get(MarketSleepFlowConfigScript.KEY_ERROR_STATE, {})
		_call_message(callbacks, String(error_state.get(MarketDayResultStateConfigScript.KEY_MESSAGE, "")))
		_call_state(callbacks, error_state)
		_call_void(callbacks, MarketSleepFlowConfigScript.CALLBACK_REFRESH_FLOW_CONTROLS)
		return

	var transition_state: Dictionary = flow_result.get(MarketSleepFlowConfigScript.KEY_TRANSITION_STATE, {})
	_call_state(callbacks, transition_state)
	_call_message(callbacks, String(transition_state.get(MarketDayResultStateConfigScript.KEY_MESSAGE, "")))
	# 날짜 전환막이 화면을 완전히 덮고 있는 동안 새 날짜의 시장 UI를 먼저 준비한다.
	# 아침 화면이 사라진 뒤 갱신하면 전날 화면이 페이드 사이로 한 프레임 비칠 수 있다.
	_call_void(callbacks, MarketSleepFlowConfigScript.CALLBACK_REFRESH_MARKET)

	var morning_state: Dictionary = await sleep_flow.play_morning(flow_result.get(MarketSleepFlowConfigScript.KEY_RESULT, {}))
	_call_state(callbacks, morning_state)
	_call_void(callbacks, MarketSleepFlowConfigScript.CALLBACK_REFRESH_FLOW_CONTROLS)
	_call_void(callbacks, MarketSleepFlowConfigScript.CALLBACK_MARKET_REVEAL_READY)


func _make_sleep_flow():
	return MarketSleepFlowScript.new()


func _call_state(callbacks: Dictionary, state: Dictionary) -> void:
	var callback: Callable = callbacks.get(MarketSleepFlowConfigScript.CALLBACK_APPLY_STATE, Callable())
	if callback.is_valid():
		callback.call(state)


func _call_message(callbacks: Dictionary, message: String) -> void:
	var callback: Callable = callbacks.get(MarketSleepFlowConfigScript.CALLBACK_SET_MESSAGE, Callable())
	if callback.is_valid():
		callback.call(message)


func _call_void(callbacks: Dictionary, key: String) -> void:
	var callback: Callable = callbacks.get(key, Callable())
	if callback.is_valid():
		callback.call()
