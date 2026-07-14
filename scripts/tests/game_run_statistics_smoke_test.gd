extends "res://scripts/tests/test_scene_tree.gd"

const GameRunStatisticsScript := preload("res://scripts/core/game_run_statistics.gd")
const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")


func _initialize() -> void:
	var statistics := GameRunStatisticsScript.new()
	statistics.reset(5000000)
	statistics.record_net_worth(7200000)
	statistics.record_net_worth(6100000)
	statistics.record_event()
	statistics.record_event()
	statistics.record_positions({
		"AAA": {MarketDataKeysScript.KEY_QUANTITY: 12},
		"BBB": {MarketDataKeysScript.KEY_QUANTITY: 30}
	})
	statistics.record_positions({
		"AAA": {MarketDataKeysScript.KEY_QUANTITY: 40},
		"BBB": {MarketDataKeysScript.KEY_QUANTITY: 1}
	})

	_expect(statistics.highest_net_worth == 7200000, "statistics should preserve the historical net-worth peak")
	_expect(statistics.total_event_count == 2, "statistics should count completed events cumulatively")
	_expect(statistics.most_held_ticker == "AAA" and statistics.most_held_quantity == 40, "statistics should preserve the largest historical position")

	var restored := GameRunStatisticsScript.new()
	restored.load_from_dict(statistics.to_dict())
	_expect(restored.highest_net_worth == statistics.highest_net_worth, "statistics should roundtrip highest net worth")
	_expect(restored.total_event_count == statistics.total_event_count, "statistics should roundtrip event count")
	_expect(restored.most_held_ticker == statistics.most_held_ticker, "statistics should roundtrip the most-held ticker")

	print("Game run statistics smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
