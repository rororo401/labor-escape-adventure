extends "res://scripts/tests/test_scene_tree.gd"

const MarketScreenViewScript := preload("res://scripts/ui/market_screen_view.gd")
const MarketScreenViewConfigScript := preload("res://scripts/ui/market_screen_view_config.gd")
const MarketScreenConfigScript := preload("res://scripts/ui/market_screen_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()
var _sink := CallbackSink.new()


class CallbackSink:
	extends RefCounted

	var selected_ticker := ""
	var category_id := ""
	var action_id := ""
	var order_side := ""
	var day_action_index := -1
	var quantity_decrease_count := 0
	var quantity_increase_count := 0
	var flow_count := 0
	var menu_count := 0
	var settings_count := 0
	var settings_save_count := 0
	var settings_gallery_count := 0
	var settings_title_count := 0
	var ending_title_count := 0
	var ending_new_game_count := 0
	var save_slot_kind := ""
	var save_slot_index := 0
	var load_slot_kind := ""
	var load_slot_index := 0

	func on_stock_selected(ticker: String) -> void:
		selected_ticker = ticker

	func on_quantity_decrease_requested() -> void:
		quantity_decrease_count += 1

	func on_quantity_increase_requested() -> void:
		quantity_increase_count += 1

	func on_order_requested(side: String) -> void:
		order_side = side

	func on_day_action_selected(index: int) -> void:
		day_action_index = index

	func on_category_selected(next_category_id: String) -> void:
		category_id = next_category_id

	func on_action_selected(next_action_id: String) -> void:
		action_id = next_action_id

	func on_flow_requested() -> void:
		flow_count += 1

	func on_menu_requested() -> void:
		menu_count += 1

	func on_settings_requested() -> void:
		settings_count += 1

	func on_settings_save_requested() -> void:
		settings_save_count += 1

	func on_settings_gallery_requested() -> void:
		settings_gallery_count += 1

	func on_settings_title_requested() -> void:
		settings_title_count += 1

	func on_ending_title_requested() -> void:
		ending_title_count += 1

	func on_ending_new_game_requested() -> void:
		ending_new_game_count += 1

	func on_save_slot_requested(kind: String, slot_index: int) -> void:
		save_slot_kind = kind
		save_slot_index = slot_index

	func on_load_slot_requested(kind: String, slot_index: int) -> void:
		load_slot_kind = kind
		load_slot_index = slot_index


func _initialize() -> void:
	var host := Control.new()
	root.add_child(host)
	var nodes: Dictionary = MarketScreenViewScript.build(host, MarketScreenConfigScript.MARKET_BACKGROUND_PATH, {
		MarketScreenViewConfigScript.CALLBACK_STOCK_SELECTED: _sink.on_stock_selected,
		MarketScreenViewConfigScript.CALLBACK_QUANTITY_DECREASE_REQUESTED: _sink.on_quantity_decrease_requested,
		MarketScreenViewConfigScript.CALLBACK_QUANTITY_INCREASE_REQUESTED: _sink.on_quantity_increase_requested,
		MarketScreenViewConfigScript.CALLBACK_ORDER_REQUESTED: _sink.on_order_requested,
		MarketScreenViewConfigScript.CALLBACK_DAY_ACTION_SELECTED: _sink.on_day_action_selected,
		MarketScreenViewConfigScript.CALLBACK_CATEGORY_SELECTED: _sink.on_category_selected,
		MarketScreenViewConfigScript.CALLBACK_ACTION_SELECTED: _sink.on_action_selected,
		MarketScreenViewConfigScript.CALLBACK_FLOW_REQUESTED: _sink.on_flow_requested,
		MarketScreenViewConfigScript.CALLBACK_MENU_REQUESTED: _sink.on_menu_requested,
		MarketScreenViewConfigScript.CALLBACK_SETTINGS_REQUESTED: _sink.on_settings_requested,
		MarketScreenViewConfigScript.CALLBACK_SETTINGS_SAVE_REQUESTED: _sink.on_settings_save_requested,
		MarketScreenViewConfigScript.CALLBACK_SETTINGS_GALLERY_REQUESTED: _sink.on_settings_gallery_requested,
		MarketScreenViewConfigScript.CALLBACK_SETTINGS_TITLE_REQUESTED: _sink.on_settings_title_requested,
		MarketScreenViewConfigScript.CALLBACK_ENDING_TITLE_REQUESTED: _sink.on_ending_title_requested,
		MarketScreenViewConfigScript.CALLBACK_ENDING_NEW_GAME_REQUESTED: _sink.on_ending_new_game_requested,
		MarketScreenViewConfigScript.CALLBACK_SAVE_SLOT_REQUESTED: _sink.on_save_slot_requested,
		MarketScreenViewConfigScript.CALLBACK_LOAD_SLOT_REQUESTED: _sink.on_load_slot_requested
	})
	await process_frame

	_expect(nodes.get(MarketScreenViewConfigScript.KEY_BACKGROUND_RECT) != null, "market screen view should expose background")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_HUD) != null, "market screen view should expose HUD")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_STOCK_LIST_PANEL) != null, "market screen view should expose stock list")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_ORDER_PANEL) != null, "market screen view should expose order panel")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_CLOSED_DAY_PANEL) != null, "market screen view should expose closed-day panel")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_STATUS_OVERLAY) != null, "market screen view should expose status overlay")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_SETTINGS_OVERLAY) != null, "market screen view should expose settings overlay")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_SAVE_SLOT_OVERLAY) != null, "market screen view should expose save-slot overlay")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_GALLERY_OVERLAY) != null, "market screen view should expose gallery overlay")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_ENDING_OVERLAY) != null, "market screen view should expose ending overlay")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_RESULT_POPUP) != null, "market screen view should expose result popup")
	_expect(nodes.get(MarketScreenViewConfigScript.KEY_MODE_VIEW) != null, "market screen view should expose mode view")
	_expect(_helpers.find_node(host, "MarketBackground") != null, "market screen view should add background node")
	_expect(_helpers.find_node(host, "StockListPanel") != null, "market screen view should add stock list node")
	_expect(_helpers.find_node(host, "OrderPanel") != null, "market screen view should add order panel node")
	_expect(_helpers.find_node(host, "ClosedDayPanel") != null, "market screen view should add closed-day node")
	_expect(_helpers.find_node(host, "MarketSettingsOverlay") != null, "market screen view should add settings overlay node")
	_expect(_helpers.find_node(host, "SaveSlotOverlay") != null, "market screen view should add save-slot overlay node")
	_expect(_helpers.find_node(host, "EventCgGalleryOverlay") != null, "market screen view should add gallery overlay node")
	_expect(_helpers.find_node(host, "EndingOverlay") != null, "market screen view should add ending overlay node")

	var stock_list = nodes.get(MarketScreenViewConfigScript.KEY_STOCK_LIST_PANEL)
	stock_list.stock_selected.emit("005930")
	var hud = nodes.get(MarketScreenViewConfigScript.KEY_HUD)
	hud.menu_requested.emit()
	hud.settings_requested.emit()
	var order_panel = nodes.get(MarketScreenViewConfigScript.KEY_ORDER_PANEL)
	order_panel.quantity_decrease_requested.emit()
	order_panel.quantity_increase_requested.emit()
	order_panel.order_requested.emit("buy")
	order_panel.day_action_selected.emit(2)
	order_panel.flow_requested.emit()
	var closed_day_panel = nodes.get(MarketScreenViewConfigScript.KEY_CLOSED_DAY_PANEL)
	closed_day_panel.category_selected.emit("go_out")
	closed_day_panel.action_selected.emit("part_time")
	closed_day_panel.flow_requested.emit()
	var settings_overlay = nodes.get(MarketScreenViewConfigScript.KEY_SETTINGS_OVERLAY)
	settings_overlay.save_slots_requested.emit()
	settings_overlay.gallery_requested.emit()
	settings_overlay.title_requested.emit()
	var save_slot_overlay = nodes.get(MarketScreenViewConfigScript.KEY_SAVE_SLOT_OVERLAY)
	save_slot_overlay.save_requested.emit("manual", 2)
	save_slot_overlay.load_requested.emit("auto", 3)
	var ending_overlay = nodes.get(MarketScreenViewConfigScript.KEY_ENDING_OVERLAY)
	ending_overlay.title_requested.emit()
	ending_overlay.new_game_requested.emit()

	_expect(_sink.selected_ticker == "005930", "stock selected callback should be connected")
	_expect(_sink.quantity_decrease_count == 1, "quantity decrease callback should be connected")
	_expect(_sink.quantity_increase_count == 1, "quantity increase callback should be connected")
	_expect(_sink.order_side == "buy", "order callback should be connected")
	_expect(_sink.day_action_index == 2, "day action callback should be connected")
	_expect(_sink.category_id == "go_out", "category callback should be connected")
	_expect(_sink.action_id == "part_time", "action callback should be connected")
	_expect(_sink.flow_count == 2, "flow callbacks from both panels should be connected")
	_expect(_sink.menu_count == 1, "menu callback should be connected")
	_expect(_sink.settings_count == 1, "settings callback should be connected")
	_expect(_sink.settings_save_count == 1, "settings save callback should be connected")
	_expect(_sink.settings_gallery_count == 1, "settings gallery callback should be connected")
	_expect(_sink.settings_title_count == 1, "settings title callback should be connected")
	_expect(_sink.ending_title_count == 1, "ending title callback should be connected")
	_expect(_sink.ending_new_game_count == 1, "ending new-game callback should be connected")
	_expect(_sink.save_slot_kind == "manual" and _sink.save_slot_index == 2, "save-slot callback should be connected")
	_expect(_sink.load_slot_kind == "auto" and _sink.load_slot_index == 3, "load-slot callback should be connected")

	print("Market screen view smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
