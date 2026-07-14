extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperSessionStoreScript := preload("res://scripts/dev/developer_session_store.gd")
const IntroScene := preload("res://scenes/intro/IntroScreen.tscn")
const IntroScreenConfigScript := preload("res://scripts/ui/intro_screen_config.gd")
const IntroTitleViewConfigScript := preload("res://scripts/ui/intro_title_view_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const TEST_DEV_SESSION_PATH := "user://intro_developer_quick_launch.test.cfg"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	_remove_test_session_file()
	ProjectSettings.set_setting(IntroScreenConfigScript.DEV_SESSION_STORE_PATH_SETTING, TEST_DEV_SESSION_PATH)
	ProjectSettings.set_setting(IntroScreenConfigScript.SHOW_DEVELOPER_QUICK_LAUNCH_SETTING, false)

	var hidden_intro := IntroScene.instantiate()
	root.add_child(hidden_intro)
	await process_frame
	await process_frame
	_expect(_helpers.find_node(root, IntroTitleViewConfigScript.DEVELOPER_QUICK_BUTTON_NAME) == null, "intro should hide the developer quick launch button by default")
	hidden_intro.queue_free()
	await process_frame

	ProjectSettings.set_setting(IntroScreenConfigScript.SHOW_DEVELOPER_QUICK_LAUNCH_SETTING, true)

	var store = DeveloperSessionStoreScript.new()
	store.store_path = TEST_DEV_SESSION_PATH
	_expect(store.save_last_jump_date(IntroScreenConfigScript.DEFAULT_DEVELOPER_RUN_DATE), "test should save a developer jump date")

	var intro := IntroScene.instantiate()
	root.add_child(intro)
	await process_frame
	await process_frame

	var quick_button := _helpers.find_node(root, IntroTitleViewConfigScript.DEVELOPER_QUICK_BUTTON_NAME) as Button
	_expect(quick_button != null, "intro should show the developer quick launch button when enabled")
	_expect(quick_button.text.contains(IntroScreenConfigScript.DEFAULT_DEVELOPER_RUN_DATE), "developer quick launch should show the stored jump date")

	quick_button.emit_signal("pressed")
	await process_frame
	await process_frame

	_expect(_helpers.find_node(root, "MarketScreen") != null, "developer quick launch should open the market scene")
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	var game = game_session.get_game()
	_expect(game.get_today_context().get("date", "") == IntroScreenConfigScript.DEFAULT_DEVELOPER_RUN_DATE, "developer quick launch should start at the stored date")
	_expect(not bool(game.get_today_context().get("is_trading_day", true)), "stored Saturday date should be a closed day")

	ProjectSettings.set_setting(IntroScreenConfigScript.DEV_SESSION_STORE_PATH_SETTING, "")
	ProjectSettings.set_setting(IntroScreenConfigScript.SHOW_DEVELOPER_QUICK_LAUNCH_SETTING, false)
	_remove_test_session_file()
	print("Intro developer quick launch test passed.")
	finish_test()


func _remove_test_session_file() -> void:
	if FileAccess.file_exists(TEST_DEV_SESSION_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_DEV_SESSION_PATH))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
