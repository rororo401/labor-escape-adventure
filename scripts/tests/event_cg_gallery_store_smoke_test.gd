extends "res://scripts/tests/test_scene_tree.gd"

const EventCgGalleryStoreScript := preload("res://scripts/core/event_cg_gallery_store.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const TestAssetPathsScript := preload("res://scripts/tests/test_asset_paths.gd")

const TEST_PATH := "user://event_cg_gallery_store_smoke_test.json"


func _initialize() -> void:
	_remove_test_file()

	var store = EventCgGalleryStoreScript.new()
	store.save_path = TEST_PATH
	var event := {
		DayEventKeysScript.KEY_ID: "night_chimaek",
		DayEventKeysScript.KEY_NAME_KO: "치맥이 땡긴다",
		DayEventKeysScript.KEY_GROUP: "night",
		DayEventKeysScript.KEY_MODE: "auto_trading",
		DayEventKeysScript.KEY_TAGS: ["food"],
		DayEventKeysScript.KEY_CG_PATH: TestAssetPathsScript.HOME_MORNING_BACKGROUND
	}

	var first_result: Dictionary = store.unlock_event_cg(event, TestAssetPathsScript.HOME_MORNING_BACKGROUND, "2016-07-01")
	_expect(bool(first_result.get(EventCgGalleryStoreScript.KEY_OK, false)), "gallery store should unlock an existing CG")
	_expect(store.has_unlocked(TestAssetPathsScript.HOME_MORNING_BACKGROUND), "gallery store should report unlocked CG")

	var second_result: Dictionary = store.unlock_event_cg(event, TestAssetPathsScript.HOME_MORNING_BACKGROUND, "2016-07-02")
	_expect(bool(second_result.get(EventCgGalleryStoreScript.KEY_OK, false)), "gallery store should update an existing CG")
	var entries := store.get_unlocked_entries()
	_expect(entries.size() == 1, "gallery store should dedupe by CG path")
	var entry := entries[0]
	_expect(String(entry.get(EventCgGalleryStoreScript.KEY_NAME_KO, "")) == "치맥이 땡긴다", "gallery entry should keep event name")
	_expect(int(entry.get(EventCgGalleryStoreScript.KEY_SEEN_COUNT, 0)) == 2, "gallery entry should count repeated views")
	_expect(String(entry.get(EventCgGalleryStoreScript.KEY_LAST_SEEN_DATE, "")) == "2016-07-02", "gallery entry should update last seen date")

	var history_result: Dictionary = store.unlock_event_history([{
		DayEventKeysScript.KEY_ID: "history_event",
		DayEventKeysScript.KEY_NAME_KO: "기존 기록",
		DayEventKeysScript.KEY_CG_PATH: TestAssetPathsScript.HOME_PROLOGUE_BACKGROUND
	}])
	_expect(bool(history_result.get(EventCgGalleryStoreScript.KEY_OK, false)), "gallery store should import event history")
	_expect(store.get_unlocked_entries().size() == 2, "gallery store should add existing event history CGs")

	_remove_test_file()
	print("Event CG gallery store smoke test passed.")
	finish_test()


func _remove_test_file() -> void:
	var absolute_path := ProjectSettings.globalize_path(TEST_PATH)
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(absolute_path)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		_remove_test_file()
		fail_test()
