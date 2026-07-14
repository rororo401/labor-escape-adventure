extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenPanelFeedbackScript := preload("res://scripts/ui/market_screen_panel_feedback.gd")


func _initialize() -> void:
	var order_panel = FakeOrderPanel.new()
	var closed_panel = FakeClosedDayPanel.new()

	MarketScreenPanelFeedbackScript.set_flow_message(order_panel, closed_panel, "테스트 메시지")
	_expect(order_panel.message == "테스트 메시지", "feedback should forward message to order panel")
	_expect(closed_panel.message == "테스트 메시지", "feedback should forward message to closed-day panel")

	MarketScreenPanelFeedbackScript.set_flow_message(null, closed_panel, "휴장일 메시지")
	_expect(closed_panel.message == "휴장일 메시지", "feedback should tolerate missing order panel")
	MarketScreenPanelFeedbackScript.set_flow_message(order_panel, null, "주문 메시지")
	_expect(order_panel.message == "주문 메시지", "feedback should tolerate missing closed-day panel")

	MarketScreenPanelFeedbackScript.set_closed_day_choice_buttons_disabled(closed_panel, true)
	_expect(closed_panel.choice_buttons_disabled, "feedback should disable closed-day choices")
	MarketScreenPanelFeedbackScript.set_closed_day_choice_buttons_disabled(closed_panel, false)
	_expect(not closed_panel.choice_buttons_disabled, "feedback should enable closed-day choices")
	MarketScreenPanelFeedbackScript.set_closed_day_choice_buttons_disabled(null, true)

	print("Market screen panel feedback smoke test passed.")
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
