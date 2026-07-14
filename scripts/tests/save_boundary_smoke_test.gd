extends "res://scripts/tests/test_scene_tree.gd"

const GameProgressStoreScript := preload("res://scripts/core/save/game_progress_store.gd")
const PlayerProfileScript := preload("res://scripts/core/player_profile.gd")
const ProfileSaveStoreScript := preload("res://scripts/core/save/profile_save_store.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const TEST_PROFILE_PATH := "user://save_boundary_profile.cfg"
const TEST_PROGRESS_PATH := "user://save_boundary_progress.json"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var profile = PlayerProfileScript.new()
	profile.set_player_name("테스트 사용자")

	var store = ProfileSaveStoreScript.new()
	_expect(store.save_profile(profile, TEST_PROFILE_PATH), "profile store should save profile data")

	var loaded = PlayerProfileScript.new()
	_expect(store.load_profile(loaded, TEST_PROFILE_PATH), "profile store should load profile data")
	_expect(loaded.player_name == "테스트 사용자", "profile store should preserve the player name")
	_expect(loaded.age_band == "20대", "profile store should keep the fixed age band")
	_expect(loaded.job_title == "스타트업 사무직", "profile store should keep the fixed job title")

	var progress_store = GameProgressStoreScript.new()
	progress_store.save_path = TEST_PROGRESS_PATH
	_remove_test_file(TEST_PROGRESS_PATH)
	_expect(progress_store.is_enabled(), "game progress persistence should be explicitly enabled")
	_expect(not progress_store.has_saved_progress(), "game progress store should not claim missing saved progress")

	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	game_session.progress_store = progress_store
	_expect(game_session.start_new_game("2016-07-01"), "GameSession should start a new game")
	_expect(game_session.save_current_game().get("ok", false), "GameSession should save current progress through its store")
	_expect(game_session.has_saved_progress(), "GameSession should report saved progress after saving")
	game_session.reset()
	_expect(game_session.has_saved_progress(), "reset GameSession should not delete saved progress")
	_expect(game_session.load_saved_game().get("ok", false), "GameSession should load saved progress")
	_expect(game_session.get_game().get_today_context().get("date", "") == "2016-07-01", "loaded GameSession should restore the saved date")
	_remove_test_file(TEST_PROGRESS_PATH)

	print("Save boundary smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _remove_test_file(path: String) -> void:
	for suffix in ["", GameProgressStoreScript.TEMP_SUFFIX, GameProgressStoreScript.BACKUP_SUFFIX, GameProgressStoreScript.REPLACEMENT_SUFFIX]:
		var candidate := path + String(suffix)
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))
