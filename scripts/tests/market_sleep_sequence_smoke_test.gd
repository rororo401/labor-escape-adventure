extends "res://scripts/tests/test_scene_tree.gd"

const MarketSleepSequenceConfigScript := preload("res://scripts/ui/market_sleep_sequence_config.gd")
const MarketSleepSequenceScript := preload("res://scripts/ui/market_sleep_sequence.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()
var _intro_finished := false


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var sequence = MarketSleepSequenceScript.new()
	root.add_child(sequence)
	sequence.sleep_intro_finished.connect(func() -> void:
		_intro_finished = true
	)
	await process_frame

	await sequence.play_sleep_intro()
	var sleep_layer := _helpers.find_node(sequence, MarketSleepSequenceConfigScript.SLEEP_LAYER_NAME) as Control
	var sleep_cg := _helpers.find_node(sequence, MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_NAME) as TextureRect
	_expect(_intro_finished, "sleep intro should emit finished signal")
	_expect(sequence.size.x > 0.0 and sequence.size.y > 0.0, "sleep sequence should resolve a non-empty viewport or fallback size")
	_expect(sequence.size.y >= MarketSleepSequenceConfigScript.FALLBACK_SIZE.y, "sleep sequence should preserve portrait-height coverage")
	_expect(sleep_layer != null, "sleep event layer should exist")
	_expect(sleep_layer.size.x > 0.0 and sleep_layer.size.y > 0.0, "sleep layer should cover a non-empty area")
	_expect(is_equal_approx(sleep_layer.modulate.a, 1.0), "sleep layer should fade in fully")
	_expect(sleep_cg != null, "sleep event CG should exist")
	_expect(sleep_cg.texture != null, "sleep event CG should load a texture")
	_expect(sleep_cg.size == sleep_layer.size, "sleep event CG should match the full sleep layer size")
	_expect(sleep_cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "sleep event CG should show the full illustration without covered cropping")

	await sequence.cancel_after_error(0.01)
	await process_frame
	_expect(not is_instance_valid(sequence), "sleep sequence should clean itself up after cancel")

	var summer_sequence = MarketSleepSequenceScript.new()
	root.add_child(summer_sequence)
	await process_frame
	await summer_sequence.play_sleep_intro("2016-07-01")
	var summer_cg := _helpers.find_node(summer_sequence, MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_NAME) as TextureRect
	_expect(summer_cg != null and summer_cg.texture != null, "summer sleep event CG should load a texture")
	_expect(
		String(summer_cg.get_meta("source_path", "")) == MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_PATH_SUMMER,
		"summer sleep intro should use the summer CG"
	)
	await summer_sequence.cancel_after_error(0.01)
	await process_frame

	print("Market sleep sequence smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
