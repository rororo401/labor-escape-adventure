extends "res://scripts/tests/test_scene_tree.gd"

const MarketStatusTextConfigScript := preload("res://scripts/ui/market_status_text_config.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketStatusTextConfigScript.KEY_CASH == PlayerStatusKeysScript.KEY_CASH, "cash key should use the shared player-status key")
	_expect(MarketStatusTextConfigScript.KEY_NET_WORTH == PlayerStatusKeysScript.KEY_NET_WORTH, "net-worth key should use the shared player-status key")
	_expect(MarketStatusTextConfigScript.CASH_LABEL == "현금", "cash label should stay stable")
	_expect(MarketStatusTextConfigScript.NET_WORTH_LABEL == "순자산", "net-worth label should stay stable")
	_expect(MarketStatusTextConfigScript.EMPTY_TEXT == UiPayloadKeysScript.EMPTY_MESSAGE, "empty text should use the shared UI payload default")
	_expect(MarketStatusTextConfigScript.DEFAULT_AMOUNT == 0, "default amount should stay zero")

	print("Market status text config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
