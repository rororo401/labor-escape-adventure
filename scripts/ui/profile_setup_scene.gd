extends Control

const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")
const PlayerProfileScript := preload("res://scripts/core/player_profile.gd")
const ProfileFormViewScript := preload("res://scripts/ui/profile_form_view.gd")
const ProfileSetupSceneConfigScript := preload("res://scripts/ui/profile_setup_scene_config.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var _profile = PlayerProfileScript.new()
var _form_view = ProfileFormViewScript.new()


func _ready() -> void:
	_profile.load_or_default()
	_build_screen()
	_form_view.grab_name_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_confirm_profile()


func _build_screen() -> void:
	var background := TextureRect.new()
	background.name = ProfileSetupSceneConfigScript.BACKGROUND_NAME
	UiHelpers.apply_cover_texture(background, ProfileSetupSceneConfigScript.BACKGROUND_PATH)
	add_child(background)

	_form_view.build(self, _profile)
	_form_view.submitted.connect(_confirm_profile)


func _confirm_profile() -> void:
	var entered_name := _form_view.get_entered_name()
	if entered_name.is_empty():
		_form_view.set_message(ProfileSetupSceneConfigScript.EMPTY_NAME_MESSAGE)
		return

	_profile.set_player_name(entered_name)
	_profile.save()
	var game_session := GameSessionAccessScript.get_from_node(self)
	if game_session != null:
		game_session.reset()
		game_session.set_new_game_difficulty(_form_view.get_selected_difficulty())
	_form_view.set_submit_disabled(true)
	get_tree().change_scene_to_file(ProfileSetupSceneConfigScript.PROLOGUE_SCENE_PATH)
