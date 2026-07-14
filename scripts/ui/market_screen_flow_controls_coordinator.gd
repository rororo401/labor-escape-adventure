class_name MarketScreenFlowControlsCoordinator
extends RefCounted

const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const MarketFlowControlsPresenterScript := preload("res://scripts/ui/market_flow_controls_presenter.gd")
const MarketFlowStateScript := preload("res://scripts/ui/market_flow_state.gd")


static func refresh(
	game,
	selected_day_action_id: String,
	is_sleep_sequence: bool,
	is_completing_day: bool,
	market_context: Dictionary,
	order_panel,
	closed_day_panel
) -> Dictionary:
	var state := MarketFlowStateScript.build_control_state(
		game,
		bool(market_context.get(GameStateContextKeysScript.KEY_IS_OPEN, false)),
		selected_day_action_id,
		is_sleep_sequence,
		is_completing_day,
		MarketDayFlowTextScript.ready_text(game)
	)
	MarketFlowControlsPresenterScript.apply(order_panel, closed_day_panel, state)
	return state
