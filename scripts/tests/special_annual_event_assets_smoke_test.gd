extends "res://scripts/tests/test_scene_tree.gd"

const DayEventCatalogScript := preload("res://scripts/core/dayflow/day_event_catalog.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	var catalog = DayEventCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.DAY_EVENTS_PATH)
	_verify_real_assets(catalog, "new_year", 10)
	_verify_real_assets(catalog, "seollal", 30)
	_verify_real_assets(catalog, "chuseok", 30)
	print("Special annual event assets smoke test passed.")
	finish_test()


func _verify_real_assets(catalog, series_id: String, expected_count: int) -> void:
	var found := 0
	for row in catalog.day_actions:
		var action := Dictionary(row)
		if String(action.get("series_id", "")) != series_id:
			continue
		found += 1
		var cg_path := String(action.get("cg_path", ""))
		_expect(cg_path == String(action.get("planned_cg_path", "")), "%s should use the planned premium CG path" % action.get("id", ""))
		_expect(not Array(action.get("tags", [])).has("cg_pending"), "%s should not keep cg_pending after image import" % action.get("id", ""))
		_expect(ResourceLoader.exists(cg_path), "%s CG should exist: %s" % [action.get("id", ""), cg_path])
	_expect(found == expected_count, "%s annual event count mismatch" % series_id)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
