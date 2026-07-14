class_name DayEventCatalogLoader
extends RefCounted

const JsonFileLoaderScript := preload("res://scripts/core/json_file_loader.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventTextAliasResolverScript := preload("res://scripts/core/dayflow/day_event_text_alias_resolver.gd")


static func load_from_json(path: String) -> Dictionary:
	var loaded := JsonFileLoaderScript.read_dictionary(path, "day event JSON")
	if not bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)):
		return empty_payload()

	return payload_from_parsed(_merge_external_content(Dictionary(loaded.get(JsonFileLoaderScript.KEY_DATA, {}))))


static func payload_from_parsed(parsed: Dictionary) -> Dictionary:
	var rules := Dictionary(parsed.get(DayEventKeysScript.KEY_RULES, {}))
	var event_conditions := Dictionary(rules.get(DayEventKeysScript.RULE_EVENT_CONDITIONS, {}))
	var action_index := index_rows(_rows_with_conditions(parsed.get(DayEventKeysScript.KEY_DAY_ACTIONS, []), event_conditions))
	var weekday_index := index_rows(_rows_with_conditions(parsed.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []), event_conditions))
	var night_index := index_rows(_rows_with_conditions(parsed.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []), event_conditions))
	return {
		DayEventKeysScript.KEY_DAY_ACTIONS: action_index.get(DayEventKeysScript.KEY_ROWS, []),
		DayEventKeysScript.KEY_ACTIONS_BY_ID: action_index.get(DayEventKeysScript.KEY_BY_ID, {}),
		DayEventKeysScript.KEY_WEEKDAY_EVENTS: weekday_index.get(DayEventKeysScript.KEY_ROWS, []),
		DayEventKeysScript.KEY_WEEKDAY_EVENTS_BY_ID: weekday_index.get(DayEventKeysScript.KEY_BY_ID, {}),
		DayEventKeysScript.KEY_NIGHT_EVENTS: night_index.get(DayEventKeysScript.KEY_ROWS, []),
		DayEventKeysScript.KEY_NIGHT_EVENTS_BY_ID: night_index.get(DayEventKeysScript.KEY_BY_ID, {}),
		DayEventKeysScript.KEY_RULES: rules,
		DayEventKeysScript.KEY_CLOSED_DAY_CHOICE_LIMIT: int(parsed.get(
			DayEventKeysScript.KEY_CLOSED_DAY_CHOICE_LIMIT,
			DayEventKeysScript.DEFAULT_CLOSED_DAY_CHOICE_LIMIT
		))
	}


static func _rows_with_conditions(rows: Array, event_conditions: Dictionary) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var event_row := Dictionary(row).duplicate(true)
		var event_id := String(event_row.get(DayEventKeysScript.KEY_ID, ""))
		if event_conditions.has(event_id):
			event_row[DayEventKeysScript.KEY_CONDITIONS] = Dictionary(event_conditions.get(event_id, {})).duplicate(true)
		normalized.append(event_row)
	return normalized


static func _merge_external_content(parsed: Dictionary) -> Dictionary:
	var merged := parsed.duplicate(true)
	for external_path in _external_content_paths(parsed):
		merged = _merge_external_file(merged, String(external_path))
	return merged


static func _external_content_paths(parsed: Dictionary) -> Array[String]:
	var paths: Array[String] = []
	for key in [
		DayEventKeysScript.KEY_SPECIAL_ANNUAL_EVENTS_PATH,
		DayEventKeysScript.KEY_MARKET_FIXED_EVENTS_PATH
	]:
		var path := String(parsed.get(key, ""))
		if not path.is_empty():
			paths.append(path)
	return paths


static func _merge_external_file(base: Dictionary, external_path: String) -> Dictionary:
	if external_path.is_empty():
		return base

	var loaded := JsonFileLoaderScript.read_dictionary(external_path, "external day event JSON")
	if not bool(loaded.get(JsonFileLoaderScript.KEY_OK, false)):
		return base

	var merged := base.duplicate(true)
	var external_data := DayEventTextAliasResolverScript.resolve_external_data(Dictionary(loaded.get(JsonFileLoaderScript.KEY_DATA, {})))
	var day_actions := Array(merged.get(DayEventKeysScript.KEY_DAY_ACTIONS, [])).duplicate()
	day_actions.append_array(Array(external_data.get(DayEventKeysScript.KEY_DAY_ACTIONS, [])))
	merged[DayEventKeysScript.KEY_DAY_ACTIONS] = day_actions
	merged[DayEventKeysScript.KEY_RULES] = _merged_rules(
		Dictionary(merged.get(DayEventKeysScript.KEY_RULES, {})),
		Dictionary(external_data.get(DayEventKeysScript.KEY_RULES, {}))
	)
	return merged


static func _merged_rules(base_rules: Dictionary, external_rules: Dictionary) -> Dictionary:
	var rules := base_rules.duplicate(true)
	for rule_key in external_rules.keys():
		var external_value = external_rules.get(rule_key)
		if typeof(external_value) == TYPE_DICTIONARY and typeof(rules.get(rule_key)) == TYPE_DICTIONARY:
			var merged_value := Dictionary(rules.get(rule_key)).duplicate(true)
			for nested_key in Dictionary(external_value).keys():
				merged_value[nested_key] = Dictionary(external_value).get(nested_key)
			rules[rule_key] = merged_value
		else:
			rules[rule_key] = external_value
	return rules


static func index_rows(rows: Array) -> Dictionary:
	var valid_rows: Array[Dictionary] = []
	var by_id := {}
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var event_row := Dictionary(row)
		var id := String(event_row.get(DayEventKeysScript.KEY_ID, ""))
		if id.is_empty():
			continue
		valid_rows.append(event_row)
		by_id[id] = event_row
	return {
		DayEventKeysScript.KEY_ROWS: valid_rows,
		DayEventKeysScript.KEY_BY_ID: by_id
	}


static func empty_payload() -> Dictionary:
	return {
		DayEventKeysScript.KEY_DAY_ACTIONS: [],
		DayEventKeysScript.KEY_ACTIONS_BY_ID: {},
		DayEventKeysScript.KEY_WEEKDAY_EVENTS: [],
		DayEventKeysScript.KEY_WEEKDAY_EVENTS_BY_ID: {},
		DayEventKeysScript.KEY_NIGHT_EVENTS: [],
		DayEventKeysScript.KEY_NIGHT_EVENTS_BY_ID: {},
		DayEventKeysScript.KEY_RULES: {},
		DayEventKeysScript.KEY_CLOSED_DAY_CHOICE_LIMIT: DayEventKeysScript.DEFAULT_CLOSED_DAY_CHOICE_LIMIT
	}
