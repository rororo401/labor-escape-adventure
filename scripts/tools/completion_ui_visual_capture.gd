extends SceneTree

const ProfileSetupScene := preload("res://scenes/profile/ProfileSetupScene.tscn")
const SaveSlotOverlayScript := preload("res://scripts/ui/save_slot_overlay.gd")
const GameSaveSlotStoreScript := preload("res://scripts/core/save/game_save_slot_store.gd")
const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const LeverageGoddessEventScript := preload("res://scripts/core/dayflow/leverage_goddess_event.gd")
const VisualNovelEventLayerScript := preload("res://scripts/ui/visual_novel_event_layer.gd")

const OUTPUT_DIR := "/tmp/gama_stock_completion_audit"


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	await _capture_profile()
	await _capture_save_slots()
	await _capture_leverage_goddess()
	quit()


func _capture_profile() -> void:
	var scene := ProfileSetupScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	await _save_frame("profile-difficulty.png")
	scene.queue_free()
	await process_frame


func _capture_save_slots() -> void:
	var host := Control.new()
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(host)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("#cba77f")
	host.add_child(background)
	var overlay := SaveSlotOverlayScript.new()
	overlay.build()
	host.add_child(overlay)
	overlay.show_slots([
		_summary(GameSaveSlotStoreScript.SLOT_KIND_MANUAL, 1, "2018-03-12", 24350000, GameSaveKeysScript.DIFFICULTY_NORMAL, 1773300000.0),
		_summary(GameSaveSlotStoreScript.SLOT_KIND_MANUAL, 2, "2021-11-05", 188400000, GameSaveKeysScript.DIFFICULTY_EASY, 1773386400.0),
		_summary(GameSaveSlotStoreScript.SLOT_KIND_AUTO, 1, "2023-08-21", 392700000, GameSaveKeysScript.DIFFICULTY_NORMAL, 1773472800.0)
	])
	await process_frame
	await process_frame
	await _save_frame("save-slots.png")
	host.queue_free()
	await process_frame


func _capture_leverage_goddess() -> void:
	var event := LeverageGoddessEventScript.event()
	var layer := VisualNovelEventLayerScript.new()
	root.add_child(layer)
	layer.play(
		String(event.get("cg_path", "")),
		String(event.get("name_ko", "")),
		PackedStringArray(event.get("dialogue", []))
	)
	await process_frame
	await process_frame
	await _save_frame("leverage-goddess-event.png")
	layer.queue_free()
	await process_frame


func _summary(kind: String, slot_index: int, date: String, net_worth: int, difficulty: String, saved_at: float) -> Dictionary:
	return {
		GameSaveSlotStoreScript.KEY_KIND: kind,
		GameSaveSlotStoreScript.KEY_INDEX: slot_index,
		GameSaveSlotStoreScript.KEY_OCCUPIED: true,
		GameSaveSlotStoreScript.KEY_VALID: true,
		GameSaveSlotStoreScript.KEY_CURRENT_DATE: date,
		GameSaveSlotStoreScript.KEY_NET_WORTH: net_worth,
		GameSaveSlotStoreScript.KEY_DIFFICULTY: difficulty,
		GameSaveSlotStoreScript.KEY_SAVED_AT_UNIX: saved_at
	}


func _save_frame(file_name: String) -> void:
	await process_frame
	await create_timer(0.12).timeout
	await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png(OUTPUT_DIR.path_join(file_name))
	if error != OK:
		push_error("Could not save UI capture: %s" % error)
	else:
		print("Saved UI capture: %s" % OUTPUT_DIR.path_join(file_name))
