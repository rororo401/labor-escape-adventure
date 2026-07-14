extends "res://scripts/tests/test_scene_tree.gd"

const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const StockCatalogScript := preload("res://scripts/core/market/stock_catalog.gd")

const KEEP_IMPORT_DECLARATION := "importer=\"keep\""


func _initialize() -> void:
	_verify_runtime_csv(GameStateConfigScript.CALENDAR_PATH)

	var catalog := StockCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.COMPANIES_PATH)
	_expect(catalog.count() == 30, "packaging test should discover all stock CSV paths")
	for ticker in catalog.get_tickers():
		_verify_runtime_csv(catalog.get_price_path(ticker))

	print("Runtime CSV packaging smoke test passed.")
	finish_test()


func _verify_runtime_csv(path: String) -> void:
	_expect(FileAccess.file_exists(path), "runtime CSV should exist: %s" % path)
	if not _is_source_checkout():
		return
	var import_path := "%s.import" % path
	_expect(FileAccess.file_exists(import_path), "runtime CSV should have tracked import metadata: %s" % import_path)
	var import_text := FileAccess.get_file_as_string(import_path)
	_expect(import_text.contains(KEEP_IMPORT_DECLARATION), "runtime CSV should use Keep File export mode: %s" % path)


func _is_source_checkout() -> bool:
	return DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("res://.git"))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
