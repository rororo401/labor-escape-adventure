class_name NpcNameCatalog
extends RefCounted

const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")
const LocalizedPayloadKeysScript := preload("res://scripts/core/localized_payload_keys.gd")

const KEY_NPCS := "npcs"
const KEY_DISPLAY_NAME_KO := LocalizedPayloadKeysScript.KEY_DISPLAY_NAME_KO
const DEFAULT_FALLBACK_NAME := ""

var npcs := {}


func load_from_json(path: String) -> void:
	npcs.clear()

	var loaded := JsonFileLoaderScript.read_dictionary(path, "NPC name JSON")
	if not bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)):
		return

	var parsed: Dictionary = loaded.get(JsonFileLoaderScript.KEY_DATA, {})
	npcs = Dictionary(parsed.get(KEY_NPCS, {}))


func get_display_name(npc_id: String, fallback_name: String = DEFAULT_FALLBACK_NAME) -> String:
	var npc: Dictionary = npcs.get(npc_id, {})
	return String(npc.get(KEY_DISPLAY_NAME_KO, fallback_name))
