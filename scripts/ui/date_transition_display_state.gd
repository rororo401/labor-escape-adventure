class_name DateTransitionDisplayState
extends RefCounted

const GameDateFormatterScript := preload("res://scripts/core/game_date_formatter.gd")
const DateTransitionDisplayStateConfigScript := preload("res://scripts/ui/date_transition_display_state_config.gd")


static func closing_state(from_date: String) -> Dictionary:
	return {
		DateTransitionDisplayStateConfigScript.KEY_DATE_TEXT: GameDateFormatterScript.dot_date(from_date),
		DateTransitionDisplayStateConfigScript.KEY_WEEKDAY_TEXT: DateTransitionDisplayStateConfigScript.CLOSING_TEXT,
		DateTransitionDisplayStateConfigScript.KEY_STAMP_TEXT: DateTransitionDisplayStateConfigScript.EMPTY_TEXT
	}


static func morning_state(to_date: String, weekday: String) -> Dictionary:
	return {
		DateTransitionDisplayStateConfigScript.KEY_DATE_TEXT: GameDateFormatterScript.dot_date(to_date),
		DateTransitionDisplayStateConfigScript.KEY_WEEKDAY_TEXT: GameDateFormatterScript.transition_morning_label(weekday),
		DateTransitionDisplayStateConfigScript.KEY_STAMP_TEXT: DateTransitionDisplayStateConfigScript.MORNING_STAMP_TEXT
	}
