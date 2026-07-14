class_name VisualNovelEventLayer
extends Control

signal finished
signal finish_transition_started

const VnMixedSceneViewScript := preload("res://scripts/ui/vn_mixed_scene_view.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")
const VnSceneSequenceRunnerScript := preload("res://scripts/ui/vn_scene_sequence_runner.gd")
const UiTweenPropertyConfigScript := preload("res://scripts/ui/ui_tween_property_config.gd")
const UiMotionScript := preload("res://scripts/ui/ui_motion.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")
const VisualNovelEventLayerConfigScript := preload("res://scripts/ui/visual_novel_event_layer_config.gd")

var characters_per_second := VisualNovelEventLayerConfigScript.CHARACTERS_PER_SECOND

var _is_finishing := false
var _event_date := ""
var _skip_finish_fade := false
var _vn_runner = VnSceneSequenceRunnerScript.new()

var _scene_view = VnMixedSceneViewScript.new()


func _init() -> void:
	_vn_runner.finished.connect(_finish)
	_vn_runner.connect_step_changed(_apply_step_visual)


func play(background_path: String, speaker_name: String, lines: Array[String], options: Dictionary = {}) -> void:
	_event_date = String(options.get("date", ""))
	_skip_finish_fade = bool(options.get(VisualNovelEventLayerConfigScript.OPTION_SKIP_FINISH_FADE, false))
	_build_layer(background_path, speaker_name, bool(options.get(VnStoryKeysScript.KEY_SHOW_CHARACTER, VisualNovelEventLayerConfigScript.SHOW_CHARACTER)))
	_vn_runner.set_steps(Array(options.get("steps", _line_steps(lines))))


func _process(delta: float) -> void:
	_vn_runner.update(delta)


func _input(event: InputEvent) -> void:
	_vn_runner.handle_input(event, get_viewport())


func _advance() -> void:
	_vn_runner.advance()


func _build_layer(background_path: String, speaker_name: String, show_character: bool = VisualNovelEventLayerConfigScript.SHOW_CHARACTER) -> void:
	name = VisualNovelEventLayerConfigScript.LAYER_NAME
	UiHelpers.stop_mouse(self)
	z_index = VisualNovelEventLayerConfigScript.LAYER_Z_INDEX
	modulate.a = VisualNovelEventLayerConfigScript.LAYER_ALPHA
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	position = Vector2.ZERO
	var viewport := get_viewport()
	size = viewport.get_visible_rect().size if viewport != null else Vector2.ZERO
	if size.x <= 0.0 or size.y <= 0.0:
		size = VisualNovelEventLayerConfigScript.FALLBACK_SIZE

	_scene_view.build(self, {
		VnStoryKeysScript.KEY_BACKGROUND_NAME: VisualNovelEventLayerConfigScript.BACKGROUND_NAME,
		VnStoryKeysScript.KEY_BACKGROUND_PATH: background_path,
		VnStoryKeysScript.KEY_SHOW_HUD: VisualNovelEventLayerConfigScript.SHOW_HUD,
		VnStoryKeysScript.KEY_SHOW_CHARACTER: show_character,
		VnStoryKeysScript.KEY_SPEAKER_NAME: speaker_name,
		VnStoryKeysScript.KEY_DIALOGUE_OPTIONS: {
			VnDialogueBoxConfigScript.OPTION_NAME_LABEL_NAME: VisualNovelEventLayerConfigScript.TITLE_LABEL_NAME,
			VnDialogueBoxConfigScript.OPTION_NAME_WIDTH: VisualNovelEventLayerConfigScript.TITLE_LABEL_WIDTH,
			VnDialogueBoxConfigScript.OPTION_DIALOGUE_LABEL_NAME: VisualNovelEventLayerConfigScript.DIALOGUE_LABEL_NAME
		}
	})
	_vn_runner.bind_to_view(_scene_view, characters_per_second)
	_scene_view.bind_auto_advance(self, _vn_runner)


func _apply_step_visual(step: Dictionary, _index: int) -> void:
	if step.has(VnStoryKeysScript.KEY_SPEAKER_NAME):
		_scene_view.set_speaker_name(String(step.get(VnStoryKeysScript.KEY_SPEAKER_NAME, "")))
	if not step.has(VnStoryKeysScript.KEY_BACKGROUND_PATH) and not step.has(VnStoryKeysScript.KEY_CHARACTER_VISIBLE):
		return
	var visual := {
		VnStoryKeysScript.KEY_BACKGROUND_PATH: String(step.get(VnStoryKeysScript.KEY_BACKGROUND_PATH, "")),
		VnStoryKeysScript.KEY_CHARACTER_VISIBLE: bool(step.get(VnStoryKeysScript.KEY_CHARACTER_VISIBLE, false)),
		VnStoryKeysScript.KEY_DEFAULT_OUTFIT: String(step.get(VnStoryKeysScript.KEY_OUTFIT, "")),
		VnStoryKeysScript.KEY_DATE_TEXT: ""
	}
	_scene_view.apply_step_visual(self, visual, step, _event_date)


func _finish() -> void:
	if _is_finishing:
		return
	_is_finishing = true
	_vn_runner.block()
	if _skip_finish_fade:
		finished.emit()
		queue_free()
		return
	finish_transition_started.emit()
	var fade_out := create_tween()
	fade_out.tween_property(self, UiTweenPropertyConfigScript.PROPERTY_MODULATE_ALPHA, 0.0, UiMotionScript.transition_duration(self, VisualNovelEventLayerConfigScript.FADE_OUT_DURATION))
	fade_out.tween_callback(func() -> void:
		finished.emit()
		queue_free()
	)


func _line_steps(lines: Array[String]) -> Array[Dictionary]:
	var steps: Array[Dictionary] = []
	for line in lines:
		if not line.is_empty():
			steps.append({VnStoryKeysScript.KEY_TEXT: line})
	if steps.is_empty():
		steps.append({VnStoryKeysScript.KEY_TEXT: ""})
	return steps
