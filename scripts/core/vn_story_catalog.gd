class_name VnStoryCatalog
extends RefCounted

const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")

var stories := {}
var visuals := {}


func load_from_json(path: String) -> void:
	stories.clear()
	visuals.clear()

	var loaded := JsonFileLoaderScript.read_dictionary(path, "VN story JSON")
	if not bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)):
		return

	var parsed: Dictionary = loaded.get(JsonFileLoaderScript.KEY_DATA, {})
	var parsed_stories: Dictionary = Dictionary(parsed.get(VnStoryKeysScript.KEY_STORIES, {}))
	for story_id in parsed_stories.keys():
		var steps = parsed_stories.get(story_id, [])
		if typeof(steps) == TYPE_ARRAY:
			stories[String(story_id)] = _copy_steps(Array(steps))

	var parsed_visuals: Dictionary = Dictionary(parsed.get(VnStoryKeysScript.KEY_VISUALS, {}))
	for story_id in parsed_visuals.keys():
		var visual_data = parsed_visuals.get(story_id, {})
		if typeof(visual_data) == TYPE_DICTIONARY:
			visuals[String(story_id)] = Dictionary(visual_data).duplicate(true)


func get_steps(story_id: String, substitutions: Dictionary = {}) -> Array[Dictionary]:
	var raw_steps: Array = Array(stories.get(story_id, []))
	var result: Array[Dictionary] = []
	for raw_step in raw_steps:
		if typeof(raw_step) != TYPE_DICTIONARY:
			continue
		result.append(_apply_substitutions(Dictionary(raw_step), substitutions))
	return result


func has_story(story_id: String) -> bool:
	return stories.has(story_id) and Array(stories.get(story_id, [])).size() > 0


func get_default_visual_mode(story_id: String) -> String:
	var visual_data: Dictionary = Dictionary(visuals.get(story_id, {}))
	return String(visual_data.get(VnStoryKeysScript.KEY_DEFAULT_MODE, ""))


func get_visual_mode(story_id: String, mode_id: String) -> Dictionary:
	var visual_data: Dictionary = Dictionary(visuals.get(story_id, {}))
	var modes: Dictionary = Dictionary(visual_data.get(VnStoryKeysScript.KEY_MODES, {}))
	var resolved_mode := mode_id
	if resolved_mode.is_empty() or not modes.has(resolved_mode):
		resolved_mode = String(visual_data.get(VnStoryKeysScript.KEY_DEFAULT_MODE, ""))
	if resolved_mode.is_empty() or not modes.has(resolved_mode):
		return {}
	return Dictionary(modes.get(resolved_mode, {})).duplicate(true)


func _copy_steps(steps: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for step in steps:
		if typeof(step) == TYPE_DICTIONARY:
			result.append(Dictionary(step).duplicate(true))
	return result


func _apply_substitutions(step: Dictionary, substitutions: Dictionary) -> Dictionary:
	var result := step.duplicate(true)
	for key in result.keys():
		if typeof(result[key]) == TYPE_STRING:
			result[key] = _replace_tokens(String(result[key]), substitutions)
	return result


func _replace_tokens(text: String, substitutions: Dictionary) -> String:
	var result := text
	for key in substitutions.keys():
		result = result.replace("{%s}" % String(key), String(substitutions[key]))
	return result
