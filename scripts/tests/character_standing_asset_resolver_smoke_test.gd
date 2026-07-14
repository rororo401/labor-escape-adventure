extends "res://scripts/tests/test_scene_tree.gd"

const CharacterStandingAssetResolverScript := preload("res://scripts/core/character_standing_asset_resolver.gd")


func _initialize() -> void:
	var characters := {
		"hero": {
			"default_outfit": "casual",
			"default_expression": "neutral",
			"expressions": [
				{"id": "neutral"},
				{"id": "smile"},
				"broken_row"
			],
			"outfits": {
				"casual": {
					"standing_full_images": {
						"neutral": {
							"path": "res://assets/characters/protagonist/casual_default/standing_sheet.png",
							"region": [0, 0, 384, 512]
						},
						"smile": "res://assets/characters/protagonist/casual_default/standing_sheet.png"
					}
				},
				"legacy": {
					"standing": {
						"neutral": {
							"path": "res://assets/characters/protagonist/homewear/standing_sheet.png"
						}
					}
				}
			}
		}
	}
	var fallbacks := {
		"outfit": "casual",
		"expression": "neutral"
	}

	_expect(
		CharacterStandingAssetResolverScript.has_expression(characters.get("hero", {}), "smile"),
		"resolver should find dictionary expression rows"
	)
	_expect(
		not CharacterStandingAssetResolverScript.has_expression(characters.get("hero", {}), "broken_row"),
		"resolver should ignore non-dictionary expression rows"
	)

	var direct: Dictionary = CharacterStandingAssetResolverScript.resolve(characters, fallbacks, "hero", "casual", "neutral")
	_expect(direct.get("asset_ready", false), "direct dictionary asset should be ready")
	_expect(direct.get("atlas_region", []).size() == 4, "direct dictionary asset should expose atlas region")
	_expect(not direct.get("fallback_used", true), "direct asset should not mark fallback used")

	var string_asset: Dictionary = CharacterStandingAssetResolverScript.resolve(characters, fallbacks, "hero", "casual", "smile")
	_expect(string_asset.get("asset_ready", false), "string asset entry should be ready")
	_expect(string_asset.get("atlas_region", []).is_empty(), "string asset entry should not invent atlas region")

	var legacy: Dictionary = CharacterStandingAssetResolverScript.resolve(characters, fallbacks, "hero", "legacy", "neutral")
	_expect(legacy.get("asset_path", "") == "res://assets/characters/protagonist/homewear/standing_sheet.png", "legacy standing map should resolve")

	var fallback: Dictionary = CharacterStandingAssetResolverScript.resolve(characters, fallbacks, "hero", "future_outfit", "future_expression")
	_expect(fallback.get("outfit_id", "") == "casual", "missing outfit should fall back to default outfit")
	_expect(fallback.get("expression_id", "") == "neutral", "missing expression should fall back to default expression")
	_expect(fallback.get("fallback_used", false), "missing outfit/expression should mark fallback used")

	var missing: Dictionary = CharacterStandingAssetResolverScript.resolve(characters, fallbacks, "missing", "casual", "neutral")
	_expect(not missing.get("asset_ready", true), "missing character should not be ready")
	_expect(missing.get("error", "") == "character_missing", "missing character should expose character_missing error")

	print("Character standing asset resolver smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
