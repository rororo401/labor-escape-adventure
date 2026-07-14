class_name StandingCalibratorEntries
extends RefCounted

const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")

const DEFAULT_OUTFIT_ORDER := ["homewear", "casual_default"]


static func build_entries(catalog, character_id: String = "protagonist", outfit_order: Array = DEFAULT_OUTFIT_ORDER) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var outfits: Dictionary = catalog.get_outfits(character_id)
	var expression_names := expression_name_map(catalog, character_id)
	var ordered_outfits := ordered_outfit_ids(outfits, outfit_order)

	for outfit_id in ordered_outfits:
		var outfit: Dictionary = outfits.get(outfit_id, {})
		var outfit_name := String(outfit.get(CharacterAssetKeysScript.KEY_NAME_KO, outfit_id))
		var standing: Dictionary = outfit.get(
			CharacterAssetKeysScript.KEY_STANDING_FULL_IMAGES,
			outfit.get(CharacterAssetKeysScript.KEY_STANDING, {})
		)
		var expression_order: Array = outfit.get(
			CharacterAssetKeysScript.KEY_STANDING_SHEET,
			{}
		).get(CharacterAssetKeysScript.KEY_EXPRESSION_ORDER, [])
		if expression_order.is_empty():
			expression_order = standing.keys()
		for expression_value in expression_order:
			var expression_id := String(expression_value)
			if not standing.has(expression_id):
				continue
			var expression_name := String(expression_names.get(expression_id, expression_id))
			entries.append({
				CharacterAssetKeysScript.ENTRY_LABEL: "%s %s" % [outfit_name, expression_name],
				CharacterAssetKeysScript.ENTRY_OUTFIT: outfit_id,
				CharacterAssetKeysScript.ENTRY_EXPRESSION: expression_id
			})
	return entries


static func expression_name_map(catalog, character_id: String = "protagonist") -> Dictionary:
	var names := {}
	for expression in catalog.get_expressions(character_id):
		var expression_id := String(expression.get(CharacterAssetKeysScript.KEY_ID, ""))
		names[expression_id] = String(expression.get(CharacterAssetKeysScript.KEY_NAME_KO, expression_id))
	return names


static func ordered_outfit_ids(outfits: Dictionary, outfit_order: Array = DEFAULT_OUTFIT_ORDER) -> Array[String]:
	var ids: Array[String] = []
	for outfit_id in outfit_order:
		var text_id := String(outfit_id)
		if outfits.has(text_id):
			ids.append(text_id)
	for outfit_id in outfits.keys():
		var text_id := String(outfit_id)
		if not ids.has(text_id):
			ids.append(text_id)
	return ids
