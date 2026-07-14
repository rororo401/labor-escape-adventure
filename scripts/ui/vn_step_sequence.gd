class_name VnStepSequence
extends RefCounted

signal step_changed(step: Dictionary, index: int)

const VnTypewriterScript := preload("res://scripts/ui/vn_typewriter.gd")
const VnTypewriterConfigScript := preload("res://scripts/ui/vn_typewriter_config.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")

const ADVANCE_INCOMPLETE := 0
const ADVANCE_LINE_CHANGED := 1
const ADVANCE_FINISHED := 2

var _steps: Array[Dictionary] = []
var _line_index := -1
var _typewriter = VnTypewriterScript.new()


func bind(label: Label, speed: float = VnTypewriterConfigScript.DEFAULT_CHARACTERS_PER_SECOND) -> void:
	_typewriter.bind(label, speed)


func set_steps(steps: Array) -> void:
	_steps.clear()
	for step in steps:
		if typeof(step) == TYPE_DICTIONARY:
			_steps.append(Dictionary(step))
	_line_index = -1
	if _steps.is_empty():
		return
	_show_line(0)


func update(delta: float, paused: bool = false) -> void:
	_typewriter.update(delta, paused)


func advance() -> int:
	if not _typewriter.consume_advance():
		return ADVANCE_INCOMPLETE

	if _line_index < _steps.size() - 1:
		_show_line(_line_index + 1)
		return ADVANCE_LINE_CHANGED

	return ADVANCE_FINISHED


func show_complete(text: String) -> void:
	_typewriter.show_complete(text)


func get_current_index() -> int:
	return _line_index


func get_current_step() -> Dictionary:
	if _line_index < 0 or _line_index >= _steps.size():
		return {}
	return _steps[_line_index]


func is_current_line_complete() -> bool:
	return _typewriter.is_complete()


func _show_line(index: int) -> void:
	_line_index = clampi(index, 0, _steps.size() - 1)
	var step: Dictionary = _steps[_line_index]
	step_changed.emit(step, _line_index)
	_typewriter.show(String(step.get(VnStoryKeysScript.KEY_TEXT, "")))
