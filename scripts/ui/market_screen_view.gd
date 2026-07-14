class_name MarketScreenView
extends RefCounted

const ClosedDayPanelScript := preload("res://scripts/ui/closed_day_panel.gd")
const MarketHudScript := preload("res://scripts/ui/market_hud.gd")
const MarketModeViewScript := preload("res://scripts/ui/market_mode_view.gd")
const MarketOrderPanelScript := preload("res://scripts/ui/market_order_panel.gd")
const EndingOverlayScript := preload("res://scripts/ui/ending_overlay.gd")
const ResultPopupOverlayScript := preload("res://scripts/ui/result_popup_overlay.gd")
const MarketScreenViewConfigScript := preload("res://scripts/ui/market_screen_view_config.gd")
const MarketStockListPanelScript := preload("res://scripts/ui/market_stock_list_panel.gd")
const MarketSettingsOverlayScript := preload("res://scripts/ui/market_settings_overlay.gd")
const SaveSlotOverlayScript := preload("res://scripts/ui/save_slot_overlay.gd")
const EventCgGalleryOverlayScript := preload("res://scripts/ui/event_cg_gallery_overlay.gd")
const StatusMenuOverlayScript := preload("res://scripts/ui/status_menu_overlay.gd")


static func build(parent: Control, background_path: String, callbacks: Dictionary = {}) -> Dictionary:
	var mode_view = MarketModeViewScript.new()
	var background_rect := mode_view.build_background(parent, background_path)
	var hud = _add_hud(parent, callbacks)
	var stock_list_panel = _add_stock_list(parent, callbacks)
	var order_panel = _add_order_panel(parent, callbacks)
	var closed_day_panel = _add_closed_day_panel(parent, callbacks)
	var status_overlay = _add_status_overlay(parent)
	var settings_overlay = _add_settings_overlay(parent, callbacks)
	var save_slot_overlay = _add_save_slot_overlay(parent, callbacks)
	var gallery_overlay = _add_gallery_overlay(parent)
	var result_popup = _add_result_popup(parent)
	var ending_overlay = _add_ending_overlay(parent, callbacks)
	mode_view.set_panels(
		[stock_list_panel, order_panel],
		[closed_day_panel]
	)
	return {
		MarketScreenViewConfigScript.KEY_BACKGROUND_RECT: background_rect,
		MarketScreenViewConfigScript.KEY_HUD: hud,
		MarketScreenViewConfigScript.KEY_STOCK_LIST_PANEL: stock_list_panel,
		MarketScreenViewConfigScript.KEY_ORDER_PANEL: order_panel,
		MarketScreenViewConfigScript.KEY_CLOSED_DAY_PANEL: closed_day_panel,
		MarketScreenViewConfigScript.KEY_STATUS_OVERLAY: status_overlay,
		MarketScreenViewConfigScript.KEY_SETTINGS_OVERLAY: settings_overlay,
		MarketScreenViewConfigScript.KEY_SAVE_SLOT_OVERLAY: save_slot_overlay,
		MarketScreenViewConfigScript.KEY_GALLERY_OVERLAY: gallery_overlay,
		MarketScreenViewConfigScript.KEY_ENDING_OVERLAY: ending_overlay,
		MarketScreenViewConfigScript.KEY_RESULT_POPUP: result_popup,
		MarketScreenViewConfigScript.KEY_MODE_VIEW: mode_view
	}


static func _add_hud(parent: Control, callbacks: Dictionary):
	var hud = MarketHudScript.new()
	hud.build()
	_connect_if_valid(hud.menu_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_MENU_REQUESTED, Callable()))
	_connect_if_valid(hud.settings_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_SETTINGS_REQUESTED, Callable()))
	parent.add_child(hud)
	return hud


static func _add_stock_list(parent: Control, callbacks: Dictionary):
	var stock_list_panel = MarketStockListPanelScript.new()
	stock_list_panel.build()
	_connect_if_valid(stock_list_panel.stock_selected, callbacks.get(MarketScreenViewConfigScript.CALLBACK_STOCK_SELECTED, Callable()))
	parent.add_child(stock_list_panel)
	return stock_list_panel


static func _add_order_panel(parent: Control, callbacks: Dictionary):
	var order_panel = MarketOrderPanelScript.new()
	order_panel.build()
	_connect_if_valid(order_panel.quantity_decrease_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_QUANTITY_DECREASE_REQUESTED, Callable()))
	_connect_if_valid(order_panel.quantity_increase_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_QUANTITY_INCREASE_REQUESTED, Callable()))
	_connect_if_valid(order_panel.order_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_ORDER_REQUESTED, Callable()))
	_connect_if_valid(order_panel.day_action_selected, callbacks.get(MarketScreenViewConfigScript.CALLBACK_DAY_ACTION_SELECTED, Callable()))
	_connect_if_valid(order_panel.flow_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_FLOW_REQUESTED, Callable()))
	parent.add_child(order_panel)
	return order_panel


static func _add_closed_day_panel(parent: Control, callbacks: Dictionary):
	var closed_day_panel = ClosedDayPanelScript.new()
	closed_day_panel.build()
	_connect_if_valid(closed_day_panel.category_selected, callbacks.get(MarketScreenViewConfigScript.CALLBACK_CATEGORY_SELECTED, Callable()))
	_connect_if_valid(closed_day_panel.action_selected, callbacks.get(MarketScreenViewConfigScript.CALLBACK_ACTION_SELECTED, Callable()))
	_connect_if_valid(closed_day_panel.flow_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_FLOW_REQUESTED, Callable()))
	parent.add_child(closed_day_panel)
	return closed_day_panel


static func _add_status_overlay(parent: Control):
	var status_overlay = StatusMenuOverlayScript.new()
	status_overlay.build()
	parent.add_child(status_overlay)
	return status_overlay


static func _add_settings_overlay(parent: Control, callbacks: Dictionary):
	var settings_overlay = MarketSettingsOverlayScript.new()
	settings_overlay.build()
	_connect_if_valid(settings_overlay.save_slots_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_SETTINGS_SAVE_REQUESTED, Callable()))
	_connect_if_valid(settings_overlay.gallery_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_SETTINGS_GALLERY_REQUESTED, Callable()))
	_connect_if_valid(settings_overlay.title_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_SETTINGS_TITLE_REQUESTED, Callable()))
	parent.add_child(settings_overlay)
	return settings_overlay


static func _add_save_slot_overlay(parent: Control, callbacks: Dictionary):
	var overlay = SaveSlotOverlayScript.new()
	overlay.build()
	_connect_if_valid(overlay.save_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_SAVE_SLOT_REQUESTED, Callable()))
	_connect_if_valid(overlay.load_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_LOAD_SLOT_REQUESTED, Callable()))
	parent.add_child(overlay)
	return overlay


static func _add_gallery_overlay(parent: Control):
	var gallery_overlay = EventCgGalleryOverlayScript.new()
	gallery_overlay.build()
	parent.add_child(gallery_overlay)
	return gallery_overlay


static func _add_result_popup(parent: Control):
	var result_popup = ResultPopupOverlayScript.new()
	result_popup.build()
	parent.add_child(result_popup)
	return result_popup


static func _add_ending_overlay(parent: Control, callbacks: Dictionary):
	var ending_overlay = EndingOverlayScript.new()
	ending_overlay.build()
	_connect_if_valid(ending_overlay.title_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_ENDING_TITLE_REQUESTED, Callable()))
	_connect_if_valid(ending_overlay.new_game_requested, callbacks.get(MarketScreenViewConfigScript.CALLBACK_ENDING_NEW_GAME_REQUESTED, Callable()))
	parent.add_child(ending_overlay)
	return ending_overlay


static func _connect_if_valid(signal_value: Signal, callback: Callable) -> void:
	if callback.is_valid():
		signal_value.connect(callback)
