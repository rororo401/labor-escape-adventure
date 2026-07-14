class_name StandingBustMetrics
extends RefCounted

const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")


static func default_metrics(source_width: float, source_height: float) -> Dictionary:
	return {
		CharacterAssetKeysScript.KEY_SOURCE_WIDTH: source_width,
		CharacterAssetKeysScript.KEY_SOURCE_HEIGHT: source_height,
		CharacterAssetKeysScript.KEY_VISIBLE_CENTER_X: source_width / 2.0
	}


static func bust_region(region: Array, source_height: float) -> Rect2:
	return Rect2(
		float(region[0]),
		float(region[1]),
		float(region[2]),
		minf(source_height, float(region[3]))
	)


static func metrics_from_image(image: Image, region: Rect2) -> Dictionary:
	if image == null:
		return default_metrics(384.0, 430.0)
	if region.size.x <= 0.0 or region.size.y <= 0.0:
		region = Rect2(0.0, 0.0, float(image.get_width()), float(image.get_height()))
	var source_width := region.size.x
	var source_height := region.size.y
	return metrics_from_visible_x_values(
		source_width,
		source_height,
		collect_visible_x_values(image, region)
	)


static func collect_visible_x_values(image: Image, region: Rect2, alpha_threshold: float = 0.04) -> Array:
	var visible_x_values := []
	if image == null:
		return visible_x_values

	var start_x := int(region.position.x)
	var start_y := int(region.position.y)
	var source_width := int(region.size.x)
	var source_height := int(region.size.y)
	for y in range(start_y, start_y + source_height):
		for x in range(start_x, start_x + source_width):
			if image.get_pixel(x, y).a > alpha_threshold:
				visible_x_values.append(x - start_x)
	return visible_x_values


static func metrics_from_visible_x_values(source_width: float, source_height: float, visible_x_values: Array) -> Dictionary:
	return {
		CharacterAssetKeysScript.KEY_SOURCE_WIDTH: source_width,
		CharacterAssetKeysScript.KEY_SOURCE_HEIGHT: source_height,
		CharacterAssetKeysScript.KEY_VISIBLE_CENTER_X: visible_center_from_values(source_width, visible_x_values)
	}


static func visible_center_from_values(source_width: float, visible_x_values: Array) -> float:
	if visible_x_values.is_empty():
		return source_width / 2.0

	visible_x_values.sort()
	var middle_index: int = visible_x_values.size() / 2
	if visible_x_values.size() % 2 == 0:
		return (float(visible_x_values[middle_index - 1]) + float(visible_x_values[middle_index])) / 2.0
	return float(visible_x_values[middle_index])
