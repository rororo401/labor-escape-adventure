class_name VnStoryRuntime
extends RefCounted

const NpcNameCatalogScript := preload("res://scripts/core/npc_name_catalog.gd")
const PlayerProfileScript := preload("res://scripts/core/player_profile.gd")
const VnStoryCatalogScript := preload("res://scripts/core/vn_story_catalog.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")

var profile = PlayerProfileScript.new()
var story_catalog = VnStoryCatalogScript.new()
var npc_names = NpcNameCatalogScript.new()


func load(stories_path: String, npc_names_path: String = "") -> void:
	profile.load_or_default()
	story_catalog.load_from_json(stories_path)
	if not npc_names_path.is_empty():
		npc_names.load_from_json(npc_names_path)


func player_name() -> String:
	return String(profile.player_name)


func speaker_name(step: Dictionary) -> String:
	var speaker := String(step.get(VnStoryKeysScript.KEY_SPEAKER, ""))
	if speaker.is_empty():
		return player_name()
	return speaker


func npc_display_name(npc_id: String, fallback_name: String = "") -> String:
	return npc_names.get_display_name(npc_id, fallback_name)


func npc_substitutions(fallbacks_by_id: Dictionary) -> Dictionary:
	var substitutions := {}
	for npc_id in fallbacks_by_id.keys():
		var key := String(npc_id)
		substitutions[key] = npc_display_name(key, String(fallbacks_by_id.get(npc_id, "")))
	return substitutions


func get_steps(story_id: String, substitutions: Dictionary = {}) -> Array[Dictionary]:
	return story_catalog.get_steps(story_id, substitutions)


func get_default_visual_mode(story_id: String) -> String:
	return story_catalog.get_default_visual_mode(story_id)


func get_visual_mode(story_id: String, mode_id: String) -> Dictionary:
	return story_catalog.get_visual_mode(story_id, mode_id)
