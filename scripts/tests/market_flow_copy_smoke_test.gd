extends "res://scripts/tests/test_scene_tree.gd"

const MarketFlowCopyScript := preload("res://scripts/ui/market_flow_copy.gd")
const MarketOrderPanelConfigScript := preload("res://scripts/ui/market_order_panel_config.gd")


func _initialize() -> void:
	_expect(MarketFlowCopyScript.DEFAULT_READY_TEXT == "오늘 하루 보내기", "default ready text should stay stable")
	_expect(MarketFlowCopyScript.SLEEP_TEXT == "잠들기", "sleep text should stay stable")
	_expect(MarketFlowCopyScript.GAME_CLEAR_TEXT == "게임 완료", "clear text should stay stable")
	_expect(MarketFlowCopyScript.GAME_OVER_TEXT == "게임오버", "game-over text should stay stable")
	_expect(MarketFlowCopyScript.IN_PROGRESS_TEXT == "진행 중", "progress text should stay stable")
	_expect(MarketFlowCopyScript.ACTION_REQUIRED_TEXT == "할 일 선택 필요", "action-required text should stay stable")
	_expect(MarketOrderPanelConfigScript.DEFAULT_FLOW_TEXT == MarketFlowCopyScript.DEFAULT_READY_TEXT, "order panel config should reuse shared default text")

	print("Market flow copy smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
