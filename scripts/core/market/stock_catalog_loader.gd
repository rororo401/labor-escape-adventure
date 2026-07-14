class_name StockCatalogLoader
extends RefCounted

const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")


static func load_from_json(path: String) -> Dictionary:
	var loaded := JsonFileLoaderScript.read_dictionary(path, "stock catalog JSON")
	if not bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)):
		return empty_payload()

	var parsed: Dictionary = loaded.get(JsonFileLoaderScript.KEY_DATA, {})
	var alias_file := to_resource_path(String(parsed.get(MarketDataKeysScript.KEY_ALIAS_FILE, "")))
	var aliases := load_aliases(alias_file)
	return build_payload(parsed, aliases, alias_file)


static func build_payload(parsed: Dictionary, aliases_by_ticker: Dictionary = {}, alias_file: String = "") -> Dictionary:
	var companies: Array[Dictionary] = []
	var company_by_ticker := {}

	for company in Array(parsed.get(MarketDataKeysScript.KEY_COMPANIES, [])):
		if typeof(company) != TYPE_DICTIONARY:
			continue
		var normalized := normalize_company(Dictionary(company), aliases_by_ticker)
		var ticker := String(normalized.get(MarketDataKeysScript.KEY_TICKER, ""))
		if ticker.is_empty():
			continue
		companies.append(normalized)
		company_by_ticker[ticker] = normalized

	return {
		MarketDataKeysScript.KEY_COMPANIES: companies,
		MarketDataKeysScript.KEY_COMPANY_BY_TICKER: company_by_ticker,
		MarketDataKeysScript.KEY_DEBUG_REAL_NAME_MODE: bool(parsed.get(MarketDataKeysScript.KEY_DEBUG_REAL_NAME_MODE, false)),
		MarketDataKeysScript.KEY_ALIAS_FILE: alias_file
	}


static func empty_payload() -> Dictionary:
	return {
		MarketDataKeysScript.KEY_COMPANIES: [],
		MarketDataKeysScript.KEY_COMPANY_BY_TICKER: {},
		MarketDataKeysScript.KEY_DEBUG_REAL_NAME_MODE: false,
		MarketDataKeysScript.KEY_ALIAS_FILE: ""
	}


static func normalize_company(company: Dictionary, aliases_by_ticker: Dictionary = {}) -> Dictionary:
	var normalized := company.duplicate(true)
	var ticker := String(normalized.get(MarketDataKeysScript.KEY_TICKER, ""))
	if aliases_by_ticker.has(ticker):
		var alias: Dictionary = Dictionary(aliases_by_ticker[ticker])
		for key in alias.keys():
			normalized[key] = alias[key]
	normalized[MarketDataKeysScript.KEY_PRICE_PATH] = to_resource_path(String(normalized.get(MarketDataKeysScript.KEY_SOURCE_FILE, "")))
	return normalized


static func load_aliases(path: String) -> Dictionary:
	if path.is_empty():
		return {}

	var loaded := JsonFileLoaderScript.read_dictionary(path, "company alias JSON", false)
	if not bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)):
		push_warning("Could not load company alias JSON (%s): %s" % [String(loaded.get(JsonFileLoaderScript.KEY_ERROR, "")), path])
		return {}

	var parsed: Dictionary = loaded.get(JsonFileLoaderScript.KEY_DATA, {})
	return normalize_aliases(Dictionary(parsed.get(MarketDataKeysScript.KEY_ALIASES, {})))


static func normalize_aliases(aliases: Dictionary) -> Dictionary:
	var aliases_by_ticker := {}
	for ticker in aliases.keys():
		var alias = aliases[ticker]
		if typeof(alias) != TYPE_DICTIONARY:
			continue
		aliases_by_ticker[String(ticker)] = Dictionary(alias)
	return aliases_by_ticker


static func to_resource_path(path: String) -> String:
	if path.begins_with("res://"):
		return path
	if path.is_empty():
		return ""
	return "res://%s" % path
