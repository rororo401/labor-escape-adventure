extends "res://scripts/tests/test_scene_tree.gd"

const StockCatalogLoaderScript := preload("res://scripts/core/market/stock_catalog_loader.gd")


func _initialize() -> void:
	_verify_resource_path_normalization()
	_verify_alias_normalization()
	_verify_payload_building()

	print("Stock catalog loader smoke test passed.")
	finish_test()


func _verify_resource_path_normalization() -> void:
	_expect(StockCatalogLoaderScript.to_resource_path("") == "", "empty paths should stay empty")
	_expect(StockCatalogLoaderScript.to_resource_path("res://already.csv") == "res://already.csv", "resource paths should stay unchanged")
	_expect(StockCatalogLoaderScript.to_resource_path("data/raw/prices/AAA.csv") == "res://data/raw/prices/AAA.csv", "relative paths should become resource paths")


func _verify_alias_normalization() -> void:
	var aliases := StockCatalogLoaderScript.normalize_aliases({
		"AAA": {"display_name_ko": "별명전자"},
		"BBB": "broken"
	})
	_expect(aliases.has("AAA"), "dictionary alias rows should be kept")
	_expect(not aliases.has("BBB"), "non-dictionary alias rows should be ignored")


func _verify_payload_building() -> void:
	var payload := StockCatalogLoaderScript.build_payload({
		"debug_real_name_mode": false,
		"companies": [
			{
				"ticker": "AAA",
				"real_name_ko": "진짜전자",
				"display_name_ko": "원래전자",
				"source_file": "data/raw/prices/AAA.csv"
			},
			{
				"ticker": "",
				"real_name_ko": "비어있음",
				"source_file": "data/raw/prices/EMPTY.csv"
			},
			"broken"
		]
	}, {
		"AAA": {"display_name_ko": "가명전자", "sector_hint": "테스트"}
	}, "res://data/market/company_aliases.json")

	var companies: Array = payload.get("companies", [])
	_expect(companies.size() == 1, "payload should include only valid ticker company rows")
	var company: Dictionary = companies[0]
	_expect(String(company.get("display_name_ko", "")) == "가명전자", "alias should override display name")
	_expect(String(company.get("real_name_ko", "")) == "진짜전자", "alias should not remove real name")
	_expect(String(company.get("sector_hint", "")) == "테스트", "alias should merge additional fields")
	_expect(String(company.get("price_path", "")) == "res://data/raw/prices/AAA.csv", "source file should become price path")
	_expect(not bool(payload.get("debug_real_name_mode", true)), "debug real-name mode should be preserved")
	_expect(String(payload.get("alias_file", "")) == "res://data/market/company_aliases.json", "alias file path should be preserved")
	_expect(Dictionary(payload.get("company_by_ticker", {})).has("AAA"), "payload should index companies by ticker")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
