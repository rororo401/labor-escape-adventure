extends "res://scripts/tests/test_scene_tree.gd"

const MarketSnapshotBuilderScript := preload("res://scripts/core/market/market_snapshot_builder.gd")


func _initialize() -> void:
	_verify_change_rate()
	_verify_row_shape()
	_verify_snapshot_limit_and_missing_prices()

	print("Market snapshot builder smoke test passed.")
	finish_test()


func _verify_change_rate() -> void:
	_expect(MarketSnapshotBuilderScript.change_rate(1100, 1000) == 10.0, "positive change rate should calculate percent")
	_expect(MarketSnapshotBuilderScript.change_rate(900, 1000) == -10.0, "negative change rate should calculate percent")
	_expect(MarketSnapshotBuilderScript.change_rate(900, 0) == 0.0, "missing previous close should produce zero change")


func _verify_row_shape() -> void:
	var row := MarketSnapshotBuilderScript.row({
		"ticker": "AAA",
		"name_ko": "가명전자",
		"sector_hint": "테스트"
	}, {
		"open": 1100,
		"close": 1200,
		"volume": 345
	}, 1000, {
		"quantity": 3,
		"avg_cost": 950
	})

	_expect(String(row.get("ticker", "")) == "AAA", "row should keep ticker")
	_expect(String(row.get("name_ko", "")) == "가명전자", "row should keep display name")
	_expect(int(row.get("open", 0)) == 1100, "row should keep open price")
	_expect(not row.has("close"), "morning row should not expose same-day close")
	_expect(not row.has("volume"), "morning row should not expose same-day final volume")
	_expect(int(row.get("previous_close", 0)) == 1000, "row should keep previous close")
	_expect(float(row.get("change_rate", 0.0)) == 10.0, "row should calculate change rate")
	_expect(int(row.get("held_quantity", 0)) == 3, "row should include held quantity")
	_expect(int(row.get("avg_cost", 0)) == 950, "row should include average cost")


func _verify_snapshot_limit_and_missing_prices() -> void:
	var prices = FakePriceRepository.new()
	var portfolio = FakePortfolio.new()
	var snapshot := MarketSnapshotBuilderScript.build([
		{"ticker": "AAA", "name_ko": "첫번째", "sector_hint": "A"},
		{"ticker": "BBB", "name_ko": "가격없음", "sector_hint": "B"},
		{"ticker": "CCC", "name_ko": "세번째", "sector_hint": "C"}
	], prices, portfolio, "2016-07-04", "2016-07-01", 2)

	var rows: Array = snapshot.get("stocks", [])
	_expect(String(snapshot.get("date", "")) == "2016-07-04", "snapshot should keep date")
	_expect(String(snapshot.get("previous_trading_date", "")) == "2016-07-01", "snapshot should keep previous trading date")
	_expect(rows.size() == 2, "snapshot should skip missing prices and keep searching until limit")
	_expect(String(Dictionary(rows[0]).get("ticker", "")) == "AAA", "first priced row should be included")
	_expect(String(Dictionary(rows[1]).get("ticker", "")) == "CCC", "later priced row should fill the limit after missing price")
	_expect(int(snapshot.get("portfolio", {}).get("cash", 0)) == 1234, "snapshot should include portfolio payload")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakePriceRepository:
	extends RefCounted

	func get_price(ticker: String, date: String) -> Dictionary:
		var rows := {
			"AAA": {"open": 1000, "close": 1100, "volume": 10},
			"CCC": {"open": 2200, "close": 2000, "volume": 20}
		}
		return Dictionary(rows.get(ticker, {}))

	func get_close(ticker: String, date: String) -> int:
		var closes := {
			"AAA": 900,
			"CCC": 2000
		}
		return int(closes.get(ticker, 0))


class FakePortfolio:
	extends RefCounted

	func get_position(ticker: String) -> Dictionary:
		if ticker == "AAA":
			return {"quantity": 2, "avg_cost": 800}
		return {"quantity": 0, "avg_cost": 0}

	func to_dict() -> Dictionary:
		return {"cash": 1234}
