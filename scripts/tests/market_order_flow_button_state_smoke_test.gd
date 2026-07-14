extends "res://scripts/tests/test_scene_tree.gd"

const FlowButtonStateConfigScript := preload("res://scripts/ui/flow_button_state_config.gd")
const MarketOrderFlowButtonStateScript := preload("res://scripts/ui/market_order_flow_button_state.gd")


func _initialize() -> void:
	_verify_terminal_states()
	_verify_day_states()
	_verify_disabled_states()

	print("Market order flow button state smoke test passed.")
	finish_test()


func _verify_terminal_states() -> void:
	_expect_state(
		MarketOrderFlowButtonStateScript.build(true, true, false, false, false, "회사 출근하기"),
		"게임 완료",
		true,
		"game clear should override ready text"
	)
	_expect_state(
		MarketOrderFlowButtonStateScript.build(true, false, true, false, false, "회사 출근하기"),
		"게임오버",
		true,
		"game over should override ready text"
	)


func _verify_day_states() -> void:
	_expect_state(
		MarketOrderFlowButtonStateScript.build(false, false, false, false, false, "1주 매수 필요"),
		"1주 매수 필요",
		false,
		"active day should keep tutorial ready text"
	)
	_expect_state(
		MarketOrderFlowButtonStateScript.build(false, false, false, false, false, "회사 출근하기"),
		"회사 출근하기",
		false,
		"active day should keep work-entry ready text"
	)
	_expect_state(
		MarketOrderFlowButtonStateScript.build(false, false, false, true, false, "회사 출근하기"),
		"잠들기",
		false,
		"completed day should become sleep"
	)


func _verify_disabled_states() -> void:
	_expect_state(
		MarketOrderFlowButtonStateScript.build(false, false, false, false, true, "오늘 하루 보내기"),
		"오늘 하루 보내기",
		true,
		"sleep sequence should disable active button"
	)
	_expect_state(
		MarketOrderFlowButtonStateScript.build(true, false, false, true, false, "오늘 하루 보내기"),
		"잠들기",
		true,
		"generic finished day should disable current text"
	)


func _expect_state(state: Dictionary, text: String, disabled: bool, message: String) -> void:
	_expect(String(state.get(FlowButtonStateConfigScript.KEY_TEXT, FlowButtonStateConfigScript.EMPTY_TEXT)) == text, "%s text" % message)
	_expect(bool(state.get(FlowButtonStateConfigScript.KEY_DISABLED, not disabled)) == disabled, "%s disabled" % message)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
