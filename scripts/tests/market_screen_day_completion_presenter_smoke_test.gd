extends "res://scripts/tests/test_scene_tree.gd"

const MarketDayCompletionFlowConfigScript := preload("res://scripts/ui/market_day_completion_flow_config.gd")
const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketScreenDayCompletionPresenterScript := preload("res://scripts/ui/market_screen_day_completion_presenter.gd")
const MarketScreenRuntimeStateScript := preload("res://scripts/ui/market_screen_runtime_state.gd")


func _initialize() -> void:
	var runtime_state = MarketScreenRuntimeStateScript.new()
	runtime_state.is_completing_day = true
	var order_panel = FakeOrderPanel.new()
	var closed_panel = FakeClosedDayPanel.new()

	var success_state := MarketScreenDayCompletionPresenterScript.apply_success(
		runtime_state,
		order_panel,
		closed_panel,
		{
			"day_action": {
				"event": {
					"name_ko": "알바하기"
				}
			},
			"night_events": [],
			"market_close_report": {
				"net_worth": 1500000,
				"unrealized_profit": 3200
			}
		}
	)
	_expect(not runtime_state.is_completing_day, "success should clear completing flag")
	_expect(runtime_state.showing_close_report, "success should show close report")
	_expect(bool(success_state.get(MarketDayResultStateConfigScript.KEY_SHOWING_CLOSE_REPORT, false)), "success should return applied state")
	_expect(order_panel.message.contains("알바하기 완료"), "success should forward message to order panel")
	_expect(closed_panel.message == order_panel.message, "success should forward message to closed-day panel")

	runtime_state.is_completing_day = true
	closed_panel.choice_buttons_disabled = true
	var error_state := MarketScreenDayCompletionPresenterScript.apply_error(
		runtime_state,
		order_panel,
		closed_panel,
		{
			MarketDayCompletionFlowConfigScript.KEY_STATE: {
				MarketDayResultStateConfigScript.KEY_IS_COMPLETING_DAY: false,
				MarketDayResultStateConfigScript.KEY_CHOICE_BUTTONS_DISABLED: false,
				MarketDayResultStateConfigScript.KEY_MESSAGE: "아직 할 일을 고르지 않았다."
			}
		}
	)
	_expect(not runtime_state.is_completing_day, "error should apply state patch")
	_expect(not closed_panel.choice_buttons_disabled, "error should apply choice disabled flag")
	_expect(String(error_state.get(MarketDayResultStateConfigScript.KEY_MESSAGE, "")) == "아직 할 일을 고르지 않았다.", "error should return error state")
	_expect(order_panel.message == "아직 할 일을 고르지 않았다.", "error should forward message to order panel")
	_expect(closed_panel.message == "아직 할 일을 고르지 않았다.", "error should forward message to closed-day panel")

	closed_panel.choice_buttons_disabled = true
	MarketScreenDayCompletionPresenterScript.apply_error(
		runtime_state,
		order_panel,
		closed_panel,
		{
			MarketDayCompletionFlowConfigScript.KEY_STATE: {
				MarketDayResultStateConfigScript.KEY_CHOICE_BUTTONS_DISABLED: false,
				MarketDayResultStateConfigScript.KEY_MESSAGE: "선택 상태는 유지한다."
			}
		},
		false
	)
	_expect(closed_panel.choice_buttons_disabled, "error should preserve choice disabled state when updates are disabled")
	_expect(closed_panel.message == "선택 상태는 유지한다.", "error should still update message when choice updates are disabled")

	MarketScreenDayCompletionPresenterScript.apply_success(null, null, null, {})
	MarketScreenDayCompletionPresenterScript.apply_error(null, null, null, {})

	print("Market screen day-completion presenter smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakeOrderPanel:
	var message := ""

	func set_message(text: String) -> void:
		message = text


class FakeClosedDayPanel:
	var message := ""
	var choice_buttons_disabled := false

	func set_message(text: String) -> void:
		message = text

	func set_choice_buttons_disabled(disabled: bool) -> void:
		choice_buttons_disabled = disabled
