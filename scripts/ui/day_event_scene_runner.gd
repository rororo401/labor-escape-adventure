extends RefCounted

const VisualNovelEventLayerScript := preload("res://scripts/ui/visual_novel_event_layer.gd")
const VisualNovelEventLayerConfigScript := preload("res://scripts/ui/visual_novel_event_layer_config.gd")
const DayEventPlaybackRequestScript := preload("res://scripts/ui/day_event_playback_request.gd")

const KEY_SKIP_FINISH_FADE := "_skip_finish_fade"


func begin(
	parent: Node,
	event: Dictionary,
	default_background_path: String,
	finished_callback: Callable = Callable(),
	date: String = ""
) -> Control:
	if parent == null or event.is_empty():
		return null

	var lines := dialogue_lines(event)
	if lines.is_empty():
		return null

	var layer: Control = VisualNovelEventLayerScript.new()
	parent.add_child(layer)
	if finished_callback.is_valid():
		layer.finished.connect(finished_callback, CONNECT_ONE_SHOT)
	var steps := DayEventPlaybackRequestScript.playback_steps(event, default_background_path, date)
	var background_path := DayEventPlaybackRequestScript.background_path(event, default_background_path, date)
	_unlock_gallery_entry(parent, event, background_path, date)
	layer.play(
		background_path,
		DayEventPlaybackRequestScript.speaker_name(event),
		lines,
		{
			"date": date,
			"steps": steps,
			"show_character": DayEventPlaybackRequestScript.should_show_character(event),
			VisualNovelEventLayerConfigScript.OPTION_SKIP_FINISH_FADE: bool(event.get(KEY_SKIP_FINISH_FADE, false))
		}
	)
	return layer


func dialogue_lines(event: Dictionary) -> Array[String]:
	return DayEventPlaybackRequestScript.dialogue_lines(event)


func _unlock_gallery_entry(parent: Node, event: Dictionary, resolved_cg_path: String, date: String) -> void:
	if parent == null or String(event.get(DayEventPlaybackRequestScript.KEY_BACKGROUND_PATH, "")).is_empty():
		return
	var game_session := parent.get_node_or_null("/root/GameSession")
	if game_session == null or not game_session.has_method("unlock_event_cg"):
		return
	game_session.unlock_event_cg(event, resolved_cg_path, date)
