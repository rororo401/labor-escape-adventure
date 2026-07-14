class_name ProfileSaveStore
extends RefCounted

const ProfileSaveKeysScript := preload("res://scripts/core/save/profile_save_keys.gd")

const DEFAULT_PATH := "user://player_profile.cfg"
const SECTION := ProfileSaveKeysScript.SECTION_PROFILE


func load_profile(profile, path: String = DEFAULT_PATH) -> bool:
	var config := ConfigFile.new()
	var error := config.load(path)
	if error != OK:
		profile.reset()
		return false

	profile.player_name = profile.sanitize_name(String(config.get_value(SECTION, ProfileSaveKeysScript.KEY_PLAYER_NAME, profile.DEFAULT_NAME)))
	profile.age_band = String(config.get_value(SECTION, ProfileSaveKeysScript.KEY_AGE_BAND, profile.AGE_BAND))
	profile.job_title = String(config.get_value(SECTION, ProfileSaveKeysScript.KEY_JOB_TITLE, profile.JOB_TITLE))
	return true


func save_profile(profile, path: String = DEFAULT_PATH) -> bool:
	var config := ConfigFile.new()
	config.set_value(SECTION, ProfileSaveKeysScript.KEY_PLAYER_NAME, profile.sanitize_name(String(profile.player_name)))
	config.set_value(SECTION, ProfileSaveKeysScript.KEY_AGE_BAND, profile.AGE_BAND)
	config.set_value(SECTION, ProfileSaveKeysScript.KEY_JOB_TITLE, profile.JOB_TITLE)
	return config.save(path) == OK
