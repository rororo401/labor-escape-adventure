extends Node

const GameStateScript := preload("res://scripts/core/game_state.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const GameProgressStoreScript := preload("res://scripts/core/save/game_progress_store.gd")
const GameSaveSlotStoreScript := preload("res://scripts/core/save/game_save_slot_store.gd")
const EventCgGalleryStoreScript := preload("res://scripts/core/event_cg_gallery_store.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")

var game = GameStateScript.new()
var is_ready := false
var progress_store = GameProgressStoreScript.new()
var slot_store = GameSaveSlotStoreScript.new()
var gallery_store = EventCgGalleryStoreScript.new()
var _legacy_migration_checked := false
var _new_game_difficulty := GameDifficultyScript.DEFAULT


func start_new_game(start_date: String = GameStateScript.DEFAULT_START_DATE) -> bool:
	game = GameStateScript.new()
	is_ready = game.setup(start_date)
	if is_ready:
		game.difficulty = GameDifficultyScript.normalize(_new_game_difficulty)
	return is_ready


func get_game():
	if not is_ready:
		start_new_game()
	return game


func reset() -> void:
	game = GameStateScript.new()
	is_ready = false


func set_new_game_difficulty(difficulty: String) -> void:
	_new_game_difficulty = GameDifficultyScript.normalize(difficulty)


func get_new_game_difficulty() -> String:
	return _new_game_difficulty


func has_saved_progress() -> bool:
	if _uses_progress_path_override():
		return progress_store.has_saved_progress()
	_ensure_legacy_save_migrated()
	return slot_store.has_saved_progress()


func save_current_game() -> Dictionary:
	return save_manual_slot(1)


func save_manual_slot(slot_index: int) -> Dictionary:
	if not is_ready:
		return GameStateGuardResultScript.error(GameStateGuardResultScript.ERROR_GAME_NOT_STARTED)
	if _uses_progress_path_override():
		return progress_store.save_game(game)
	return slot_store.save_manual(game, slot_index)


func auto_save_current_game() -> Dictionary:
	if not is_ready:
		return GameStateGuardResultScript.error(GameStateGuardResultScript.ERROR_GAME_NOT_STARTED)
	if _uses_progress_path_override():
		return progress_store.save_game(game)
	return slot_store.save_auto(game)


func load_saved_game() -> Dictionary:
	if _uses_progress_path_override():
		return _apply_load_result(progress_store.load_game(game))
	_ensure_legacy_save_migrated()
	return _apply_load_result(slot_store.load_latest(game))


func load_save_slot(kind: String, slot_index: int) -> Dictionary:
	if _uses_progress_path_override():
		return _apply_load_result(progress_store.load_game(game))
	_ensure_legacy_save_migrated()
	return _apply_load_result(slot_store.load_slot(game, kind, slot_index))


func get_save_slot_summaries() -> Array[Dictionary]:
	if _uses_progress_path_override():
		return []
	_ensure_legacy_save_migrated()
	return slot_store.slot_summaries()


func _apply_load_result(result: Dictionary) -> Dictionary:
	is_ready = bool(result.get(GameStateGuardResultScript.KEY_OK, false))
	if is_ready:
		sync_event_history_to_gallery()
	return result


func _ensure_legacy_save_migrated() -> void:
	if _legacy_migration_checked:
		return
	_legacy_migration_checked = true
	if slot_store.has_any_slot_file() or not progress_store.has_saved_progress():
		return
	slot_store.migrate_legacy_save(progress_store.save_path)


func _uses_progress_path_override() -> bool:
	return progress_store.save_path != GameProgressStoreScript.DEFAULT_PATH


func unlock_event_cg(event: Dictionary, resolved_cg_path: String, date: String = "") -> Dictionary:
	return gallery_store.unlock_event_cg(event, resolved_cg_path, date)


func get_event_cg_gallery_entries() -> Array[Dictionary]:
	if is_ready:
		sync_event_history_to_gallery()
	return gallery_store.get_unlocked_entries()


func sync_event_history_to_gallery() -> Dictionary:
	return gallery_store.unlock_event_history(game.event_history)
