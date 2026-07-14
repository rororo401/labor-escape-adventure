class_name CharacterStandingAssetResolver
extends RefCounted

const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")

const ERROR_CHARACTER_MISSING := CharacterAssetKeysScript.ERROR_CHARACTER_MISSING


static func resolve(
	characters: Dictionary,
	fallbacks: Dictionary,
	character_id: String,
	outfit_id: String,
	expression_id: String
) -> Dictionary:
	var character: Dictionary = Dictionary(characters.get(character_id, {}))
	if character.is_empty():
		return empty_resolution(character_id, outfit_id, expression_id, CharacterAssetKeysScript.ERROR_CHARACTER_MISSING)

	var outfits: Dictionary = Dictionary(character.get(CharacterAssetKeysScript.KEY_OUTFITS, {}))
	var resolved_outfit_id := outfit_id
	if not outfits.has(resolved_outfit_id):
		resolved_outfit_id = String(character.get(
			CharacterAssetKeysScript.KEY_DEFAULT_OUTFIT,
			fallbacks.get(CharacterAssetKeysScript.KEY_FALLBACK_OUTFIT, "")
		))

	var resolved_expression_id := expression_id
	if not has_expression(character, resolved_expression_id):
		resolved_expression_id = String(character.get(
			CharacterAssetKeysScript.KEY_DEFAULT_EXPRESSION,
			fallbacks.get(CharacterAssetKeysScript.KEY_FALLBACK_EXPRESSION, "")
		))

	var outfit: Dictionary = Dictionary(outfits.get(resolved_outfit_id, {}))
	var standing := _standing_dictionary(outfit)
	var asset := _asset_entry(standing.get(resolved_expression_id))

	return {
		CharacterAssetKeysScript.KEY_CHARACTER_ID: character_id,
		CharacterAssetKeysScript.KEY_REQUESTED_OUTFIT_ID: outfit_id,
		CharacterAssetKeysScript.KEY_REQUESTED_EXPRESSION_ID: expression_id,
		CharacterAssetKeysScript.KEY_OUTFIT_ID: resolved_outfit_id,
		CharacterAssetKeysScript.KEY_EXPRESSION_ID: resolved_expression_id,
		CharacterAssetKeysScript.KEY_ASSET_PATH: asset.get(CharacterAssetKeysScript.KEY_PATH),
		CharacterAssetKeysScript.KEY_ATLAS_REGION: asset.get(CharacterAssetKeysScript.KEY_REGION, []),
		CharacterAssetKeysScript.KEY_ASSET_READY: typeof(asset.get(CharacterAssetKeysScript.KEY_PATH)) == TYPE_STRING and not String(asset.get(CharacterAssetKeysScript.KEY_PATH)).is_empty(),
		CharacterAssetKeysScript.KEY_FALLBACK_USED: resolved_outfit_id != outfit_id or resolved_expression_id != expression_id,
		CharacterAssetKeysScript.KEY_ERROR: ""
	}


static func has_expression(character: Dictionary, expression_id: String) -> bool:
	for expression in Array(character.get(CharacterAssetKeysScript.KEY_EXPRESSIONS, [])):
		if typeof(expression) != TYPE_DICTIONARY:
			continue
		if String(Dictionary(expression).get(CharacterAssetKeysScript.KEY_ID, "")) == expression_id:
			return true
	return false


static func empty_resolution(character_id: String, outfit_id: String, expression_id: String, error: String) -> Dictionary:
	return {
		CharacterAssetKeysScript.KEY_CHARACTER_ID: character_id,
		CharacterAssetKeysScript.KEY_REQUESTED_OUTFIT_ID: outfit_id,
		CharacterAssetKeysScript.KEY_REQUESTED_EXPRESSION_ID: expression_id,
		CharacterAssetKeysScript.KEY_OUTFIT_ID: "",
		CharacterAssetKeysScript.KEY_EXPRESSION_ID: "",
		CharacterAssetKeysScript.KEY_ASSET_PATH: null,
		CharacterAssetKeysScript.KEY_ATLAS_REGION: [],
		CharacterAssetKeysScript.KEY_ASSET_READY: false,
		CharacterAssetKeysScript.KEY_FALLBACK_USED: false,
		CharacterAssetKeysScript.KEY_ERROR: error
	}


static func _standing_dictionary(outfit: Dictionary) -> Dictionary:
	var source = outfit.get(
		CharacterAssetKeysScript.KEY_STANDING_FULL_IMAGES,
		outfit.get(CharacterAssetKeysScript.KEY_STANDING, {})
	)
	if typeof(source) != TYPE_DICTIONARY:
		return {}
	return Dictionary(source)


static func _asset_entry(asset_entry) -> Dictionary:
	if typeof(asset_entry) == TYPE_DICTIONARY:
		var row: Dictionary = Dictionary(asset_entry)
		return {
			CharacterAssetKeysScript.KEY_PATH: row.get(CharacterAssetKeysScript.KEY_PATH),
			CharacterAssetKeysScript.KEY_REGION: Array(row.get(CharacterAssetKeysScript.KEY_REGION, []))
		}
	return {
		CharacterAssetKeysScript.KEY_PATH: asset_entry,
		CharacterAssetKeysScript.KEY_REGION: []
	}
