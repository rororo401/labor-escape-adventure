class_name ProtagonistStandingView
extends RefCounted

const CharacterAssetCatalogScript := preload("res://scripts/core/character_asset_catalog.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const StandingBustLayoutScript := preload("res://scripts/core/standing_bust_layout.gd")
const CharacterOutfitSeasonScript := preload("res://scripts/core/character_outfit_season.gd")

const CHARACTER_ASSETS_PATH := GameStateConfigScript.CHARACTER_ASSETS_PATH
const CHARACTER_ID := GameStateConfigScript.PROTAGONIST_CHARACTER_ID

var texture_rect: TextureRect

var _character_assets = CharacterAssetCatalogScript.new()
var _standing_layout = StandingBustLayoutScript.new()
var _is_loaded := false


func add_to(parent: Node, node_name: String) -> TextureRect:
	texture_rect = TextureRect.new()
	texture_rect.name = node_name
	texture_rect.size = StandingBustLayoutScript.BUST_SIZE
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(texture_rect)
	return texture_rect


func apply(owner: Control, outfit_id: String, expression_id: String, date: String = "") -> Dictionary:
	ensure_loaded()
	if texture_rect == null:
		return {}

	var viewport_width := 720.0
	if owner != null:
		viewport_width = owner.get_viewport_rect().size.x
		if owner.size.x > 0.0:
			viewport_width = minf(viewport_width, owner.size.x)
		if viewport_width <= 0.0:
			viewport_width = 720.0

	var resolved := resolve(outfit_id, expression_id, date)
	_standing_layout.apply_to_texture_rect(texture_rect, resolved, viewport_width)
	return resolved


func resolve(outfit_id: String, expression_id: String, date: String = "") -> Dictionary:
	ensure_loaded()
	var seasonal_outfit := CharacterOutfitSeasonScript.outfit_for_date(outfit_id, date)
	return _character_assets.resolve_standing_asset(CHARACTER_ID, seasonal_outfit, expression_id)


func ensure_loaded() -> void:
	if _is_loaded:
		return
	_character_assets.load_from_json(CHARACTER_ASSETS_PATH)
	_standing_layout.load_overrides()
	_is_loaded = true
