extends "res://scripts/tests/test_scene_tree.gd"

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const EndingOverlayConfigScript := preload("res://scripts/ui/ending_overlay_config.gd")
const EndingOverlayScript := preload("res://scripts/ui/ending_overlay.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")
const GameRunStatisticsScript := preload("res://scripts/core/game_run_statistics.gd")

var _helpers := TestHelpersScript.new()
var _title_count := 0
var _new_game_count := 0


func _initialize() -> void:
	root.size = Vector2i(720, 1280)

	var overlay := EndingOverlayScript.new()
	overlay.build()
	overlay.title_requested.connect(func() -> void:
		_title_count += 1
	)
	overlay.new_game_requested.connect(func() -> void:
		_new_game_count += 1
	)
	root.add_child(overlay)
	await process_frame

	_expect(not overlay.visible, "ending overlay should start hidden")
	overlay.show_result(_clear_result())
	_expect(overlay.visible, "ending overlay should show final clear result")
	_expect((_find_label_containing(overlay, "10억, 진짜 찍었다!") != null), "clear ending should show clear title")
	_expect((_find_label_containing(overlay, "1,100,000,000원") != null), "clear ending should show final net worth")
	_expect((_find_label_containing(overlay, "1,250,000,000원") != null), "ending should show the run's highest net worth")
	_expect((_find_label_containing(overlay, "+210,000,000원") != null), "ending should show total investment profit")
	_expect((_find_label_containing(overlay, "도독전자 · 420주") != null), "ending should show the most-held stock")
	_expect((_find_label_containing(overlay, "1,234회") != null), "ending should show cumulative event count")

	overlay.show_result(_bad_result())
	_expect((_find_label_containing(overlay, "한 발 모자란 탈출") != null), "bad ending should show route title")
	_expect((_find_label_containing(overlay, "게임의 마지막 날") != null), "bad ending should show route-specific body")

	var title_button := _helpers.find_node(overlay, EndingOverlayConfigScript.TITLE_BUTTON_NAME) as Button
	var new_game_button := _helpers.find_node(overlay, EndingOverlayConfigScript.NEW_GAME_BUTTON_NAME) as Button
	_expect(title_button != null, "ending overlay should have title button")
	_expect(new_game_button != null, "ending overlay should have new-game button")
	title_button.emit_signal("pressed")
	new_game_button.emit_signal("pressed")
	_expect(_title_count == 1, "title button should emit title request")
	_expect(_new_game_count == 1, "new-game button should emit new-game request")

	print("Ending overlay smoke test passed.")
	finish_test()


func _clear_result() -> Dictionary:
	return {
		DayEventKeysScript.KEY_GAME_FINISHED: true,
		PlayerStatusKeysScript.KEY_GAME_CLEAR: true,
		PlayerStatusKeysScript.KEY_GAME_OVER: false,
		DayEventKeysScript.KEY_STATUS: {
			PlayerStatusKeysScript.KEY_NET_WORTH: 1100000000
		},
		GameRunStatisticsScript.KEY_SAVE: {
			GameRunStatisticsScript.KEY_HIGHEST_NET_WORTH: 1250000000,
			GameRunStatisticsScript.KEY_TOTAL_INVESTMENT_PROFIT: 210000000,
			GameRunStatisticsScript.KEY_MOST_HELD_TICKER: "005930",
			GameRunStatisticsScript.KEY_MOST_HELD_NAME_KO: "도독전자",
			GameRunStatisticsScript.KEY_MOST_HELD_QUANTITY: 420,
			GameRunStatisticsScript.KEY_TOTAL_EVENT_COUNT: 1234
		}
	}


func _bad_result() -> Dictionary:
	return {
		DayEventKeysScript.KEY_GAME_FINISHED: true,
		PlayerStatusKeysScript.KEY_GAME_CLEAR: false,
		PlayerStatusKeysScript.KEY_GAME_OVER: true,
		PlayerStatusKeysScript.KEY_GAME_OVER_REASON: PlayerStatusKeysScript.GAME_OVER_REASON_FINAL_BAD_ENDING,
		PlayerStatusKeysScript.KEY_ENDING_ROUTE: "bad_ending_05_near_miss",
		PlayerStatusKeysScript.KEY_ENDING_TITLE_KO: "한 발 모자란 탈출",
		DayEventKeysScript.KEY_STATUS: {
			PlayerStatusKeysScript.KEY_NET_WORTH: 500000000
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
		fail_test()
