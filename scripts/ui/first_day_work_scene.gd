extends Control

const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const FirstDayWorkSceneConfigScript := preload("res://scripts/ui/first_day_work_scene_config.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")
const VnStoryRuntimeScript := preload("res://scripts/core/vn_story_runtime.gd")
const VnMixedSceneViewScript := preload("res://scripts/ui/vn_mixed_scene_view.gd")
const VnSceneSequenceRunnerScript := preload("res://scripts/ui/vn_scene_sequence_runner.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")

var _steps: Array[Dictionary] = []
var _is_finishing := false
var _vn_runner = VnSceneSequenceRunnerScript.new()

var _story_runtime = VnStoryRuntimeScript.new()
var _scene_view = VnMixedSceneViewScript.new()


func _ready() -> void:
	_story_runtime.load(
		FirstDayWorkSceneConfigScript.VN_STORIES_PATH,
		FirstDayWorkSceneConfigScript.NPC_NAMES_PATH
	)
	_build_steps()
	_build_screen()
	_vn_runner.connect_step_changed(_on_step_changed)
	_vn_runner.finished.connect(_finish_first_day)
	_vn_runner.set_steps(_steps)


func _process(delta: float) -> void:
	_vn_runner.update(delta)


func _input(event: InputEvent) -> void:
	_vn_runner.handle_input(event, get_viewport())


func _advance_dialogue() -> void:
	_vn_runner.advance()


func _build_steps() -> void:
	_steps = _story_runtime.get_steps(
		FirstDayWorkSceneConfigScript.STORY_ID,
		_story_runtime.npc_substitutions({
			FirstDayWorkSceneConfigScript.NPC_BOX_TRADING_MANAGER: FirstDayWorkSceneConfigScript.FALLBACK_BOX_TRADING_MANAGER_NAME
		})
	)


func _build_screen() -> void:
	var default_visual := _story_runtime.get_visual_mode(
		FirstDayWorkSceneConfigScript.STORY_ID,
		_story_runtime.get_default_visual_mode(FirstDayWorkSceneConfigScript.STORY_ID)
	)
	_scene_view.build(self, {
		VnStoryKeysScript.KEY_BACKGROUND_PATH: String(default_visual.get(VnStoryKeysScript.KEY_BACKGROUND_PATH, "")),
		VnStoryKeysScript.KEY_DATE_TEXT: String(default_visual.get(VnStoryKeysScript.KEY_DATE_TEXT, "")),
		VnStoryKeysScript.KEY_HUD_OPTIONS: {
			VnTopHudConfigScript.OPTION_STATUS: _current_status()
		},
		VnStoryKeysScript.KEY_DIALOGUE_OPTIONS: {
			VnDialogueBoxConfigScript.OPTION_NAME_WIDTH: FirstDayWorkSceneConfigScript.DIALOGUE_NAME_WIDTH
		}
	})
	_vn_runner.bind_to_view(_scene_view)
	_scene_view.bind_auto_advance(self, _vn_runner)


func _on_step_changed(step: Dictionary, _index: int) -> void:
	_apply_step_visuals(step)
	_scene_view.set_speaker_name(_speaker_name(step))


func _apply_step_visuals(step: Dictionary) -> void:
	var visual := _story_runtime.get_visual_mode(
		FirstDayWorkSceneConfigScript.STORY_ID,
		String(step.get(VnStoryKeysScript.KEY_MODE, ""))
	)
	_scene_view.apply_step_visual(self, visual, step, _current_date())


func _finish_first_day() -> void:
	if _is_finishing:
		return

	_is_finishing = true
	_vn_runner.block()
	var game_session := GameSessionAccessScript.get_from_node(self)
	if game_session == null:
		_show_finish_error(FirstDayWorkSceneConfigScript.flow_error_message(GameStateGuardResultScript.ERROR_GAME_NOT_STARTED))
		return

	var result: Dictionary = game_session.get_game().complete_today(FirstDayWorkSceneConfigScript.DAY_ACTION_ID, [], true)
	if not result.get(GameStateGuardResultScript.KEY_OK, false):
		_show_finish_error(FirstDayWorkSceneConfigScript.flow_error_message(String(result.get(GameStateGuardResultScript.KEY_ERROR, ""))))
		return

	get_tree().change_scene_to_file(FirstDayWorkSceneConfigScript.MARKET_SCENE_PATH)


func _show_finish_error(message: String) -> void:
	_is_finishing = false
	_vn_runner.unblock()
	_vn_runner.pause_auto_advance()
	_vn_runner.show_complete(message)


func _speaker_name(step: Dictionary) -> String:
	return _story_runtime.speaker_name(step)


func _current_status() -> Dictionary:
	var game_session := GameSessionAccessScript.get_from_node(self)
	if game_session == null or not GameSessionAccessScript.is_ready(game_session):
		return {}
	return game_session.get_game().status.to_dict()


func _current_date() -> String:
	var game_session := GameSessionAccessScript.get_from_node(self)
	if game_session == null or not GameSessionAccessScript.is_ready(game_session):
		return ""
	return String(game_session.get_game().get_today_context().get("date", ""))
