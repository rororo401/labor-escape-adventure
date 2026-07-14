extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenSessionBootstrapConfigScript := preload("res://scripts/ui/market_screen_session_bootstrap_config.gd")
const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")


func _initialize() -> void:
	_expect(MarketScreenSessionBootstrapConfigScript.KEY_OK == ResultKeysScript.KEY_OK, "ok key should use the shared result key")
	_expect(MarketScreenSessionBootstrapConfigScript.KEY_SESSION == GameSessionAccessScript.KEY_SESSION, "session key should use the shared session access key")
	_expect(MarketScreenSessionBootstrapConfigScript.KEY_GAME == GameSessionAccessScript.KEY_GAME, "game key should use the shared session access key")
	_expect(MarketScreenSessionBootstrapConfigScript.KEY_MESSAGE == UiPayloadKeysScript.KEY_MESSAGE, "message key should use the shared UI payload key")
	_expect(not MarketScreenSessionBootstrapConfigScript.DEFAULT_OK, "default ok should stay false")
	_expect(MarketScreenSessionBootstrapConfigScript.EMPTY_MESSAGE == UiPayloadKeysScript.EMPTY_MESSAGE, "empty message should use the shared empty UI message")

	print("Market screen session bootstrap config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
