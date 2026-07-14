class_name CharacterAssetCatalog
extends RefCounted

const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")
const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")
const CharacterStandingAssetResolverScript := preload("res://scripts/core/character_standing_asset_resolver.gd")

var characters: Dictionary = {}
var fallbacks: Dictionary = {}


func load_from_json(path: String) -> void:
	characters.clear()
	fallbacks.clear()

	var loaded := JsonFileLoaderScript.read_dictionary(path, "character asset JSON")
	if not bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)):
		return

	var parsed: Dictionary = loaded.get(JsonFileLoaderScript.KEY_DATA, {})
	characters = parsed.get(CharacterAssetKeysScript.KEY_CHARACTERS, {})
	fallbacks = parsed.get(CharacterAssetKeysScript.KEY_FALLBACKS, {})


func get_character(character_id: String) -> Dictionary:
	return characters.get(character_id, {})


func get_outfits(character_id: String) -> Dictionary:
	return get_character(character_id).get(CharacterAssetKeysScript.KEY_OUTFITS, {})


func get_expressions(character_id: String) -> Array:
	return get_character(character_id).get(CharacterAssetKeysScript.KEY_EXPRESSIONS, [])


func get_expression_ids(character_id: String) -> Array[String]:
	var ids: Array[String] = []
	for expression in get_expressions(character_id):
		ids.append(String(expression.get(CharacterAssetKeysScript.KEY_ID, "")))
	return ids


func get_character_asset_context(
	character_id: String,
	default_outfit_id: String,
	default_expression_id: String
) -> Dictionary:
	return {
		CharacterAssetKeysScript.KEY_OUTFITS: get_outfits(character_id).keys(),
		CharacterAssetKeysScript.KEY_EXPRESSIONS: get_expression_ids(character_id),
		CharacterAssetKeysScript.KEY_DEFAULT: resolve_standing_asset(character_id, default_outfit_id, default_expression_id)
	}


func has_outfit(character_id: String, outfit_id: String) -> bool:
	return get_outfits(character_id).has(outfit_id)


func has_expression(character_id: String, expression_id: String) -> bool:
	return CharacterStandingAssetResolverScript.has_expression(get_character(character_id), expression_id)


func resolve_standing_asset(character_id: String, outfit_id: String, expression_id: String) -> Dictionary:
	return CharacterStandingAssetResolverScript.resolve(characters, fallbacks, character_id, outfit_id, expression_id)


func make_standing_texture(resolved_asset: Dictionary) -> Texture2D:
	if not bool(resolved_asset.get(CharacterAssetKeysScript.KEY_ASSET_READY, false)):
		return null

	var asset_path := String(resolved_asset.get(CharacterAssetKeysScript.KEY_ASSET_PATH, ""))
	var texture := load(asset_path) as Texture2D
	if texture == null:
		return null

	var region: Array = resolved_asset.get(CharacterAssetKeysScript.KEY_ATLAS_REGION, [])
	if region.size() != 4:
		return texture

	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(
		float(region[0]),
		float(region[1]),
		float(region[2]),
		float(region[3])
	)
	return atlas
