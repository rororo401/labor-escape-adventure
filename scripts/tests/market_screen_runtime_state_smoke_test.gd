extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")
const MarketScreenRuntimeStateScript := preload("res://scripts/ui/market_screen_runtime_state.gd")


func _initialize() -> void:
	var state = MarketScreenRuntimeStateScript.new()
	_expect(state.quantity == 1, "runtime state should default quantity")
	_expect(not state.is_sleep_sequence, "runtime state should default sleep flag")

	state.apply({
		MarketScreenStateConfigScript.KEY_SELECTED_STOCK: {"ticker": "AAA"},
		MarketScreenStateConfigScript.KEY_QUANTITY: "4",
		MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID: 777,
		MarketScreenStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID: "go_out",
		MarketScreenStateConfigScript.KEY_SHOWING_CLOSE_REPORT: true,
		MarketScreenStateConfigScript.KEY_IS_COMPLETING_DAY: true
	})
	_expect(String(state.selected_stock.get("ticker", "")) == "AAA", "runtime state should apply selected stock")
	_expect(state.quantity == 4, "runtime state should normalize quantity")
	_expect(state.selected_day_action_id == "777", "runtime state should normalize action id")
	_expect(state.selected_closed_day_category_id == "go_out", "runtime state should apply category id")
	_expect(state.showing_close_report, "runtime state should apply close report flag")
	_expect(state.is_completing_day, "runtime state should apply completing flag")

	var snapshot := state.to_dict()
	var stock: Dictionary = snapshot.get(MarketScreenStateConfigScript.KEY_SELECTED_STOCK, {})
	stock["ticker"] = "MUTATED"
	_expect(String(state.selected_stock.get("ticker", "")) == "AAA", "runtime state snapshots should not mutate state")

	state.load_from_dict({
		MarketScreenStateConfigScript.KEY_IS_SLEEP_SEQUENCE: true,
		MarketScreenStateConfigScript.KEY_QUANTITY: 2
	})
	_expect(state.is_sleep_sequence, "runtime state should load sleep flag")
	_expect(state.quantity == 2, "runtime state should load quantity")
	_expect(state.selected_day_action_id == "", "runtime state should default missing action id")

	print("Market screen runtime state smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
