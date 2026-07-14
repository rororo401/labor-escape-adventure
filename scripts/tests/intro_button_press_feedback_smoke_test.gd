extends "res://scripts/tests/test_scene_tree.gd"

const IntroScene := preload("res://scenes/intro/IntroScreen.tscn")
const IntroTitleViewConfigScript := preload("res://scripts/ui/intro_title_view_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const TEST_PROGRESS_PATH := "user://intro_button_press_feedback.test.json"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	_remove_test_file()
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	game_session.progress_store.save_path = TEST_PROGRESS_PATH
	_expect(game_session.start_new_game("2016-07-05"), "test should start a game")
	_expect(bool(game_session.save_current_game().get("ok", false)), "test should create continue data")
	game_session.reset()

	var preferences := root.get_node_or_null("GamePreferences")
	var previous_reduced_motion := false
	if preferences != null:
		previous_reduced_motion = bool(preferences.reduced_motion_enabled)
		preferences.reduced_motion_enabled = false

	var intro := IntroScene.instantiate()
	root.add_child(intro)
	await process_frame
	await process_frame

	await _expect_button_feedback(
		_helpers.find_node(intro, IntroTitleViewConfigScript.START_BUTTON_HIT_AREA_NAME) as Button,
		_helpers.find_node(intro, IntroTitleViewConfigScript.START_BUTTON_FRAME_NAME) as Control,
		"start"
	)
	await _expect_button_feedback(
		_helpers.find_node(intro, IntroTitleViewConfigScript.CONTINUE_BUTTON_NAME) as Button,
		_helpers.find_node(intro, IntroTitleViewConfigScript.CONTINUE_BUTTON_FRAME_NAME) as Control,
		"continue"
	)
	await _expect_button_feedback(
		_helpers.find_node(intro, IntroTitleViewConfigScript.GALLERY_BUTTON_NAME) as Button,
		_helpers.find_node(intro, IntroTitleViewConfigScript.GALLERY_BUTTON_FRAME_NAME) as Control,
		"gallery"
	)

	if preferences != null:
		preferences.reduced_motion_enabled = previous_reduced_motion
	_remove_test_file()
	print("Intro button press feedback smoke test passed.")
	finish_test()


func _expect_button_feedback(button: Button, frame: Control, label: String) -> void:
	_expect(button != null, "%s button should exist" % label)
	_expect(frame != null, "%s button frame should exist" % label)
	if button == null or frame == null:
		return
	button.emit_signal("button_down")
	await create_timer(0.05).timeout
	_expect(frame.scale.x < 1.0 and frame.scale.y < 1.0, "%s button should visibly press inward" % label)
	await create_timer(0.25).timeout
	_expect(frame.scale.is_equal_approx(Vector2.ONE), "%s button should return to its original scale" % label)


func _remove_test_file() -> void:
	if FileAccess.file_exists(TEST_PROGRESS_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PROGRESS_PATH))


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
