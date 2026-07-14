extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenViewConfigScript := preload("res://scripts/ui/market_screen_view_config.gd")
const UiNodeRefKeysScript := preload("res://scripts/ui/ui_node_ref_keys.gd")


func _initialize() -> void:
	_verify_node_keys()
	_verify_callback_keys()

	print("Market screen view config smoke test passed.")
	finish_test()


func _verify_node_keys() -> void:
	_expect(MarketScreenViewConfigScript.KEY_BACKGROUND_RECT == UiNodeRefKeysScript.KEY_BACKGROUND_RECT, "background key should use the shared node-ref key")
	_expect(MarketScreenViewConfigScript.KEY_HUD == "hud", "HUD key should stay stable")
	_expect(MarketScreenViewConfigScript.KEY_STOCK_LIST_PANEL == "stock_list_panel", "stock-list key should stay stable")
	_expect(MarketScreenViewConfigScript.KEY_ORDER_PANEL == "order_panel", "order-panel key should stay stable")
	_expect(MarketScreenViewConfigScript.KEY_CLOSED_DAY_PANEL == "closed_day_panel", "closed-day panel key should stay stable")
	_expect(MarketScreenViewConfigScript.KEY_SETTINGS_OVERLAY == "settings_overlay", "settings overlay key should stay stable")
	_expect(MarketScreenViewConfigScript.KEY_SAVE_SLOT_OVERLAY == "save_slot_overlay", "save-slot overlay key should stay stable")
	_expect(MarketScreenViewConfigScript.KEY_GALLERY_OVERLAY == "gallery_overlay", "gallery overlay key should stay stable")
	_expect(MarketScreenViewConfigScript.KEY_ENDING_OVERLAY == "ending_overlay", "ending overlay key should stay stable")
	_expect(MarketScreenViewConfigScript.KEY_MODE_VIEW == "mode_view", "mode-view key should stay stable")


func _verify_callback_keys() -> void:
	_expect(MarketScreenViewConfigScript.CALLBACK_STOCK_SELECTED == "stock_selected", "stock callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_QUANTITY_DECREASE_REQUESTED == "quantity_decrease_requested", "quantity decrease callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_QUANTITY_INCREASE_REQUESTED == "quantity_increase_requested", "quantity increase callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_ORDER_REQUESTED == "order_requested", "order callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_DAY_ACTION_SELECTED == "day_action_selected", "day-action callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_CATEGORY_SELECTED == "category_selected", "category callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_ACTION_SELECTED == "action_selected", "action callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_FLOW_REQUESTED == "flow_requested", "flow callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_SETTINGS_SAVE_REQUESTED == "settings_save_requested", "settings save callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_SETTINGS_GALLERY_REQUESTED == "settings_gallery_requested", "settings gallery callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_SETTINGS_TITLE_REQUESTED == "settings_title_requested", "settings title callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_ENDING_TITLE_REQUESTED == "ending_title_requested", "ending title callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_ENDING_NEW_GAME_REQUESTED == "ending_new_game_requested", "ending new-game callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_SAVE_SLOT_REQUESTED == "save_slot_requested", "save-slot callback key should stay stable")
	_expect(MarketScreenViewConfigScript.CALLBACK_LOAD_SLOT_REQUESTED == "load_slot_requested", "load-slot callback key should stay stable")
	var callbacks := MarketScreenViewConfigScript.screen_callbacks(_noop, _noop, _noop, _noop, _noop, _noop, _noop, _noop)
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_STOCK_SELECTED), "screen callbacks should include stock callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_QUANTITY_DECREASE_REQUESTED), "screen callbacks should include quantity decrease callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_QUANTITY_INCREASE_REQUESTED), "screen callbacks should include quantity increase callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_ORDER_REQUESTED), "screen callbacks should include order callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_DAY_ACTION_SELECTED), "screen callbacks should include day-action callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_CATEGORY_SELECTED), "screen callbacks should include category callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_ACTION_SELECTED), "screen callbacks should include action callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_FLOW_REQUESTED), "screen callbacks should include flow callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_SETTINGS_SAVE_REQUESTED), "screen callbacks should include settings save callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_SETTINGS_GALLERY_REQUESTED), "screen callbacks should include settings gallery callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_SETTINGS_TITLE_REQUESTED), "screen callbacks should include settings title callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_ENDING_TITLE_REQUESTED), "screen callbacks should include ending title callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_ENDING_NEW_GAME_REQUESTED), "screen callbacks should include ending new-game callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_SAVE_SLOT_REQUESTED), "screen callbacks should include save-slot callback")
	_expect(callbacks.has(MarketScreenViewConfigScript.CALLBACK_LOAD_SLOT_REQUESTED), "screen callbacks should include load-slot callback")
	_expect(Callable(callbacks.get(MarketScreenViewConfigScript.CALLBACK_FLOW_REQUESTED, Callable())).is_valid(), "screen callbacks should store valid callables")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _noop(_value = null) -> void:
	pass
