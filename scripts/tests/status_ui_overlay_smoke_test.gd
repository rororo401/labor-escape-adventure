extends "res://scripts/tests/test_scene_tree.gd"

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultPopupOverlayConfigScript := preload("res://scripts/ui/result_popup_overlay_config.gd")
const ResultPopupOverlayScript := preload("res://scripts/ui/result_popup_overlay.gd")
const StatusMenuOverlayConfigScript := preload("res://scripts/ui/status_menu_overlay_config.gd")
const StatusMenuOverlayScript := preload("res://scripts/ui/status_menu_overlay.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()
var _result_popup_closed := false


func _initialize() -> void:
	_verify_status_overlay()
	_verify_result_popup()
	print("Status UI overlay smoke test passed.")
	finish_test()


func _verify_status_overlay() -> void:
	var game := GameStateScript.new()
	_expect(game.setup("2016-07-02"), "game should set up for status overlay")
	game.status.fatigue = 95

	var overlay := StatusMenuOverlayScript.new()
	overlay.build()
	root.add_child(overlay)
	await process_frame

	_expect(ResourceLoader.exists(StatusMenuOverlayConfigScript.PANEL_TEXTURE_PATH), "status notebook texture should exist")
	_expect(not overlay.visible, "status overlay should start hidden")
	overlay.show_for_game(game)
	_expect(overlay.visible, "status overlay should become visible")
	_expect(_helpers.find_node(overlay, StatusMenuOverlayConfigScript.PANEL_IMAGE_NAME) != null, "status overlay should render image frame")
	_expect(_find_label_containing(overlay, "피로가 매우 높아") != null, "status overlay should explain high fatigue risk")
	overlay.update_from_status(game.status.to_dict(), true)
	_expect(_find_label_containing(overlay, "레버리지의 여신") != null, "status overlay should show the active blessing without exposing an exact expiry")


func _verify_result_popup() -> void:
	var popup := ResultPopupOverlayScript.new()
	popup.build()
	popup.closed.connect(func() -> void:
		_result_popup_closed = true
	)
	root.add_child(popup)
	await process_frame

	_expect(ResourceLoader.exists(ResultPopupOverlayConfigScript.PANEL_TEXTURE_PATH), "result receipt texture should exist")
	_expect(not popup.visible, "result popup should start hidden")
	popup.show_result({
		DayEventKeysScript.KEY_OK: true,
		DayEventKeysScript.KEY_DAY_ACTION: {
			DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_NAME_KO: "회사 업무"},
			DayEventKeysScript.KEY_EFFECT: {
				PlayerStatusKeysScript.KEY_DELTA: {
					PlayerStatusKeysScript.KEY_CASH: 70000,
					PlayerStatusKeysScript.KEY_HEALTH: -4,
					PlayerStatusKeysScript.KEY_MOOD: -8,
					PlayerStatusKeysScript.KEY_FATIGUE: 22
				}
			}
		},
		DayEventKeysScript.KEY_WEEKDAY_EVENTS: [
			{
				DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_NAME_KO: "월급 입금"},
				DayEventKeysScript.KEY_EFFECT: {
					PlayerStatusKeysScript.KEY_DELTA: {
						PlayerStatusKeysScript.KEY_CASH: 600000,
						PlayerStatusKeysScript.KEY_HEALTH: 0,
						PlayerStatusKeysScript.KEY_MOOD: 0,
						PlayerStatusKeysScript.KEY_FATIGUE: 0
					}
				}
			}
		],
		DayEventKeysScript.KEY_NIGHT_EVENTS: [
			{
				DayEventKeysScript.KEY_EVENT: {DayEventKeysScript.KEY_NAME_KO: "치맥이 땡긴다"},
				DayEventKeysScript.KEY_EFFECT: {
					PlayerStatusKeysScript.KEY_DELTA: {
						PlayerStatusKeysScript.KEY_CASH: -35000,
						PlayerStatusKeysScript.KEY_HEALTH: -2,
						PlayerStatusKeysScript.KEY_MOOD: 22,
						PlayerStatusKeysScript.KEY_FATIGUE: 3
					}
				}
			}
		],
		DayEventKeysScript.KEY_END_OF_DAY_EFFECT: {
			PlayerStatusKeysScript.KEY_DELTA: {
				PlayerStatusKeysScript.KEY_CASH: 0,
				PlayerStatusKeysScript.KEY_HEALTH: 0,
				PlayerStatusKeysScript.KEY_MOOD: 0,
				PlayerStatusKeysScript.KEY_FATIGUE: 0
			}
		},
		DayEventKeysScript.KEY_STATUS: {
			PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: 320000,
			PlayerStatusKeysScript.KEY_NET_WORTH: 5070000
		}
	})
	_expect(popup.visible, "result popup should become visible")
	_expect(_helpers.find_node(popup, ResultPopupOverlayConfigScript.PANEL_IMAGE_NAME) != null, "result popup should render image frame")
	var activity_value := _find_label_containing(popup, "회사 업무")
	_expect(activity_value != null, "result popup should show activity summary")
	_expect(activity_value.text.contains("+1"), "result popup should summarize extra daytime events without consuming the night line")
	_expect(activity_value.text.contains("치맥이 땡긴다"), "result popup should include triggered night event names")
	_expect(activity_value.text.contains("\n"), "result popup should split day and night activities across lines")
	_expect(activity_value.autowrap_mode == TextServer.AUTOWRAP_OFF, "activity summary should reserve one fixed line for day and night")
	_expect(activity_value.max_lines_visible == ResultPopupOverlayConfigScript.ACTIVITY_MAX_LINES, "activity summary should cap visible lines")
	_expect(activity_value.size.x == ResultPopupOverlayConfigScript.ACTIVITY_VALUE_SIZE.x, "activity summary should use the expanded width")
	_expect(_find_label_containing(popup, "현금") != null, "result popup should show cash label")
	var cash_delta := _find_label_containing(popup, "+635,000원")
	_expect(cash_delta != null, "result popup should show cash delta")
	_expect(cash_delta.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT, "result popup values should align left")
	_expect(int(cash_delta.position.x) == int(activity_value.position.x), "result popup values should start on the activity value x position")
	_expect(_find_label_containing(popup, "투자자산") != null, "result popup should show investment assets label")
	_expect(_find_label_containing(popup, "320,000원") != null, "result popup should show investment assets")
	_expect(_find_label_containing(popup, "피로") != null, "result popup should show fatigue label")
	_expect(_find_label_containing(popup, "+25") != null, "result popup should show fatigue delta")
	var close_button := _helpers.find_node(popup, ResultPopupOverlayConfigScript.CLOSE_BUTTON_NAME) as Button
	_expect(close_button != null, "result popup should expose close button")
	close_button.emit_signal("pressed")
	_expect(_result_popup_closed, "result popup should emit closed signal")
	_expect(not popup.visible, "result popup should hide after close")


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
