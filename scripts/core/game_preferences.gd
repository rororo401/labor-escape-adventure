extends Node

signal auto_advance_changed(enabled: bool)
signal ui_text_scale_changed(scale: float)
signal reduced_motion_changed(enabled: bool)

const UiAccessibilityScript := preload("res://scripts/ui/ui_accessibility.gd")

const DEFAULT_PATH := "user://game_preferences.cfg"
const SECTION_GAMEPLAY := "gameplay"
const SECTION_ACCESSIBILITY := "accessibility"
const KEY_AUTO_ADVANCE := "auto_advance"
const KEY_UI_TEXT_SCALE := "ui_text_scale"
const KEY_REDUCED_MOTION := "reduced_motion"

var settings_path := DEFAULT_PATH
var auto_advance_enabled := false
var ui_text_scale := UiAccessibilityScript.DEFAULT_TEXT_SCALE
var reduced_motion_enabled := false
var _text_scale_refresh_queued := false


func _ready() -> void:
	reload()
	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)
	call_deferred("_apply_text_scale_to_current_tree")


func reload() -> void:
	var config := ConfigFile.new()
	if config.load(settings_path) != OK:
		auto_advance_enabled = false
		ui_text_scale = UiAccessibilityScript.DEFAULT_TEXT_SCALE
		reduced_motion_enabled = false
		_apply_text_scale_to_current_tree()
		return
	auto_advance_enabled = bool(config.get_value(SECTION_GAMEPLAY, KEY_AUTO_ADVANCE, false))
	ui_text_scale = UiAccessibilityScript.normalize_text_scale(
		float(config.get_value(SECTION_ACCESSIBILITY, KEY_UI_TEXT_SCALE, UiAccessibilityScript.DEFAULT_TEXT_SCALE))
	)
	reduced_motion_enabled = bool(config.get_value(SECTION_ACCESSIBILITY, KEY_REDUCED_MOTION, false))
	_apply_text_scale_to_current_tree()


func is_auto_advance_enabled() -> bool:
	return auto_advance_enabled


func set_auto_advance_enabled(enabled: bool) -> bool:
	if auto_advance_enabled == enabled:
		return true
	auto_advance_enabled = enabled
	var saved := _save()
	auto_advance_changed.emit(auto_advance_enabled)
	return saved


func get_ui_text_scale() -> float:
	return ui_text_scale


func set_ui_text_scale(scale: float) -> bool:
	var normalized := UiAccessibilityScript.normalize_text_scale(scale)
	if is_equal_approx(ui_text_scale, normalized):
		return true
	ui_text_scale = normalized
	var saved := _save()
	_apply_text_scale_to_current_tree()
	ui_text_scale_changed.emit(ui_text_scale)
	return saved


func is_reduced_motion_enabled() -> bool:
	return reduced_motion_enabled


func set_reduced_motion_enabled(enabled: bool) -> bool:
	if reduced_motion_enabled == enabled:
		return true
	reduced_motion_enabled = enabled
	var saved := _save()
	reduced_motion_changed.emit(reduced_motion_enabled)
	return saved


func _save() -> bool:
	var config := ConfigFile.new()
	config.set_value(SECTION_GAMEPLAY, KEY_AUTO_ADVANCE, auto_advance_enabled)
	config.set_value(SECTION_ACCESSIBILITY, KEY_UI_TEXT_SCALE, ui_text_scale)
	config.set_value(SECTION_ACCESSIBILITY, KEY_REDUCED_MOTION, reduced_motion_enabled)
	return config.save(settings_path) == OK


func _on_node_added(node: Node) -> void:
	if node is Control and not _text_scale_refresh_queued:
		_text_scale_refresh_queued = true
		call_deferred("_apply_queued_text_scale")


func _apply_queued_text_scale() -> void:
	_text_scale_refresh_queued = false
	_apply_text_scale_to_current_tree()


func _apply_text_scale_to_current_tree() -> void:
	if not is_inside_tree():
		return
	UiAccessibilityScript.apply_text_scale_to_subtree(get_tree().root, ui_text_scale)
