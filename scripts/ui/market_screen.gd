extends Control

const DayEventSceneRunnerScript := preload("res://scripts/ui/day_event_scene_runner.gd")
const MarketDayCompletionScreenFlowScript := preload("res://scripts/ui/market_day_completion_screen_flow.gd")
const MarketScreenDayCompletionLauncherScript := preload("res://scripts/ui/market_screen_day_completion_launcher.gd")
const MarketScreenDayActionPresenterScript := preload("res://scripts/ui/market_screen_day_action_presenter.gd")
const MarketScreenDayCompletionPresenterScript := preload("res://scripts/ui/market_screen_day_completion_presenter.gd")
const MarketScreenFlowCoordinatorScript := preload("res://scripts/ui/market_screen_flow_coordinator.gd")
const MarketScreenFlowControlsCoordinatorScript := preload("res://scripts/ui/market_screen_flow_controls_coordinator.gd")
const MarketScreenOrderPresenterScript := preload("res://scripts/ui/market_screen_order_presenter.gd")
const MarketScreenRefreshCoordinatorScript := preload("res://scripts/ui/market_screen_refresh_coordinator.gd")
const MarketScreenSelectionPresenterScript := preload("res://scripts/ui/market_screen_selection_presenter.gd")
const MarketFlowActionConfigScript := preload("res://scripts/ui/market_flow_action_config.gd")
const MarketDayActionSelectionResultConfigScript := preload("res://scripts/ui/market_day_action_selection_result_config.gd")
const MarketScreenConfigScript := preload("res://scripts/ui/market_screen_config.gd")
const MarketScreenRefreshResultConfigScript := preload("res://scripts/ui/market_screen_refresh_result_config.gd")
const MarketScreenSessionBootstrapScript := preload("res://scripts/ui/market_screen_session_bootstrap.gd")
const MarketScreenSessionBootstrapConfigScript := preload("res://scripts/ui/market_screen_session_bootstrap_config.gd")
const MarketScreenViewScript := preload("res://scripts/ui/market_screen_view.gd")
const MarketScreenViewConfigScript := preload("res://scripts/ui/market_screen_view_config.gd")
const MarketSleepScreenFlowScript := preload("res://scripts/ui/market_sleep_screen_flow.gd")
const MarketSleepFlowConfigScript := preload("res://scripts/ui/market_sleep_flow_config.gd")
const MarketOrderFlowConfigScript := preload("res://scripts/ui/market_order_flow_config.gd")
const MarketScreenPanelFeedbackScript := preload("res://scripts/ui/market_screen_panel_feedback.gd")
const MarketScreenRuntimeStateScript := preload("res://scripts/ui/market_screen_runtime_state.gd")
const MarketSettingsOverlayConfigScript := preload("res://scripts/ui/market_settings_overlay_config.gd")
const ClearEndingStoryScript := preload("res://scripts/core/clear_ending_story.gd")
const BadEndingStoryScript := preload("res://scripts/core/bad_ending_story.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")
const VisualNovelEventLayerScript := preload("res://scripts/ui/visual_novel_event_layer.gd")

var _game: GameState
var _market_context := {}
var _day_action_ids: Array[String] = []
var _screen_state = MarketScreenRuntimeStateScript.new()
var _shown_market_fixed_event_ids := {}

var _hud
var _stock_list_panel
var _order_panel
var _closed_day_panel
var _status_overlay
var _settings_overlay
var _save_slot_overlay
var _gallery_overlay
var _result_popup
var _ending_overlay
var _ending_story_layer: Control
var _pending_ending_result := {}
var _day_event_runner = DayEventSceneRunnerScript.new()
var _day_completion_screen_flow = MarketDayCompletionScreenFlowScript.new()
var _mode_view


func _ready() -> void:
	_build_screen()
	var bootstrap := MarketScreenSessionBootstrapScript.resolve(self)
	_game = bootstrap.get(MarketScreenSessionBootstrapConfigScript.KEY_GAME)
	if not bool(bootstrap.get(MarketScreenSessionBootstrapConfigScript.KEY_OK, MarketScreenSessionBootstrapConfigScript.DEFAULT_OK)):
		_set_flow_message(String(bootstrap.get(
			MarketScreenSessionBootstrapConfigScript.KEY_MESSAGE,
			MarketScreenSessionBootstrapConfigScript.EMPTY_MESSAGE
		)))
		return
	_refresh_market()


func _build_screen() -> void:
	var view_nodes: Dictionary = MarketScreenViewScript.build(
		self,
		MarketScreenConfigScript.MARKET_BACKGROUND_PATH,
		_screen_callbacks()
	)
	_hud = view_nodes.get(MarketScreenViewConfigScript.KEY_HUD)
	_stock_list_panel = view_nodes.get(MarketScreenViewConfigScript.KEY_STOCK_LIST_PANEL)
	_order_panel = view_nodes.get(MarketScreenViewConfigScript.KEY_ORDER_PANEL)
	_closed_day_panel = view_nodes.get(MarketScreenViewConfigScript.KEY_CLOSED_DAY_PANEL)
	_status_overlay = view_nodes.get(MarketScreenViewConfigScript.KEY_STATUS_OVERLAY)
	_settings_overlay = view_nodes.get(MarketScreenViewConfigScript.KEY_SETTINGS_OVERLAY)
	_save_slot_overlay = view_nodes.get(MarketScreenViewConfigScript.KEY_SAVE_SLOT_OVERLAY)
	_gallery_overlay = view_nodes.get(MarketScreenViewConfigScript.KEY_GALLERY_OVERLAY)
	_result_popup = view_nodes.get(MarketScreenViewConfigScript.KEY_RESULT_POPUP)
	_ending_overlay = view_nodes.get(MarketScreenViewConfigScript.KEY_ENDING_OVERLAY)
	_mode_view = view_nodes.get(MarketScreenViewConfigScript.KEY_MODE_VIEW)


func _refresh_market(play_fixed_event: bool = true) -> void:
	var refresh_result := MarketScreenRefreshCoordinatorScript.refresh(
		_game,
		_screen_state,
		_hud,
		_stock_list_panel,
		_order_panel,
		_closed_day_panel,
		_mode_view,
		MarketScreenConfigScript.MARKET_BACKGROUND_PATH,
		MarketScreenConfigScript.CLOSED_DAY_BACKGROUND_PATH
	)
	_market_context = refresh_result.get(MarketScreenRefreshResultConfigScript.KEY_MARKET_CONTEXT, {})
	_refresh_day_action_options()
	_refresh_flow_controls()
	var completed_message := String(refresh_result.get(
		MarketScreenRefreshResultConfigScript.KEY_COMPLETED_MESSAGE,
		MarketScreenRefreshResultConfigScript.EMPTY_MESSAGE
	))
	if not completed_message.is_empty():
		_set_flow_message(completed_message)
	if play_fixed_event:
		_queue_market_fixed_event()


func _queue_market_fixed_event() -> void:
	call_deferred("_play_market_fixed_event_if_needed")


func _refresh_day_action_options() -> void:
	_day_action_ids.clear()
	MarketScreenDayActionPresenterScript.refresh_options(
		_screen_state,
		_day_action_ids,
		_order_panel,
		_closed_day_panel,
		_game,
	)


func _select_closed_day_category(category_id: String) -> void:
	var selection := MarketScreenDayActionPresenterScript.select_category(
		_screen_state,
		_order_panel,
		_closed_day_panel,
		_game,
		category_id
	)
	if not bool(selection.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED)):
		return

	_refresh_flow_controls()


func _select_closed_day_action(action_id: String) -> void:
	var selection := MarketScreenDayActionPresenterScript.select_action(
		_screen_state,
		_order_panel,
		_closed_day_panel,
		_game,
		action_id
	)
	if not bool(selection.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED)):
		return

	_refresh_flow_controls()


func _start_closed_day_action(action_id: String) -> void:
	var start := MarketScreenDayActionPresenterScript.start_action(
		_screen_state,
		_order_panel,
		_closed_day_panel,
		_game,
		action_id
	)
	if not bool(start.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, MarketDayActionSelectionResultConfigScript.DEFAULT_ACCEPTED)):
		return

	_refresh_flow_controls()
	call_deferred("_complete_closed_day_action")


func _complete_closed_day_action() -> void:
	await MarketScreenDayCompletionLauncherScript.play_closed_day_action(
		self,
		_day_completion_screen_flow,
		_day_event_runner,
		_game,
		_selected_day_action_id(),
		_market_context,
		MarketScreenConfigScript.CLOSED_DAY_BACKGROUND_PATH,
		_day_completion_callbacks()
	)


func _finish_day_completion(result: Dictionary) -> void:
	MarketScreenDayCompletionPresenterScript.apply_success(_screen_state, _order_panel, _closed_day_panel, result)
	_refresh_market()
	if _result_popup != null:
		_queue_ending_after_result_popup(result)
		_result_popup.show_result(result)
	elif bool(result.get(DayEventKeysScript.KEY_GAME_FINISHED, false)):
		_show_ending(result)


func _apply_day_completion_error(completion: Dictionary, update_closed_day_choices: bool = true) -> void:
	MarketScreenDayCompletionPresenterScript.apply_error(
		_screen_state,
		_order_panel,
		_closed_day_panel,
		completion,
		update_closed_day_choices
	)
	_refresh_flow_controls()


func _refresh_flow_controls() -> void:
	MarketScreenFlowControlsCoordinatorScript.refresh(
		_game,
		_selected_day_action_id(),
		_is_sleep_sequence(),
		_is_completing_day(),
		_market_context,
		_order_panel,
		_closed_day_panel
	)


func _select_stock(ticker: String) -> void:
	MarketScreenSelectionPresenterScript.select_stock(_screen_state, _order_panel, _market_context, ticker)


func _submit_order(side: String) -> void:
	var order_flow := MarketScreenOrderPresenterScript.submit_order(
		_selected_stock(),
		_order_quantity(),
		_apply_market_screen_state,
		_order_panel,
		_closed_day_panel,
		_game,
		side
	)
	if not bool(order_flow.get(MarketOrderFlowConfigScript.KEY_HANDLED, MarketOrderFlowConfigScript.DEFAULT_HANDLED)):
		return

	_refresh_market()


func _handle_flow_button() -> void:
	var decision := MarketScreenFlowCoordinatorScript.flow_button_action(
		_game,
		_is_sleep_sequence(),
		_is_completing_day()
	)
	match String(decision.get(MarketFlowActionConfigScript.KEY_ACTION, MarketFlowActionConfigScript.EMPTY_ACTION)):
		MarketScreenFlowCoordinatorScript.ACTION_SLEEP:
			await _sleep_to_next_day()
		MarketScreenFlowCoordinatorScript.ACTION_COMPLETE_DAY:
			await _complete_today()
		_:
			return


func _complete_today() -> void:
	var completion_decision := MarketScreenFlowCoordinatorScript.day_completion_request(
		_game,
		_order_panel,
		_closed_day_panel
	)
	match String(completion_decision.get(MarketFlowActionConfigScript.KEY_ACTION, MarketFlowActionConfigScript.EMPTY_ACTION)):
		MarketScreenFlowCoordinatorScript.ACTION_MESSAGE:
			return
		MarketScreenFlowCoordinatorScript.ACTION_CHANGE_SCENE:
			get_tree().change_scene_to_file(String(completion_decision.get(MarketFlowActionConfigScript.KEY_SCENE_PATH, MarketFlowActionConfigScript.EMPTY_SCENE_PATH)))
			return
		MarketScreenFlowCoordinatorScript.ACTION_COMPLETE_DAY:
			pass
		_:
			return

	await MarketScreenDayCompletionLauncherScript.play_today(
		self,
		_day_completion_screen_flow,
		_day_event_runner,
		_game,
		_selected_day_action_id(),
		_market_context,
		MarketScreenConfigScript.CLOSED_DAY_BACKGROUND_PATH,
		_day_completion_callbacks()
	)


func _sleep_to_next_day() -> void:
	var previous_day_index := -1 if _game == null else int(_game.day_index)
	var sleep_screen_flow = MarketSleepScreenFlowScript.new()
	await sleep_screen_flow.play(
		self,
		_game,
		_sleep_callbacks()
	)
	if _game != null and int(_game.day_index) != previous_day_index:
		_auto_save_after_day_transition()


func _auto_save_after_day_transition() -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null or not game_session.has_method("auto_save_current_game"):
		return
	var result: Dictionary = game_session.auto_save_current_game()
	if not bool(result.get("ok", false)):
		_set_flow_message("자동 저장에 실패했어. 설정에서 수동 저장을 확인해줘.")


func _set_flow_message(text: String) -> void:
	MarketScreenPanelFeedbackScript.set_flow_message(_order_panel, _closed_day_panel, text)


func _play_market_fixed_event_if_needed() -> void:
	if _game == null or bool(_game.day_completed):
		return
	var event := Dictionary(_market_context.get(DayEventKeysScript.KEY_MARKET_FIXED_EVENT, {}))
	var event_id := String(event.get(DayEventKeysScript.KEY_ID, ""))
	if event_id.is_empty() or _shown_market_fixed_event_ids.has(event_id) or _game.has_seen_market_fixed_event(event_id):
		return
	_shown_market_fixed_event_ids[event_id] = true
	_game.mark_market_fixed_event_seen(event_id)
	_day_event_runner.begin(
		self,
		event,
		MarketScreenConfigScript.MARKET_BACKGROUND_PATH,
		Callable(),
		String(event.get(DayEventKeysScript.KEY_DATE, ""))
	)


func _apply_market_screen_state(state: Dictionary) -> void:
	_screen_state.apply(state)


func _screen_callbacks() -> Dictionary:
	return MarketScreenViewConfigScript.screen_callbacks(
		_select_stock,
		_decrease_quantity,
		_increase_quantity,
		_submit_order,
		_on_day_action_selected,
		_select_closed_day_category,
		_start_closed_day_action,
		_handle_flow_button,
		_show_status_overlay,
		_show_settings_menu,
		_save_from_settings_menu,
		_show_gallery_from_settings_menu,
		_return_to_title_from_settings_menu,
		_return_to_title_from_ending,
		_start_new_game_from_ending,
		_save_to_slot,
		_load_from_slot
	)


func _day_completion_callbacks() -> Dictionary:
	return MarketScreenDayCompletionLauncherScript.make_callbacks(
		_apply_day_completion_error,
		_finish_day_completion
	)


func _selected_day_action_id() -> String:
	return String(_screen_state.selected_day_action_id)


func _selected_stock() -> Dictionary:
	return Dictionary(_screen_state.selected_stock)


func _order_quantity() -> int:
	return int(_screen_state.quantity)


func _is_sleep_sequence() -> bool:
	return bool(_screen_state.is_sleep_sequence)


func _is_completing_day() -> bool:
	return bool(_screen_state.is_completing_day)


func _sleep_callbacks() -> Dictionary:
	return MarketSleepFlowConfigScript.screen_callbacks(
		_apply_market_screen_state,
		_set_flow_message,
		_refresh_flow_controls,
		_refresh_market.bind(false),
		_queue_market_fixed_event
	)


func _increase_quantity() -> void:
	MarketScreenSelectionPresenterScript.increase_quantity(_screen_state, _order_panel)


func _decrease_quantity() -> void:
	MarketScreenSelectionPresenterScript.decrease_quantity(_screen_state, _order_panel)


func _on_day_action_selected(index: int) -> void:
	MarketScreenDayActionPresenterScript.select_action_index(
		_screen_state,
		_day_action_ids,
		index
	)


func _show_status_overlay() -> void:
	if _status_overlay != null:
		_status_overlay.show_for_game(_game)


func _show_settings_menu() -> void:
	if _settings_overlay != null:
		_settings_overlay.show_for_game(_game)


func _save_from_settings_menu() -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null or _save_slot_overlay == null:
		_show_settings_message(MarketSettingsOverlayConfigScript.SAVE_FAILED_MESSAGE)
		return
	_save_slot_overlay.show_slots(game_session.get_save_slot_summaries())


func _save_to_slot(_kind: String, slot_index: int) -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null or _save_slot_overlay == null:
		return
	var result: Dictionary = game_session.save_manual_slot(slot_index)
	_save_slot_overlay.show_slots(game_session.get_save_slot_summaries())
	_save_slot_overlay.set_message("수동 저장 완료" if bool(result.get("ok", false)) else "저장하지 못했어")


func _load_from_slot(kind: String, slot_index: int) -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null or _save_slot_overlay == null:
		return
	var result: Dictionary = game_session.load_save_slot(kind, slot_index)
	if not bool(result.get("ok", false)):
		_save_slot_overlay.set_message("불러오지 못했어")
		return
	_game = game_session.get_game()
	_save_slot_overlay.hide()
	if _settings_overlay != null:
		_settings_overlay.hide()
	_refresh_market()


func _show_gallery_from_settings_menu() -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session != null and game_session.has_method("sync_event_history_to_gallery"):
		game_session.sync_event_history_to_gallery()
	if _gallery_overlay != null:
		_gallery_overlay.show_gallery()


func _return_to_title_from_settings_menu() -> void:
	get_tree().change_scene_to_file(UiScenePathsScript.INTRO_SCREEN)


func _return_to_title_from_ending() -> void:
	get_tree().change_scene_to_file(UiScenePathsScript.INTRO_SCREEN)


func _start_new_game_from_ending() -> void:
	get_tree().change_scene_to_file(UiScenePathsScript.PROFILE_SETUP)


func _show_settings_message(text: String) -> void:
	if _settings_overlay != null:
		_settings_overlay.set_message(text)
	else:
		_set_flow_message(text)


func _queue_ending_after_result_popup(result: Dictionary) -> void:
	if not bool(result.get(DayEventKeysScript.KEY_GAME_FINISHED, false)):
		return
	_pending_ending_result = result.duplicate(true)
	if not _result_popup.closed.is_connected(_show_pending_ending):
		_result_popup.closed.connect(_show_pending_ending)


func _show_pending_ending() -> void:
	if _pending_ending_result.is_empty():
		return
	var result := _pending_ending_result.duplicate(true)
	_pending_ending_result = {}
	_show_ending(result)


func _show_ending(result: Dictionary) -> void:
	if bool(result.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, false)):
		_play_clear_ending_story(result)
		return
	if String(result.get(PlayerStatusKeysScript.KEY_GAME_OVER_REASON, "")) == PlayerStatusKeysScript.GAME_OVER_REASON_FINAL_BAD_ENDING:
		_play_bad_ending_story(result)
		return
	_show_ending_summary(result)


func _play_clear_ending_story(result: Dictionary) -> void:
	_play_ending_story(
		result,
		ClearEndingStoryScript.TARGET_REACHED_CG,
		ClearEndingStoryScript.steps(),
		ClearEndingStoryScript.gallery_events()
	)


func _play_bad_ending_story(result: Dictionary) -> void:
	var route := String(result.get(PlayerStatusKeysScript.KEY_ENDING_ROUTE, ""))
	if not BadEndingStoryScript.has_route(route):
		_show_ending_summary(result)
		return
	_play_ending_story(
		result,
		BadEndingStoryScript.cg_path(route),
		BadEndingStoryScript.steps(route),
		[BadEndingStoryScript.gallery_event(route)]
	)


func _play_ending_story(result: Dictionary, initial_cg_path: String, steps: Array[Dictionary], gallery_events: Array) -> void:
	if _ending_story_layer != null and is_instance_valid(_ending_story_layer):
		return
	_unlock_ending_gallery(gallery_events)
	_ending_story_layer = VisualNovelEventLayerScript.new()
	add_child(_ending_story_layer)
	_ending_story_layer.finished.connect(func() -> void:
		_ending_story_layer = null
		_show_ending_summary(result)
	, CONNECT_ONE_SHOT)
	var empty_lines: Array[String] = []
	_ending_story_layer.play(
		initial_cg_path,
		"",
		empty_lines,
		{
			"date": String(result.get(DayEventKeysScript.KEY_DATE, BadEndingStoryScript.EVENT_DATE)),
			"steps": steps,
			"show_character": false
		}
	)


func _unlock_ending_gallery(events: Array) -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null or not game_session.has_method("unlock_event_cg"):
		return
	for event in events:
		var row := Dictionary(event)
		game_session.unlock_event_cg(
			row,
			String(row.get(DayEventKeysScript.KEY_CG_PATH, "")),
			String(row.get(DayEventKeysScript.KEY_DATE, BadEndingStoryScript.EVENT_DATE))
		)


func _show_ending_summary(result: Dictionary) -> void:
	if _ending_overlay != null:
		_ending_overlay.show_result(result)
