extends "res://scripts/tests/test_scene_tree.gd"

const CharacterAssetCatalogScript := preload("res://scripts/core/character_asset_catalog.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	var catalog = CharacterAssetCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.CHARACTER_ASSETS_PATH)

	var expressions := catalog.get_expression_ids("protagonist")
	_expect(expressions.has("neutral"), "protagonist should expose neutral expression id")
	_expect(expressions.has("thinking"), "protagonist should expose thinking expression id")

	var context: Dictionary = catalog.get_character_asset_context("protagonist", "casual_default", "neutral")
	_expect(context.get("outfits", []).has("casual_default"), "protagonist context should expose casual outfit")
	_expect(context.get("outfits", []).has("homewear"), "protagonist context should expose homewear outfit")
	_expect(context.get("outfits", []).has("summer_office"), "protagonist context should expose summer office outfit")
	_expect(context.get("outfits", []).has("summer_homewear"), "protagonist context should expose summer homewear outfit")
	_expect(context.get("expressions", []).has("smile"), "protagonist context should expose smile expression")
	_expect(context.get("default", {}).get("outfit_id", "") == "casual_default", "protagonist default outfit mismatch")
	_expect(context.get("default", {}).get("expression_id", "") == "neutral", "protagonist default expression mismatch")
	_expect(context.get("default", {}).get("asset_ready", false), "protagonist default asset should be ready")

	var summer_asset: Dictionary = catalog.resolve_standing_asset("protagonist", "summer_office", "smile")
	_expect(summer_asset.get("outfit_id", "") == "summer_office", "summer office outfit should resolve")
	_expect(summer_asset.get("expression_id", "") == "smile", "summer office smile should resolve")
	_expect(summer_asset.get("asset_path", "") == "res://assets/characters/protagonist/summer_office/standing/smile.png", "summer office path mismatch")
	_expect(summer_asset.get("atlas_region", []).is_empty(), "summer office individual image should not expose atlas region")

	var summer_homewear_asset: Dictionary = catalog.resolve_standing_asset("protagonist", "summer_homewear", "smile")
	_expect(summer_homewear_asset.get("outfit_id", "") == "summer_homewear", "summer homewear outfit should resolve")
	_expect(summer_homewear_asset.get("expression_id", "") == "smile", "summer homewear smile should resolve")
	_expect(summer_homewear_asset.get("asset_path", "") == "res://assets/characters/protagonist/summer_homewear/standing/smile.png", "summer homewear individual path mismatch")
	_expect(summer_homewear_asset.get("atlas_region", []).is_empty(), "summer homewear individual image should not expose atlas region")

	var base_asset: Dictionary = catalog.resolve_standing_asset("protagonist", "casual_default", "neutral")
	_expect(base_asset.get("asset_path", "") == "res://assets/characters/protagonist/casual_default/standing/neutral.png", "casual default individual path mismatch")
	_expect(base_asset.get("atlas_region", []).is_empty(), "casual default individual image should not expose atlas region")

	var homewear_asset: Dictionary = catalog.resolve_standing_asset("protagonist", "homewear", "neutral")
	_expect(homewear_asset.get("asset_path", "") == "res://assets/characters/protagonist/homewear/standing/neutral.png", "homewear individual path mismatch")
	_expect(homewear_asset.get("atlas_region", []).is_empty(), "homewear individual image should not expose atlas region")

	var fallback: Dictionary = catalog.resolve_standing_asset("protagonist", "future_outfit", "future_expression")
	_expect(fallback.get("outfit_id", "") == "casual_default", "missing outfit should fall back to casual_default")
	_expect(fallback.get("expression_id", "") == "neutral", "missing expression should fall back to neutral")
	_expect(fallback.get("fallback_used", false), "missing asset request should mark fallback used")

	var missing: Dictionary = catalog.get_character_asset_context("missing_character", "casual_default", "neutral")
	_expect(missing.get("outfits", []).is_empty(), "missing character should expose no outfits")
	_expect(missing.get("expressions", []).is_empty(), "missing character should expose no expressions")
	_expect(not missing.get("default", {}).get("asset_ready", true), "missing character default should not be ready")
	_expect(missing.get("default", {}).get("error", "") == "character_missing", "missing character should expose resolution error")

	print("Character asset catalog smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
