extends "res://scripts/tests/test_scene_tree.gd"

const MarketStockSelectionScript := preload("res://scripts/ui/market_stock_selection.gd")
const MarketStockRowConfigScript := preload("res://scripts/ui/market_stock_row_config.gd")


func _initialize() -> void:
	var stocks := [
		{
			MarketStockRowConfigScript.KEY_TICKER: "AAA",
			MarketStockRowConfigScript.KEY_NAME: "첫 종목",
			"price": 1000
		},
		{
			MarketStockRowConfigScript.KEY_TICKER: "BBB",
			MarketStockRowConfigScript.KEY_NAME: "둘째 종목",
			"price": 2000
		}
	]

	var found := MarketStockSelectionScript.find_stock(stocks, "BBB")
	_expect(found.get(MarketStockRowConfigScript.KEY_NAME, "") == "둘째 종목", "stock selection should find a stock by ticker")
	_expect(MarketStockSelectionScript.find_stock(stocks, "ZZZ").is_empty(), "stock selection should return empty when ticker is missing")

	var default_selection := MarketStockSelectionScript.resolve_after_refresh(stocks, {})
	_expect(default_selection.get(MarketStockRowConfigScript.KEY_TICKER, "") == "AAA", "empty selection should resolve to the first stock")

	var kept_selection := MarketStockSelectionScript.resolve_after_refresh(stocks, {MarketStockRowConfigScript.KEY_TICKER: "BBB"})
	_expect(kept_selection.get(MarketStockRowConfigScript.KEY_TICKER, "") == "BBB", "existing selection should be preserved after refresh")

	var missing_selection := MarketStockSelectionScript.resolve_after_refresh(stocks, {MarketStockRowConfigScript.KEY_TICKER: "ZZZ"})
	_expect(missing_selection.is_empty(), "missing refreshed selection should resolve to empty")
	_expect(MarketStockSelectionScript.resolve_after_refresh([], {MarketStockRowConfigScript.KEY_TICKER: "AAA"}).is_empty(), "empty stock list should resolve to empty")

	print("Market stock selection smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
