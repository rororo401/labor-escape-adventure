extends "res://scripts/tests/test_scene_tree.gd"

const IntroScene := preload("res://scenes/intro/IntroScreen.tscn")
const IntroScreenConfigScript := preload("res://scripts/ui/intro_screen_config.gd")
const IntroTitleViewConfigScript := preload("res://scripts/ui/intro_title_view_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const TEST_PROGRESS_PATH := "user://intro_continue_saved_game.test.json"
const SAVED_DATE := "2016-07-05"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	_remove_test_progress_file()

	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	game_session.progress_store.save_path = TEST_PROGRESS_PATH
	_expect(game_session.start_new_game(SAVED_DATE), "test should start a saved game")
	_expect(game_session.save_current_game().get("ok", false), "test should save current game")
	game_session.reset()

	var intro := IntroScene.instantiate()
	root.add_child(intro)
	await process_frame
	await process_frame

	var continue_button := _helpers.find_node(root, IntroTitleViewConfigScript.CONTINUE_BUTTON_NAME) as Button
	var continue_image := _helpers.find_node(root, IntroTitleViewConfigScript.CONTINUE_BUTTON_IMAGE_NAME) as TextureRect
	_expect(continue_button != null, "intro should show continue button when saved progress exists")
	_expect(continue_button.text == "", "continue button copy should be baked into the image")
	_expect(continue_image != null and continue_image.texture != null, "continue button should use configured image")

	continue_button.emit_signal("pressed")
	await process_frame
	await process_frame

	_expect(_helpers.find_node(root, "MarketScreen") != null, "continue should open the market scene")
	var loaded_game = game_session.get_game()
	_expect(loaded_game.get_today_context().get("date", "") == SAVED_DATE, "continue should restore saved date")

	_remove_test_progress_file()
	print("Intro continue saved game test passed.")
	finish_test()


func _remove_test_progress_file() -> void:
	if FileAccess.file_exists(TEST_PROGRESS_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PROGRESS_PATH))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
