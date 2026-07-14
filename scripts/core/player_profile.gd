class_name PlayerProfile
extends RefCounted

const ProfileSaveStoreScript := preload("res://scripts/core/save/profile_save_store.gd")
const ProfileSaveKeysScript := preload("res://scripts/core/save/profile_save_keys.gd")

const SAVE_PATH := ProfileSaveStoreScript.DEFAULT_PATH
const DEFAULT_NAME := "나"
const AGE_BAND := "20대"
const JOB_TITLE := "스타트업 사무직"

var player_name := DEFAULT_NAME
var age_band := AGE_BAND
var job_title := JOB_TITLE
var _save_store = ProfileSaveStoreScript.new()


func load_or_default() -> void:
	_save_store.load_profile(self, _get_save_path())


func save() -> bool:
	return _save_store.save_profile(self, _get_save_path())


func reset() -> void:
	player_name = DEFAULT_NAME
	age_band = AGE_BAND
	job_title = JOB_TITLE


func set_player_name(value: String) -> void:
	player_name = sanitize_name(value)


func to_dict() -> Dictionary:
	return {
		ProfileSaveKeysScript.KEY_PLAYER_NAME: player_name,
		ProfileSaveKeysScript.KEY_AGE_BAND: age_band,
		ProfileSaveKeysScript.KEY_JOB_TITLE: job_title
	}


func sanitize_name(value: String) -> String:
	var trimmed := value.strip_edges()
	if trimmed.is_empty():
		return DEFAULT_NAME
	if trimmed.length() > 8:
		return trimmed.substr(0, 8)
	return trimmed


func _get_save_path() -> String:
	return SAVE_PATH
