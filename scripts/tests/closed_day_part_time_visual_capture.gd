extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketScene := preload("res://scenes/market/MarketScreen.tscn")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")
const OUTPUT_PATH := "res://assets/previews/part_time_event_capture.png"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var game_session := _helpers.get_game_session(root)
	if game_session == null:
		push_error("GameSession autoload should exist")
		fail_test()
		return

	game_session.start_new_game(_helpers.find_closed_date_with_choice(GameStateScript.new(), "go_out", "part_time", "2016-07-02"))
	var scene := MarketScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	scene.call("_select_closed_day_category", "go_out")
	await process_frame
	var choice_grid := _helpers.find_node(scene, "ClosedDayChoiceGrid")
	var part_time_button := _helpers.find_button_containing(choice_grid, "알바")
	if part_time_button == null:
		push_error("Could not find part-time button")
		fail_test()
		return

	part_time_button.emit_signal("pressed")
	await create_timer(0.5).timeout
	await process_frame
	await process_frame

	var event_layer := _helpers.find_node(scene, "DayEventCgLayer")
	if event_layer == null:
		push_error("Part-time event layer was not shown")
		fail_test()
		return

	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png(OUTPUT_PATH)
	if error != OK:
		push_error("Could not save visual capture: %s" % error)
		fail_test()
		return

	print("Saved part-time event capture: %s" % OUTPUT_PATH)
	finish_test()
