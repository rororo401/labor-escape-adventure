extends "res://scripts/tests/test_scene_tree.gd"

const MarketFlowControlsPresenterScript := preload("res://scripts/ui/market_flow_controls_presenter.gd")
const MarketFlowControlStateConfigScript := preload("res://scripts/ui/market_flow_control_state_config.gd")
const MarketOrderPanelScript := preload("res://scripts/ui/market_order_panel.gd")
const ClosedDayPanelScript := preload("res://scripts/ui/closed_day_panel.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var order_panel = MarketOrderPanelScript.new()
	order_panel.build()
	root.add_child(order_panel)
	var closed_panel = ClosedDayPanelScript.new()
	closed_panel.build()
	root.add_child(closed_panel)
	await process_frame

	MarketFlowControlsPresenterScript.apply(order_panel, closed_panel, {
		MarketFlowControlStateConfigScript.KEY_CAN_TRADE: true,
		MarketFlowControlStateConfigScript.KEY_ORDER_FLOW: {
			MarketFlowControlStateConfigScript.KEY_GAME_FINISHED: false,
			MarketFlowControlStateConfigScript.KEY_GAME_CLEAR: false,
			MarketFlowControlStateConfigScript.KEY_GAME_OVER: false,
			MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED: false,
			MarketFlowControlStateConfigScript.KEY_SLEEP_SEQUENCE: false,
			MarketFlowControlStateConfigScript.KEY_READY_TEXT: "회사 출근하기"
		},
		MarketFlowControlStateConfigScript.KEY_CLOSED_FLOW: {
			MarketFlowControlStateConfigScript.KEY_GAME_FINISHED: false,
			MarketFlowControlStateConfigScript.KEY_GAME_CLEAR: false,
			MarketFlowControlStateConfigScript.KEY_GAME_OVER: false,
			MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED: false,
			MarketFlowControlStateConfigScript.KEY_SLEEP_SEQUENCE: false,
			MarketFlowControlStateConfigScript.KEY_COMPLETING_DAY: false,
			MarketFlowControlStateConfigScript.KEY_HAS_SELECTION: true
		}
	})

	var buy_button := _helpers.find_node(order_panel, "BuyButton") as Button
	var sell_button := _helpers.find_node(order_panel, "SellButton") as Button
	var order_flow_button := _find_primary_button_with_text(order_panel, "회사 출근하기")
	var closed_flow_button := _helpers.find_node(closed_panel, "ClosedDayFlowButton") as Button
	_expect(buy_button != null and not buy_button.disabled, "presenter should enable buy button when trading is allowed")
	_expect(sell_button != null and not sell_button.disabled, "presenter should enable sell button when trading is allowed")
	_expect(order_flow_button != null and order_flow_button.text == "회사 출근하기", "presenter should apply order flow text")
	_expect(closed_flow_button != null and closed_flow_button.text == "오늘 하루 보내기", "presenter should enable selected closed-day flow")
	_expect(not closed_flow_button.disabled, "selected closed-day flow should be enabled")

	MarketFlowControlsPresenterScript.apply(order_panel, closed_panel, {
		MarketFlowControlStateConfigScript.KEY_CAN_TRADE: false,
		MarketFlowControlStateConfigScript.KEY_ORDER_FLOW: {
			MarketFlowControlStateConfigScript.KEY_GAME_FINISHED: false,
			MarketFlowControlStateConfigScript.KEY_GAME_CLEAR: false,
			MarketFlowControlStateConfigScript.KEY_GAME_OVER: false,
			MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED: true,
			MarketFlowControlStateConfigScript.KEY_SLEEP_SEQUENCE: false,
			MarketFlowControlStateConfigScript.KEY_READY_TEXT: "오늘 하루 보내기"
		},
		MarketFlowControlStateConfigScript.KEY_CLOSED_FLOW: {
			MarketFlowControlStateConfigScript.KEY_GAME_FINISHED: false,
			MarketFlowControlStateConfigScript.KEY_GAME_CLEAR: false,
			MarketFlowControlStateConfigScript.KEY_GAME_OVER: false,
			MarketFlowControlStateConfigScript.KEY_DAY_COMPLETED: false,
			MarketFlowControlStateConfigScript.KEY_SLEEP_SEQUENCE: false,
			MarketFlowControlStateConfigScript.KEY_COMPLETING_DAY: true,
			MarketFlowControlStateConfigScript.KEY_HAS_SELECTION: true
		}
	})
	_expect(buy_button.disabled and sell_button.disabled, "presenter should disable order buttons when trading is blocked")
	_expect(order_flow_button.text == "잠들기", "completed order flow should become sleep")
	_expect(closed_flow_button.text == "진행 중", "completing closed-day flow should show progress")
	_expect(closed_flow_button.disabled, "completing closed-day flow should be disabled")

	MarketFlowControlsPresenterScript.apply(null, null, {})

	print("Market flow controls presenter smoke test passed.")
	finish_test()


func _find_primary_button_with_text(root_node: Node, text: String) -> Button:
	return _helpers.find_button_containing(root_node, text)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
