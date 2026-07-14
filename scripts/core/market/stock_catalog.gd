class_name StockCatalog
extends RefCounted

const StockCatalogLoaderScript := preload("res://scripts/core/market/stock_catalog_loader.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")

var companies: Array[Dictionary] = []
var debug_real_name_mode := false
var alias_file := ""
var _company_by_ticker := {}


func load_from_json(path: String) -> void:
	companies.clear()
	_company_by_ticker.clear()
	_apply_payload(StockCatalogLoaderScript.load_from_json(path))


func count() -> int:
	return companies.size()


func get_company(ticker: String) -> Dictionary:
	return _company_by_ticker.get(ticker, {})


func get_companies(real_name_mode: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for company in companies:
		var row := Dictionary(company)
		row[MarketDataKeysScript.KEY_NAME_KO] = get_display_name(row, real_name_mode)
		result.append(row)
	return result


func get_display_name(company: Dictionary, real_name_mode: bool = false) -> String:
	if real_name_mode:
		return String(company.get(MarketDataKeysScript.KEY_REAL_NAME_KO, company.get(MarketDataKeysScript.KEY_DISPLAY_NAME_KO, "")))
	return String(company.get(MarketDataKeysScript.KEY_DISPLAY_NAME_KO, company.get(MarketDataKeysScript.KEY_REAL_NAME_KO, "")))


func get_display_name_by_ticker(ticker: String, real_name_mode: bool = debug_real_name_mode) -> String:
	return get_display_name(get_company(ticker), real_name_mode)


func get_price_path(ticker: String) -> String:
	return String(get_company(ticker).get(MarketDataKeysScript.KEY_PRICE_PATH, ""))


func get_tickers() -> Array[String]:
	var tickers: Array[String] = []
	for company in companies:
		tickers.append(String(company.get(MarketDataKeysScript.KEY_TICKER, "")))
	return tickers


func _apply_payload(payload: Dictionary) -> void:
	companies.assign(payload.get(MarketDataKeysScript.KEY_COMPANIES, []))
	_company_by_ticker = Dictionary(payload.get(MarketDataKeysScript.KEY_COMPANY_BY_TICKER, {}))
	debug_real_name_mode = bool(payload.get(MarketDataKeysScript.KEY_DEBUG_REAL_NAME_MODE, false))
	alias_file = String(payload.get(MarketDataKeysScript.KEY_ALIAS_FILE, ""))
