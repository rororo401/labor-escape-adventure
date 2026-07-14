extends "res://scripts/tests/test_scene_tree.gd"

const GameDayContextScript := preload("res://scripts/core/dayflow/game_day_context.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	_verify_trading_day_context()
	_verify_closed_day_context()
	_verify_summer_vacation_context()
	_verify_run_seed_changes_closed_day_choices()
	_verify_event_branches_create_diverse_futures()
	_verify_missing_day_context()

	print("Game day context smoke test passed.")
	finish_test()


func _verify_trading_day_context() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up first trading day")

	var context: Dictionary = GameDayContextScript.today_context(game)
	_expect(context.get(GameStateContextKeysScript.KEY_DATE, "") == "2016-07-01", "today context should expose first date")
	_expect(context.get(GameStateContextKeysScript.KEY_DAY_MODE, "") == GameStateContextKeysScript.DAY_MODE_MARKET_AND_LIFE, "trading day should expose market-and-life mode")
	_expect(bool(context.get(GameStateContextKeysScript.KEY_MARKET_PHASE_AVAILABLE, false)), "trading day should expose market phase")
	_expect(Dictionary(context.get("market", {})).get("is_open", false), "trading day market should be open")

	var actions: Array[Dictionary] = GameDayContextScript.available_life_actions(game)
	_expect(_helpers.ids_from_items(actions).has("company_work"), "trading day should include work action")

	var flow: Dictionary = GameDayContextScript.day_flow_context(game)
	_expect(Dictionary(flow.get("default_action", {})).get("id", "") == "company_work", "trading day should default to company work")
	_expect(not bool(flow.get("day_completed", true)), "fresh day flow should not be completed")

	var categories: Array[Dictionary] = GameDayContextScript.closed_day_categories(game)
	_expect(categories.is_empty(), "trading day should not expose closed-day categories")

	var assets: Dictionary = GameDayContextScript.character_asset_context(game)
	var protagonist_assets := Dictionary(assets.get(GameStateConfigScript.PROTAGONIST_CHARACTER_ID, {}))
	_expect(protagonist_assets.has("outfits"), "character context should expose protagonist outfits")
	_expect(protagonist_assets.get("default", {}).get("outfit_id", "") == "summer_office", "July context should default to summer office outfit")


func _verify_closed_day_context() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-02"), "game should set up first closed day")

	var context: Dictionary = GameDayContextScript.today_context(game)
	_expect(context.get(GameStateContextKeysScript.KEY_DATE, "") == "2016-07-02", "closed-day context should expose Saturday date")
	_expect(context.get(GameStateContextKeysScript.KEY_DAY_MODE, "") == GameStateContextKeysScript.DAY_MODE_LIFE_ONLY, "closed day should expose life-only mode")
	_expect(not bool(Dictionary(context.get("market", {})).get("is_open", true)), "closed-day market should be closed")

	var actions: Array[Dictionary] = GameDayContextScript.available_life_actions(game)
	var action_ids := _helpers.ids_from_items(actions)
	_expect(action_ids.has("part_time"), "closed day should include part-time action")
	_expect(not action_ids.has("company_work"), "closed day should not include normal work action")

	var categories: Array[Dictionary] = GameDayContextScript.closed_day_categories(game)
	var category_ids := _helpers.ids_from_items(categories)
	_expect(category_ids.has("stay_home"), "closed day should include stay-home category")
	_expect(category_ids.has("go_out"), "closed day should include go-out category")

	var choices: Array[Dictionary] = GameDayContextScript.closed_day_choices(game, "stay_home", 4)
	_expect(choices.size() == 4, "closed-day choices should respect requested limit")


func _verify_summer_vacation_context() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-08-01"), "game should set up first summer vacation day")

	var context: Dictionary = GameDayContextScript.today_context(game)
	_expect(context.get(GameStateContextKeysScript.KEY_DATE, "") == "2016-08-01", "summer vacation context should expose date")
	_expect(context.get(GameStateContextKeysScript.KEY_DAY_MODE, "") == GameStateContextKeysScript.DAY_MODE_LIFE_ONLY, "summer vacation should expose life-only mode")
	_expect(not bool(context.get(GameStateContextKeysScript.KEY_MARKET_PHASE_AVAILABLE, true)), "summer vacation should hide market phase")
	var market := Dictionary(context.get(GameStateContextKeysScript.KEY_MARKET, {}))
	_expect(not bool(market.get(GameStateContextKeysScript.KEY_IS_OPEN, true)), "summer vacation market should be closed")
	_expect(String(market.get(GameStateContextKeysScript.KEY_CLOSED_NAME, "")) == "여름휴가", "summer vacation closed name should be visible")
	var flow := Dictionary(context.get(GameStateContextKeysScript.KEY_DAY_FLOW, {}))
	_expect(String(Dictionary(flow.get("default_action", {})).get("id", "")) == "summer_vacation_2016_day_1", "summer vacation should keep annual default event")


func _verify_run_seed_changes_closed_day_choices() -> void:
	var baseline_game := GameStateScript.new()
	_expect(baseline_game.setup("2016-07-02", "seed_0"), "baseline closed day should set up")
	var baseline_ids := _helpers.ids_from_items(GameDayContextScript.closed_day_choices(baseline_game, "stay_home", 4))

	var repeated_game := GameStateScript.new()
	_expect(repeated_game.setup("2016-07-02", "seed_0"), "repeated closed day should set up")
	_expect(
		_helpers.ids_from_items(GameDayContextScript.closed_day_choices(repeated_game, "stay_home", 4)) == baseline_ids,
		"same run seed should keep first weekend choices stable"
	)

	var changed := false
	for index in range(1, 20):
		var seeded_game := GameStateScript.new()
		_expect(seeded_game.setup("2016-07-02", "seed_%d" % index), "seeded closed day should set up")
		var seeded_ids := _helpers.ids_from_items(GameDayContextScript.closed_day_choices(seeded_game, "stay_home", 4))
		if seeded_ids != baseline_ids:
			changed = true
			break
	_expect(changed, "different run seeds should be able to change first weekend choices")


func _verify_event_branches_create_diverse_futures() -> void:
	var closed_game := GameStateScript.new()
	_expect(closed_game.setup("2016-07-02", "shared-save-seed"), "branched closed day should set up")
	closed_game.event_branch_seed = "branch_0"
	var stable_choices := _helpers.ids_from_items(GameDayContextScript.closed_day_choices(closed_game, "stay_home", 4))
	_expect(
		_helpers.ids_from_items(GameDayContextScript.closed_day_choices(closed_game, "stay_home", 4)) == stable_choices,
		"one loaded branch should keep its closed-day offers stable"
	)
	var choice_signatures := {}
	for index in range(32):
		closed_game.event_branch_seed = "branch_%d" % index
		var ids := _helpers.ids_from_items(GameDayContextScript.closed_day_choices(closed_game, "stay_home", 4))
		choice_signatures[",".join(ids)] = true
	_expect(choice_signatures.size() >= 20, "the same save should expose many different closed-day offer sets across load branches")

	var trading_game := GameStateScript.new()
	_expect(trading_game.setup("2016-07-04", "shared-save-seed"), "branched trading day should set up")
	var company_event_ids := {}
	var day: Dictionary = trading_game.calendar.get_day(trading_game.day_index)
	for index in range(64):
		trading_game.event_branch_seed = "branch_%d" % index
		var plan: Dictionary = trading_game.day_events.build_day_result(
			day,
			trading_game.status.to_dict(),
			trading_game.completed_days,
			"company_work",
			[],
			true,
			[],
			trading_game.get_event_random_seed(),
			trading_game.random_seed
		)
		var event_id := String(Dictionary(plan.get("day_action", {})).get("id", ""))
		company_event_ids[event_id] = true
	_expect(company_event_ids.size() >= 40, "the same save should draw broadly from company events across load branches")


func _verify_missing_day_context() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01"), "game should set up before missing-day checks")
	game.day_index = -1

	_expect(GameDayContextScript.today_context(game).is_empty(), "missing day should have empty today context")
	_expect(GameDayContextScript.available_life_actions(game).is_empty(), "missing day should have no life actions")
	_expect(GameDayContextScript.day_flow_context(game).is_empty(), "missing day should have empty day flow")
	_expect(GameDayContextScript.closed_day_categories(game).is_empty(), "missing day should have no categories")
	_expect(GameDayContextScript.closed_day_choices(game, "stay_home").is_empty(), "missing day should have no choices")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
