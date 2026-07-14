extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenSessionBootstrapConfigScript := preload("res://scripts/ui/market_screen_session_bootstrap_config.gd")
const MarketScreenSessionBootstrapScript := preload("res://scripts/ui/market_screen_session_bootstrap.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketDayFlowTextConfigScript := preload("res://scripts/ui/market_day_flow_text_config.gd")


func _initialize() -> void:
	var missing := MarketScreenSessionBootstrapScript.from_session(null)
	_expect(not bool(missing.get(MarketScreenSessionBootstrapConfigScript.KEY_OK, true)), "missing session should fail bootstrap")
	_expect(missing.get(MarketScreenSessionBootstrapConfigScript.KEY_SESSION) == null, "missing session should expose null session")
	_expect(missing.get(MarketScreenSessionBootstrapConfigScript.KEY_GAME) == null, "missing session should expose null game")
	_expect(
		String(missing.get(MarketScreenSessionBootstrapConfigScript.KEY_MESSAGE, "")) == MarketDayFlowTextScript.flow_error_message(MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_NOT_STARTED),
		"missing session should expose the missing-session message"
	)

	var unready_session := FakeSession.new(false, {"date": "2016-07-01"})
	var unready := MarketScreenSessionBootstrapScript.from_session(unready_session)
	_expect(not bool(unready.get(MarketScreenSessionBootstrapConfigScript.KEY_OK, true)), "unready session should fail bootstrap")
	_expect(unready.get(MarketScreenSessionBootstrapConfigScript.KEY_SESSION) == unready_session, "unready session should preserve session")
	_expect(Dictionary(unready.get(MarketScreenSessionBootstrapConfigScript.KEY_GAME, {})).get("date", "") == "2016-07-01", "unready session should still expose game")
	_expect(
		String(unready.get(MarketScreenSessionBootstrapConfigScript.KEY_MESSAGE, "")) == MarketScreenSessionBootstrapScript.SESSION_NOT_READY_MESSAGE,
		"unready session should expose the not-ready message"
	)

	var ready_session := FakeSession.new(true, {"date": "2016-07-02"})
	var ready := MarketScreenSessionBootstrapScript.from_session(ready_session)
	_expect(bool(ready.get(MarketScreenSessionBootstrapConfigScript.KEY_OK, false)), "ready session should pass bootstrap")
	_expect(ready.get(MarketScreenSessionBootstrapConfigScript.KEY_SESSION) == ready_session, "ready session should preserve session")
	_expect(Dictionary(ready.get(MarketScreenSessionBootstrapConfigScript.KEY_GAME, {})).get("date", "") == "2016-07-02", "ready session should expose game")
	_expect(String(ready.get(MarketScreenSessionBootstrapConfigScript.KEY_MESSAGE, "bad")).is_empty(), "ready session should not expose an error message")

	unready_session.free()
	ready_session.free()

	print("Market screen session bootstrap smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakeSession:
	extends Node

	var is_ready := false
	var game := {}

	func _init(next_is_ready: bool, next_game: Dictionary) -> void:
		is_ready = next_is_ready
		game = next_game

	func get_game() -> Dictionary:
		return game
