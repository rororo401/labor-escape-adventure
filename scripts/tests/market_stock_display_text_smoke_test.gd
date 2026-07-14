extends "res://scripts/tests/test_scene_tree.gd"

const MarketStockDisplayTextScript := preload("res://scripts/ui/market_stock_display_text.gd")
const MarketStockRowConfigScript := preload("res://scripts/ui/market_stock_row_config.gd")


func _initialize() -> void:
	var stock := {
		MarketStockRowConfigScript.KEY_TICKER: "005930",
		MarketStockRowConfigScript.KEY_NAME_KO: "삼성전자",
		MarketStockRowConfigScript.KEY_DISPLAY_NAME: "별빛전자",
		MarketStockRowConfigScript.KEY_OPEN: 28540,
		MarketStockRowConfigScript.KEY_PREVIOUS_CLOSE: 28700,
		MarketStockRowConfigScript.KEY_CHANGE_RATE: 1.234,
		MarketStockRowConfigScript.KEY_HELD_QUANTITY: 3,
		MarketStockRowConfigScript.KEY_AVG_COST: 28000
	}

	_expect(MarketStockDisplayTextScript.display_name(stock) == "별빛전자", "display text should prefer an explicit display name")
	_expect(MarketStockDisplayTextScript.title(stock) == "별빛전자", "title should not expose the source-market ticker")
	_expect(MarketStockDisplayTextScript.price_line(stock) == "시가 28,540원  전일종가 28,700원  등락 +1.23%", "price line should show only prices known at market open")
	_expect(MarketStockDisplayTextScript.holding_line(stock) == "보유 3주  평균 28,000원", "holding line should format quantity and average cost")
	_expect(MarketStockDisplayTextScript.open_price(stock) == "28,540원", "open price should format won")
	_expect(MarketStockDisplayTextScript.change_rate(stock) == "+1.23%", "change rate should format percent")
	_expect(MarketStockDisplayTextScript.quantity(12) == "12주", "quantity should format share counts")

	var fallback_stock := {
		MarketStockRowConfigScript.KEY_TICKER: "AAA",
		MarketStockRowConfigScript.KEY_NAME: "Fallback Name"
	}
	_expect(MarketStockDisplayTextScript.display_name(fallback_stock) == "Fallback Name", "display name should fall back to generic name")
	_expect(MarketStockDisplayTextScript.title({MarketStockRowConfigScript.KEY_TICKER: "ONLY"}) == "ONLY", "title should tolerate missing names")
	_expect(MarketStockDisplayTextScript.title({MarketStockRowConfigScript.KEY_NAME_KO: "이름만"}) == "이름만", "title should tolerate missing tickers")
	_expect(MarketStockDisplayTextScript.price_line({MarketStockRowConfigScript.KEY_OPEN: 1000}) == "시가 1,000원  전일종가 -  등락 0.00%", "first market day should label a missing previous close without inventing a price")

	print("Market stock display text smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
