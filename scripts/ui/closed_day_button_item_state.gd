class_name ClosedDayButtonItemState
extends RefCounted

const ClosedDayButtonItemStateConfigScript := preload("res://scripts/ui/closed_day_button_item_state_config.gd")


static func category(row_value) -> Dictionary:
	var row := _row(row_value)
	var category_id := String(row.get(ClosedDayButtonItemStateConfigScript.ROW_ID, ClosedDayButtonItemStateConfigScript.EMPTY_ID))
	return {
		ClosedDayButtonItemStateConfigScript.KEY_ID: category_id,
		ClosedDayButtonItemStateConfigScript.KEY_LABEL: String(row.get(ClosedDayButtonItemStateConfigScript.ROW_NAME, category_id))
	}


static func choice(row_value) -> Dictionary:
	var row := _row(row_value)
	var action_id := String(row.get(ClosedDayButtonItemStateConfigScript.ROW_ID, ClosedDayButtonItemStateConfigScript.EMPTY_ID))
	var name := String(row.get(ClosedDayButtonItemStateConfigScript.ROW_NAME, ClosedDayButtonItemStateConfigScript.EMPTY_LABEL))
	var summary := String(row.get(ClosedDayButtonItemStateConfigScript.ROW_SUMMARY, ClosedDayButtonItemStateConfigScript.EMPTY_LABEL))
	return {
		ClosedDayButtonItemStateConfigScript.KEY_ID: action_id,
		ClosedDayButtonItemStateConfigScript.KEY_LABEL: "%s%s%s" % [name, ClosedDayButtonItemStateConfigScript.CHOICE_LABEL_SEPARATOR, summary],
		ClosedDayButtonItemStateConfigScript.KEY_TOOLTIP: summary
	}


static func has_item_id(items: Array, selected_id: String) -> bool:
	for item in items:
		if String(category(item).get(ClosedDayButtonItemStateConfigScript.KEY_ID, ClosedDayButtonItemStateConfigScript.EMPTY_ID)) == selected_id:
			return true
	return false


static func _row(value) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return Dictionary(value)
