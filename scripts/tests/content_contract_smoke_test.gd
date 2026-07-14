extends "res://scripts/tests/test_scene_tree.gd"

const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")


func _initialize() -> void:
	_verify_day_event_contract()
	_verify_character_asset_contract()
	_verify_vn_story_visual_contract()

	print("Content contract smoke test passed.")
	finish_test()


func _verify_day_event_contract() -> void:
	var payload := _load_dict(GameStateConfigScript.DAY_EVENTS_PATH, "day events")
	var seen_ids := {}
	for action in Array(payload.get(DayEventKeysScript.KEY_DAY_ACTIONS, [])):
		_verify_event_row(Dictionary(action), seen_ids, "day action")

	for night_event in Array(payload.get(DayEventKeysScript.KEY_NIGHT_EVENTS, [])):
		var event := Dictionary(night_event)
		_verify_event_row(event, seen_ids, "night event")
		var chance := float(event.get(DayEventKeysScript.KEY_CHANCE, -1.0))
		_expect(chance >= 0.0 and chance <= 1.0, "night event chance should be between 0 and 1: %s" % event.get(DayEventKeysScript.KEY_ID, ""))


func _verify_event_row(event: Dictionary, seen_ids: Dictionary, label: String) -> void:
	var id := String(event.get(DayEventKeysScript.KEY_ID, ""))
	_expect(not id.is_empty(), "%s should have an id" % label)
	_expect(not seen_ids.has(id), "event id should be unique: %s" % id)
	seen_ids[id] = true
	_expect(not String(event.get(DayEventKeysScript.KEY_NAME_KO, "")).is_empty(), "%s should have Korean name: %s" % [label, id])
	_verify_effects(Dictionary(event.get(DayEventKeysScript.KEY_EFFECTS, {})), id)

	if String(event.get(DayEventKeysScript.KEY_MODE, "")) == DayEventKeysScript.MODE_CHOICE_CLOSED:
		_expect(not String(event.get(DayEventKeysScript.KEY_CATEGORY_ID, "")).is_empty(), "closed-day action should have category id: %s" % id)
		_expect(not String(event.get(DayEventKeysScript.KEY_CATEGORY_KO, "")).is_empty(), "closed-day action should have category label: %s" % id)

	var cg_path := String(event.get(DayEventKeysScript.KEY_CG_PATH, ""))
	if not cg_path.is_empty():
		_expect(ResourceLoader.exists(cg_path), "event CG path should exist for %s: %s" % [id, cg_path])
	var dialogue := Array(event.get(DayEventKeysScript.KEY_DIALOGUE, []))
	if not cg_path.is_empty() or not dialogue.is_empty():
		_expect(not dialogue.is_empty(), "event with CG should have dialogue: %s" % id)
		for line in dialogue:
			_expect(not String(line).strip_edges().is_empty(), "event dialogue line should not be empty: %s" % id)


func _verify_effects(effects: Dictionary, event_id: String) -> void:
	for key in [
		PlayerStatusKeysScript.KEY_CASH_DELTA,
		PlayerStatusKeysScript.KEY_HEALTH_DELTA,
		PlayerStatusKeysScript.KEY_MOOD_DELTA,
		PlayerStatusKeysScript.KEY_FATIGUE_DELTA
	]:
		if effects.has(key):
			_verify_effect_value(effects.get(key), "%s.%s" % [event_id, key])


func _verify_effect_value(value, label: String) -> void:
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return
	_expect(typeof(value) == TYPE_ARRAY, "effect should be a number or range: %s" % label)
	var range := Array(value)
	_expect(range.size() == 2, "effect range should have two values: %s" % label)
	_expect(_is_number(range[0]) and _is_number(range[1]), "effect range values should be numeric: %s" % label)


func _verify_character_asset_contract() -> void:
	var payload := _load_dict(GameStateConfigScript.CHARACTER_ASSETS_PATH, "character assets")
	var characters := Dictionary(payload.get(CharacterAssetKeysScript.KEY_CHARACTERS, {}))
	for character_id in characters.keys():
		var character := Dictionary(characters.get(character_id, {}))
		var expression_ids := {}
		for expression in Array(character.get(CharacterAssetKeysScript.KEY_EXPRESSIONS, [])):
			var expression_id := String(Dictionary(expression).get(CharacterAssetKeysScript.KEY_ID, ""))
			_expect(not expression_id.is_empty(), "character expression should have id: %s" % character_id)
			expression_ids[expression_id] = true

		var outfits := Dictionary(character.get(CharacterAssetKeysScript.KEY_OUTFITS, {}))
		for outfit_id in outfits.keys():
			var outfit := Dictionary(outfits.get(outfit_id, {}))
			var standing_images := Dictionary(outfit.get(CharacterAssetKeysScript.KEY_STANDING_FULL_IMAGES, {}))
			_expect(not standing_images.is_empty(), "outfit should expose standing images: %s/%s" % [character_id, outfit_id])
			for expression_id in expression_ids.keys():
				_expect(standing_images.has(expression_id), "outfit should include standing image for expression: %s/%s/%s" % [character_id, outfit_id, expression_id])
				var asset := Dictionary(standing_images.get(expression_id, {}))
				var path := String(asset.get(CharacterAssetKeysScript.KEY_PATH, ""))
				_expect(ResourceLoader.exists(path), "standing image path should exist: %s" % path)
				var region := Array(asset.get(CharacterAssetKeysScript.KEY_REGION, []))
				_expect(region.is_empty() or region.size() == 4, "standing image region should be empty for an individual PNG or have four atlas values: %s/%s/%s" % [character_id, outfit_id, expression_id])


func _verify_vn_story_visual_contract() -> void:
	var payload := _load_dict(GameStateConfigScript.VN_STORIES_PATH, "VN stories")
	var visuals := Dictionary(payload.get(VnStoryKeysScript.KEY_VISUALS, {}))
	for visual_id in visuals.keys():
		var visual := Dictionary(visuals.get(visual_id, {}))
		var modes := Dictionary(visual.get(VnStoryKeysScript.KEY_MODES, {}))
		for mode_id in modes.keys():
			var mode := Dictionary(modes.get(mode_id, {}))
			var path := String(mode.get(VnStoryKeysScript.KEY_BACKGROUND_PATH, ""))
			_expect(path.is_empty() or ResourceLoader.exists(path), "VN visual background should exist: %s/%s -> %s" % [visual_id, mode_id, path])


func _load_dict(path: String, label: String) -> Dictionary:
	var loaded := JsonFileLoaderScript.read_dictionary(path, label)
	_expect(bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)), "%s should load: %s" % [label, path])
	return Dictionary(loaded.get(JsonFileLoaderScript.KEY_DATA, {}))


func _is_number(value) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
