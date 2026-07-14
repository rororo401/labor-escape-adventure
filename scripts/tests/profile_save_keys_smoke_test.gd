extends "res://scripts/tests/test_scene_tree.gd"

const ProfileSaveKeysScript := preload("res://scripts/core/save/profile_save_keys.gd")


func _initialize() -> void:
	_expect(ProfileSaveKeysScript.SECTION_PROFILE == "profile", "profile save section should stay stable")
	_expect(ProfileSaveKeysScript.KEY_PLAYER_NAME == "player_name", "player name key should stay stable")
	_expect(ProfileSaveKeysScript.KEY_AGE_BAND == "age_band", "age band key should stay stable")
	_expect(ProfileSaveKeysScript.KEY_JOB_TITLE == "job_title", "job title key should stay stable")

	print("Profile save keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
