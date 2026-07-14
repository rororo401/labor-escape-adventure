extends "res://scripts/tests/test_scene_tree.gd"

const ClosedDayFlowButtonStateScript := preload("res://scripts/ui/closed_day_flow_button_state.gd")
const FlowButtonStateConfigScript := preload("res://scripts/ui/flow_button_state_config.gd")


func _initialize() -> void:
	_verify_terminal_states()
	_verify_completed_day_state()
	_verify_choice_states()

	print("Closed-day flow button state smoke test passed.")
	finish_test()


func _verify_terminal_states() -> void:
	_expect_state(
		ClosedDayFlowButtonStateScript.build(true, true, false, false, false, false, false),
		"게임 완료",
		true,
		"game clear should disable with completion text"
	)
	_expect_state(
		ClosedDayFlowButtonStateScript.build(true, false, true, false, false, false, false),
		"게임오버",
		true,
		"game over should disable with game-over text"
	)


func _verify_completed_day_state() -> void:
	_expect_state(
		ClosedDayFlowButtonStateScript.build(false, false, false, true, false, false, true),
		"잠들기",
		false,
		"completed day should allow sleep when no sleep sequence is running"
	)
	_expect_state(
		ClosedDayFlowButtonStateScript.build(false, false, false, true, true, false, true),
		"잠들기",
		true,
		"completed day should disable sleep during sleep sequence"
	)


func _verify_choice_states() -> void:
	_expect_state(
		ClosedDayFlowButtonStateScript.build(false, false, false, false, false, false, false),
		"할 일 선택 필요",
		true,
		"open closed-day choice should require a selection"
	)
	_expect_state(
		ClosedDayFlowButtonStateScript.build(false, false, false, false, false, false, true),
		"오늘 하루 보내기",
		false,
		"selected closed-day action should be runnable"
	)
	_expect_state(
		ClosedDayFlowButtonStateScript.build(false, false, false, false, false, true, true),
		"진행 중",
		true,
		"completing closed-day action should be disabled with progress text"
	)


func _expect_state(state: Dictionary, text: String, disabled: bool, message: String) -> void:
	_expect(String(state.get(FlowButtonStateConfigScript.KEY_TEXT, FlowButtonStateConfigScript.EMPTY_TEXT)) == text, "%s text" % message)
	_expect(bool(state.get(FlowButtonStateConfigScript.KEY_DISABLED, not disabled)) == disabled, "%s disabled" % message)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
