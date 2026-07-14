class_name VnTypewriter
extends RefCounted

const VnTypewriterConfigScript := preload("res://scripts/ui/vn_typewriter_config.gd")

var characters_per_second := VnTypewriterConfigScript.DEFAULT_CHARACTERS_PER_SECOND

var _label: Label
var _current_text := ""
var _visible_characters := 0
var _character_accumulator := 0.0
var _is_line_complete := true


func bind(label: Label, speed: float = VnTypewriterConfigScript.DEFAULT_CHARACTERS_PER_SECOND) -> void:
	_label = label
	characters_per_second = speed


func show(text: String) -> void:
	_current_text = text
	_visible_characters = 0
	_character_accumulator = 0.0
	_is_line_complete = false
	if _label == null:
		return
	_label.text = _current_text
	_label.visible_characters = 0


func update(delta: float, paused: bool = false) -> void:
	if paused or _is_line_complete or _label == null:
		return

	_character_accumulator += delta * characters_per_second
	var next_visible := mini(_current_text.length(), int(_character_accumulator))
	if next_visible == _visible_characters:
		return

	_visible_characters = next_visible
	_label.visible_characters = _visible_characters
	if _visible_characters >= _current_text.length():
		_is_line_complete = true


func is_complete() -> bool:
	return _is_line_complete


func complete_current() -> void:
	_visible_characters = _current_text.length()
	_character_accumulator = float(_visible_characters)
	_is_line_complete = true
	if _label != null:
		_label.visible_characters = _visible_characters


func consume_advance() -> bool:
	if not _is_line_complete:
		complete_current()
		return false
	return true


func show_complete(text: String) -> void:
	_current_text = text
	_visible_characters = _current_text.length()
	_character_accumulator = float(_visible_characters)
	_is_line_complete = true
	if _label == null:
		return
	_label.text = _current_text
	_label.visible_characters = _visible_characters
