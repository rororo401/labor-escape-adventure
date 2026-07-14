class_name MarketScreenPanelFeedback
extends RefCounted


static func set_flow_message(order_panel, closed_day_panel, text: String) -> void:
	if order_panel != null:
		order_panel.set_message(text)
	if closed_day_panel != null:
		closed_day_panel.set_message(text)


static func set_closed_day_choice_buttons_disabled(closed_day_panel, disabled: bool) -> void:
	if closed_day_panel != null:
		closed_day_panel.set_choice_buttons_disabled(disabled)
