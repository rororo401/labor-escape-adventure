class_name VnSceneSequenceRunner
extends RefCounted

signal finished
signal auto_advance_changed(enabled: bool)

const VnInputHelperScript := preload("res://scripts/ui/vn_input_helper.gd")
const VnStepSequenceScript := preload("res://scripts/ui/vn_step_sequence.gd")
const VnTypewriterConfigScript := preload("res://scripts/ui/vn_typewriter_config.gd")

var sequence = VnStepSequenceScript.new()
var is_blocked := false
var auto_advance_enabled := false
var _auto_advance_elapsed := 0.0
var _auto_advance_paused := false


func bind_to_view(scene_view, characters_per_second: float = -1.0) -> void:
	if scene_view == null:
		return
	scene_view.bind_sequence(sequence, characters_per_second)


func bind_label(label: Label, characters_per_second: float = VnTypewriterConfigScript.DEFAULT_CHARACTERS_PER_SECOND) -> void:
	sequence.bind(label, characters_per_second)


func connect_step_changed(callback: Callable) -> void:
	if callback.is_valid():
		sequence.step_changed.connect(callback)


func set_steps(steps: Array) -> void:
	_auto_advance_elapsed = 0.0
	_auto_advance_paused = false
	sequence.set_steps(steps)


func update(delta: float) -> void:
	sequence.update(delta, is_blocked)
	_update_auto_advance(delta)


func handle_input(event: InputEvent, viewport: Viewport = null) -> int:
	if is_blocked or not VnInputHelperScript.is_advance_event(event):
		return VnStepSequenceScript.ADVANCE_INCOMPLETE
	if viewport != null:
		viewport.set_input_as_handled()
	_auto_advance_elapsed = 0.0
	return advance()


func advance() -> int:
	if is_blocked:
		return VnStepSequenceScript.ADVANCE_INCOMPLETE

	_auto_advance_elapsed = 0.0
	var result: int = sequence.advance()
	if result == VnStepSequenceScript.ADVANCE_FINISHED:
		finished.emit()
	return result


func block() -> void:
	is_blocked = true


func unblock() -> void:
	is_blocked = false


func set_auto_advance_enabled(enabled: bool) -> void:
	if auto_advance_enabled == enabled:
		_auto_advance_elapsed = 0.0
		return
	auto_advance_enabled = enabled
	_auto_advance_elapsed = 0.0
	_auto_advance_paused = false
	auto_advance_changed.emit(auto_advance_enabled)


func pause_auto_advance() -> void:
	_auto_advance_elapsed = 0.0
	_auto_advance_paused = true


func resume_auto_advance() -> void:
	_auto_advance_elapsed = 0.0
	_auto_advance_paused = false


func _update_auto_advance(delta: float) -> void:
	if is_blocked or not auto_advance_enabled or _auto_advance_paused:
		_auto_advance_elapsed = 0.0
		return
	if not sequence.is_current_line_complete():
		_auto_advance_elapsed = 0.0
		return
	_auto_advance_elapsed += delta
	if _auto_advance_elapsed < VnTypewriterConfigScript.AUTO_ADVANCE_DELAY_SECONDS:
		return
	_auto_advance_elapsed = 0.0
	advance()


func show_complete(text: String) -> void:
	sequence.show_complete(text)


func get_current_index() -> int:
	return sequence.get_current_index()


func get_current_step() -> Dictionary:
	return sequence.get_current_step()
