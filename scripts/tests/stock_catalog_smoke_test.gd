extends "res://scripts/tests/test_scene_tree.gd"

const StockCatalogScript := preload("res://scripts/core/market/stock_catalog.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")


func _initialize() -> void:
	var catalog = StockCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.COMPANIES_PATH)

	_expect(catalog.count() == 30, "stock catalog should load 30 companies")
	_expect(catalog.get_tickers().has("005930"), "stock catalog should expose Samsung ticker")
	_expect(not catalog.debug_real_name_mode, "the shipped catalog should default to fictional company names")
	_expect(catalog.get_display_name_by_ticker("005930") == "새벽전자", "the catalog default should use the fictional company name")
	_expect(catalog.get_display_name_by_ticker("005930", true) == "삼성전자", "real-name mode should keep real company name")
	_expect(catalog.get_display_name_by_ticker("005930", false) == "새벽전자", "alias mode should use fictional company name")
	_expect(String(catalog.get_price_path("005930")).ends_with("data/raw/prices/005930.csv"), "stock catalog should resolve price path")
	_expect(catalog.get_companies(false)[0].get("name_ko", "") == "새벽전자", "company rows should apply display mode")

	print("Stock catalog smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
