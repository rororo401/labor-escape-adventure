extends "res://scripts/tests/test_scene_tree.gd"

const IntroScene := preload("res://scenes/intro/IntroScreen.tscn")
const IntroTitleViewConfigScript := preload("res://scripts/ui/intro_title_view_config.gd")
const MarketSleepSequenceConfigScript := preload("res://scripts/ui/market_sleep_sequence_config.gd")
const ProfileFormConfigScript := preload("res://scripts/ui/profile_form_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)

	var intro := IntroScene.instantiate()
	root.add_child(intro)
	await process_frame
	await process_frame

	var start_button := _helpers.find_node(root, IntroTitleViewConfigScript.START_BUTTON_HIT_AREA_NAME) as Button
	_expect(start_button != null, "fresh editor run should start at the title screen")
	start_button.emit_signal("pressed")

	var profile := await _wait_for_node("ProfileSetupScene", 0.8)
	_expect(profile != null, "title start should open profile setup")
	var name_input := _helpers.find_node(root, ProfileFormConfigScript.NAME_INPUT_NAME) as LineEdit
	var confirm_button := _helpers.find_node(root, ProfileFormConfigScript.CONFIRM_BUTTON_NAME) as Button
	_expect(name_input != null, "profile setup should expose name input")
	_expect(confirm_button != null, "profile setup should expose confirm button")
	name_input.text = "테스트 사용자"
	confirm_button.emit_signal("pressed")

	var prologue := await _wait_for_node("PrologueScene", 0.8)
	_expect(prologue != null, "profile confirmation should open prologue")
	for _index in 24:
		prologue.call("_advance_dialogue")
		await process_frame
		if _helpers.find_node(root, MarketSleepSequenceConfigScript.SLEEP_LAYER_NAME) != null:
			break

	var sleep_layer := await _wait_for_node(MarketSleepSequenceConfigScript.SLEEP_LAYER_NAME, 0.8) as Control
	_expect(sleep_layer != null, "prologue should show the sleep event CG before the first date transition")

	await create_timer(MarketSleepSequenceConfigScript.SLEEP_FADE_IN_DURATION + MarketSleepSequenceConfigScript.SLEEP_HOLD_DURATION + 0.35).timeout
	var transition := await _wait_for_node("DateTransitionLayer", 2.8)
	_expect(transition != null, "prologue should show the first date transition")
	await create_timer(0.8).timeout
	transition.call("continue_now")

	var market := await _wait_for_node("MarketScreen", 0.8)
	_expect(market != null, "fresh run should reach the first market screen")
	var flow_button := _helpers.find_button_containing(market, "1주 매수 필요")
	var buy_button := _helpers.find_node(market, "BuyButton") as Button
	_expect(flow_button != null, "fresh first day should require one share before the event")
	_expect(buy_button != null and not buy_button.disabled, "fresh first day should allow buying")

	buy_button.emit_signal("pressed")
	await process_frame
	await process_frame

	flow_button = _helpers.find_button_containing(market, "회사 출근하기")
	_expect(flow_button != null, "fresh first day should show the work event entry after buying")
	flow_button.emit_signal("pressed")
	await process_frame
	await process_frame

	_expect(_helpers.find_node(root, "FirstDayWorkScene") != null, "fresh run should open the first work event scene")

	print("Fresh run first event flow test passed.")
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
