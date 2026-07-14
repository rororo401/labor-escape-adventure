extends "res://scripts/tests/test_scene_tree.gd"

const BadEndingStoryScript := preload("res://scripts/core/bad_ending_story.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const EndingOverlayConfigScript := preload("res://scripts/ui/ending_overlay_config.gd")
const GameEndingScript := preload("res://scripts/core/game_ending.gd")
const MarketScene := preload("res://scenes/market/MarketScreen.tscn")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultPopupOverlayConfigScript := preload("res://scripts/ui/result_popup_overlay_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const TEST_GALLERY_PATH := "user://market_screen_bad_ending_gallery_test.json"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var game_session := _helpers.get_game_session(root)
	_expect(game_session != null, "GameSession autoload should exist")
	_remove_test_gallery()
	game_session.gallery_store.save_path = TEST_GALLERY_PATH
	_expect(game_session.start_new_game("2026-06-30"), "test should start on final day")

	var scene := MarketScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var result := _final_bad_result()
	scene.call("_finish_day_completion", result)
	await process_frame

	var ending_overlay := _helpers.find_node(scene, EndingOverlayConfigScript.OVERLAY_NAME) as Control
	_expect(ending_overlay != null, "market screen should include ending overlay")
	_expect(not ending_overlay.visible, "ending overlay should wait for result popup close")

	var close_button := _helpers.find_node(scene, ResultPopupOverlayConfigScript.CLOSE_BUTTON_NAME) as Button
	_expect(close_button != null, "result popup should have close button")
	close_button.emit_signal("pressed")
	await process_frame

	var ending_story := _helpers.find_node(scene, "DayEventCgLayer") as Control
	_expect(ending_story != null, "bad ending story should appear after result popup closes")
	_expect(not ending_overlay.visible, "ending summary should wait for the bad ending story")
	_expect(game_session.gallery_store.has_unlocked(BadEndingStoryScript.NEAR_MISS_CG), "viewed bad ending CG should unlock in gallery")
	_expect(not game_session.gallery_store.has_unlocked(BadEndingStoryScript.BARELY_LEFT_CG), "unseen bad ending CG should stay locked")

	ending_story.call("_finish")
	await create_timer(0.25).timeout
	await process_frame

	_expect(ending_overlay.visible, "ending overlay should appear after bad ending story")
	_expect(_find_label_containing(ending_overlay, GameEndingScript.BAD_ENDING_05_TITLE) != null, "ending overlay should show route title")
	_expect(_find_label_containing(ending_overlay, "게임의 마지막 날") != null, "ending overlay should show route-specific epilogue")

	_remove_test_gallery()
	print("Market screen bad ending story smoke test passed.")
	finish_test()


func _final_bad_result() -> Dictionary:
	return {
		DayEventKeysScript.KEY_OK: true,
		DayEventKeysScript.KEY_DATE: "2026-06-30",
		DayEventKeysScript.KEY_GAME_FINISHED: true,
		PlayerStatusKeysScript.KEY_GAME_CLEAR: false,
		PlayerStatusKeysScript.KEY_GAME_OVER: true,
		PlayerStatusKeysScript.KEY_GAME_OVER_REASON: PlayerStatusKeysScript.GAME_OVER_REASON_FINAL_BAD_ENDING,
		PlayerStatusKeysScript.KEY_ENDING_ROUTE: GameEndingScript.BAD_ENDING_05_ROUTE,
		PlayerStatusKeysScript.KEY_ENDING_TIER: 5,
		PlayerStatusKeysScript.KEY_ENDING_TITLE_KO: GameEndingScript.BAD_ENDING_05_TITLE,
		DayEventKeysScript.KEY_DAY_ACTION: {
			DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_NAME_KO: "마지막 회사 업무"},
			DayEventKeysScript.KEY_EFFECT: {PlayerStatusKeysScript.KEY_DELTA: {}}
		},
		DayEventKeysScript.KEY_WEEKDAY_EVENTS: [],
		DayEventKeysScript.KEY_NIGHT_EVENTS: [],
		DayEventKeysScript.KEY_END_OF_DAY_EFFECT: {PlayerStatusKeysScript.KEY_DELTA: {}},
		DayEventKeysScript.KEY_MARKET_CLOSE_REPORT: {},
		DayEventKeysScript.KEY_STATUS: {
			PlayerStatusKeysScript.KEY_CASH: 750000000,
			PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: 0,
			PlayerStatusKeysScript.KEY_NET_WORTH: 750000000,
			PlayerStatusKeysScript.KEY_HEALTH: 70,
			PlayerStatusKeysScript.KEY_MOOD: 45,
			PlayerStatusKeysScript.KEY_FATIGUE: 35
		}
	}


func _find_label_containing(root_node: Node, text: String) -> Label:
	if root_node is Label:
		var label := root_node as Label
		if label.text.contains(text):
			return label
	for child in root_node.get_children():
		var found := _find_label_containing(child, text)
		if found != null:
			return found
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		_remove_test_gallery()
		fail_test()


func _remove_test_gallery() -> void:
	if FileAccess.file_exists(TEST_GALLERY_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_GALLERY_PATH))
