class_name MarketScreenViewConfig
extends RefCounted

const UiNodeRefKeysScript := preload("res://scripts/ui/ui_node_ref_keys.gd")

const KEY_BACKGROUND_RECT := UiNodeRefKeysScript.KEY_BACKGROUND_RECT
const KEY_HUD := "hud"
const KEY_STOCK_LIST_PANEL := "stock_list_panel"
const KEY_ORDER_PANEL := "order_panel"
const KEY_CLOSED_DAY_PANEL := "closed_day_panel"
const KEY_STATUS_OVERLAY := "status_overlay"
const KEY_SETTINGS_OVERLAY := "settings_overlay"
const KEY_SAVE_SLOT_OVERLAY := "save_slot_overlay"
const KEY_GALLERY_OVERLAY := "gallery_overlay"
const KEY_ENDING_OVERLAY := "ending_overlay"
const KEY_RESULT_POPUP := "result_popup"
const KEY_MODE_VIEW := "mode_view"

const CALLBACK_STOCK_SELECTED := "stock_selected"
const CALLBACK_QUANTITY_DECREASE_REQUESTED := "quantity_decrease_requested"
const CALLBACK_QUANTITY_INCREASE_REQUESTED := "quantity_increase_requested"
const CALLBACK_ORDER_REQUESTED := "order_requested"
const CALLBACK_DAY_ACTION_SELECTED := "day_action_selected"
const CALLBACK_CATEGORY_SELECTED := "category_selected"
const CALLBACK_ACTION_SELECTED := "action_selected"
const CALLBACK_FLOW_REQUESTED := "flow_requested"
const CALLBACK_MENU_REQUESTED := "menu_requested"
const CALLBACK_SETTINGS_REQUESTED := "settings_requested"
const CALLBACK_SETTINGS_SAVE_REQUESTED := "settings_save_requested"
const CALLBACK_SAVE_SLOT_REQUESTED := "save_slot_requested"
const CALLBACK_LOAD_SLOT_REQUESTED := "load_slot_requested"
const CALLBACK_SETTINGS_GALLERY_REQUESTED := "settings_gallery_requested"
const CALLBACK_SETTINGS_TITLE_REQUESTED := "settings_title_requested"
const CALLBACK_ENDING_TITLE_REQUESTED := "ending_title_requested"
const CALLBACK_ENDING_NEW_GAME_REQUESTED := "ending_new_game_requested"


static func screen_callbacks(
	stock_selected: Callable,
	quantity_decrease_requested: Callable,
	quantity_increase_requested: Callable,
	order_requested: Callable,
	day_action_selected: Callable,
	category_selected: Callable,
	action_selected: Callable,
	flow_requested: Callable,
	menu_requested: Callable = Callable(),
	settings_requested: Callable = Callable(),
	settings_save_requested: Callable = Callable(),
	settings_gallery_requested: Callable = Callable(),
	settings_title_requested: Callable = Callable(),
	ending_title_requested: Callable = Callable(),
	ending_new_game_requested: Callable = Callable(),
	save_slot_requested: Callable = Callable(),
	load_slot_requested: Callable = Callable()
) -> Dictionary:
	return {
		CALLBACK_STOCK_SELECTED: stock_selected,
		CALLBACK_QUANTITY_DECREASE_REQUESTED: quantity_decrease_requested,
		CALLBACK_QUANTITY_INCREASE_REQUESTED: quantity_increase_requested,
		CALLBACK_ORDER_REQUESTED: order_requested,
		CALLBACK_DAY_ACTION_SELECTED: day_action_selected,
		CALLBACK_CATEGORY_SELECTED: category_selected,
		CALLBACK_ACTION_SELECTED: action_selected,
		CALLBACK_FLOW_REQUESTED: flow_requested,
		CALLBACK_MENU_REQUESTED: menu_requested,
		CALLBACK_SETTINGS_REQUESTED: settings_requested,
		CALLBACK_SETTINGS_SAVE_REQUESTED: settings_save_requested,
		CALLBACK_SETTINGS_GALLERY_REQUESTED: settings_gallery_requested,
		CALLBACK_SETTINGS_TITLE_REQUESTED: settings_title_requested,
		CALLBACK_ENDING_TITLE_REQUESTED: ending_title_requested,
		CALLBACK_ENDING_NEW_GAME_REQUESTED: ending_new_game_requested,
		CALLBACK_SAVE_SLOT_REQUESTED: save_slot_requested,
		CALLBACK_LOAD_SLOT_REQUESTED: load_slot_requested
	}
