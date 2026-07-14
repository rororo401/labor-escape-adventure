extends "res://scripts/tests/test_scene_tree.gd"

const StandingCalibratorScene := preload("res://scenes/dev/StandingPositionCalibrator.tscn")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const TEST_USER_PATH := "user://standing_position_overrides.test.json"
const TEST_DEFAULT_PATH := "user://standing_position_overrides.generated.test.json"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	_remove_test_file(TEST_USER_PATH)
	_remove_test_file(TEST_DEFAULT_PATH)

	root.size = Vector2i(720, 1280)
	var scene := StandingCalibratorScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var offset_label := _helpers.find_node(scene, "StandingOffsetLabel") as Label
	var save_label := _helpers.find_node(scene, "StandingSaveLabel") as Label
	var confirm_button := _helpers.find_node(scene, "StandingConfirmButton") as Button
	var character_rect := _helpers.find_node(scene, "CalibratedStandingBust") as TextureRect
	_expect(offset_label != null, "standing calibrator should expose the offset label")
	_expect(save_label != null, "standing calibrator should expose the save label")
	_expect(confirm_button != null, "standing calibrator should expose the confirm button")
	_expect(character_rect != null, "standing calibrator should expose the character rect")
	_expect(character_rect.size.x <= 720.0, "standing calibrator character rect should fit within the viewport width")
	_expect(character_rect.position.x >= -1.0 and character_rect.position.x + character_rect.size.x <= 721.0, "standing calibrator character rect should not overflow horizontally")

	var layout = scene.get("_layout")
	var resolved: Dictionary = scene.get("_current_resolved")
	layout.set_override_paths(TEST_USER_PATH, TEST_DEFAULT_PATH)
	var start_offset: Vector2 = layout.get_offset(resolved)

	await _press_key(scene, KEY_RIGHT)
	await _press_key(scene, KEY_DOWN)
	resolved = scene.get("_current_resolved")
	var moved_offset: Vector2 = layout.get_offset(resolved)
	_expect(moved_offset == start_offset + Vector2(1, 1), "arrow keys should move the selected standing by one pixel")
	_expect(offset_label.text == "x %d  y %d" % [int(moved_offset.x), int(moved_offset.y)], "offset label should reflect keyboard movement")

	await _press_key(scene, KEY_ENTER)
	_expect(FileAccess.file_exists(TEST_USER_PATH), "standing calibrator should save to the configured user override path")
	_expect(FileAccess.file_exists(TEST_DEFAULT_PATH), "standing calibrator should save to the configured generated override path")
	_expect(save_label.text.contains("저장 완료"), "standing calibrator should show a save completion message")
	_expect(save_label.text.contains(TEST_USER_PATH), "standing calibrator save message should include configured user path")

	var saved_text := FileAccess.get_file_as_string(TEST_USER_PATH)
	var parsed = JSON.parse_string(saved_text)
	_expect(typeof(parsed) == TYPE_DICTIONARY, "saved standing override should be valid JSON")
	var key: String = layout.make_key_from_resolved(resolved)
	var saved_offset: Dictionary = parsed.get("offsets", {}).get(key, {})
	_expect(int(saved_offset.get("x", 99999)) == int(moved_offset.x), "saved standing x offset should match moved offset")
	_expect(int(saved_offset.get("y", 99999)) == int(moved_offset.y), "saved standing y offset should match moved offset")

	_remove_test_file(TEST_USER_PATH)
	_remove_test_file(TEST_DEFAULT_PATH)

	print("Standing calibrator behavior test passed.")
	finish_test()


func _press_key(scene: Node, keycode: int) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	event.echo = false
	scene.call("_unhandled_input", event)
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


func _remove_test_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
