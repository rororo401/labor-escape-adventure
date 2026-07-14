extends "res://scripts/tests/test_scene_tree.gd"

const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const GameSaveSlotStoreScript := preload("res://scripts/core/save/game_save_slot_store.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")

const TEST_BASE_DIR := "user://game_save_slot_store_test"
const TEST_LEGACY_PATH := "user://game_save_slot_store_legacy_test.json"


func _initialize() -> void:
	_remove_test_dir()
	_remove_legacy_files()
	var store = GameSaveSlotStoreScript.new()
	store.base_dir = TEST_BASE_DIR
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-01", "slot-store"), "slot fixture should set up")

	_expect(store.save_manual(game, 1).get(GameSaveKeysScript.KEY_OK, false), "manual slot 1 should save")
	_set_cash(game, 6100000)
	_expect(store.save_manual(game, 2).get(GameSaveKeysScript.KEY_OK, false), "manual slot 2 should save independently")
	_expect(not store.save_manual(game, 4).get(GameSaveKeysScript.KEY_OK, true), "manual slot outside 1..3 should fail")

	var manual_one := GameStateScript.new()
	_expect(store.load_slot(manual_one, GameSaveSlotStoreScript.SLOT_KIND_MANUAL, 1).get(GameSaveKeysScript.KEY_OK, false), "manual slot 1 should load")
	_expect(manual_one.status.cash == 5000000, "manual slot 1 should retain its original cash")
	var manual_two := GameStateScript.new()
	_expect(store.load_slot(manual_two, GameSaveSlotStoreScript.SLOT_KIND_MANUAL, 2).get(GameSaveKeysScript.KEY_OK, false), "manual slot 2 should load")
	_expect(manual_two.status.cash == 6100000, "manual slot 2 should retain its own cash")

	for cash in [7000000, 8000000, 9000000, 10000000]:
		_set_cash(game, cash)
		_expect(store.save_auto(game).get(GameSaveKeysScript.KEY_OK, false), "auto save should rotate")
	var auto_one := GameStateScript.new()
	var auto_two := GameStateScript.new()
	var auto_three := GameStateScript.new()
	_expect(store.load_slot(auto_one, GameSaveSlotStoreScript.SLOT_KIND_AUTO, 1).get(GameSaveKeysScript.KEY_OK, false), "latest auto slot should load")
	_expect(store.load_slot(auto_two, GameSaveSlotStoreScript.SLOT_KIND_AUTO, 2).get(GameSaveKeysScript.KEY_OK, false), "second auto slot should load")
	_expect(store.load_slot(auto_three, GameSaveSlotStoreScript.SLOT_KIND_AUTO, 3).get(GameSaveKeysScript.KEY_OK, false), "third auto slot should load")
	_expect(auto_one.status.cash == 10000000, "auto slot 1 should be newest")
	_expect(auto_two.status.cash == 9000000, "auto slot 2 should be previous")
	_expect(auto_three.status.cash == 8000000, "auto slot 3 should be oldest retained save")

	_write_text(store.slot_path(GameSaveSlotStoreScript.SLOT_KIND_AUTO, 1), "truncated")
	var newest_backup := store.slot_path(GameSaveSlotStoreScript.SLOT_KIND_AUTO, 1) + ".bak"
	if FileAccess.file_exists(newest_backup):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(newest_backup))
	var recovered_latest := GameStateScript.new()
	var recovered_latest_result := store.load_latest(recovered_latest)
	_expect(recovered_latest_result.get(GameSaveKeysScript.KEY_OK, false), "latest load should skip a corrupt newest slot")
	_expect(recovered_latest.status.cash == 9000000, "latest load should recover from the next valid auto slot")

	var summaries := store.slot_summaries()
	_expect(summaries.size() == 6, "slot store should expose three manual and three auto rows")
	_expect(store.valid_slot_summaries().size() == 4, "corrupt newest auto slot should be excluded from valid summaries")
	_expect(store.has_saved_progress(), "slot store should report valid progress")

	_remove_test_dir()
	var legacy_store = preload("res://scripts/core/save/game_progress_store.gd").new()
	legacy_store.save_path = TEST_LEGACY_PATH
	_set_cash(game, 12300000)
	_expect(legacy_store.save_game(game).get(GameSaveKeysScript.KEY_OK, false), "legacy fixture should save")
	var migrated_store = GameSaveSlotStoreScript.new()
	migrated_store.base_dir = TEST_BASE_DIR
	var migrated := migrated_store.migrate_legacy_save(TEST_LEGACY_PATH)
	_expect(migrated.get(GameSaveKeysScript.KEY_OK, false), "legacy save should migrate")
	_expect(bool(migrated.get("migrated", false)), "legacy migration should report a copied save")
	var migrated_game := GameStateScript.new()
	_expect(migrated_store.load_slot(migrated_game, GameSaveSlotStoreScript.SLOT_KIND_MANUAL, 1).get(GameSaveKeysScript.KEY_OK, false), "migrated manual slot should load")
	_expect(migrated_game.status.cash == 12300000, "migrated manual slot should retain progress")
	_expect(FileAccess.file_exists(TEST_LEGACY_PATH), "legacy source file should remain after verified migration")

	_remove_legacy_files()
	_remove_test_dir()
	print("Game save slot store smoke test passed.")
	finish_test()


func _set_cash(game, cash: int) -> void:
	game.status.cash = cash
	game.market.set_cash_balance(cash)
	game.refresh_status_from_current_phase()


func _remove_test_dir() -> void:
	var absolute := ProjectSettings.globalize_path(TEST_BASE_DIR)
	if not DirAccess.dir_exists_absolute(absolute):
		return
	var dir := DirAccess.open(TEST_BASE_DIR)
	if dir != null:
		for file_name in dir.get_files():
			DirAccess.remove_absolute(absolute.path_join(file_name))
	DirAccess.remove_absolute(absolute)


func _remove_legacy_files() -> void:
	for suffix in ["", ".tmp", ".bak", ".replace_old"]:
		var path := TEST_LEGACY_PATH + String(suffix)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		fail_test()
		return
	file.store_string(text)
	file.close()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		_remove_legacy_files()
		_remove_test_dir()
		fail_test()
