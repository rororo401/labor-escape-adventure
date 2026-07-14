extends "res://scripts/tests/test_scene_tree.gd"

const MarketSleepSequenceConfigScript := preload("res://scripts/ui/market_sleep_sequence_config.gd")


func _initialize() -> void:
	_expect(MarketSleepSequenceConfigScript.SLEEP_LAYER_NAME == "SleepEventLayer", "sleep layer name should stay stable")
	_expect(MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_NAME == "SleepEventCG", "sleep CG node name should stay stable")
	_expect(MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_PATH == "res://assets/backgrounds/home/sleeping_night_event.png", "sleep CG path should stay stable")
	_expect(MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_PATH_SUMMER == "res://assets/backgrounds/home/sleeping_night_event_summer.png", "summer sleep CG path should stay stable")
	_expect(MarketSleepSequenceConfigScript.sleep_event_cg_path_for_date("2016-07-01") == MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_PATH_SUMMER, "summer date should use summer sleep CG")
	_expect(MarketSleepSequenceConfigScript.sleep_event_cg_path_for_date("2016-12-01") == MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_PATH, "winter date should use base sleep CG")
	_expect(MarketSleepSequenceConfigScript.FALLBACK_SIZE == Vector2(720, 1280), "sleep sequence fallback size should match portrait viewport")
	_expect(MarketSleepSequenceConfigScript.SLEEP_FADE_IN_DURATION == 0.22, "sleep fade-in duration should preserve current timing")
	_expect(MarketSleepSequenceConfigScript.SLEEP_HOLD_DURATION == 1.85, "sleep hold duration should preserve current timing")
	_expect(MarketSleepSequenceConfigScript.CANCEL_FADE_DURATION == 0.20, "cancel fade duration should preserve current timing")

	print("Market sleep sequence config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
