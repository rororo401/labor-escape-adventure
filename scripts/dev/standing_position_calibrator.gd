extends Control

const CharacterAssetCatalogScript := preload("res://scripts/core/character_asset_catalog.gd")
const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const StandingCalibratorEntriesScript := preload("res://scripts/dev/standing_calibrator_entries.gd")
const StandingCalibratorDisplayStateScript := preload("res://scripts/dev/standing_calibrator_display_state.gd")
const StandingCalibratorInputScript := preload("res://scripts/dev/standing_calibrator_input.gd")
const StandingCalibratorViewConfigScript := preload("res://scripts/dev/standing_calibrator_view_config.gd")
const StandingCalibratorViewScript := preload("res://scripts/dev/standing_calibrator_view.gd")
const StandingBustLayoutScript := preload("res://scripts/core/standing_bust_layout.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")

const BACKGROUND_PATH := UiBackgroundPathsScript.HOME_PROLOGUE_LIVING_ROOM
const CHARACTER_ASSETS_PATH := GameStateConfigScript.CHARACTER_ASSETS_PATH
const DEVELOPER_MODE_SCENE_PATH := UiScenePathsScript.DEVELOPER_MODE

var _catalog = CharacterAssetCatalogScript.new()
var _layout = StandingBustLayoutScript.new()
var _standing_entries: Array[Dictionary] = []
var _current_index := 0
var _current_resolved := {}

var _character_rect: TextureRect
var _entry_label: Label
var _offset_label: Label
var _save_label: Label
var _entry_buttons: Array[Button] = []


func _ready() -> void:
	_catalog.load_from_json(CHARACTER_ASSETS_PATH)
	_layout.load_overrides()
	_build_standing_entries()
	_build_screen()
	_select_entry(0)


func _unhandled_input(event: InputEvent) -> void:
	var action := StandingCalibratorInputScript.action_from_event(event)
	match String(action.get(StandingCalibratorInputScript.KEY_ACTION, StandingCalibratorInputScript.ACTION_NONE)):
		StandingCalibratorInputScript.ACTION_MOVE:
			_move_current(action.get(StandingCalibratorInputScript.KEY_DELTA, Vector2.ZERO))
		StandingCalibratorInputScript.ACTION_SELECT_RELATIVE:
			_select_relative(int(action.get(StandingCalibratorInputScript.KEY_DELTA, 0)))
		StandingCalibratorInputScript.ACTION_SELECT_INDEX:
			_select_entry(int(action.get(StandingCalibratorInputScript.KEY_INDEX, 0)))
		StandingCalibratorInputScript.ACTION_CONFIRM:
			_confirm_current()
		StandingCalibratorInputScript.ACTION_BACK:
			_go_back_to_developer_mode()


func _build_standing_entries() -> void:
	_standing_entries = StandingCalibratorEntriesScript.build_entries(_catalog)


func _build_screen() -> void:
	var view_nodes: Dictionary = StandingCalibratorViewScript.build(
		self,
		BACKGROUND_PATH,
		_standing_entries,
		StandingCalibratorViewConfigScript.callbacks(
			_select_entry,
			_confirm_current,
			_reset_current,
			_go_back_to_developer_mode
		)
	)
	_character_rect = view_nodes.get(StandingCalibratorViewConfigScript.KEY_CHARACTER_RECT) as TextureRect
	_entry_label = view_nodes.get(StandingCalibratorViewConfigScript.KEY_ENTRY_LABEL) as Label
	_offset_label = view_nodes.get(StandingCalibratorViewConfigScript.KEY_OFFSET_LABEL) as Label
	_save_label = view_nodes.get(StandingCalibratorViewConfigScript.KEY_SAVE_LABEL) as Label
	_entry_buttons.clear()
	for button in view_nodes.get(StandingCalibratorViewConfigScript.KEY_ENTRY_BUTTONS, []):
		_entry_buttons.append(button as Button)


func _select_entry(index: int) -> void:
	if _standing_entries.is_empty():
		return
	_current_index = StandingCalibratorDisplayStateScript.selected_index(index, _standing_entries.size())
	var entry: Dictionary = _standing_entries[_current_index]
	_current_resolved = _catalog.resolve_standing_asset(
		"protagonist",
		String(entry.get(CharacterAssetKeysScript.ENTRY_OUTFIT, "")),
		String(entry.get(CharacterAssetKeysScript.ENTRY_EXPRESSION, ""))
	)
	_apply_current()
	_save_label.text = StandingCalibratorDisplayStateScript.SELECTED_HELP_TEXT


func _select_relative(delta: int) -> void:
	if _standing_entries.is_empty():
		return
	var next_index := StandingCalibratorDisplayStateScript.relative_index(_current_index, delta, _standing_entries.size())
	_select_entry(next_index)


func _move_current(delta: Vector2) -> void:
	var offset := _layout.get_offset(_current_resolved) + delta
	_layout.set_offset(_current_resolved, offset)
	_apply_current()


func _reset_current() -> void:
	_layout.set_offset(_current_resolved, Vector2.ZERO)
	_apply_current()
	_save_label.text = StandingCalibratorDisplayStateScript.reset_message()


func _confirm_current() -> void:
	_layout.save_overrides()
	var key := _layout.make_key_from_resolved(_current_resolved)
	_save_label.text = StandingCalibratorDisplayStateScript.save_message(
		key,
		_layout.get_user_override_path(),
		_layout.get_default_override_path()
	)


func _apply_current() -> void:
	var viewport_width := get_viewport_rect().size.x
	if size.x > 0.0:
		viewport_width = minf(viewport_width, size.x)
	if viewport_width <= 0.0:
		viewport_width = 720.0

	_layout.apply_to_texture_rect(_character_rect, _current_resolved, viewport_width)
	var entry: Dictionary = _standing_entries[_current_index]
	var offset := _layout.get_offset(_current_resolved)
	_entry_label.text = StandingCalibratorDisplayStateScript.entry_label(
		_current_index,
		_standing_entries.size(),
		entry
	)
	_offset_label.text = StandingCalibratorDisplayStateScript.offset_label(offset)
	for index in _entry_buttons.size():
		_entry_buttons[index].disabled = index == _current_index


func _go_back_to_developer_mode() -> void:
	get_tree().change_scene_to_file(DEVELOPER_MODE_SCENE_PATH)
