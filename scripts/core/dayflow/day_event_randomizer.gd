class_name DayEventRandomizer
extends RefCounted

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventConditionResolverScript := preload("res://scripts/core/dayflow/day_event_condition_resolver.gd")
const DayEventRecencyIndexScript := preload("res://scripts/core/dayflow/day_event_recency_index.gd")
const RandomSeedMixerScript := preload("res://scripts/core/random_seed_mixer.gd")

const IGNORED_SIMILARITY_TAGS := {
	"work": true,
	"office": true,
	"routine": true,
	"rare": true,
	"seasonal": true
}
const SHORT_SIMILARITY_TAG_COOLDOWNS := {
	"money": 3,
	"health": 3,
	"mood": 2,
	"recovery": 2,
	"food": 2,
	"stress": 2,
	"social": 2,
	"calm": 2,
	"productive": 3,
	"hobby": 2,
	"career": 3,
	"high_fatigue": 2,
	"light_outing": 2,
	"expensive": 3,
	"selfcare": 2
}
const NUMERIC_SUFFIX_FAMILY_COOLDOWN_DAYS := 14


static func limited_category_choices(
	available_choices: Array,
	category_id: String,
	date: String,
	completed_days: int,
	limit: int,
	event_history: Array = [],
	random_seed: String = ""
) -> Array[Dictionary]:
	if limit <= 0:
		return []

	var recency_index := DayEventRecencyIndexScript.build(event_history, completed_days)
	var filtered := _filtered_category_choices(available_choices, category_id, recency_index, completed_days, true)
	if filtered.is_empty():
		filtered = _filtered_category_choices(available_choices, category_id, recency_index, completed_days, false)
	if filtered.is_empty():
		return []

	var shuffled := filtered.duplicate()
	stable_shuffle(shuffled, _seed_text(date, category_id, completed_days, random_seed))
	var selected := _pick_with_tag_limit(shuffled, limit)
	if selected.size() >= limit:
		return selected

	var relaxed := _filtered_category_choices(available_choices, category_id, recency_index, completed_days, false)
	stable_shuffle(relaxed, _seed_text(date, "relaxed:%s" % category_id, completed_days, random_seed))
	for action in relaxed:
		if selected.size() >= limit:
			break
		var action_row := Dictionary(action)
		if not _has_event_id(selected, String(action_row.get(DayEventKeysScript.KEY_ID, ""))):
			selected.append(action_row)
	return selected


static func _filtered_category_choices(
	available_choices: Array,
	category_id: String,
	recency_index: Dictionary,
	completed_days: int,
	include_similarity_cooldown: bool
) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	for action in available_choices:
		var action_row := Dictionary(action)
		if (
			String(action_row.get(DayEventKeysScript.KEY_CATEGORY_ID, "")) == category_id
			and _is_allowed_by_recent_selection(action_row, recency_index, completed_days, include_similarity_cooldown)
		):
			filtered.append(action_row)
	return filtered


static func select_stable_event(
	events: Array,
	date: String,
	seed_group: String,
	completed_days: int,
	event_history: Array = [],
	random_seed: String = ""
) -> Dictionary:
	var candidates := events.duplicate()
	if candidates.is_empty():
		return {}

	var recency_index := DayEventRecencyIndexScript.build(event_history, completed_days)
	stable_shuffle(candidates, _seed_text(date, seed_group, completed_days, random_seed))
	for event in candidates:
		var event_row := Dictionary(event)
		if _is_allowed_by_recent_selection(event_row, recency_index, completed_days, true):
			return event_row
	for event in candidates:
		var event_row := Dictionary(event)
		if _is_allowed_by_recent_selection(event_row, recency_index, completed_days, false):
			return event_row
	return Dictionary(candidates[0])


static func select_night_events(
	night_events: Array,
	night_events_by_id: Dictionary,
	day: Dictionary,
	completed_days: int,
	forced_event_ids: Array,
	suppress_random_night_events: bool = false,
	event_history: Array = [],
	random_seed: String = "",
	status: Dictionary = {},
	group_occurrence_chance: float = -1.0,
	condition_seed: String = ""
) -> Array[Dictionary]:
	var selected: Array[Dictionary] = []
	for event_id in forced_event_ids:
		var event := Dictionary(night_events_by_id.get(String(event_id), {}))
		if not event.is_empty():
			selected.append(event)

	if suppress_random_night_events:
		return selected

	if not selected.is_empty() or not bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
		return selected

	var recency_index := DayEventRecencyIndexScript.build(event_history, completed_days)
	return _select_group_event(
		night_events,
		day,
		status,
		"night",
		completed_days,
		recency_index,
		random_seed,
		group_occurrence_chance,
		condition_seed
	)


static func select_weekday_events(
	weekday_events: Array,
	weekday_events_by_id: Dictionary,
	day: Dictionary,
	completed_days: int,
	forced_event_ids: Array,
	suppress_random_weekday_events: bool = false,
	event_history: Array = [],
	random_seed: String = "",
	status: Dictionary = {},
	group_occurrence_chance: float = -1.0,
	condition_seed: String = ""
) -> Array[Dictionary]:
	var selected: Array[Dictionary] = []
	for event_id in forced_event_ids:
		var event := Dictionary(weekday_events_by_id.get(String(event_id), {}))
		if not event.is_empty():
			selected.append(event)

	if suppress_random_weekday_events:
		return selected

	if not selected.is_empty() or not bool(day.get(DayEventKeysScript.KEY_IS_TRADING_DAY, false)):
		return selected

	var recency_index := DayEventRecencyIndexScript.build(event_history, completed_days)
	return _select_group_event(
		weekday_events,
		day,
		status,
		"weekday",
		completed_days,
		recency_index,
		random_seed,
		group_occurrence_chance,
		condition_seed
	)


static func _select_group_event(
	events: Array,
	day: Dictionary,
	status: Dictionary,
	group: String,
	completed_days: int,
	recency_index: Dictionary,
	random_seed: String,
	configured_occurrence_chance: float,
	condition_seed: String
) -> Array[Dictionary]:
	var use_legacy_chance_weight := configured_occurrence_chance < 0.0
	var resolved_condition_seed := random_seed if condition_seed.is_empty() else condition_seed
	var candidates := _eligible_random_events(
		events,
		day,
		status,
		recency_index,
		completed_days,
		resolved_condition_seed,
		true,
		use_legacy_chance_weight
	)
	if candidates.is_empty():
		candidates = _eligible_random_events(
			events,
			day,
			status,
			recency_index,
			completed_days,
			resolved_condition_seed,
			false,
			use_legacy_chance_weight
		)
	if candidates.is_empty():
		return []

	var occurrence_chance := configured_occurrence_chance
	if occurrence_chance < 0.0:
		occurrence_chance = _legacy_group_occurrence_chance(candidates)
	occurrence_chance = clampf(occurrence_chance, 0.0, 1.0)
	var date := String(day.get(DayEventKeysScript.KEY_DATE, ""))
	if stable_chance(date, "%s:occurrence" % group, completed_days, random_seed) >= occurrence_chance:
		return []

	var selected_event := _pick_weighted_event(
		candidates,
		date,
		group,
		completed_days,
		random_seed,
		use_legacy_chance_weight
	)
	var selected: Array[Dictionary] = []
	if not selected_event.is_empty():
		selected.append(selected_event)
	return selected


static func _eligible_random_events(
	events: Array,
	day: Dictionary,
	status: Dictionary,
	recency_index: Dictionary,
	completed_days: int,
	condition_seed: String,
	include_similarity_cooldown: bool,
	use_legacy_chance_weight: bool
) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	for event in events:
		var event_row := Dictionary(event)
		if not DayEventConditionResolverScript.is_event_eligible(event_row, day, status, condition_seed):
			continue
		if not _is_allowed_by_recent_selection(event_row, recency_index, completed_days, include_similarity_cooldown):
			continue
		if _event_selection_weight(event_row, use_legacy_chance_weight) > 0.0:
			candidates.append(event_row)
	return candidates


static func _legacy_group_occurrence_chance(events: Array[Dictionary]) -> float:
	var occurrence_chance := 0.0
	for event in events:
		occurrence_chance = maxf(occurrence_chance, float(event.get(DayEventKeysScript.KEY_CHANCE, 0.0)))
	return occurrence_chance


static func _pick_weighted_event(
	events: Array[Dictionary],
	date: String,
	group: String,
	completed_days: int,
	random_seed: String,
	use_legacy_chance_weight: bool
) -> Dictionary:
	var total_weight := 0.0
	for event in events:
		total_weight += _event_selection_weight(event, use_legacy_chance_weight)
	if total_weight <= 0.0:
		return {}

	var target := stable_chance(date, "%s:selection" % group, completed_days, random_seed) * total_weight
	var cumulative := 0.0
	for event in events:
		cumulative += _event_selection_weight(event, use_legacy_chance_weight)
		if target < cumulative:
			return event
	return events.back()


static func _event_selection_weight(event: Dictionary, use_legacy_chance_weight: bool) -> float:
	var configured_weight := maxf(0.0, float(event.get(DayEventKeysScript.KEY_WEIGHT, 1.0)))
	if not use_legacy_chance_weight:
		return configured_weight
	var chance_weight := maxf(0.0, float(event.get(DayEventKeysScript.KEY_CHANCE, 0.0)))
	return chance_weight * configured_weight


static func stable_chance(date: String, event_id: String, completed_days: int, random_seed: String = "") -> float:
	return RandomSeedMixerScript.unit_float(_seed_text(date, event_id, completed_days, random_seed))


static func _seed_text(date: String, group: String, completed_days: int, random_seed: String = "") -> String:
	if random_seed.is_empty():
		return "%s:%s:%d" % [date, group, completed_days]
	return "%s:%s:%s:%d" % [random_seed, date, group, completed_days]


static func stable_shuffle(items: Array, seed_text: String) -> void:
	RandomSeedMixerScript.shuffle_in_place(items, seed_text)


static func _pick_with_tag_limit(shuffled: Array, limit: int) -> Array[Dictionary]:
	var selected: Array[Dictionary] = []
	var tag_counts := {}
	for action in shuffled:
		if selected.size() >= limit:
			break
		var action_row := Dictionary(action)
		if _fits_tag_limit(action_row, tag_counts):
			selected.append(action_row)
			_count_tags(action_row, tag_counts)
	return selected


static func _fits_tag_limit(event: Dictionary, tag_counts: Dictionary) -> bool:
	for tag in _event_tags(event):
		if int(tag_counts.get(tag, 0)) >= DayEventKeysScript.DEFAULT_TAG_CANDIDATE_LIMIT:
			return false
	return true


static func _count_tags(event: Dictionary, tag_counts: Dictionary) -> void:
	for tag in _event_tags(event):
		tag_counts[tag] = int(tag_counts.get(tag, 0)) + 1


static func _is_allowed_by_recent_selection(
	event: Dictionary,
	recency_index: Dictionary,
	completed_days: int,
	include_similarity_cooldown: bool = true
) -> bool:
	var event_id := String(event.get(DayEventKeysScript.KEY_ID, ""))
	var cooldown_days := int(event.get(
		DayEventKeysScript.KEY_COOLDOWN_DAYS,
		DayEventKeysScript.DEFAULT_EVENT_COOLDOWN_DAYS
	))

	if _is_within_cooldown(
		completed_days,
		DayEventRecencyIndexScript.last_event_day(recency_index, event_id),
		cooldown_days
	):
		return false
	var family_id := DayEventRecencyIndexScript.numeric_suffix_family(event_id)
	if _is_within_cooldown(
		completed_days,
		DayEventRecencyIndexScript.last_family_day(recency_index, family_id),
		NUMERIC_SUFFIX_FAMILY_COOLDOWN_DAYS
	):
		return false
	if include_similarity_cooldown and _is_recently_similar(event, recency_index, completed_days):
		return false
	return true


static func _is_recently_similar(event: Dictionary, recency_index: Dictionary, completed_days: int) -> bool:
	return _is_recent_cg_match(event, recency_index, completed_days) or _is_recent_tag_match(event, recency_index, completed_days)


static func _is_recent_cg_match(event: Dictionary, recency_index: Dictionary, completed_days: int) -> bool:
	var cg_cooldown_days := int(event.get(
		DayEventKeysScript.KEY_CG_COOLDOWN_DAYS,
		DayEventKeysScript.DEFAULT_CG_COOLDOWN_DAYS
	))
	var cg_path := String(event.get(DayEventKeysScript.KEY_CG_PATH, ""))
	return (
		not cg_path.is_empty()
		and _is_within_cooldown(
			completed_days,
			DayEventRecencyIndexScript.last_cg_day(recency_index, cg_path),
			cg_cooldown_days
		)
	)


static func _is_recent_tag_match(event: Dictionary, recency_index: Dictionary, completed_days: int) -> bool:
	for tag in _event_tags(event):
		if IGNORED_SIMILARITY_TAGS.has(tag):
			continue
		var tag_cooldown_days := _tag_similarity_cooldown_days(event, tag)
		if _is_within_cooldown(
			completed_days,
			DayEventRecencyIndexScript.last_tag_day(recency_index, tag),
			tag_cooldown_days
		):
			return true
	return false


static func _tag_similarity_cooldown_days(event: Dictionary, tag: String) -> int:
	var configured_days := int(event.get(
		DayEventKeysScript.KEY_TAG_COOLDOWN_DAYS,
		DayEventKeysScript.DEFAULT_TAG_COOLDOWN_DAYS
	))
	if configured_days <= 0:
		return 0
	if SHORT_SIMILARITY_TAG_COOLDOWNS.has(tag):
		return mini(configured_days, int(SHORT_SIMILARITY_TAG_COOLDOWNS.get(tag, configured_days)))
	return configured_days


static func _is_within_cooldown(completed_days: int, last_completed_day: int, cooldown_days: int) -> bool:
	if cooldown_days <= 0 or last_completed_day < 0:
		return false
	var day_gap := completed_days - last_completed_day
	return day_gap >= 0 and day_gap <= cooldown_days


static func _has_event_id(events: Array, event_id: String) -> bool:
	for event in events:
		if String(Dictionary(event).get(DayEventKeysScript.KEY_ID, "")) == event_id:
			return true
	return false


static func _event_tags(event: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	for tag in event.get(DayEventKeysScript.KEY_TAGS, []):
		var tag_id := String(tag)
		if not tag_id.is_empty():
			tags.append(tag_id)
	return tags
