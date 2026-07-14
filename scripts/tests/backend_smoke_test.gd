extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusScript := preload("res://scripts/core/player_status.gd")
const PlayerProfileScript := preload("res://scripts/core/player_profile.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var profile = TestPlayerProfile.new()
	profile.set_player_name("테스트 사용자")
	_expect(profile.player_name == "테스트 사용자", "profile name should be set")
	_expect(profile.age_band == "20대", "profile age band should be 20s")
	_expect(profile.job_title == "스타트업 사무직", "profile job should be broad startup office work")
	profile.save()
	var loaded_profile = TestPlayerProfile.new()
	loaded_profile.load_or_default()
	_expect(loaded_profile.player_name == "테스트 사용자", "profile name should persist")

	var game = GameStateScript.new()
	if not game.setup("2016-07-01"):
		_fail("setup failed")
		return

	var first_day := game.get_today_context()
	_expect(first_day.get("is_trading_day", false), "2016-07-01 should be a trading day")
	_expect(first_day.get("day_mode", "") == "market_and_life", "trading day mode should include market")
	_expect(game.market.catalog.count() == 30, "stock catalog should contain 30 companies")
	var market_context: Dictionary = first_day.get("market", {})
	var first_stocks: Array = market_context.get("stocks", [])
	_expect(not first_stocks.is_empty(), "market context should include stock rows")
	var samsung := _find_stock(first_stocks, "005930")
	_expect(samsung.get("open", 0) == 28540, "Samsung open price mismatch")
	_expect(not samsung.has("close"), "morning market context should not expose same-day close")
	_expect(not samsung.has("volume"), "morning market context should not expose same-day final volume")
	_expect(samsung.get("name_ko", "") == "새벽전자", "the game should show the fictional company name by default")
	_expect(game.market.catalog.get_display_name_by_ticker("005930", false) == "새벽전자", "alias file should control fictional display name")
	var alias_stocks: Array = game.market.get_market_snapshot("2016-07-01", "", 1).get("stocks", [])
	_expect(alias_stocks[0].get("name_ko", "") == "새벽전자", "game alias mode should show fictional company name")
	game.market.set_real_name_mode(true)
	var debug_stocks: Array = game.market.get_market_snapshot("2016-07-01", "", 1).get("stocks", [])
	_expect(debug_stocks[0].get("name_ko", "") == "삼성전자", "an explicit developer override should still allow source-data diagnostics")
	game.market.set_real_name_mode(false)
	_expect(market_context.get("is_open", false), "market should be open on first day")
	var buy_result := game.submit_market_order("005930", "buy", 1)
	_expect(buy_result.get("ok", false), "buy order should succeed")
	_expect(int(buy_result.get("cash_after", 0)) == 4971460, "cash after buy mismatch")
	var open_report := game.get_market_open_report()
	_expect(int(open_report.get("investment_assets", 0)) == 28540, "open report should value position at open")
	_expect(int(open_report.get("net_worth", 0)) == 5000000, "net worth should not change immediately after buy at open")
	var close_report := game.get_market_close_report()
	_expect(int(close_report.get("investment_assets", 0)) == 29320, "close report should value position at close")
	_expect(int(close_report.get("net_worth", 0)) == 5000780, "net worth after first close mismatch")
	_expect(int(close_report.get("status", {}).get("target_net_worth", 0)) == 1000000000, "target net worth should be 1 billion")
	var oversell_result := game.submit_market_order("005930", "sell", 99)
	_expect(not oversell_result.get("ok", true), "oversell should fail")
	_expect(_helpers.ids_from_items(first_day.get("available_life_actions", [])).has("company_work"), "work action should be available on trading days")
	var first_flow: Dictionary = game.get_day_flow_context()
	_expect(first_flow.get("default_action", {}).get("id", "") == "company_work", "trading day should default to company work")
	_expect(not first_flow.get("has_choice", true), "trading day should not expose day action choices by default")
	var day_result := game.complete_today()
	_expect(day_result.get("ok", false), "complete_today should succeed")
	_expect(day_result.get("day_action", {}).get("event", {}).get(DayEventKeysScript.KEY_GROUP, "") == DayEventKeysScript.GROUP_COMPANY_WORK, "trading day completion should run a company work variant")
	_expect(game.get_today_context().get("date", "") == "2016-07-01", "date should not advance before sleep")
	var sleep_result := game.sleep_to_next_day()
	_expect(sleep_result.get("ok", false), "sleep should advance after day completion")
	_expect(sleep_result.get("to_date", "") == "2016-07-02", "sleep should advance to next calendar day")
	var asset_context: Dictionary = first_day.get("character_assets", {})
	_expect(asset_context.get("protagonist", {}).get("outfits", []).has("casual_default"), "casual default outfit should exist")
	_expect(asset_context.get("protagonist", {}).get("outfits", []).has("homewear"), "homewear outfit should exist")
	_expect(asset_context.get("protagonist", {}).get("outfits", []).has("summer_office"), "summer office outfit should exist")
	_expect(asset_context.get("protagonist", {}).get("outfits", []).has("summer_homewear"), "summer homewear outfit should exist")
	_expect(asset_context.get("protagonist", {}).get("expressions", []).has("thinking"), "thinking expression should exist")

	var resolved_asset := game.resolve_protagonist_standing("homewear", "smile")
	_expect(resolved_asset.get("outfit_id", "") == "summer_homewear", "summer date should resolve homewear to summer homewear")
	_expect(resolved_asset.get("expression_id", "") == "smile", "smile should resolve")
	_expect(resolved_asset.get("asset_ready", false), "standing asset should be ready after PNG generation")
	_expect(resolved_asset.get("asset_path", "") == "res://assets/characters/protagonist/summer_homewear/standing/smile.png", "standing asset path mismatch")
	_expect(resolved_asset.get("atlas_region", []).is_empty(), "individual standing asset should not expose an atlas region")
	_expect(game.character_assets.make_standing_texture(resolved_asset) != null, "standing texture should load")

	var summer_asset := game.resolve_protagonist_standing("summer_office", "smile")
	_expect(summer_asset.get("outfit_id", "") == "summer_office", "summer office should resolve")
	_expect(summer_asset.get("expression_id", "") == "smile", "summer office smile should resolve")
	_expect(summer_asset.get("asset_ready", false), "summer office asset should be ready")
	_expect(summer_asset.get("asset_path", "") == "res://assets/characters/protagonist/summer_office/standing/smile.png", "summer office asset path mismatch")
	_expect(summer_asset.get("atlas_region", []).is_empty(), "summer office individual asset should not expose an atlas region")
	_expect(game.character_assets.make_standing_texture(summer_asset) != null, "summer office texture should load")

	var winter_game = GameStateScript.new()
	_expect(winter_game.setup("2016-12-01"), "winter simulation setup failed")
	var winter_asset := winter_game.resolve_protagonist_standing("summer_office", "neutral")
	_expect(winter_asset.get("outfit_id", "") == "casual_default", "winter date should map summer office to base office")
	_expect(winter_asset.get("asset_path", "") == "res://assets/characters/protagonist/casual_default/standing/neutral.png", "winter office asset path mismatch")
	_expect(winter_asset.get("atlas_region", []).is_empty(), "winter office individual asset should not expose an atlas region")

	var fallback_asset := game.resolve_protagonist_standing("future_outfit", "future_expression")
	_expect(fallback_asset.get("outfit_id", "") == "casual_default", "missing outfit should fallback to casual_default")
	_expect(fallback_asset.get("expression_id", "") == "neutral", "missing expression should fallback to neutral")

	var trading_game = GameStateScript.new()
	_expect(trading_game.setup("2016-07-01"), "trading simulation setup failed")
	var blocked_first_day := trading_game.complete_today()
	_expect(not blocked_first_day.get("ok", true), "first tutorial day should block before buying a stock")
	_expect(blocked_first_day.get("error", "") == "first_day_stock_required", "first tutorial day block error mismatch")
	var tutorial_buy := trading_game.submit_market_order("005930", "buy", 1)
	_expect(tutorial_buy.get("ok", false), "tutorial buy should succeed before first day simulation")
	var trading_result := trading_game.simulate_day("go_to_work")
	_expect(trading_result.get("ok", false), "go_to_work simulation failed")
	_expect(trading_result.get("market", {}).get("is_open", false), "market should be open on trading simulation")

	var closed_game = GameStateScript.new()
	if not closed_game.setup("2016-07-02"):
		_fail("closed-day setup failed")
		return

	var closed_day := closed_game.get_today_context()
	_expect(not closed_day.get("is_trading_day", true), "2016-07-02 should be a non-trading day")
	_expect(closed_day.get("day_mode", "") == "life_only", "closed day should be life-only")
	var closed_flow: Dictionary = closed_game.get_day_flow_context()
	_expect(closed_flow.get("has_choice", false), "normal non-trading day should expose choices")
	_expect(_helpers.ids_from_items(closed_flow.get("available_choices", [])).has("part_time"), "closed day choices should include part time")
	var closed_categories := closed_game.get_closed_day_categories()
	_expect(_helpers.ids_from_items(closed_categories).has("stay_home"), "closed day categories should include stay home")
	_expect(_helpers.ids_from_items(closed_categories).has("go_out"), "closed day categories should include go out")
	var stay_home_choices := closed_game.get_closed_day_choices("stay_home", 4)
	_expect(stay_home_choices.size() == 4, "stay home should show four random choices")
	_expect(not String(stay_home_choices[0].get(DayEventKeysScript.KEY_CG_PATH, "")).is_empty(), "closed day choice should include event CG path")
	_expect(Array(stay_home_choices[0].get(DayEventKeysScript.KEY_DIALOGUE, [])).size() >= 3, "closed day choice should include dialogue lines")
	var closed_buy := closed_game.submit_market_order("005930", "buy", 1)
	_expect(not closed_buy.get("ok", true), "closed day buy should fail")
	_expect(closed_buy.get("error", "") == "market_closed", "closed day buy error mismatch")
	var closed_actions := _helpers.ids_from_items(closed_day.get("available_life_actions", []))
	_expect(not closed_actions.has("company_work"), "regular work should not be available on closed days")
	_expect(closed_actions.has("part_time"), "part-time work should be available on closed days")
	_expect(closed_actions.has("nap"), "nap should be available on closed days")

	var closed_result := closed_game.simulate_day("nap")
	_expect(closed_result.get("ok", false), "nap simulation failed")
	_expect(not closed_result.get("market", {}).get("is_open", true), "market should stay closed on closed day simulation")

	var vacation_game = GameStateScript.new()
	_expect(vacation_game.setup("2016-08-01"), "summer vacation setup failed")
	var vacation_flow: Dictionary = vacation_game.get_day_flow_context()
	_expect(vacation_flow.get("default_action", {}).get("id", "") == "summer_vacation_2016_day_1", "first August Monday should be annual summer vacation")
	_expect(not vacation_flow.get("has_choice", true), "summer vacation should override choices")
	var vacation_market := vacation_game.get_market_context()
	_expect(not bool(vacation_market.get("is_open", true)), "summer vacation market should be closed")
	_expect(vacation_market.get("closed_name", "") == "여름휴가", "summer vacation market should show vacation closed name")
	var vacation_buy := vacation_game.submit_market_order("005930", "buy", 1)
	_expect(not vacation_buy.get("ok", true), "summer vacation buy should fail")
	_expect(vacation_buy.get("error", "") == "market_closed", "summer vacation buy error mismatch")
	var vacation_result := vacation_game.complete_today()
	_expect(vacation_result.get("ok", false), "summer vacation completion failed")
	_expect(vacation_result.get("day_action", {}).get("event", {}).get("id", "") == "summer_vacation_2016_day_1", "summer vacation completion should use annual event")
	_expect(Array(vacation_result.get("weekday_events", [])).is_empty(), "summer vacation should suppress random weekday events")
	_expect(Array(vacation_result.get("night_events", [])).is_empty(), "summer vacation should suppress random night events")

	var chuseok_game = GameStateScript.new()
	_expect(chuseok_game.setup("2016-09-14"), "chuseok setup failed")
	var chuseok_flow: Dictionary = chuseok_game.get_day_flow_context()
	_expect(chuseok_flow.get("default_action", {}).get("id", "") == "chuseok_2016_day_1", "Chuseok holiday should run annual Chuseok day 1 event")

	var chuseok_day_game = GameStateScript.new()
	_expect(chuseok_day_game.setup("2016-09-15"), "annual chuseok setup failed")
	var chuseok_day_flow: Dictionary = chuseok_day_game.get_day_flow_context()
	_expect(chuseok_day_flow.get("default_action", {}).get("id", "") == "chuseok_2016_day_2", "Chuseok day should run annual Chuseok day 2 event")

	var seollal_game = GameStateScript.new()
	_expect(seollal_game.setup("2017-01-28"), "annual Seollal setup failed")
	var seollal_flow: Dictionary = seollal_game.get_day_flow_context()
	_expect(seollal_flow.get("default_action", {}).get("id", "") == "seollal_2017_day_2", "Seollal day should run annual Seollal day 2 event")

	var new_year_game = GameStateScript.new()
	_expect(new_year_game.setup("2022-01-01"), "annual New Year setup failed")
	var new_year_flow: Dictionary = new_year_game.get_day_flow_context()
	_expect(new_year_flow.get("default_action", {}).get("id", "") == "new_year_2022", "New Year should run annual one-day event")
	_expect(not new_year_flow.get("has_choice", true), "New Year should override closed-day choices")

	var substitute_game = GameStateScript.new()
	_expect(substitute_game.setup("2017-10-06"), "substitute holiday setup failed")
	var substitute_flow: Dictionary = substitute_game.get_day_flow_context()
	_expect(substitute_flow.get("has_choice", false), "substitute holiday should expose closed-day choices")
	_expect(_helpers.ids_from_items(substitute_flow.get("available_choices", [])).has("part_time"), "substitute holiday choices should include part time")

	var extra_family_holiday_game = GameStateScript.new()
	_expect(extra_family_holiday_game.setup("2020-01-27"), "extra family holiday setup failed")
	var extra_family_holiday_flow: Dictionary = extra_family_holiday_game.get_day_flow_context()
	_expect(extra_family_holiday_flow.get("has_choice", false), "extra family holiday should expose closed-day choices")

	var sick_game = GameStateScript.new()
	_expect(sick_game.setup("2016-07-04"), "sick setup failed")
	sick_game.status.fatigue = 98
	var sick_flow: Dictionary = sick_game.get_day_flow_context()
	_expect(sick_flow.get("default_action", {}).get("id", "") == "sick_rest", "high fatigue should override work with sick rest")

	var doomed = PlayerStatusScript.new()
	doomed.apply_effects({"cash_delta": -999999999})
	_expect(doomed.is_game_over(), "cash zero should trigger game over")
	_expect(doomed.get_game_over_reason() == "cash_zero", "cash game-over reason mismatch")

	var exhausted = PlayerStatusScript.new()
	exhausted.apply_effects({"health_delta": -999999999})
	_expect(exhausted.is_game_over(), "health zero should trigger game over")
	_expect(exhausted.get_game_over_reason() == "health_zero", "health game-over reason mismatch")

	var clear_status = PlayerStatusScript.new()
	clear_status.apply_effects({"cash_delta": 995000000})
	_expect(clear_status.is_game_clear(), "1 billion net worth should still mark target reached on raw status")
	_expect(clear_status.get_clear_reason() == "target_net_worth", "raw target reason mismatch")

	var target_reached_game = GameStateScript.new()
	_expect(target_reached_game.setup("2016-07-25"), "target-reached game setup failed")
	target_reached_game.status.cash = 1000000000
	target_reached_game.market.set_cash_balance(target_reached_game.status.cash)
	var target_reached_result := target_reached_game.complete_today("company_work", [], true)
	_expect(not target_reached_result.get("game_clear", true), "target reached before final day should not clear the game")
	_expect(target_reached_result.get("sleep_required", false), "target reached before final day should still require sleep")
	var target_reached_sleep := target_reached_game.sleep_to_next_day()
	_expect(target_reached_sleep.get("ok", false), "target reached before final day should sleep to next day")

	var clear_game = GameStateScript.new()
	_expect(clear_game.setup("2026-06-30"), "final clear game setup failed")
	clear_game.status.cash = 1100000000
	clear_game.market.set_cash_balance(clear_game.status.cash)
	var clear_result := clear_game.complete_today("company_work", [], true)
	_expect(clear_result.get("game_clear", false), "final-day complete_today should report game clear")
	_expect(clear_result.get("game_finished", false), "clear result should finish game")
	_expect(not clear_result.get("sleep_required", true), "clear result should not require sleep")
	var clear_sleep := clear_game.sleep_to_next_day()
	_expect(not clear_sleep.get("ok", true), "clear game should not sleep to next day")
	_expect(clear_sleep.get("error", "") == "game_clear", "clear sleep error mismatch")

	var bad_ending_game = GameStateScript.new()
	_expect(bad_ending_game.setup("2026-06-30"), "final bad-ending game setup failed")
	bad_ending_game.status.cash = 500000000
	bad_ending_game.market.set_cash_balance(bad_ending_game.status.cash)
	var bad_ending_result := bad_ending_game.complete_today("company_work", [], true)
	_expect(not bad_ending_result.get("game_clear", true), "final bad ending should not clear")
	_expect(bad_ending_result.get("game_over", false), "final bad ending should finish as game over state")
	_expect(bad_ending_result.get("game_over_reason", "") == "final_bad_ending", "final bad ending reason mismatch")
	_expect(bad_ending_result.get("ending_route", "") == "bad_ending_05_near_miss", "final bad ending route mismatch")

	print("Backend smoke test passed.")
	finish_test()


func _find_stock(stocks: Array, ticker: String) -> Dictionary:
	for stock in stocks:
		if String(stock.get("ticker", "")) == ticker:
			return stock
	return {}


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	push_error(message)
	fail_test()


class TestPlayerProfile:
	extends PlayerProfileScript

	func _get_save_path() -> String:
		return "user://backend_smoke_profile.cfg"
