extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenStateScript := preload("res://scripts/ui/market_screen_state.gd")
const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")

var _failed := false


func _initialize() -> void:
	var current := {
		MarketScreenStateConfigScript.KEY_IS_SLEEP_SEQUENCE: false,
		MarketScreenStateConfigScript.KEY_IS_COMPLETING_DAY: true,
		MarketScreenStateConfigScript.KEY_SHOWING_CLOSE_REPORT: true,
		MarketScreenStateConfigScript.KEY_SELECTED_STOCK: {"ticker": "AAA"},
		MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID: "cleaning",
		MarketScreenStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID: "stay_home",
		MarketScreenStateConfigScript.KEY_QUANTITY: 3
	}

	var next := MarketScreenStateScript.apply(current, {
		MarketScreenStateConfigScript.KEY_IS_SLEEP_SEQUENCE: true,
		MarketScreenStateConfigScript.KEY_SELECTED_STOCK: {"ticker": "BBB"},
		MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID: 123,
		MarketScreenStateConfigScript.KEY_QUANTITY: "7",
		"unknown_key": "ignored"
	})

	_expect(bool(next.get(MarketScreenStateConfigScript.KEY_IS_SLEEP_SEQUENCE, false)), "state patch should update sleep flag")
	_expect(bool(next.get(MarketScreenStateConfigScript.KEY_IS_COMPLETING_DAY, false)), "state patch should preserve unpatched completing flag")
	_expect(bool(next.get(MarketScreenStateConfigScript.KEY_SHOWING_CLOSE_REPORT, false)), "state patch should preserve unpatched close report flag")
	_expect(String(next.get(MarketScreenStateConfigScript.KEY_SELECTED_STOCK, {}).get("ticker", "")) == "BBB", "state patch should update selected stock")
	_expect(String(next.get(MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID, "")) == "123", "state patch should normalize selected action id")
	_expect(String(next.get(MarketScreenStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID, "")) == "stay_home", "state patch should preserve selected category")
	_expect(int(next.get(MarketScreenStateConfigScript.KEY_QUANTITY, 0)) == 7, "state patch should normalize quantity")
	_expect(not next.has("unknown_key"), "state patch should ignore unknown keys")

	var selected_stock: Dictionary = next.get(MarketScreenStateConfigScript.KEY_SELECTED_STOCK, {})
	selected_stock["ticker"] = "MUTATED"
	_expect(String(current.get(MarketScreenStateConfigScript.KEY_SELECTED_STOCK, {}).get("ticker", "")) == "AAA", "state patch should not mutate current selected stock")

	var unchanged := MarketScreenStateScript.apply(current, {})
	_expect(unchanged == current, "empty patch should preserve current state values")

	if _failed:
		fail_test()
	else:
		print("Market screen state smoke test passed.")
		finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
