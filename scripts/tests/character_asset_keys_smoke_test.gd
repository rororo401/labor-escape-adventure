extends "res://scripts/tests/test_scene_tree.gd"

const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")
const CharacterVisualKeysScript := preload("res://scripts/core/character_visual_keys.gd")
const IdentityPayloadKeysScript := preload("res://scripts/core/identity_payload_keys.gd")
const LocalizedPayloadKeysScript := preload("res://scripts/core/localized_payload_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")


func _initialize() -> void:
	_verify_catalog_schema_keys()
	_verify_resolved_asset_keys()
	_verify_layout_and_override_keys()
	_verify_calibrator_entry_keys()

	print("Character asset keys smoke test passed.")
	finish_test()


func _verify_catalog_schema_keys() -> void:
	_expect(CharacterAssetKeysScript.KEY_CHARACTERS == "characters", "characters key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_FALLBACKS == "fallbacks", "fallbacks key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_OUTFITS == "outfits", "outfits key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_EXPRESSIONS == "expressions", "expressions key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_DEFAULT == "default", "default key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_ID == IdentityPayloadKeysScript.KEY_ID, "id key should use the shared identity key")
	_expect(CharacterAssetKeysScript.KEY_NAME_KO == LocalizedPayloadKeysScript.KEY_NAME_KO, "Korean name key should use the shared localized payload key")
	_expect(CharacterAssetKeysScript.KEY_DEFAULT_OUTFIT == CharacterVisualKeysScript.KEY_DEFAULT_OUTFIT, "default outfit key should use the shared character visual key")
	_expect(CharacterAssetKeysScript.KEY_DEFAULT_EXPRESSION == CharacterVisualKeysScript.KEY_DEFAULT_EXPRESSION, "default expression key should use the shared character visual key")
	_expect(CharacterAssetKeysScript.KEY_FALLBACK_OUTFIT == CharacterVisualKeysScript.KEY_OUTFIT, "fallback outfit key should use the shared character visual key")
	_expect(CharacterAssetKeysScript.KEY_FALLBACK_EXPRESSION == CharacterVisualKeysScript.KEY_EXPRESSION, "fallback expression key should use the shared character visual key")


func _verify_resolved_asset_keys() -> void:
	_expect(CharacterAssetKeysScript.KEY_STANDING_FULL_IMAGES == "standing_full_images", "standing full-image key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_STANDING == "standing", "legacy standing key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_STANDING_SHEET == "standing_sheet", "standing sheet key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_EXPRESSION_ORDER == "expression_order", "expression order key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_PATH == ResultKeysScript.KEY_PATH, "asset path source key should use the shared result key")
	_expect(CharacterAssetKeysScript.KEY_REGION == "region", "asset region source key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_CHARACTER_ID == "character_id", "character id key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_OUTFIT_ID == "outfit_id", "resolved outfit key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_EXPRESSION_ID == "expression_id", "resolved expression key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_ASSET_PATH == "asset_path", "resolved asset path key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_ATLAS_REGION == "atlas_region", "atlas region key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_ASSET_READY == "asset_ready", "asset-ready key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_FALLBACK_USED == "fallback_used", "fallback-used key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_ERROR == ResultKeysScript.KEY_ERROR, "asset error key should use the shared result key")
	_expect(CharacterAssetKeysScript.ERROR_CHARACTER_MISSING == "character_missing", "missing-character error should stay stable")


func _verify_layout_and_override_keys() -> void:
	_expect(CharacterAssetKeysScript.KEY_SOURCE_WIDTH == "source_width", "source width key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_SOURCE_HEIGHT == "source_height", "source height key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_VISIBLE_CENTER_X == "visible_center_x", "visible-center key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_VERSION == "version", "override version key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_NOTE == "note", "override note key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_OFFSETS == "offsets", "offsets key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_LOADED_PATH == "loaded_path", "loaded-path key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_X == "x", "x-offset key should stay stable")
	_expect(CharacterAssetKeysScript.KEY_Y == "y", "y-offset key should stay stable")


func _verify_calibrator_entry_keys() -> void:
	_expect(CharacterAssetKeysScript.ENTRY_LABEL == "label", "calibrator entry label key should stay stable")
	_expect(CharacterAssetKeysScript.ENTRY_OUTFIT == CharacterVisualKeysScript.KEY_OUTFIT, "calibrator entry outfit key should use the shared character visual key")
	_expect(CharacterAssetKeysScript.ENTRY_EXPRESSION == CharacterVisualKeysScript.KEY_EXPRESSION, "calibrator entry expression key should use the shared character visual key")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
