extends Control

const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")
const MarketSleepSequenceScript := preload("res://scripts/ui/market_sleep_sequence.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const VnStoryRuntimeScript := preload("res://scripts/core/vn_story_runtime.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")
const VnMixedSceneViewScript := preload("res://scripts/ui/vn_mixed_scene_view.gd")
const PrologueSceneConfigScript := preload("res://scripts/ui/prologue_scene_config.gd")
const VnSceneSequenceRunnerScript := preload("res://scripts/ui/vn_scene_sequence_runner.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")

var _is_transitioning := false
var _vn_runner = VnSceneSequenceRunnerScript.new()
var _story_runtime = VnStoryRuntimeScript.new()
var _scene_view = VnMixedSceneViewScript.new()


func _ready() -> void:
	_story_runtime.load(PrologueSceneConfigScript.VN_STORIES_PATH)
	_start_fresh_game_session()
	_build_screen()
	_vn_runner.connect_step_changed(_on_step_changed)
	_vn_runner.finished.connect(_on_dialogue_finished)
	_vn_runner.set_steps(_story_runtime.get_steps(PrologueSceneConfigScript.STORY_ID))


func _process(delta: float) -> void:
	_vn_runner.update(delta)


func _input(event: InputEvent) -> void:
	_vn_runner.handle_input(event, get_viewport())


func _advance_dialogue() -> void:
	_vn_runner.advance()


func _build_screen() -> void:
	_scene_view.build(self, {
		VnStoryKeysScript.KEY_BACKGROUND_NAME: PrologueSceneConfigScript.BACKGROUND_NAME,
		VnStoryKeysScript.KEY_BACKGROUND_PATH: PrologueSceneConfigScript.BACKGROUND_PATH,
		VnStoryKeysScript.KEY_DATE_TEXT: PrologueSceneConfigScript.DATE_TEXT,
		VnStoryKeysScript.KEY_CHARACTER_NAME: PrologueSceneConfigScript.CHARACTER_NAME,
		VnStoryKeysScript.KEY_SPEAKER_NAME: _story_runtime.player_name(),
		VnStoryKeysScript.KEY_HUD_OPTIONS: {
			VnTopHudConfigScript.OPTION_DATE_WIDTH: PrologueSceneConfigScript.HUD_DATE_WIDTH,
			VnTopHudConfigScript.OPTION_STATUS: _current_status()
		},
		VnStoryKeysScript.KEY_DIALOGUE_OPTIONS: {
			VnDialogueBoxConfigScript.OPTION_DIALOGUE_POSITION: PrologueSceneConfigScript.DIALOGUE_POSITION,
			VnDialogueBoxConfigScript.OPTION_DIALOGUE_SIZE: PrologueSceneConfigScript.DIALOGUE_SIZE,
			VnDialogueBoxConfigScript.OPTION_DIALOGUE_FONT_SIZE: PrologueSceneConfigScript.DIALOGUE_FONT_SIZE
		}
	})
	_vn_runner.bind_to_view(_scene_view, PrologueSceneConfigScript.CHARACTERS_PER_SECOND)
	_scene_view.bind_auto_advance(self, _vn_runner)


func _on_step_changed(step: Dictionary, _index: int) -> void:
	_set_character_expression(String(step.get(VnStoryKeysScript.KEY_EXPRESSION, PrologueSceneConfigScript.DEFAULT_EXPRESSION)))


func _on_dialogue_finished() -> void:
	if _is_transitioning:
		return

	_vn_runner.block()
	await _play_first_morning_transition()
	get_tree().change_scene_to_file(PrologueSceneConfigScript.MARKET_SCENE_PATH)


func _play_first_morning_transition() -> void:
	_is_transitioning = true
	var sleep_sequence: Control = MarketSleepSequenceScript.new()
	sleep_sequence.name = PrologueSceneConfigScript.SLEEP_SEQUENCE_NAME
	add_child(sleep_sequence)
	await sleep_sequence.play_sleep_intro()
	await sleep_sequence.play_date_transition({
		GameDayProgressKeysScript.KEY_FROM_DATE: PrologueSceneConfigScript.PROLOGUE_DATE,
		GameDayProgressKeysScript.KEY_TO_DATE: PrologueSceneConfigScript.FIRST_MARKET_DATE,
		GameDayProgressKeysScript.KEY_TO_WEEKDAY: PrologueSceneConfigScript.FIRST_MARKET_WEEKDAY
	})


func _set_character_expression(expression_id: String) -> void:
	_scene_view.apply_character(self, PrologueSceneConfigScript.HOMEWEAR_OUTFIT, expression_id, PrologueSceneConfigScript.PROLOGUE_DATE)


func _start_fresh_game_session() -> void:
	var game_session := GameSessionAccessScript.get_from_node(self)
	if game_session == null:
		return
	game_session.start_new_game(PrologueSceneConfigScript.FIRST_MARKET_DATE)


func _current_status() -> Dictionary:
	var game_session := GameSessionAccessScript.get_from_node(self)
	if game_session == null or not GameSessionAccessScript.is_ready(game_session):
		return {}
	return game_session.get_game().status.to_dict()
