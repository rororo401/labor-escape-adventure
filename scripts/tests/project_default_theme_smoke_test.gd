extends "res://scripts/tests/test_scene_tree.gd"

const THEME_PATH := "res://assets/ui/game_default_theme.tres"
const FONT_PATH := "res://assets/fonts/Pretendard-Regular.otf"


func _initialize() -> void:
	_expect(String(ProjectSettings.get_setting("gui/theme/custom", "")) == THEME_PATH, "project should register the custom UI theme")
	var theme := load(THEME_PATH) as Theme
	_expect(theme != null, "project UI theme should load")
	_expect(theme.default_font != null, "project UI theme should define a default font")
	if theme != null and theme.default_font != null:
		_expect(theme.default_font.resource_path == FONT_PATH, "project UI theme should use Pretendard")
	print("Project default theme smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
