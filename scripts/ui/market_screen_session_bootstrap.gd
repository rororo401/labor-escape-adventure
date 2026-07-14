class_name MarketScreenSessionBootstrap
extends RefCounted

const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketDayFlowTextConfigScript := preload("res://scripts/ui/market_day_flow_text_config.gd")
const MarketScreenSessionBootstrapConfigScript := preload("res://scripts/ui/market_screen_session_bootstrap_config.gd")

const SESSION_NOT_READY_MESSAGE := "시장 데이터를 불러오지 못했다."


static func resolve(node: Node) -> Dictionary:
	return from_session(GameSessionAccessScript.get_from_node(node))


static func from_session(session: Node) -> Dictionary:
	if session == null:
		return {
			MarketScreenSessionBootstrapConfigScript.KEY_OK: MarketScreenSessionBootstrapConfigScript.DEFAULT_OK,
			MarketScreenSessionBootstrapConfigScript.KEY_SESSION: null,
			MarketScreenSessionBootstrapConfigScript.KEY_GAME: null,
			MarketScreenSessionBootstrapConfigScript.KEY_MESSAGE: session_missing_message()
		}

	var game = session.get_game() if session.has_method("get_game") else null
	if not GameSessionAccessScript.is_ready(session):
		return {
			MarketScreenSessionBootstrapConfigScript.KEY_OK: MarketScreenSessionBootstrapConfigScript.DEFAULT_OK,
			MarketScreenSessionBootstrapConfigScript.KEY_SESSION: session,
			MarketScreenSessionBootstrapConfigScript.KEY_GAME: game,
			MarketScreenSessionBootstrapConfigScript.KEY_MESSAGE: SESSION_NOT_READY_MESSAGE
		}

	return {
		MarketScreenSessionBootstrapConfigScript.KEY_OK: true,
		MarketScreenSessionBootstrapConfigScript.KEY_SESSION: session,
		MarketScreenSessionBootstrapConfigScript.KEY_GAME: game,
		MarketScreenSessionBootstrapConfigScript.KEY_MESSAGE: MarketScreenSessionBootstrapConfigScript.EMPTY_MESSAGE
	}


static func session_missing_message() -> String:
	return MarketDayFlowTextScript.flow_error_message(MarketDayFlowTextConfigScript.FLOW_ERROR_GAME_NOT_STARTED)
