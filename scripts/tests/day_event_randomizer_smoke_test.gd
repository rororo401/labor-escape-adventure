extends "res://scripts/tests/test_scene_tree.gd"

const DayEventRandomizerScript := preload("res://scripts/core/dayflow/day_event_randomizer.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	_verify_limited_category_choices()
	_verify_event_history_filters()
	_verify_night_event_selection()
	_verify_weekday_event_selection()
	_verify_configured_occurrence_uses_selection_weight_only()
	_verify_group_occurrence_is_pool_size_independent()
	_verify_run_seed_changes_stable_choices()
	_verify_stable_helpers()

	print("Day event randomizer smoke test passed.")
	finish_test()


func _verify_limited_category_choices() -> void:
	var choices: Array[Dictionary] = [
		{"id": "home_1", "category_id": "stay_home"},
		{"id": "home_2", "category_id": "stay_home"},
		{"id": "home_3", "category_id": "stay_home"},
		{"id": "out_1", "category_id": "go_out"}
	]
	var first: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(choices, "stay_home", "2016-07-02", 0, 2)
	var second: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(choices, "stay_home", "2016-07-02", 0, 2)
	_expect(first.size() == 2, "category choices should respect limit")
	_expect(_helpers.ids_from_items(first) == _helpers.ids_from_items(second), "category choices should be stable for same seed")
	_expect(not _helpers.ids_from_items(first).has("out_1"), "category choices should filter other categories")

	var all_choices: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(choices, "stay_home", "2016-07-02", 0, 99)
	_expect(all_choices.size() == 3, "large limit should not exceed filtered count")
	_expect(DayEventRandomizerScript.limited_category_choices(choices, "missing", "2016-07-02", 0, 4).is_empty(), "missing category should return empty choices")
	var same_tag_choices: Array[Dictionary] = []
	for index in range(4):
		same_tag_choices.append({"id": "shared_%d" % index, "category_id": "stay_home", "tags": ["shared"]})
	var filled := DayEventRandomizerScript.limited_category_choices(same_tag_choices, "stay_home", "2016-07-02", 0, 4, [], "fill-seed")
	_expect(filled.size() == 4, "relaxed pass should fill every requested slot when enough candidates exist")


func _verify_event_history_filters() -> void:
	var choices: Array[Dictionary] = [
		{"id": "home_1", "category_id": "stay_home", "tags": ["quiet"], "cooldown_days": 60},
		{"id": "home_2", "category_id": "stay_home", "tags": ["quiet"], "cooldown_days": 60},
		{"id": "home_3", "category_id": "stay_home", "tags": ["quiet"], "cooldown_days": 60},
		{"id": "home_4", "category_id": "stay_home", "tags": ["active"], "cooldown_days": 60}
	]
	var history := [
		{"id": "home_1", "completed_day": 9, "selected": true}
	]
	var filtered: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(choices, "stay_home", "2016-07-02", 10, 4, history)
	var ids := _helpers.ids_from_items(filtered)
	_expect(not ids.has("home_1"), "recently selected choice should be filtered by cooldown")

	var similar_history := [{
		"id": "older_quiet",
		"tags": ["quiet"],
		"cg_path": "res://events/older_quiet.png",
		"completed_day": 9,
		"selected": true
	}]
	var tag_filtered: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(choices, "stay_home", "2016-07-02", 10, 1, similar_history)
	var tag_ids := _helpers.ids_from_items(tag_filtered)
	_expect(not tag_ids.has("home_1"), "recently selected similar tag should be filtered")
	_expect(not tag_ids.has("home_2"), "recently selected similar tag should filter more than exact id")
	_expect(tag_ids.has("home_4"), "different specific tag should remain available")

	var cg_choices: Array[Dictionary] = [
		{"id": "cg_same", "category_id": "stay_home", "cg_path": "res://events/same.png", "cooldown_days": 60},
		{"id": "cg_other", "category_id": "stay_home", "cg_path": "res://events/other.png", "cooldown_days": 60}
	]
	var cg_history := [{
		"id": "older_cg",
		"cg_path": "res://events/same.png",
		"completed_day": 9,
		"selected": true
	}]
	var cg_filtered: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(cg_choices, "stay_home", "2016-07-02", 10, 1, cg_history)
	var cg_ids := _helpers.ids_from_items(cg_filtered)
	_expect(not cg_ids.has("cg_same"), "recently selected same CG should be filtered")
	_expect(cg_ids.has("cg_other"), "different CG should remain available")

	var broad_choices: Array[Dictionary] = [
		{"id": "work_a", "category_id": "stay_home", "tags": ["work"], "cooldown_days": 60},
		{"id": "work_b", "category_id": "stay_home", "tags": ["work"], "cooldown_days": 60}
	]
	var broad_history := [{"id": "older_work", "tags": ["work"], "completed_day": 9, "selected": true}]
	var broad_filtered: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(broad_choices, "stay_home", "2016-07-02", 10, 4, broad_history)
	_expect(broad_filtered.size() == 2, "broad tags should not block whole event pools")
	var short_history := [{"id": "older_productive", "tags": ["productive"], "completed_day": 9, "selected": true}]
	var short_choice := [{"id": "productive_new", "category_id": "stay_home", "tags": ["productive"]}, {"id": "unrelated", "category_id": "stay_home", "tags": ["active"]}]
	_expect(_helpers.ids_from_items(DayEventRandomizerScript.limited_category_choices(short_choice, "stay_home", "2016-07-02", 12, 1, short_history)) == ["unrelated"], "common experience tags should receive a short similarity cooldown")
	_expect(_helpers.ids_from_items(DayEventRandomizerScript.limited_category_choices([short_choice[0]], "stay_home", "2016-07-02", 13, 1, short_history)) == ["productive_new"], "short similarity cooldown should expire after three days")
	var zero_choice := [{"id": "zero", "category_id": "stay_home", "tags": ["quiet"], "cooldown_days": 0}, {"id": "zero_unrelated", "category_id": "stay_home", "tags": ["active"]}]
	var zero_history := [{"id": "other", "tags": ["quiet"], "completed_day": 9, "selected": true}]
	_expect(_helpers.ids_from_items(DayEventRandomizerScript.limited_category_choices(zero_choice, "stay_home", "2016-07-02", 10, 1, zero_history)) == ["zero_unrelated"], "zero exact cooldown should not disable similarity cooldowns")
	var family_choice := [{"id": "company_handoff_08", "category_id": "stay_home"}]
	var family_history := [{"id": "company_handoff_07", "completed_day": 0, "selected": true}]
	_expect(DayEventRandomizerScript.limited_category_choices(family_choice, "stay_home", "2016-07-02", 14, 1, family_history).is_empty(), "numeric suffix variants should share a fourteen-day family cooldown")
	_expect(DayEventRandomizerScript.limited_category_choices(family_choice, "stay_home", "2016-07-02", 15, 1, family_history).size() == 1, "numeric suffix family cooldown should expire after fourteen days")

	var limited: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(choices, "stay_home", "2016-07-02", 100, 3)
	var quiet_count := 0
	for item in limited:
		if Array(Dictionary(item).get("tags", [])).has("quiet"):
			quiet_count += 1
	_expect(quiet_count <= DayEventKeysScript.DEFAULT_TAG_CANDIDATE_LIMIT, "candidate list should avoid overfilling a tag while possible")


func _verify_night_event_selection() -> void:
	var night_events: Array[Dictionary] = [
		{"id": "night_always", "chance": 1.0},
		{"id": "night_never", "chance": 0.0}
	]
	var night_events_by_id := {
		"night_always": night_events[0],
		"night_never": night_events[1]
	}
	var trading_day := {"date": "2016-07-01", "is_trading_day": true}
	var closed_day := {"date": "2016-07-02", "is_trading_day": false}

	var forced: Array[Dictionary] = DayEventRandomizerScript.select_night_events(night_events, night_events_by_id, trading_day, 0, ["night_never"], false)
	_expect(_helpers.ids_from_items(forced) == ["night_never"], "forced night event should win and prevent random selection")

	var suppressed: Array[Dictionary] = DayEventRandomizerScript.select_night_events(night_events, night_events_by_id, trading_day, 0, [], true)
	_expect(suppressed.is_empty(), "suppressed random night events should return only forced events")

	var selected: Array[Dictionary] = DayEventRandomizerScript.select_night_events(night_events, night_events_by_id, trading_day, 0, [], false)
	_expect(_helpers.ids_from_items(selected) == ["night_always"], "trading day should select first passing random night event")

	var cooldown_history := [{"id": "night_always", "completed_day": 0, "selected": true}]
	var cooldown_selected: Array[Dictionary] = DayEventRandomizerScript.select_night_events(night_events, night_events_by_id, trading_day, 10, [], false, cooldown_history)
	_expect(cooldown_selected.is_empty(), "recently selected night event should be filtered by cooldown")

	var closed_selected: Array[Dictionary] = DayEventRandomizerScript.select_night_events(night_events, night_events_by_id, closed_day, 0, [], false)
	_expect(closed_selected.is_empty(), "closed day should not roll random night events")


func _verify_weekday_event_selection() -> void:
	var weekday_events: Array[Dictionary] = [
		{"id": "weekday_always", "chance": 1.0},
		{"id": "weekday_never", "chance": 0.0}
	]
	var weekday_events_by_id := {
		"weekday_always": weekday_events[0],
		"weekday_never": weekday_events[1]
	}
	var trading_day := {"date": "2016-07-01", "is_trading_day": true}
	var closed_day := {"date": "2016-07-02", "is_trading_day": false}

	var forced: Array[Dictionary] = DayEventRandomizerScript.select_weekday_events(weekday_events, weekday_events_by_id, trading_day, 0, ["weekday_never"], false)
	_expect(_helpers.ids_from_items(forced) == ["weekday_never"], "forced weekday event should win and prevent random selection")

	var selected: Array[Dictionary] = DayEventRandomizerScript.select_weekday_events(weekday_events, weekday_events_by_id, trading_day, 0, [], false)
	_expect(_helpers.ids_from_items(selected) == ["weekday_always"], "trading day should select first passing weekday event")

	var closed_selected: Array[Dictionary] = DayEventRandomizerScript.select_weekday_events(weekday_events, weekday_events_by_id, closed_day, 0, [], false)
	_expect(closed_selected.is_empty(), "closed day should not roll random weekday events")


func _verify_configured_occurrence_uses_selection_weight_only() -> void:
	var events: Array[Dictionary] = [
		{"id": "zero_chance_positive_weight", "chance": 0.0, "weight": 1.0},
		{"id": "high_chance_zero_weight", "chance": 1.0, "weight": 0.0}
	]
	var by_id := {"zero_chance_positive_weight": events[0], "high_chance_zero_weight": events[1]}
	var selected := DayEventRandomizerScript.select_weekday_events(
		events, by_id, {"date": "2016-07-01", "is_trading_day": true}, 0, [], false, [], "configured-weight", {}, 1.0
	)
	_expect(_helpers.ids_from_items(selected) == ["zero_chance_positive_weight"], "configured occurrence should select by weight without multiplying legacy chance")


func _verify_group_occurrence_is_pool_size_independent() -> void:
	var one_event: Array[Dictionary] = [{"id": "one", "chance": 1.0, "weight": 1}]
	var large_pool: Array[Dictionary] = []
	for index in range(100):
		large_pool.append({"id": "event_%03d" % index, "chance": 1.0, "weight": 1})
	var one_by_id := {"one": one_event[0]}
	var large_by_id := {}
	for event in large_pool:
		large_by_id[String(event.get("id", ""))] = event

	var one_count := 0
	var large_count := 0
	var sample_count := 5000
	for index in range(sample_count):
		var day := {"date": "simulation-%05d" % index, "is_trading_day": true}
		var one_result := DayEventRandomizerScript.select_weekday_events(
			one_event, one_by_id, day, index, [], false, [], "rate-seed", {}, 0.30
		)
		var large_result := DayEventRandomizerScript.select_weekday_events(
			large_pool, large_by_id, day, index, [], false, [], "rate-seed", {}, 0.30
		)
		one_count += 0 if one_result.is_empty() else 1
		large_count += 0 if large_result.is_empty() else 1

	_expect(one_count == large_count, "adding events to a pool must not change group occurrence days")
	var observed_rate := float(one_count) / float(sample_count)
	_expect(observed_rate >= 0.27 and observed_rate <= 0.33, "configured 30%% group occurrence should remain near 30%%")


func _verify_run_seed_changes_stable_choices() -> void:
	var choices: Array[Dictionary] = [
		{"id": "home_1", "category_id": "stay_home"},
		{"id": "home_2", "category_id": "stay_home"},
		{"id": "home_3", "category_id": "stay_home"},
		{"id": "home_4", "category_id": "stay_home"},
		{"id": "home_5", "category_id": "stay_home"},
		{"id": "home_6", "category_id": "stay_home"}
	]
	var baseline: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(choices, "stay_home", "2016-07-02", 0, 3, [], "run_seed_0")
	var repeated: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(choices, "stay_home", "2016-07-02", 0, 3, [], "run_seed_0")
	_expect(_helpers.ids_from_items(baseline) == _helpers.ids_from_items(repeated), "same run seed should keep stable choices")

	var changed := false
	for index in range(1, 20):
		var seeded: Array[Dictionary] = DayEventRandomizerScript.limited_category_choices(choices, "stay_home", "2016-07-02", 0, 3, [], "run_seed_%d" % index)
		if _helpers.ids_from_items(seeded) != _helpers.ids_from_items(baseline):
			changed = true
			break
	_expect(changed, "different run seeds should be able to change closed-day choices")


func _verify_stable_helpers() -> void:
	var chance := DayEventRandomizerScript.stable_chance("2016-07-01", "night_always", 0)
	_expect(chance >= 0.0 and chance < 1.0, "stable chance should be normalized")
	_expect(chance == DayEventRandomizerScript.stable_chance("2016-07-01", "night_always", 0), "stable chance should repeat for same seed")
	_expect(
		DayEventRandomizerScript.stable_chance("2016-07-01", "night_always", 0, "run_a")
			== DayEventRandomizerScript.stable_chance("2016-07-01", "night_always", 0, "run_a"),
		"stable chance should repeat for same run seed"
	)

	var items := [1, 2, 3, 4]
	var same_items := [1, 2, 3, 4]
	DayEventRandomizerScript.stable_shuffle(items, "seed")
	DayEventRandomizerScript.stable_shuffle(same_items, "seed")
	_expect(items == same_items, "stable shuffle should repeat for same seed")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
