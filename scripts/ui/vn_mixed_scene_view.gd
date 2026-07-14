class_name VnMixedSceneView
extends RefCounted

const ProtagonistStandingViewScript := preload("res://scripts/ui/protagonist_standing_view.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const VnDialogueBoxScript := preload("res://scripts/ui/vn_dialogue_box.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")
const VnMixedSceneViewConfigScript := preload("res://scripts/ui/vn_mixed_scene_view_config.gd")
const VnSceneBackgroundScript := preload("res://scripts/ui/vn_scene_background.gd")
const HudStatusBarsScript := preload("res://scripts/ui/hud_status_bars.gd")
const VnTopHudScript := preload("res://scripts/ui/vn_top_hud.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")

var background_rect: TextureRect
var character_texture_rect: TextureRect
var date_label: Label
var name_label: Label
var dialogue_label: Label
var status_bars := {}
var auto_button: Button

var _standing_view = ProtagonistStandingViewScript.new()
var _auto_runner
var _preferences: Node


func build(parent: Control, options: Dictionary = {}) -> Dictionary:
	background_rect = VnSceneBackgroundScript.add_to(
		parent,
		String(options.get(VnStoryKeysScript.KEY_BACKGROUND_NAME, VnMixedSceneViewConfigScript.DEFAULT_BACKGROUND_NAME)),
		String(options.get(VnStoryKeysScript.KEY_BACKGROUND_PATH, VnMixedSceneViewConfigScript.DEFAULT_BACKGROUND_PATH))
	)

	if bool(options.get(VnStoryKeysScript.KEY_SHOW_HUD, VnMixedSceneViewConfigScript.DEFAULT_SHOW_HUD)):
		var hud_options: Dictionary = Dictionary(options.get(VnStoryKeysScript.KEY_HUD_OPTIONS, {}))
		var hud := VnTopHudScript.add_to(
			parent,
			String(options.get(VnStoryKeysScript.KEY_DATE_TEXT, VnMixedSceneViewConfigScript.DEFAULT_DATE_TEXT)),
			bool(options.get(VnStoryKeysScript.KEY_SHOW_TOP_BUTTONS, VnMixedSceneViewConfigScript.DEFAULT_SHOW_TOP_BUTTONS)),
			hud_options
		)
		date_label = hud.get(VnTopHudConfigScript.KEY_DATE_LABEL)
		status_bars = hud.get(VnTopHudConfigScript.KEY_STATUS_BARS, {})
		auto_button = hud.get(VnTopHudConfigScript.KEY_AUTO_BUTTON) as Button
	else:
		date_label = null
		status_bars = {}
		auto_button = null

	if bool(options.get(VnStoryKeysScript.KEY_SHOW_CHARACTER, VnMixedSceneViewConfigScript.DEFAULT_SHOW_CHARACTER)):
		character_texture_rect = _standing_view.add_to(
			parent,
			String(options.get(VnStoryKeysScript.KEY_CHARACTER_NAME, VnMixedSceneViewConfigScript.DEFAULT_CHARACTER_NAME))
		)
	else:
		character_texture_rect = null

	var dialogue_options: Dictionary = Dictionary(options.get(VnStoryKeysScript.KEY_DIALOGUE_OPTIONS, {}))
	var dialogue := VnDialogueBoxScript.add_to(
		parent,
		String(options.get(VnStoryKeysScript.KEY_SPEAKER_NAME, VnMixedSceneViewConfigScript.DEFAULT_SPEAKER_NAME)),
		dialogue_options
	)
	name_label = dialogue.get(VnDialogueBoxConfigScript.KEY_NAME_LABEL)
	dialogue_label = dialogue.get(VnDialogueBoxConfigScript.KEY_DIALOGUE_LABEL)

	return {
		VnMixedSceneViewConfigScript.KEY_BACKGROUND_RECT: background_rect,
		VnMixedSceneViewConfigScript.KEY_CHARACTER_TEXTURE_RECT: character_texture_rect,
		VnMixedSceneViewConfigScript.KEY_DATE_LABEL: date_label,
		VnMixedSceneViewConfigScript.KEY_STATUS_BARS: status_bars,
		VnMixedSceneViewConfigScript.KEY_NAME_LABEL: name_label,
		VnMixedSceneViewConfigScript.KEY_DIALOGUE_LABEL: dialogue_label
	}


func bind_sequence(sequence, characters_per_second: float = -1.0) -> void:
	if sequence == null or dialogue_label == null:
		return
	if characters_per_second > 0.0:
		sequence.bind(dialogue_label, characters_per_second)
	else:
		sequence.bind(dialogue_label)


func bind_auto_advance(parent: Node, runner) -> void:
	_auto_runner = runner
	_preferences = null
	if parent != null and parent.is_inside_tree() and parent.get_tree() != null:
		_preferences = parent.get_tree().root.get_node_or_null("GamePreferences")
	var enabled := false
	if _preferences != null and _preferences.has_method("is_auto_advance_enabled"):
		enabled = bool(_preferences.is_auto_advance_enabled())
	if _auto_runner != null and _auto_runner.has_method("set_auto_advance_enabled"):
		_auto_runner.set_auto_advance_enabled(enabled)
	_set_auto_button_state(enabled)
	if auto_button != null and not auto_button.toggled.is_connected(_on_auto_button_toggled):
		auto_button.toggled.connect(_on_auto_button_toggled)


func _on_auto_button_toggled(enabled: bool) -> void:
	if _auto_runner != null and _auto_runner.has_method("set_auto_advance_enabled"):
		_auto_runner.set_auto_advance_enabled(enabled)
	if _preferences != null and _preferences.has_method("set_auto_advance_enabled"):
		_preferences.set_auto_advance_enabled(enabled)
	_set_auto_button_state(enabled)


func _set_auto_button_state(enabled: bool) -> void:
	if auto_button == null:
		return
	auto_button.set_pressed_no_signal(enabled)
	auto_button.text = VnTopHudConfigScript.AUTO_BUTTON_ON_TEXT if enabled else VnTopHudConfigScript.AUTO_BUTTON_TEXT


func set_speaker_name(speaker_name: String) -> void:
	if name_label != null:
		name_label.text = speaker_name


func set_date_text(date_text: String) -> void:
	if date_label != null:
		date_label.text = date_text


func set_status_bars(status: Dictionary) -> void:
	HudStatusBarsScript.update(status_bars, status)


func apply_step_visual(parent: Control, visual: Dictionary, step: Dictionary = {}, date: String = "") -> Dictionary:
	VnSceneBackgroundScript.set_texture(background_rect, String(visual.get(VnStoryKeysScript.KEY_BACKGROUND_PATH, "")))

	var character_visible := bool(visual.get(VnStoryKeysScript.KEY_CHARACTER_VISIBLE, VnMixedSceneViewConfigScript.DEFAULT_CHARACTER_VISIBLE))
	if character_texture_rect != null:
		character_texture_rect.visible = character_visible
	if date_label != null:
		date_label.text = String(visual.get(VnStoryKeysScript.KEY_DATE_TEXT, ""))

	if not character_visible:
		return {}

	return apply_character(
		parent,
		String(step.get(VnStoryKeysScript.KEY_OUTFIT, visual.get(VnStoryKeysScript.KEY_DEFAULT_OUTFIT, VnMixedSceneViewConfigScript.DEFAULT_OUTFIT))),
		String(step.get(VnStoryKeysScript.KEY_EXPRESSION, VnMixedSceneViewConfigScript.DEFAULT_EXPRESSION)),
		date
	)


func apply_character(parent: Control, outfit_id: String, expression_id: String, date: String = "") -> Dictionary:
	return _standing_view.apply(parent, outfit_id, expression_id, date)
