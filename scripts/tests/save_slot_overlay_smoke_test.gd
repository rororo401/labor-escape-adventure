extends "res://scripts/tests/test_scene_tree.gd"

const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const GameSaveSlotStoreScript := preload("res://scripts/core/save/game_save_slot_store.gd")
const SaveSlotOverlayConfigScript := preload("res://scripts/ui/save_slot_overlay_config.gd")
const SaveSlotOverlayScript := preload("res://scripts/ui/save_slot_overlay.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()
var _saved_kind := ""
var _saved_index := 0
var _loaded_kind := ""
var _loaded_index := 0


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var overlay := SaveSlotOverlayScript.new()
	overlay.build()
	overlay.save_requested.connect(_on_save_requested)
	overlay.load_requested.connect(_on_load_requested)
	root.add_child(overlay)
	await process_frame

	_expect(not overlay.visible, "save-slot overlay should start hidden")
	overlay.show_slots([
		_summary(GameSaveSlotStoreScript.SLOT_KIND_MANUAL, 1, true, true),
		_summary(GameSaveSlotStoreScript.SLOT_KIND_MANUAL, 2, true, false)
	])
	_expect(overlay.visible, "show_slots should display the overlay")
	_expect(_helpers.find_node(overlay, SaveSlotOverlayConfigScript.PANEL_NAME) != null, "save-slot overlay should render a panel")

	var manual_one_summary := _helpers.find_node(overlay, "Manual1Summary") as Label
	var manual_one_save := _helpers.find_node(overlay, "Manual1SaveButton") as Button
	var manual_one_load := _helpers.find_node(overlay, "Manual1LoadButton") as Button
	var manual_two_load := _helpers.find_node(overlay, "Manual2LoadButton") as Button
	var auto_one_load := _helpers.find_node(overlay, "Auto1LoadButton") as Button
	var manual_three_save := _helpers.find_node(overlay, "Manual3SaveButton") as Button
	var confirm_layer := _helpers.find_node(overlay, SaveSlotOverlayConfigScript.CONFIRM_LAYER_NAME) as Control
	var confirm_cancel := _helpers.find_node(overlay, SaveSlotOverlayConfigScript.CONFIRM_CANCEL_BUTTON_NAME) as Button
	var confirm_accept := _helpers.find_node(overlay, SaveSlotOverlayConfigScript.CONFIRM_ACCEPT_BUTTON_NAME) as Button
	_expect(manual_one_summary != null and manual_one_summary.text.contains("노멀"), "valid slot should show saved difficulty")
	_expect(manual_one_summary.text.contains("순자산"), "valid slot should show net worth")
	_expect(manual_one_save != null, "manual slot should have a save button")
	_expect(manual_one_load != null and not manual_one_load.disabled, "valid manual slot should be loadable")
	_expect(manual_two_load != null and manual_two_load.disabled, "invalid slot should not be loadable")
	_expect(auto_one_load != null and auto_one_load.disabled, "empty auto slot should not be loadable")
	_expect(_helpers.find_node(overlay, "Auto1SaveButton") == null, "auto slot should not expose a manual save button")

	manual_one_save.emit_signal("pressed")
	_expect(_saved_index == 0 and confirm_layer.visible, "occupied save slot should require confirmation")
	_expect(confirm_accept.text == SaveSlotOverlayConfigScript.CONFIRM_OVERWRITE_TEXT, "overwrite confirmation should use explicit action copy")
	confirm_cancel.emit_signal("pressed")
	_expect(_saved_index == 0 and not confirm_layer.visible, "cancel should preserve the existing save")
	manual_one_save.emit_signal("pressed")
	confirm_accept.emit_signal("pressed")
	_expect(_saved_kind == GameSaveSlotStoreScript.SLOT_KIND_MANUAL and _saved_index == 1, "confirmed overwrite should identify its slot")

	manual_three_save.emit_signal("pressed")
	_expect(_saved_index == 3 and not confirm_layer.visible, "empty manual slot should save immediately")

	manual_one_load.emit_signal("pressed")
	_expect(_loaded_index == 0 and confirm_layer.visible, "load should require confirmation")
	_expect(confirm_accept.text == SaveSlotOverlayConfigScript.CONFIRM_LOAD_TEXT, "load confirmation should use explicit action copy")
	confirm_accept.emit_signal("pressed")
	_expect(_loaded_kind == GameSaveSlotStoreScript.SLOT_KIND_MANUAL and _loaded_index == 1, "confirmed load should identify its slot")

	var close_button := _helpers.find_node(overlay, SaveSlotOverlayConfigScript.CLOSE_BUTTON_NAME) as Button
	close_button.emit_signal("pressed")
	_expect(not overlay.visible, "close button should hide the save-slot overlay")

	print("Save slot overlay smoke test passed.")
	finish_test()


func _summary(kind: String, slot_index: int, occupied: bool, valid: bool) -> Dictionary:
	return {
		GameSaveSlotStoreScript.KEY_KIND: kind,
		GameSaveSlotStoreScript.KEY_INDEX: slot_index,
		GameSaveSlotStoreScript.KEY_OCCUPIED: occupied,
		GameSaveSlotStoreScript.KEY_VALID: valid,
		GameSaveSlotStoreScript.KEY_CURRENT_DATE: "2018-03-12",
		GameSaveSlotStoreScript.KEY_NET_WORTH: 12000000,
		GameSaveSlotStoreScript.KEY_DIFFICULTY: GameSaveKeysScript.DIFFICULTY_NORMAL,
		GameSaveSlotStoreScript.KEY_SAVED_AT_UNIX: 1700000000.5
	}


func _on_save_requested(kind: String, slot_index: int) -> void:
	_saved_kind = kind
	_saved_index = slot_index


func _on_load_requested(kind: String, slot_index: int) -> void:
	_loaded_kind = kind
	_loaded_index = slot_index


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
