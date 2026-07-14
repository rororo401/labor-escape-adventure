class_name MarketScreenDayActionPresenter
extends RefCounted

const MarketDayActionSelectionScript := preload("res://scripts/ui/market_day_action_selection.gd")
const MarketDayActionSelectionResultConfigScript := preload("res://scripts/ui/market_day_action_selection_result_config.gd")
const MarketDayActionControlsPresenterScript := preload("res://scripts/ui/market_day_action_controls_presenter.gd")
const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")
const MarketDayResultStateConfigScript := preload("res://scripts/ui/market_day_result_state_config.gd")
const MarketScreenPanelFeedbackScript := preload("res://scripts/ui/market_screen_panel_feedback.gd")


static func apply_option_state(
	runtime_state,
	day_action_ids: Array,
	order_panel,
	closed_day_panel,
	state: Dictionary
) -> void:
	if runtime_state != null:
		runtime_state.selected_closed_day_category_id = String(
			state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID, runtime_state.selected_closed_day_category_id)
		)
		runtime_state.selected_day_action_id = String(
			state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, runtime_state.selected_day_action_id)
		)
	day_action_ids.assign(state.get(MarketDayActionOptionsConfigScript.KEY_ACTION_IDS, []))
	MarketDayActionControlsPresenterScript.apply(order_panel, closed_day_panel, state)


static func apply_closed_day_panel(closed_day_panel, state: Dictionary) -> void:
	MarketDayActionControlsPresenterScript.apply_closed_day_panel(closed_day_panel, state)


static func refresh_options(
	runtime_state,
	day_action_ids: Array,
	order_panel,
	closed_day_panel,
	game
) -> Dictionary:
	var selected_category_id := "" if runtime_state == null else String(runtime_state.selected_closed_day_category_id)
	var selected_action_id := "" if runtime_state == null else String(runtime_state.selected_day_action_id)
	var is_completing_day := false if runtime_state == null else bool(runtime_state.is_completing_day)
	var disabled := is_completing_day or (game != null and bool(game.day_completed))
	var state := MarketDayActionSelectionScript.refresh_state(
		game,
		selected_category_id,
		selected_action_id,
		disabled
	)
	apply_option_state(runtime_state, day_action_ids, order_panel, closed_day_panel, state)
	return state


static func select_action_index(runtime_state, day_action_ids: Array[String], index: int) -> String:
	var current_action_id := "" if runtime_state == null else String(runtime_state.selected_day_action_id)
	var action_id := MarketDayActionSelectionScript.selected_action_from_index(
		day_action_ids,
		index,
		current_action_id
	)
	if runtime_state != null:
		runtime_state.selected_day_action_id = action_id
	return action_id


static func select_category(runtime_state, order_panel, closed_day_panel, game, category_id: String) -> Dictionary:
	var selection := MarketDayActionSelectionScript.category_selected(game, category_id)
	if not bool(selection.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED)):
		return selection

	_apply_state(runtime_state, selection.get(MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE, {}))
	apply_closed_day_panel(closed_day_panel, selection.get(MarketDayActionSelectionResultConfigScript.KEY_PANEL_STATE, {}))
	MarketScreenPanelFeedbackScript.set_flow_message(
		order_panel,
		closed_day_panel,
		String(selection.get(MarketDayResultStateConfigScript.KEY_MESSAGE, MarketDayResultStateConfigScript.CLEAR_MESSAGE))
	)
	return selection


static func select_action(runtime_state, order_panel, closed_day_panel, game, action_id: String) -> Dictionary:
	var is_completing_day := false if runtime_state == null else bool(runtime_state.is_completing_day)
	var selection := MarketDayActionSelectionScript.action_selected(game, is_completing_day, action_id)
	if not bool(selection.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED)):
		return selection

	_apply_state(runtime_state, selection.get(MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE, {}))
	if closed_day_panel != null:
		closed_day_panel.select_action(String(selection.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, action_id)))
	MarketScreenPanelFeedbackScript.set_flow_message(
		order_panel,
		closed_day_panel,
		String(selection.get(MarketDayResultStateConfigScript.KEY_MESSAGE, MarketDayResultStateConfigScript.CLEAR_MESSAGE))
	)
	return selection


static func start_action(runtime_state, order_panel, closed_day_panel, game, action_id: String) -> Dictionary:
	var selection := select_action(runtime_state, order_panel, closed_day_panel, game, action_id)
	if not bool(selection.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED)):
		return selection

	var is_completing_day := false if runtime_state == null else bool(runtime_state.is_completing_day)
	var start := MarketDayActionSelectionScript.action_start(game, is_completing_day, action_id)
	if not bool(start.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED)):
		return start

	_apply_state(runtime_state, start.get(MarketDayActionSelectionResultConfigScript.KEY_SCREEN_STATE, {}))
	MarketScreenPanelFeedbackScript.set_closed_day_choice_buttons_disabled(
		closed_day_panel,
		bool(start.get(MarketDayActionSelectionResultConfigScript.KEY_DISABLE_CHOICES, MarketDayActionSelectionResultConfigScript.DEFAULT_DISABLE_CHOICES))
	)
	return start


static func _apply_state(runtime_state, state: Dictionary) -> void:
	if runtime_state != null:
		runtime_state.apply(state)
