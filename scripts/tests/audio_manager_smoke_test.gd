extends "res://scripts/tests/test_scene_tree.gd"

const AudioManagerScript := preload("res://scripts/core/audio_manager.gd")

const TEST_SETTINGS_PATH := "user://audio_settings_smoke_test.cfg"


func _initialize() -> void:
	var manager = AudioManagerScript.new()
	manager.settings_path = TEST_SETTINGS_PATH
	root.add_child(manager)
	await process_frame

	_expect(AudioServer.get_bus_index(manager.MUSIC_BUS) >= 0, "music bus should exist")
	_expect(AudioServer.get_bus_index(manager.SFX_BUS) >= 0, "sfx bus should exist")
	_expect(manager.is_music_enabled(), "music should be enabled by default")

	manager.set_music_volume_percent(37.0)
	manager.set_music_enabled(false)
	_expect(is_equal_approx(manager.get_music_volume_percent(), 37.0), "music volume should update")
	_expect(not manager.is_music_enabled(), "music toggle should update")

	manager.music_enabled = true
	manager.music_volume_percent = 99.0
	manager.reload_settings()
	_expect(not manager.is_music_enabled(), "music enabled setting should persist")
	_expect(is_equal_approx(manager.get_music_volume_percent(), 37.0), "music volume setting should persist")

	manager.stop_music()
	manager.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SETTINGS_PATH))
	print("Audio manager smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
