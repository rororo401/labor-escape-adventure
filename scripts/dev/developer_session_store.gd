class_name DeveloperSessionStore
extends RefCounted

const DEFAULT_PATH := "user://developer_session.cfg"
const SECTION := "developer_session"
const KEY_LAST_JUMP_DATE := "last_jump_date"

var store_path := DEFAULT_PATH


func load_last_jump_date(default_date: String = "") -> String:
	var config := ConfigFile.new()
	if config.load(store_path) != OK:
		return default_date
	return String(config.get_value(SECTION, KEY_LAST_JUMP_DATE, default_date))


func save_last_jump_date(date: String) -> bool:
	var clean_date := date.strip_edges()
	if clean_date.is_empty():
		return false

	var config := ConfigFile.new()
	config.load(store_path)
	config.set_value(SECTION, KEY_LAST_JUMP_DATE, clean_date)
	return config.save(store_path) == OK
