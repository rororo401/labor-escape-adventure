extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketDayCompletionFlowConfigScript := preload("res://scripts/ui/market_day_completion_flow_config.gd")
const MarketDayCompletionFlowScript := preload("res://scripts/ui/market_day_completion_flow.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventPlaybackRequestScript := preload("res://scripts/ui/day_event_playback_request.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const SUMMER_WORKDAY_DEPARTURE_CG := "res://assets/events_summer/transition/leave_work_evening.png"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var missing_game := MarketDayCompletionFlowScript.complete(null, "", {})
	_expect(not bool(missing_game.get(MarketDayCompletionFlowConfigScript.KEY_OK, true)), "missing game should return a completion error")
	_expect(String(missing_game.get(MarketDayCompletionFlowConfigScript.KEY_STATE, {}).get("message", "")).length() > 0, "missing game should include an error message")

	var trading_game := GameStateScript.new()
	_expect(trading_game.setup("2016-07-01"), "trading game should set up the first tutorial day")
	var blocked := MarketDayCompletionFlowScript.complete(trading_game, "company_work", trading_game.get_market_context())
	_expect(not bool(blocked.get(MarketDayCompletionFlowConfigScript.KEY_OK, true)), "first tutorial day should block completion before buying")
	_expect(String(blocked.get(MarketDayCompletionFlowConfigScript.KEY_RESULT, {}).get(MarketDayCompletionFlowConfigScript.KEY_ERROR, "")) == "first_day_stock_required", "blocked first day should preserve backend error")
	_expect(String(blocked.get(MarketDayCompletionFlowConfigScript.KEY_STATE, {}).get("message", "")).contains("최소 1주"), "blocked first day should expose UI error state")

	var ticker := String(Dictionary(trading_game.get_market_context().get("stocks", [])[0]).get("ticker", ""))
	_expect(trading_game.submit_market_order(ticker, "buy", 1).get("ok", false), "test should buy one share")
	var trading_completion := MarketDayCompletionFlowScript.complete(trading_game, "company_work", trading_game.get_market_context())
	_expect(bool(trading_completion.get(MarketDayCompletionFlowConfigScript.KEY_OK, false)), "trading day completion should succeed after buying")
	_expect(Array(trading_completion.get(MarketDayCompletionFlowConfigScript.KEY_PLAYBACK_EVENTS, [])).is_empty() == not bool(trading_completion.get(MarketDayCompletionFlowConfigScript.KEY_SHOULD_PLAY_DAY_EVENT, false)), "playback flag should match playback events")
	_expect(not Dictionary(trading_completion.get(MarketDayCompletionFlowConfigScript.KEY_RESULT, {})).is_empty(), "trading completion should include the backend result")
	var trading_playback: Array = trading_completion.get(MarketDayCompletionFlowConfigScript.KEY_PLAYBACK_EVENTS, [])
	_expect(not trading_playback.is_empty(), "trading completion should include playback events")
	_expect(String(Dictionary(trading_playback[0]).get(DayEventKeysScript.KEY_GROUP, "")) == DayEventKeysScript.GROUP_COMPANY_WORK, "trading playback should start with company work")
	_verify_weekday_playback_contract()
	_verify_workday_departure_conditions()
	_verify_workday_departure_seasons()
	_verify_summer_vacation_common_playback()

	var closed_game := GameStateScript.new()
	var closed_date := _helpers.find_closed_date_with_choice(closed_game, "go_out", "part_time", "2016-07-02")
	_expect(closed_game.setup(closed_date), "closed game should set up a day with part-time work")
	var closed_completion := MarketDayCompletionFlowScript.complete(closed_game, "part_time", closed_game.get_market_context())
	_expect(bool(closed_completion.get(MarketDayCompletionFlowConfigScript.KEY_OK, false)), "closed-day completion should succeed with a selected action")
	_expect(bool(closed_completion.get(MarketDayCompletionFlowConfigScript.KEY_SHOULD_PLAY_DAY_EVENT, false)), "closed-day completion should request a day-event CG")
	_expect(String(closed_completion.get(MarketDayCompletionFlowConfigScript.KEY_DAY_ACTION, {}).get("id", "")) == "part_time", "closed-day completion should expose the selected day action")
	_expect(String(Dictionary(Array(closed_completion.get(MarketDayCompletionFlowConfigScript.KEY_PLAYBACK_EVENTS, []))[0]).get("id", "")) == "part_time", "closed-day playback should include selected day action")

	print("Market day completion flow smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _verify_weekday_playback_contract() -> void:
	var playback: Array[Dictionary] = MarketDayCompletionFlowScript._playback_events(
		{
			DayEventKeysScript.KEY_ID: "company_communication_01",
			DayEventKeysScript.KEY_GROUP: DayEventKeysScript.GROUP_COMPANY_WORK
		},
		[
			{DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_ID: "salary_day"}},
			{DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_ID: "overtime_request"}}
		],
		[
			{DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_ID: "night_chimaek"}},
			{DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_ID: "night_insomnia"}}
		],
		true
	)
	_expect(playback.size() == 6, "trading-day playback should include company work, weekday events, one departure, and night events")
	_expect(String(playback[0].get(DayEventKeysScript.KEY_ID, "")) == "company_communication_01", "company work should play before weekday events")
	_expect(String(playback[1].get(DayEventKeysScript.KEY_ID, "")) == "salary_day", "the first weekday event should keep its order")
	_expect(String(playback[2].get(DayEventKeysScript.KEY_ID, "")) == "overtime_request", "all weekday events should play before departure")
	_expect(String(playback[3].get(DayEventKeysScript.KEY_ID, "")) == MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_ID, "departure should bridge weekday and night events")
	_expect(String(playback[4].get(DayEventKeysScript.KEY_ID, "")) == "night_chimaek", "the first night event should play after departure")
	_expect(String(playback[5].get(DayEventKeysScript.KEY_ID, "")) == "night_insomnia", "night events should keep their order")
	_expect(_event_id_count(playback, MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_ID) == 1, "multiple night events should still add departure exactly once")


func _verify_workday_departure_conditions() -> void:
	var base_company_playback: Array[Dictionary] = MarketDayCompletionFlowScript._playback_events(
		{DayEventKeysScript.KEY_ID: DayEventKeysScript.ACTION_COMPANY_WORK},
		[],
		[{DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_ID: "night_chimaek"}}],
		true
	)
	_expect(_event_id_count(base_company_playback, MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_ID) == 1, "base company-work action should receive departure before a night event")

	var no_night_playback: Array[Dictionary] = MarketDayCompletionFlowScript._playback_events(
		{DayEventKeysScript.KEY_ID: DayEventKeysScript.ACTION_COMPANY_WORK},
		[{DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_ID: "overtime_request"}}],
		[{}, {DayEventKeysScript.KEY_EVENT: {}}],
		true
	)
	_expect(_event_id_count(no_night_playback, MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_ID) == 0, "invalid or missing night events should not add departure")

	for action_id in ["part_time", DayEventKeysScript.ACTION_SICK_REST, "summer_vacation_2016_day_1"]:
		var non_company_playback: Array[Dictionary] = MarketDayCompletionFlowScript._playback_events(
			{DayEventKeysScript.KEY_ID: action_id},
			[],
			[{DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_ID: "night_recovery"}}],
			true
		)
		_expect(_event_id_count(non_company_playback, MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_ID) == 0, "non-company actions should never add workday departure: %s" % action_id)

	var hidden_company_playback: Array[Dictionary] = MarketDayCompletionFlowScript._playback_events(
		{DayEventKeysScript.KEY_ID: DayEventKeysScript.ACTION_COMPANY_WORK},
		[],
		[{DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_ID: "night_chimaek"}}],
		false
	)
	_expect(_event_id_count(hidden_company_playback, MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_ID) == 0, "departure should not appear when the company day action is not being played")


func _verify_workday_departure_seasons() -> void:
	var departure := MarketDayCompletionFlowScript._workday_departure_event()
	_expect(not Array(departure.get(DayEventKeysScript.KEY_DIALOGUE, [])).is_empty(), "departure event needs dialogue so the scene runner does not skip it")
	_expect(FileAccess.file_exists(MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_CG), "winter/default departure CG should exist")
	_expect(FileAccess.file_exists(SUMMER_WORKDAY_DEPARTURE_CG), "summer departure CG should exist")
	_expect(ResourceLoader.load(MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_CG) is Texture2D, "winter/default departure CG should load as a runtime texture")
	_expect(ResourceLoader.load(SUMMER_WORKDAY_DEPARTURE_CG) is Texture2D, "summer departure CG should load as a runtime texture")

	var winter_image := Image.new()
	var summer_image := Image.new()
	_expect(winter_image.load(MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_CG) == OK, "winter/default departure CG should load as an image")
	_expect(summer_image.load(SUMMER_WORKDAY_DEPARTURE_CG) == OK, "summer departure CG should load as an image")
	_expect(winter_image.get_size() == summer_image.get_size(), "summer and winter departure CGs should use the same dimensions")

	var summer_event := DayEventPlaybackRequestScript.event_for_date(departure, "2016-07-15")
	var winter_event := DayEventPlaybackRequestScript.event_for_date(departure, "2016-12-15")
	_expect(String(summer_event.get(DayEventKeysScript.KEY_CG_PATH, "")) == SUMMER_WORKDAY_DEPARTURE_CG, "summer workday departure should use the matching summer CG")
	_expect(String(winter_event.get(DayEventKeysScript.KEY_CG_PATH, "")) == MarketDayCompletionFlowScript.WORKDAY_DEPARTURE_CG, "winter workday departure should keep the base CG")


func _event_id_count(events: Array[Dictionary], event_id: String) -> int:
	var count := 0
	for event in events:
		if String(event.get(DayEventKeysScript.KEY_ID, "")) == event_id:
			count += 1
	return count


func _verify_summer_vacation_common_playback() -> void:
	var day_1_playback: Array[Dictionary] = MarketDayCompletionFlowScript._playback_events(
		{DayEventKeysScript.KEY_ID: "summer_vacation_2016_day_1"},
		[],
		[],
		true
	)
	_expect(day_1_playback.size() == 2, "summer vacation day 1 should play departure and destination events")
	_expect(String(day_1_playback[0].get(DayEventKeysScript.KEY_ID, "")) == MarketDayCompletionFlowScript.SUMMER_VACATION_COMMON_DEPARTURE_ID, "vacation day 1 should start with departure")
	_expect(String(day_1_playback[1].get(DayEventKeysScript.KEY_ID, "")) == "summer_vacation_2016_day_1", "vacation day 1 should then play destination event")
	_expect(String(day_1_playback[0].get(DayEventKeysScript.KEY_CG_PATH, "")) == MarketDayCompletionFlowScript.SUMMER_VACATION_COMMON_DEPARTURE_CG, "departure CG path mismatch")

	var day_3_playback: Array[Dictionary] = MarketDayCompletionFlowScript._playback_events(
		{DayEventKeysScript.KEY_ID: "summer_vacation_2016_day_3"},
		[],
		[],
		true
	)
	_expect(day_3_playback.size() == 2, "summer vacation day 3 should play destination and return events")
	_expect(String(day_3_playback[0].get(DayEventKeysScript.KEY_ID, "")) == "summer_vacation_2016_day_3", "vacation day 3 should start with destination")
	_expect(String(day_3_playback[1].get(DayEventKeysScript.KEY_ID, "")) == MarketDayCompletionFlowScript.SUMMER_VACATION_COMMON_RETURN_ID, "vacation day 3 should end with return")
	_expect(String(day_3_playback[1].get(DayEventKeysScript.KEY_CG_PATH, "")) == MarketDayCompletionFlowScript.SUMMER_VACATION_COMMON_RETURN_CG, "return CG path mismatch")
