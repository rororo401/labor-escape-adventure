class_name CharacterOutfitSeason
extends RefCounted

const DEFAULT_OFFICE_OUTFIT := "casual_default"
const DEFAULT_HOME_OUTFIT := "homewear"
const SUMMER_OFFICE_OUTFIT := "summer_office"
const SUMMER_HOME_OUTFIT := "summer_homewear"

const SUMMER_START_MONTH := 6
const SUMMER_END_MONTH := 9


static func outfit_for_date(outfit_id: String, date: String) -> String:
	if not is_summer_date(date):
		return winter_base_outfit(outfit_id)
	if outfit_id == DEFAULT_OFFICE_OUTFIT or outfit_id == SUMMER_OFFICE_OUTFIT:
		return SUMMER_OFFICE_OUTFIT
	if outfit_id == DEFAULT_HOME_OUTFIT or outfit_id == SUMMER_HOME_OUTFIT:
		return SUMMER_HOME_OUTFIT
	return outfit_id


static func winter_base_outfit(outfit_id: String) -> String:
	if outfit_id == SUMMER_OFFICE_OUTFIT:
		return DEFAULT_OFFICE_OUTFIT
	if outfit_id == SUMMER_HOME_OUTFIT:
		return DEFAULT_HOME_OUTFIT
	return outfit_id


static func is_summer_date(date: String) -> bool:
	var parts := date_parts(date)
	if parts.is_empty():
		return false
	var month := int(parts.get("month", 0))
	return month >= SUMMER_START_MONTH and month <= SUMMER_END_MONTH


static func date_parts(date: String) -> Dictionary:
	var pieces := date.split("-")
	if pieces.size() != 3:
		return {}
	if not pieces[0].is_valid_int() or not pieces[1].is_valid_int() or not pieces[2].is_valid_int():
		return {}
	return {
		"year": int(pieces[0]),
		"month": int(pieces[1]),
		"day": int(pieces[2])
	}
