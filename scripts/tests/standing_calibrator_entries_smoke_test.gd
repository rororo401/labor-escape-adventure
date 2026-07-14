extends "res://scripts/tests/test_scene_tree.gd"

const CharacterAssetCatalogScript := preload("res://scripts/core/character_asset_catalog.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const StandingCalibratorEntriesScript := preload("res://scripts/dev/standing_calibrator_entries.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	_verify_real_catalog_entries()
	_verify_outfit_order()
	_verify_missing_standing_rows_are_skipped()

	print("Standing calibrator entries smoke test passed.")
	finish_test()


func _verify_real_catalog_entries() -> void:
	var catalog = CharacterAssetCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.CHARACTER_ASSETS_PATH)

	var entries: Array[Dictionary] = StandingCalibratorEntriesScript.build_entries(catalog)
	_expect(not entries.is_empty(), "real character catalog should produce standing entries")
	_expect(String(entries[0].get("outfit", "")) == "homewear", "homewear should be first in default order")
	_expect(_helpers.ids_from_items(_entry_id_rows(entries)).has("homewear:smile"), "entries should include homewear smile")
	_expect(String(entries[0].get("label", "")).length() > 0, "entries should include display labels")

	var expression_names := StandingCalibratorEntriesScript.expression_name_map(catalog)
	_expect(String(expression_names.get("smile", "")).length() > 0, "expression name map should include smile")


func _verify_outfit_order() -> void:
	var ordered := StandingCalibratorEntriesScript.ordered_outfit_ids({
		"third": {},
		"casual_default": {},
		"homewear": {}
	}, ["homewear", "casual_default"])
	_expect(ordered[0] == "homewear", "explicit outfit order should place homewear first")
	_expect(ordered[1] == "casual_default", "explicit outfit order should place casual default second")
	_expect(ordered.has("third"), "ordered outfit ids should include remaining outfits")


func _verify_missing_standing_rows_are_skipped() -> void:
	var catalog = FakeCatalog.new()
	var entries: Array[Dictionary] = StandingCalibratorEntriesScript.build_entries(catalog, "protagonist", ["test_outfit"])
	_expect(entries.size() == 1, "missing standing expressions should be skipped")
	_expect(entries[0].get("expression", "") == "neutral", "only existing standing expression should remain")
	_expect(String(entries[0].get("label", "")).contains("기본"), "entry label should use expression display name")


func _entry_id_rows(entries: Array[Dictionary]) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for entry in entries:
		rows.append({
			"id": "%s:%s" % [String(entry.get("outfit", "")), String(entry.get("expression", ""))]
		})
	return rows


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakeCatalog:
	func get_outfits(_character_id: String) -> Dictionary:
		return {
			"test_outfit": {
				"name_ko": "테스트복",
				"standing": {
					"neutral": {}
				},
				"standing_sheet": {
					"expression_order": ["neutral", "missing"]
				}
			}
		}

	func get_expressions(_character_id: String) -> Array[Dictionary]:
		return [
			{"id": "neutral", "name_ko": "기본"},
			{"id": "missing", "name_ko": "없음"}
		]
