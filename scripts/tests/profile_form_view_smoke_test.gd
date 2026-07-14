extends "res://scripts/tests/test_scene_tree.gd"

const PlayerProfileScript := preload("res://scripts/core/player_profile.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const ProfileFormConfigScript := preload("res://scripts/ui/profile_form_config.gd")
const ProfileFormViewScript := preload("res://scripts/ui/profile_form_view.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")

var _helpers := TestHelpersScript.new()
var _submitted_count := 0


func _initialize() -> void:
	root.size = Vector2i(720, 1280)

	var host := Control.new()
	root.add_child(host)

	var profile = PlayerProfileScript.new()
	profile.set_player_name("테스트 사용자")
	var form = ProfileFormViewScript.new()
	form.build(host, profile)
	form.submitted.connect(func() -> void:
		_submitted_count += 1
	)

	var panel := _helpers.find_node(host, ProfileFormConfigScript.PANEL_NAME) as PanelContainer
	var name_input := _helpers.find_node(host, ProfileFormConfigScript.NAME_INPUT_NAME) as LineEdit
	var difficulty_option := _helpers.find_node(host, ProfileFormConfigScript.DIFFICULTY_OPTION_NAME) as OptionButton
	var difficulty_description := _helpers.find_node(host, ProfileFormConfigScript.DIFFICULTY_DESCRIPTION_NAME) as Label
	var confirm_button := _helpers.find_node(host, ProfileFormConfigScript.CONFIRM_BUTTON_NAME) as Button
	_expect(panel != null, "profile form should create the profile panel")
	_expect(name_input != null, "profile form should create a named player input")
	_expect(difficulty_option != null and difficulty_option.item_count == 3, "profile form should offer three difficulty choices")
	_expect(difficulty_description != null, "profile form should explain the selected difficulty")
	_expect(confirm_button != null, "profile form should create a named confirm button")
	_expect(panel.position == ProfileFormConfigScript.PANEL_POSITION, "profile panel should use configured position")
	_expect(panel.custom_minimum_size == ProfileFormConfigScript.PANEL_SIZE, "profile panel should use configured minimum size")
	_expect(panel.size.x >= ProfileFormConfigScript.PANEL_SIZE.x and panel.size.y >= ProfileFormConfigScript.PANEL_SIZE.y, "profile panel should not shrink below configured size")
	var margin := panel.get_child(0) as MarginContainer
	_expect(margin != null and margin.get_theme_constant(PanelLayoutHelpersScript.THEME_MARGIN_LEFT) == int(ProfileFormConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)), "profile panel should use configured layout margin")
	var layout := margin.get_child(0) as VBoxContainer
	_expect(layout != null and layout.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == ProfileFormConfigScript.LAYOUT_SEPARATION, "profile panel should use configured layout separation")
	_expect(name_input.max_length == ProfileFormConfigScript.NAME_MAX_LENGTH, "profile form should use configured name max length")
	_expect(name_input.custom_minimum_size == ProfileFormConfigScript.NAME_INPUT_SIZE, "profile form should use configured name input size")
	_expect(confirm_button.custom_minimum_size == ProfileFormConfigScript.SUBMIT_BUTTON_SIZE, "profile form should use configured submit size")
	_expect(name_input.text == "테스트 사용자", "profile form should prefill saved names")
	_expect(form.get_selected_difficulty() == GameDifficultyScript.NORMAL, "new runs should recommend normal difficulty")
	difficulty_option.select(1)
	difficulty_option.item_selected.emit(1)
	_expect(form.get_selected_difficulty() == GameDifficultyScript.EASY, "difficulty selection should expose the selected id")
	_expect(difficulty_description.text.contains("7배"), "difficulty description should update with selection")
	var input_style := StyleboxThemeHelpersScript.get_style(name_input, StyleboxThemeHelpersScript.STYLE_NORMAL) as StyleBoxFlat
	_expect(input_style != null, "profile form should apply a normal line-edit style")
	_expect(input_style.content_margin_left == ProfileFormConfigScript.LINE_EDIT_CONTENT_MARGIN_LEFT, "profile form should use configured line-edit left margin")
	_expect(input_style.content_margin_top == ProfileFormConfigScript.LINE_EDIT_CONTENT_MARGIN_TOP, "profile form should use configured line-edit top margin")

	name_input.text = "  "
	_expect(form.get_entered_name().is_empty(), "profile form should trim entered names")
	form.set_message("이름을 입력해줘.")
	_expect(form.message_label.text == "이름을 입력해줘.", "profile form should expose message updates")

	name_input.text = "나리"
	confirm_button.emit_signal("pressed")
	await process_frame
	_expect(_submitted_count == 1, "profile form should emit submit from confirm button")
	_expect(form.get_entered_name() == "나리", "profile form should return the trimmed entered name")

	form.set_submit_disabled(true)
	_expect(confirm_button.disabled, "profile form should expose submit disabled state")

	print("Profile form view smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
