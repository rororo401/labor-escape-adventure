class_name MarketScreenState
extends RefCounted

const MarketScreenStateConfigScript := preload("res://scripts/ui/market_screen_state_config.gd")


static func apply(current: Dictionary, patch: Dictionary) -> Dictionary:
	var next := current.duplicate(true)
	for key in MarketScreenStateConfigScript.KNOWN_KEYS:
		if not patch.has(key):
			continue
		match key:
			MarketScreenStateConfigScript.KEY_SELECTED_STOCK:
				next[key] = Dictionary(patch.get(key, current.get(key, MarketScreenStateConfigScript.DEFAULT_SELECTED_STOCK))).duplicate(true)
			MarketScreenStateConfigScript.KEY_SELECTED_DAY_ACTION_ID:
				next[key] = str(patch.get(key, current.get(key, MarketScreenStateConfigScript.DEFAULT_SELECTED_DAY_ACTION_ID)))
			MarketScreenStateConfigScript.KEY_SELECTED_CLOSED_DAY_CATEGORY_ID:
				next[key] = str(patch.get(key, current.get(key, MarketScreenStateConfigScript.DEFAULT_SELECTED_CLOSED_DAY_CATEGORY_ID)))
			MarketScreenStateConfigScript.KEY_QUANTITY:
				next[key] = int(patch.get(key, current.get(key, MarketScreenStateConfigScript.DEFAULT_QUANTITY)))
			_:
				next[key] = bool(patch.get(key, current.get(key, MarketScreenStateConfigScript.DEFAULT_FLAG)))
	return next
