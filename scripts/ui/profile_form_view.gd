class_name ProfileFormView
extends RefCounted

signal submitted

const PlayerProfileScript := preload("res://scripts/core/player_profile.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")
const ProfileFormConfigScript := preload("res://scripts/ui/profile_form_config.gd")
const ProfileFormStyleScript := preload("res://scripts/ui/profile_form_style.gd")
const ProfileFormTextStateConfigScript := preload("res://scripts/ui/profile_form_text_state_config.gd")
const ProfileFormTextStateScript := preload("res://scripts/ui/profile_form_text_state.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")

var name_input: LineEdit
var difficulty_option: OptionButton
var difficulty_description: Label
var submit_button: Button
var message_label: Label


func build(parent: Control, profile: PlayerProfile) -> void:
	var panel := PanelContainer.new()
	panel.name = ProfileFormConfigScript.PANEL_NAME
	panel.position = ProfileFormConfigScript.PANEL_POSITION
	panel.size = ProfileFormConfigScript.PANEL_SIZE
	panel.custom_minimum_size = ProfileFormConfigScript.PANEL_SIZE
	StyleboxThemeHelpersScript.apply_panel_style(
		panel,
		ProfileFormStyleScript.panel_style(
			ProfileFormConfigScript.PANEL_COLOR,
			ProfileFormConfigScript.PANEL_BORDER_COLOR
		)
	)
	parent.add_child(panel)

	var layout := PanelLayoutHelpersScript.add_margin_layout(
		panel,
		ProfileFormConfigScript.PANEL_SIZE,
		ProfileFormConfigScript.PANEL_MARGIN,
		ProfileFormConfigScript.LAYOUT_SEPARATION
	)

	_add_header_labels(layout)
	_add_name_input(layout, profile)
	_add_profile_summary(layout, profile)
	_add_difficulty_controls(layout)
	_add_message_label(layout)
	_add_submit_button(layout)


func get_entered_name() -> String:
	return "" if name_input == null else name_input.text.strip_edges()


func get_selected_difficulty() -> String:
	if difficulty_option == null or difficulty_option.selected < 0:
		return GameDifficultyScript.DEFAULT
	return String(difficulty_option.get_item_metadata(difficulty_option.selected))


func set_message(text: String) -> void:
	if message_label != null:
		message_label.text = text


func set_submit_disabled(disabled: bool) -> void:
	if submit_button != null:
		submit_button.disabled = disabled


func grab_name_focus() -> void:
	if name_input != null:
		name_input.grab_focus.call_deferred()


func _add_header_labels(layout: VBoxContainer) -> void:
	for label_state in ProfileFormTextStateScript.header_labels():
		var row: Dictionary = label_state
		var label := ProfileFormStyleScript.make_label(
			String(row.get(ProfileFormTextStateConfigScript.KEY_TEXT, ProfileFormTextStateConfigScript.EMPTY_TEXT)),
			int(row.get(ProfileFormTextStateConfigScript.KEY_FONT_SIZE, ProfileFormTextStateConfigScript.DEFAULT_FONT_SIZE)),
			row.get(ProfileFormTextStateConfigScript.KEY_COLOR, ProfileFormConfigScript.DEFAULT_LABEL_COLOR),
			int(row.get(ProfileFormTextStateConfigScript.KEY_ALIGNMENT, ProfileFormTextStateConfigScript.DEFAULT_ALIGNMENT))
		)
		if bool(row.get(ProfileFormTextStateConfigScript.KEY_OUTLINE, ProfileFormTextStateConfigScript.DEFAULT_OUTLINE)):
			ProfileFormStyleScript.apply_outline(label)
		layout.add_child(label)


func _add_name_input(layout: VBoxContainer, profile: PlayerProfile) -> void:
	name_input = LineEdit.new()
	name_input.name = ProfileFormConfigScript.NAME_INPUT_NAME
	name_input.text = ProfileFormTextStateScript.name_input_text(profile, PlayerProfileScript.DEFAULT_NAME)
	name_input.placeholder_text = ProfileFormTextStateScript.NAME_PLACEHOLDER
	name_input.max_length = ProfileFormConfigScript.NAME_MAX_LENGTH
	name_input.custom_minimum_size = ProfileFormConfigScript.NAME_INPUT_SIZE
	ProfileFormStyleScript.apply_name_input(name_input)
	name_input.text_submitted.connect(func(_text: String) -> void:
		submitted.emit()
	)
	layout.add_child(name_input)


func _add_profile_summary(layout: VBoxContainer, profile: PlayerProfile) -> void:
	var profile_text := ProfileFormStyleScript.make_label(
		ProfileFormTextStateScript.profile_summary(profile),
		ProfileFormConfigScript.SUMMARY_FONT_SIZE,
		ProfileFormConfigScript.SUMMARY_COLOR
	)
	profile_text.custom_minimum_size = ProfileFormConfigScript.PROFILE_SUMMARY_SIZE
	layout.add_child(profile_text)


func _add_difficulty_controls(layout: VBoxContainer) -> void:
	var label := ProfileFormStyleScript.make_label(
		"난이도",
		ProfileFormConfigScript.DIFFICULTY_LABEL_FONT_SIZE,
		ProfileFormConfigScript.SUMMARY_COLOR
	)
	layout.add_child(label)

	difficulty_option = OptionButton.new()
	difficulty_option.name = ProfileFormConfigScript.DIFFICULTY_OPTION_NAME
	difficulty_option.custom_minimum_size = ProfileFormConfigScript.DIFFICULTY_OPTION_SIZE
	for difficulty in [GameDifficultyScript.NORMAL, GameDifficultyScript.EASY, GameDifficultyScript.HARD]:
		difficulty_option.add_item(GameDifficultyScript.display_name(difficulty))
		difficulty_option.set_item_metadata(difficulty_option.item_count - 1, difficulty)
	difficulty_option.select(0)
	difficulty_option.item_selected.connect(_on_difficulty_selected)
	ProfileFormStyleScript.apply_difficulty_option(difficulty_option)
	layout.add_child(difficulty_option)

	difficulty_description = ProfileFormStyleScript.make_label(
		GameDifficultyScript.description(get_selected_difficulty()),
		ProfileFormConfigScript.DIFFICULTY_DESCRIPTION_FONT_SIZE,
		ProfileFormConfigScript.SUMMARY_COLOR
	)
	difficulty_description.name = ProfileFormConfigScript.DIFFICULTY_DESCRIPTION_NAME
	difficulty_description.custom_minimum_size = ProfileFormConfigScript.DIFFICULTY_DESCRIPTION_SIZE
	difficulty_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(difficulty_description)


func _on_difficulty_selected(_index: int) -> void:
	if difficulty_description != null:
		difficulty_description.text = GameDifficultyScript.description(get_selected_difficulty())


func _add_message_label(layout: VBoxContainer) -> void:
	message_label = ProfileFormStyleScript.make_label("", ProfileFormConfigScript.MESSAGE_FONT_SIZE, ProfileFormConfigScript.MESSAGE_COLOR)
	message_label.custom_minimum_size = ProfileFormConfigScript.MESSAGE_LABEL_SIZE
	layout.add_child(message_label)


func _add_submit_button(layout: VBoxContainer) -> void:
	submit_button = Button.new()
	submit_button.name = ProfileFormConfigScript.CONFIRM_BUTTON_NAME
	submit_button.text = ProfileFormTextStateScript.SUBMIT_TEXT
	submit_button.custom_minimum_size = ProfileFormConfigScript.SUBMIT_BUTTON_SIZE
	ProfileFormStyleScript.apply_submit_button(submit_button)
	submit_button.pressed.connect(func() -> void:
		submitted.emit()
	)
	layout.add_child(submit_button)
