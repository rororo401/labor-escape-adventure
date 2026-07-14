extends "res://scripts/tests/test_scene_tree.gd"

const ResultPopupLayoutStoreScript := preload("res://scripts/ui/result_popup_layout_store.gd")
const ResultPopupOverlayConfigScript := preload("res://scripts/ui/result_popup_overlay_config.gd")

const TEST_USER_PATH := "user://result_popup_layout_store.test.json"
const TEST_DEFAULT_PATH := "user://result_popup_layout_store.default.test.json"


func _initialize() -> void:
	_remove(TEST_USER_PATH)
	_remove(TEST_DEFAULT_PATH)

	var store = ResultPopupLayoutStoreScript.new()
	store.user_path = TEST_USER_PATH
	store.default_path = TEST_DEFAULT_PATH

	var missing := store.load_layout()
	_expect(int(missing.get(ResultPopupOverlayConfigScript.KEY_ROW_LABEL_X, 0)) == ResultPopupOverlayConfigScript.ROW_LABEL_X, "missing layout should use defaults")
	_expect(int(missing.get(ResultPopupOverlayConfigScript.KEY_ROW_VALUE_X, 0)) == ResultPopupOverlayConfigScript.ROW_VALUE_X, "missing layout should use the shared value start x")

	_write_legacy_layout(TEST_USER_PATH)
	var migrated := store.load_layout()
	_expect(int(migrated.get(ResultPopupOverlayConfigScript.KEY_ROW_VALUE_X, 0)) == ResultPopupOverlayConfigScript.ROW_VALUE_X, "legacy right-aligned value x should migrate to the shared value start x")
	_remove(TEST_USER_PATH)

	var layout := ResultPopupOverlayConfigScript.default_layout()
	layout[ResultPopupOverlayConfigScript.KEY_ROW_LABEL_X] = 244
	layout[ResultPopupOverlayConfigScript.KEY_ROW_Y] = [450, 500, 550, 600, 650, 700, 750]
	_expect(store.save_layout(layout), "layout store should save user override")

	var loaded := store.load_layout()
	_expect(int(loaded.get(ResultPopupOverlayConfigScript.KEY_ROW_LABEL_X, 0)) == 244, "layout store should reload scalar override")
	var row_y: Array = loaded.get(ResultPopupOverlayConfigScript.KEY_ROW_Y, [])
	_expect(row_y.size() == ResultPopupOverlayConfigScript.RESULT_ROW_COUNT, "layout store should preserve row count")
	_expect(int(row_y[6]) == 750, "layout store should reload row y override")

	_remove(TEST_USER_PATH)
	_remove(TEST_DEFAULT_PATH)
	print("Result popup layout store smoke test passed.")
	finish_test()


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _write_legacy_layout(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write legacy layout test fixture")
		fail_test()
		return
	file.store_string(JSON.stringify({
		ResultPopupOverlayConfigScript.KEY_VERSION: 1,
		ResultPopupOverlayConfigScript.KEY_LAYOUT: {
			ResultPopupOverlayConfigScript.KEY_ROW_VALUE_X: 420.0
		}
	}))
	file.close()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
