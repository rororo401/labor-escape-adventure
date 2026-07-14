extends "res://scripts/tests/test_scene_tree.gd"

const ProfileFormConfigScript := preload("res://scripts/ui/profile_form_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")


func _initialize() -> void:
	_expect(ProfileFormConfigScript.PANEL_NAME == "ProfilePanel", "panel name should stay stable")
	_expect(ProfileFormConfigScript.PANEL_POSITION == Vector2(52, 202), "panel position should fit the difficulty selector")
	_expect(ProfileFormConfigScript.PANEL_SIZE == Vector2(616, 766), "panel size should fit the difficulty selector")
	_expect(int(ProfileFormConfigScript.PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)) == 32, "left margin should preserve current layout")
	_expect(ProfileFormConfigScript.LAYOUT_SEPARATION == 16, "layout separation should preserve current layout")
	_expect(ProfileFormConfigScript.NAME_INPUT_NAME == "PlayerNameInput", "name input node name should stay stable")
	_expect(ProfileFormConfigScript.DIFFICULTY_OPTION_NAME == "DifficultyOption", "difficulty option should have a stable node name")
	_expect(ProfileFormConfigScript.CONFIRM_BUTTON_NAME == "ProfileConfirmButton", "confirm button node name should stay stable")
	_expect(ProfileFormConfigScript.NAME_MAX_LENGTH == 8, "name max length should stay stable")
	_expect(ProfileFormConfigScript.NAME_INPUT_SIZE == Vector2(552, 62), "name input size should preserve current layout")
	_expect(ProfileFormConfigScript.SUBMIT_BUTTON_SIZE == Vector2(552, 62), "submit button size should preserve current layout")
	_expect(ProfileFormConfigScript.DEFAULT_LABEL_COLOR == Color("#46362f"), "default label color should stay stable")
	_expect(ProfileFormConfigScript.HEADER_OUTLINE_COLOR == Color("#fff7e9"), "header outline color should stay stable")
	_expect(ProfileFormConfigScript.HEADER_OUTLINE_SIZE == 3, "header outline size should stay stable")
	_expect(ProfileFormConfigScript.PANEL_SHADOW_SIZE == 10, "panel shadow size should preserve current layout")
	_expect(ProfileFormConfigScript.LINE_EDIT_CONTENT_MARGIN_LEFT == 18, "line edit left content margin should stay stable")
	_expect(ProfileFormConfigScript.LINE_EDIT_CONTENT_MARGIN_TOP == 8, "line edit top content margin should stay stable")

	print("Profile form config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
