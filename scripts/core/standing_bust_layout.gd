class_name StandingBustLayout
extends RefCounted

const StandingBustMetricsScript := preload("res://scripts/core/standing_bust_metrics.gd")
const StandingBustLayoutConfigScript := preload("res://scripts/core/standing_bust_layout_config.gd")
const StandingPositionOverrideStoreScript := preload("res://scripts/core/standing_position_override_store.gd")
const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")

const DEFAULT_OVERRIDE_PATH := StandingBustLayoutConfigScript.DEFAULT_OVERRIDE_PATH
const USER_OVERRIDE_PATH := StandingBustLayoutConfigScript.USER_OVERRIDE_PATH
const BUST_SIZE := StandingBustLayoutConfigScript.BUST_SIZE
const BUST_SOURCE_HEIGHT := StandingBustLayoutConfigScript.BUST_SOURCE_HEIGHT
const BUST_BASE_Y := StandingBustLayoutConfigScript.BUST_BASE_Y
const DESIGN_VIEWPORT_WIDTH := 720.0
const HORIZONTAL_SAFE_MARGIN := 24.0

var offsets := {}
var _metrics_by_key := {}
var _loaded_path := ""
var _override_store = StandingPositionOverrideStoreScript.new(USER_OVERRIDE_PATH, DEFAULT_OVERRIDE_PATH)


func load_overrides() -> void:
	var result := _override_store.load_offsets()
	offsets = Dictionary(result.get(CharacterAssetKeysScript.KEY_OFFSETS, {}))
	_loaded_path = String(result.get(CharacterAssetKeysScript.KEY_LOADED_PATH, ""))


func get_loaded_path() -> String:
	return _loaded_path


func set_override_paths(user_path: String = USER_OVERRIDE_PATH, default_path: String = DEFAULT_OVERRIDE_PATH) -> void:
	_override_store.set_paths(user_path, default_path)


func get_user_override_path() -> String:
	return _override_store.user_path


func get_default_override_path() -> String:
	return _override_store.default_path


func make_bust_texture(resolved_asset: Dictionary) -> Texture2D:
	if not bool(resolved_asset.get(CharacterAssetKeysScript.KEY_ASSET_READY, false)):
		return null

	var texture := load(String(resolved_asset.get(CharacterAssetKeysScript.KEY_ASSET_PATH, ""))) as Texture2D
	if texture == null:
		return null

	var region: Array = resolved_asset.get(CharacterAssetKeysScript.KEY_ATLAS_REGION, [])
	if region.size() != 4:
		return texture

	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = get_bust_region(region)
	return atlas


func apply_to_texture_rect(texture_rect: TextureRect, resolved_asset: Dictionary, viewport_width: float = 720.0) -> void:
	texture_rect.size = get_display_size(viewport_width)
	texture_rect.texture = make_bust_texture(resolved_asset)
	texture_rect.position = get_position(resolved_asset, viewport_width)


func get_position(resolved_asset: Dictionary, viewport_width: float = 720.0) -> Vector2:
	viewport_width = get_layout_width(viewport_width)
	var display_size := get_display_size(viewport_width)
	var metrics := get_bust_metrics(resolved_asset)
	var source_width := float(metrics.get(CharacterAssetKeysScript.KEY_SOURCE_WIDTH, 384.0))
	var source_height := float(metrics.get(CharacterAssetKeysScript.KEY_SOURCE_HEIGHT, BUST_SOURCE_HEIGHT))
	var scale := minf(display_size.x / source_width, display_size.y / source_height)
	var draw_x_padding := (display_size.x - source_width * scale) / 2.0
	var visible_center_x := float(metrics.get(CharacterAssetKeysScript.KEY_VISIBLE_CENTER_X, source_width / 2.0))
	var centered_x := viewport_width / 2.0 - draw_x_padding - visible_center_x * scale
	return Vector2(centered_x, BUST_BASE_Y) + get_offset(resolved_asset)


func get_display_size(viewport_width: float = 720.0) -> Vector2:
	var width := BUST_SIZE.x
	if viewport_width > 0.0:
		width = minf(width, maxf(1.0, get_layout_width(viewport_width) - HORIZONTAL_SAFE_MARGIN))
	return Vector2(width, BUST_SIZE.y)


func get_layout_width(viewport_width: float = 720.0) -> float:
	if viewport_width <= 0.0:
		return DESIGN_VIEWPORT_WIDTH
	return minf(viewport_width, DESIGN_VIEWPORT_WIDTH)


func get_offset(resolved_asset: Dictionary) -> Vector2:
	var key := make_key_from_resolved(resolved_asset)
	var value: Dictionary = offsets.get(key, {})
	return Vector2(
		float(value.get(CharacterAssetKeysScript.KEY_X, 0.0)),
		float(value.get(CharacterAssetKeysScript.KEY_Y, 0.0))
	)


func set_offset(resolved_asset: Dictionary, offset: Vector2) -> void:
	offsets[make_key_from_resolved(resolved_asset)] = {
		CharacterAssetKeysScript.KEY_X: int(round(offset.x)),
		CharacterAssetKeysScript.KEY_Y: int(round(offset.y))
	}


func save_overrides() -> bool:
	return _override_store.save_offsets(offsets)


func make_key(outfit_id: String, expression_id: String) -> String:
	return "%s:%s" % [outfit_id, expression_id]


func make_key_from_resolved(resolved_asset: Dictionary) -> String:
	return make_key(
		String(resolved_asset.get(CharacterAssetKeysScript.KEY_OUTFIT_ID, "")),
		String(resolved_asset.get(CharacterAssetKeysScript.KEY_EXPRESSION_ID, ""))
	)


func get_bust_metrics(resolved_asset: Dictionary) -> Dictionary:
	var asset_path := String(resolved_asset.get(CharacterAssetKeysScript.KEY_ASSET_PATH, ""))
	var region: Array = resolved_asset.get(CharacterAssetKeysScript.KEY_ATLAS_REGION, [])
	if asset_path.is_empty():
		return StandingBustMetricsScript.default_metrics(384.0, float(BUST_SOURCE_HEIGHT))

	var bust_region := get_bust_region(region) if region.size() == 4 else Rect2()
	var cache_key := "%s:%s" % [asset_path, str(bust_region)]
	if _metrics_by_key.has(cache_key):
		return _metrics_by_key[cache_key]

	var source_texture := load(asset_path) as Texture2D
	var image := source_texture.get_image() if source_texture != null else null
	var metrics := StandingBustMetricsScript.metrics_from_image(image, bust_region)
	_metrics_by_key[cache_key] = metrics
	return metrics


func get_bust_region(region: Array) -> Rect2:
	return StandingBustMetricsScript.bust_region(region, float(BUST_SOURCE_HEIGHT))
