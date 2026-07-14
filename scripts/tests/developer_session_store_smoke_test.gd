extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperDateJumpPanelConfigScript := preload("res://scripts/dev/developer_date_jump_panel_config.gd")
const DeveloperDateJumpPanelScript := preload("res://scripts/dev/developer_date_jump_panel.gd")
const DeveloperSessionStoreScript := preload("res://scripts/dev/developer_session_store.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const TEST_STORE_PATH := "user://developer_session_store.test.cfg"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	if FileAccess.file_exists(TEST_STORE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_STORE_PATH))

	var store = DeveloperSessionStoreScript.new()
	store.store_path = TEST_STORE_PATH
	_expect(store.load_last_jump_date("2016-07-02") == "2016-07-02", "missing developer session should return the default date")
	_expect(not store.save_last_jump_date(""), "developer session should reject empty dates")
	_expect(store.save_last_jump_date("2016-07-03"), "developer session should save the last jump date")
	_expect(store.load_last_jump_date("2016-07-02") == "2016-07-03", "developer session should load the saved jump date")

	var panel := DeveloperDateJumpPanelScript.new()
	root.add_child(panel)
	panel.build(store.load_last_jump_date("2016-07-02"))
	await process_frame
	var input := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.DATE_INPUT_NAME) as LineEdit
	var baseline := _helpers.find_node(panel, DeveloperDateJumpPanelConfigScript.BASELINE_LABEL_NAME) as Label
	_expect(input != null, "developer date jump panel should expose the date input")
	_expect(input.text == "2016-07-03", "developer date jump panel should use the stored jump date")
	_expect(baseline != null and baseline.text.contains("새 게임"), "developer panel should explain the fresh-run baseline")

	panel.queue_free()
	await process_frame
	if FileAccess.file_exists(TEST_STORE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_STORE_PATH))

	print("Developer session store smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
