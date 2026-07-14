class_name DayEventTextAliasResolver
extends RefCounted

const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")

const KEY_ALIAS_FILE := "alias_file"
const KEY_ENTITIES := "entities"
const KEY_DISPLAY_NAME_KO := "display_name_ko"
const KEY_REAL_NAME_KO := "real_name_ko"


static func resolve_external_data(data: Dictionary) -> Dictionary:
	var alias_file := String(data.get(KEY_ALIAS_FILE, ""))
	var aliases := load_aliases(alias_file)
	if aliases.is_empty():
		return data
	return Dictionary(_resolve_value(data, aliases))


static func load_aliases(path: String) -> Dictionary:
	if path.is_empty():
		return {}

	var loaded := JsonFileLoaderScript.read_dictionary(path, "day event text alias JSON", false)
	if not bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)):
		push_warning("Could not load day event text alias JSON: %s" % path)
		return {}

	var parsed: Dictionary = loaded.get(JsonFileLoaderScript.KEY_DATA, {})
	var aliases := {}
	for entity_id in Dictionary(parsed.get(KEY_ENTITIES, {})).keys():
		var row = Dictionary(parsed.get(KEY_ENTITIES, {})).get(entity_id)
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var entity := Dictionary(row)
		var display_name := String(entity.get(KEY_DISPLAY_NAME_KO, entity.get(KEY_REAL_NAME_KO, "")))
		if not display_name.is_empty():
			aliases[String(entity_id)] = display_name
	return aliases


static func _resolve_value(value, aliases: Dictionary):
	match typeof(value):
		TYPE_STRING:
			return _resolve_text(String(value), aliases)
		TYPE_ARRAY:
			var resolved: Array = []
			for item in Array(value):
				resolved.append(_resolve_value(item, aliases))
			return resolved
		TYPE_DICTIONARY:
			var resolved := {}
			for key in Dictionary(value).keys():
				resolved[key] = _resolve_value(Dictionary(value).get(key), aliases)
			return resolved
	return value


static func _resolve_text(text: String, aliases: Dictionary) -> String:
	var resolved := text
	for entity_id in aliases.keys():
		resolved = resolved.replace("{%s}" % String(entity_id), String(aliases.get(entity_id, "")))
	return resolved
