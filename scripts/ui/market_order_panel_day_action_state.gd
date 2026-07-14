class_name MarketOrderPanelDayActionState
extends RefCounted

const MarketOrderPanelDayActionStateConfigScript := preload("res://scripts/ui/market_order_panel_day_action_state_config.gd")


static func build(labels: Array, disabled: bool, selected_index: int = 0) -> Dictionary:
	var normalized_labels: Array[String] = []
	for label in labels:
		normalized_labels.append(str(label))

	return {
		MarketOrderPanelDayActionStateConfigScript.KEY_LABELS: normalized_labels,
		MarketOrderPanelDayActionStateConfigScript.KEY_DISABLED: disabled,
		MarketOrderPanelDayActionStateConfigScript.KEY_SELECTED_INDEX: _selected_index(selected_index, normalized_labels.size()),
		MarketOrderPanelDayActionStateConfigScript.KEY_HAS_SELECTION: not normalized_labels.is_empty()
	}


static func _selected_index(selected_index: int, label_count: int) -> int:
	if label_count <= 0:
		return MarketOrderPanelDayActionStateConfigScript.DEFAULT_SELECTED_INDEX
	return clampi(selected_index, 0, label_count - 1)
