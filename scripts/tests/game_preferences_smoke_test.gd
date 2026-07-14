extends "res://scripts/tests/test_scene_tree.gd"

const GamePreferencesScript := preload("res://scripts/core/game_preferences.gd")

const TEST_PATH := "user://game_preferences_smoke_test.cfg"


func _initialize() -> void:
	_remove_test_file()
	var preferences = GamePreferencesScript.new()
	preferences.settings_path = TEST_PATH
	preferences.reload()
	_expect(not preferences.is_auto_advance_enabled(), "auto advance should default to off")
	_expect(is_equal_approx(preferences.get_ui_text_scale(), 1.0), "text scale should default to 100 percent")
	_expect(not preferences.is_reduced_motion_enabled(), "reduced motion should default to off")
	_expect(preferences.set_auto_advance_enabled(true), "auto advance preference should save")
	_expect(preferences.set_ui_text_scale(1.1), "text scale preference should save")
	_expect(preferences.set_reduced_motion_enabled(true), "reduced motion preference should save")

	var loaded = GamePreferencesScript.new()
	loaded.settings_path = TEST_PATH
	loaded.reload()
	_expect(loaded.is_auto_advance_enabled(), "auto advance preference should reload")
	_expect(is_equal_approx(loaded.get_ui_text_scale(), 1.1), "text scale preference should reload")
	_expect(loaded.is_reduced_motion_enabled(), "reduced motion preference should reload")
	_expect(loaded.set_auto_advance_enabled(false), "disabled auto advance should save")

	var disabled = GamePreferencesScript.new()
	disabled.settings_path = TEST_PATH
	disabled.reload()
	_expect(not disabled.is_auto_advance_enabled(), "disabled auto advance should reload")
	_expect(is_equal_approx(disabled.get_ui_text_scale(), 1.1), "saving gameplay preference should preserve text scale")
	_expect(disabled.is_reduced_motion_enabled(), "saving gameplay preference should preserve reduced motion")
	preferences.free()
	loaded.free()
	disabled.free()

	_remove_test_file()
	print("Game preferences smoke test passed.")
	finish_test()


func _remove_test_file() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		_remove_test_file()
		fail_test()
