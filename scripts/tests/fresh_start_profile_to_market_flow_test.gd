extends "res://scripts/tests/test_scene_tree.gd"

const IntroScene := preload("res://scenes/intro/IntroScreen.tscn")
const IntroTitleViewConfigScript := preload("res://scripts/ui/intro_title_view_config.gd")
const MarketSleepSequenceConfigScript := preload("res://scripts/ui/market_sleep_sequence_config.gd")
const ProfileFormConfigScript := preload("res://scripts/ui/profile_form_config.gd")
const PrologueSceneConfigScript := preload("res://scripts/ui/prologue_scene_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")
const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)

	var intro := IntroScene.instantiate()
	root.add_child(intro)
	await process_frame
	await process_frame

	var start_button := _helpers.find_node(root, IntroTitleViewConfigScript.START_BUTTON_HIT_AREA_NAME) as Button
	_expect(start_button != null, "intro should show the game start button")
	start_button.emit_signal("pressed")

	var profile := await _wait_for_node("ProfileSetupScene", 0.8)
	_expect(profile != null, "start button should open profile setup")

	var name_input := _helpers.find_node(root, ProfileFormConfigScript.NAME_INPUT_NAME) as LineEdit
	var difficulty_option := _helpers.find_node(root, ProfileFormConfigScript.DIFFICULTY_OPTION_NAME) as OptionButton
	var confirm_button := _helpers.find_node(root, ProfileFormConfigScript.CONFIRM_BUTTON_NAME) as Button
	_expect(name_input != null, "profile setup should expose the player name input")
	_expect(confirm_button != null, "profile setup should expose the confirm button")
	_expect(difficulty_option != null, "profile setup should expose difficulty selection")
	name_input.text = "테스트 사용자"
	difficulty_option.select(1)
	confirm_button.emit_signal("pressed")

	var prologue := await _wait_for_node("PrologueScene", 0.6)
	_expect(prologue != null, "profile confirmation should open prologue")

	for _index in 24:
		prologue.call("_advance_dialogue")
		await process_frame
		if _helpers.find_node(root, MarketSleepSequenceConfigScript.SLEEP_LAYER_NAME) != null:
			break

	var sleep_layer := await _wait_for_node(MarketSleepSequenceConfigScript.SLEEP_LAYER_NAME, 0.8) as Control
	_expect(sleep_layer != null, "prologue should show the sleep event CG before the first date transition")
	var sleep_cg := _helpers.find_node(sleep_layer, MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_NAME) as TextureRect
	_expect(sleep_cg != null and sleep_cg.size == sleep_layer.size, "prologue sleep CG should cover the full portrait scene")

	await create_timer(MarketSleepSequenceConfigScript.SLEEP_FADE_IN_DURATION + MarketSleepSequenceConfigScript.SLEEP_HOLD_DURATION + 0.35).timeout
	var transition := await _wait_for_node("DateTransitionLayer", 2.8)
	_expect(transition != null, "prologue should show date transition before market")
	await create_timer(0.8).timeout
	transition.call("continue_now")

	var market := await _wait_for_node("MarketScreen", 0.8)
	_expect(market != null, "fresh start should reach the first market screen")
	var date_label := _helpers.find_node(root, "DateLabel") as Label
	_expect(date_label != null and date_label.text.contains(PrologueSceneConfigScript.FIRST_MARKET_DATE), "first market screen should start on first market date")
	_expect(date_label.text.contains("금요일 아침"), "first market screen should be Friday morning")

	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist after fresh flow")
	var game = game_session.get_game()
	_expect(game.get_today_context().get("date", "") == PrologueSceneConfigScript.FIRST_MARKET_DATE, "GameSession should start the new game on first market date")
	_expect(game.get_total_held_quantity() == 0, "fresh market should start before any purchase")
	_expect(game.difficulty == GameDifficultyScript.EASY, "fresh market should keep the selected difficulty through the prologue")

	print("Fresh start profile-to-market flow test passed.")
	finish_test()


func _wait_for_node(node_name: String, timeout_seconds: float) -> Node:
	var elapsed := 0.0
	while elapsed < timeout_seconds:
		var found := _helpers.find_node(root, node_name)
		if found != null:
			return found
		await process_frame
		elapsed += 1.0 / 60.0
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
