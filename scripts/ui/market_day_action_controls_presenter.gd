class_name MarketDayActionControlsPresenter
extends RefCounted

const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")


static func apply(order_panel, closed_day_panel, state: Dictionary) -> void:
	if order_panel != null:
		order_panel.set_day_actions(
			state.get(MarketDayActionOptionsConfigScript.KEY_ACTION_LABELS, []),
			bool(state.get(MarketDayActionOptionsConfigScript.KEY_ORDER_ACTIONS_DISABLED, true)),
			int(state.get(MarketDayActionOptionsConfigScript.KEY_ACTION_SELECTED_INDEX, MarketDayActionOptionsConfigScript.DEFAULT_SELECTED_INDEX))
		)
	apply_closed_day_panel(closed_day_panel, state)


static func apply_closed_day_panel(closed_day_panel, state: Dictionary) -> void:
	if closed_day_panel == null:
		return
	closed_day_panel.render_categories(
		state.get(MarketDayActionOptionsConfigScript.KEY_CATEGORIES, []),
		String(state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID, MarketDayActionOptionsConfigScript.EMPTY_ID)),
		bool(state.get(MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED, false))
	)
	closed_day_panel.render_choices(
		state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES, []),
		String(state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID, MarketDayActionOptionsConfigScript.EMPTY_ID)),
		bool(state.get(MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED, false))
	)
