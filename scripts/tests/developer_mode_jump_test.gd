extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperDateJumpPanelConfigScript := preload("res://scripts/dev/developer_date_jump_panel_config.gd")
const DeveloperDayActionPreviewPanelConfigScript := preload("res://scripts/dev/developer_day_action_preview_panel_config.gd")
const DeveloperModeSceneConfigScript := preload("res://scripts/dev/developer_mode_scene_config.gd")
const DeveloperModeScene := preload("res://scenes/dev/DeveloperModeScene.tscn")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const TEST_DEV_SESSION_PATH := "user://developer_mode_jump_session.test.cfg"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	ProjectSettings.set_setting(DeveloperModeSceneConfigScript.DEV_SESSION_STORE_PATH_SETTING, TEST_DEV_SESSION_PATH)
	_remove_test_session_file()
	await _assert_invalid_date_message()
	await _assert_day_action_preview()
	await _assert_standing_calibrator_jump()
	await _assert_date_jump(DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_BUTTON_NAME, DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_DATE, true)
	await _assert_date_jump(DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_BUTTON_NAME, DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_DATE, false)
	await _assert_input_date_jump("2016-07-03", false)

	_remove_test_session_file()
	ProjectSettings.set_setting(DeveloperModeSceneConfigScript.DEV_SESSION_STORE_PATH_SETTING, "")
	print("Developer mode jump test passed.")
	finish_test()


func _assert_invalid_date_message() -> void:
	var scene: Control = await _new_scene()
	var input := _helpers.find_node(scene, DeveloperDateJumpPanelConfigScript.DATE_INPUT_NAME) as LineEdit
	var button := _helpers.find_node(scene, DeveloperDateJumpPanelConfigScript.DATE_BUTTON_NAME) as Button
	var message := _helpers.find_node(scene, DeveloperModeSceneConfigScript.MESSAGE_LABEL_NAME) as Label
	_expect(input != null, "developer date input should exist")
	_expect(button != null, "developer date jump button should exist")
	_expect(message != null, "developer message label should exist")
	input.text = ""
	button.emit_signal("pressed")
	await process_frame
	_expect(message.text.contains("날짜를 입력"), "empty developer jump should show an error")
	scene.queue_free()
	await process_frame


func _assert_day_action_preview() -> void:
	var scene: Control = await _new_scene()
	var option := _helpers.find_node(scene, DeveloperDayActionPreviewPanelConfigScript.PREVIEW_OPTION_NAME) as OptionButton
	var preview_button := _helpers.find_node(scene, String(Dictionary(DeveloperDayActionPreviewPanelConfigScript.QUICK_PREVIEWS[0]).get("button_name", ""))) as Button
	var message := _helpers.find_node(scene, DeveloperModeSceneConfigScript.MESSAGE_LABEL_NAME) as Label
	_expect(option != null, "developer action preview option should exist")
	_expect(option.item_count > 0, "developer action preview option should include closed-day events")
	_expect(preview_button != null, "developer part-time preview button should exist")
	_expect(message != null, "developer message label should exist")

	preview_button.emit_signal("pressed")
	await process_frame
	await process_frame
	_expect(_helpers.find_node(scene, "DayEventCgLayer") != null, "developer action preview should show the VN event layer")
	_expect(_helpers.find_node(scene, "EventCG") != null, "developer action preview should show event CG")
	_expect(_helpers.find_node(scene, "EventDialogue") != null, "developer action preview should show event dialogue")
	_expect(message.text.contains("알바"), "developer action preview should update the message")
	_clear_current_scene()
	await process_frame


func _assert_standing_calibrator_jump() -> void:
	var scene: Control = await _new_scene()
	var button := _helpers.find_node(scene, DeveloperDateJumpPanelConfigScript.STANDING_BUTTON_NAME) as Button
	_expect(button != null, "developer standing calibrator button should exist")
	button.emit_signal("pressed")
	await process_frame
	await process_frame
	_expect(_helpers.find_node(root, "StandingPositionCalibrator") != null, "developer standing calibrator button should open the calibrator")
	_expect(_helpers.find_node(root, "CalibrationPanel") != null, "standing calibrator should show its control panel")
	_clear_current_scene()
	await process_frame


func _assert_date_jump(button_name: String, expected_date: String, expected_market_open: bool) -> void:
	var scene: Control = await _new_scene()
	var button := _helpers.find_node(scene, button_name) as Button
	_expect(button != null, "%s should exist" % button_name)
	button.emit_signal("pressed")
	await process_frame
	await process_frame
	_expect(_helpers.find_node(root, "MarketScreen") != null, "developer jump should change to MarketScreen")
	_assert_session_date(expected_date, expected_market_open)
	_clear_current_scene()
	await process_frame


func _assert_input_date_jump(date: String, expected_market_open: bool) -> void:
	var scene: Control = await _new_scene()
	var input := _helpers.find_node(scene, DeveloperDateJumpPanelConfigScript.DATE_INPUT_NAME) as LineEdit
	var button := _helpers.find_node(scene, DeveloperDateJumpPanelConfigScript.DATE_BUTTON_NAME) as Button
	_expect(input != null, "developer date input should exist")
	_expect(button != null, "developer date jump button should exist")
	input.text = date
	button.emit_signal("pressed")
	await process_frame
	await process_frame
	_expect(_helpers.find_node(root, "MarketScreen") != null, "developer input jump should change to MarketScreen")
	_assert_session_date(date, expected_market_open)
	_clear_current_scene()
	await process_frame


func _new_scene() -> Control:
	_clear_current_scene()
	await process_frame
	var scene := DeveloperModeScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	return scene


func _clear_current_scene() -> void:
	for child in root.get_children():
		if child.name != "GameSession":
			child.queue_free()


func _remove_test_session_file() -> void:
	if FileAccess.file_exists(TEST_DEV_SESSION_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_DEV_SESSION_PATH))


func _assert_session_date(expected_date: String, expected_market_open: bool) -> void:
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	var game = game_session.get_game()
	var today: Dictionary = game.get_today_context()
	_expect(today.get("date", "") == expected_date, "developer jump should start %s" % expected_date)
	_expect(bool(today.get("is_trading_day", false)) == expected_market_open, "developer jump market-open state mismatch")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
