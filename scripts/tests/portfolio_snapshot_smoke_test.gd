extends "res://scripts/tests/test_scene_tree.gd"

const PortfolioSnapshotScript := preload("res://scripts/core/market/portfolio_snapshot.gd")


func _initialize() -> void:
	_verify_snapshot_payload()
	_verify_position_restore_filters()
	_verify_scalar_normalization()

	print("Portfolio snapshot smoke test passed.")
	finish_test()


func _verify_snapshot_payload() -> void:
	var positions := {
		"AAA": {
			"ticker": "AAA",
			"quantity": 2,
			"avg_cost": 1000
		},
		"BAD": {
			"ticker": "BAD",
			"quantity": 0,
			"avg_cost": 1000
		}
	}

	var snapshot := PortfolioSnapshotScript.to_dict(5000, -200, positions)
	_expect(int(snapshot.get("cash", 0)) == 5000, "snapshot should keep cash")
	_expect(int(snapshot.get("realized_profit", 0)) == -200, "snapshot should keep realized profit")

	var rows: Array = snapshot.get("positions", [])
	_expect(rows.size() == 1, "snapshot should skip invalid position rows")
	_expect(Dictionary(rows[0]).get("ticker", "") == "AAA", "snapshot should keep valid ticker")

	var row := Dictionary(rows[0])
	row["quantity"] = 999
	_expect(int(Dictionary(positions.get("AAA", {})).get("quantity", 0)) == 2, "snapshot rows should not mutate source positions")


func _verify_position_restore_filters() -> void:
	var restored := PortfolioSnapshotScript.load_positions({
		"positions": [
			{
				"ticker": "AAA",
				"quantity": 3,
				"avg_cost": -100
			},
			{
				"ticker": "",
				"quantity": 1,
				"avg_cost": 100
			},
			{
				"ticker": "BBB",
				"quantity": 0,
				"avg_cost": 100
			},
			"bad"
		]
	})

	_expect(restored.size() == 1, "restore should keep only valid position rows")
	_expect(restored.has("AAA"), "restore should index positions by ticker")
	_expect(int(Dictionary(restored.get("AAA", {})).get("quantity", 0)) == 3, "restore should keep valid quantity")
	_expect(int(Dictionary(restored.get("AAA", {})).get("avg_cost", 99)) == 0, "restore should clamp negative average cost")


func _verify_scalar_normalization() -> void:
	_expect(PortfolioSnapshotScript.normalize_cash(-5) == 0, "cash should not restore below zero")
	_expect(PortfolioSnapshotScript.normalize_cash(7) == 7, "cash should keep positive values")
	_expect(PortfolioSnapshotScript.normalize_realized_profit(-10) == -10, "realized profit should allow losses")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
