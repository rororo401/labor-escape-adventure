class_name CharacterAssetKeys
extends RefCounted

const LocalizedPayloadKeysScript := preload("res://scripts/core/localized_payload_keys.gd")
const CharacterVisualKeysScript := preload("res://scripts/core/character_visual_keys.gd")
const IdentityPayloadKeysScript := preload("res://scripts/core/identity_payload_keys.gd")
const ResultKeysScript := preload("res://scripts/core/result_keys.gd")

const KEY_CHARACTERS := "characters"
const KEY_FALLBACKS := "fallbacks"
const KEY_OUTFITS := "outfits"
const KEY_EXPRESSIONS := "expressions"
const KEY_DEFAULT := "default"
const KEY_ID := IdentityPayloadKeysScript.KEY_ID
const KEY_NAME_KO := LocalizedPayloadKeysScript.KEY_NAME_KO

const KEY_DEFAULT_OUTFIT := CharacterVisualKeysScript.KEY_DEFAULT_OUTFIT
const KEY_DEFAULT_EXPRESSION := CharacterVisualKeysScript.KEY_DEFAULT_EXPRESSION
const KEY_FALLBACK_OUTFIT := CharacterVisualKeysScript.KEY_OUTFIT
const KEY_FALLBACK_EXPRESSION := CharacterVisualKeysScript.KEY_EXPRESSION

const KEY_STANDING_FULL_IMAGES := "standing_full_images"
const KEY_STANDING := "standing"
const KEY_STANDING_SHEET := "standing_sheet"
const KEY_EXPRESSION_ORDER := "expression_order"
const KEY_PATH := ResultKeysScript.KEY_PATH
const KEY_REGION := "region"

const KEY_CHARACTER_ID := "character_id"
const KEY_REQUESTED_OUTFIT_ID := "requested_outfit_id"
const KEY_REQUESTED_EXPRESSION_ID := "requested_expression_id"
const KEY_OUTFIT_ID := "outfit_id"
const KEY_EXPRESSION_ID := "expression_id"
const KEY_ASSET_PATH := "asset_path"
const KEY_ATLAS_REGION := "atlas_region"
const KEY_ASSET_READY := "asset_ready"
const KEY_FALLBACK_USED := "fallback_used"
const KEY_ERROR := ResultKeysScript.KEY_ERROR

const KEY_SOURCE_WIDTH := "source_width"
const KEY_SOURCE_HEIGHT := "source_height"
const KEY_VISIBLE_CENTER_X := "visible_center_x"

const KEY_VERSION := "version"
const KEY_NOTE := "note"
const KEY_OFFSETS := "offsets"
const KEY_LOADED_PATH := "loaded_path"
const KEY_X := "x"
const KEY_Y := "y"

const ENTRY_LABEL := "label"
const ENTRY_OUTFIT := CharacterVisualKeysScript.KEY_OUTFIT
const ENTRY_EXPRESSION := CharacterVisualKeysScript.KEY_EXPRESSION

const ERROR_CHARACTER_MISSING := "character_missing"
