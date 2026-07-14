extends "res://scripts/tests/test_scene_tree.gd"

const MorningBriefingLayerScene := preload("res://scenes/day/MorningBriefingLayer.tscn")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const MorningBriefingLayerConfigScript := preload("res://scripts/ui/morning_briefing_layer_config.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)

	await _verify_closed_day_briefing()
	await _verify_market_fixed_context_briefing()
	await _verify_salary_context_briefing()

	print("Morning briefing layer smoke test passed.")
	finish_test()


func _verify_closed_day_briefing() -> void:
	var layer := MorningBriefingLayerScene.instantiate()
	root.add_child(layer)
	await process_frame
	await process_frame

	layer.play("2016-07-02", "Saturday", false)
	await process_frame

	var background := _helpers.find_node(layer, MorningBriefingLayerConfigScript.BACKGROUND_NAME) as TextureRect
	var protagonist := _helpers.find_node(layer, MorningBriefingLayerConfigScript.CHARACTER_NAME) as TextureRect
	var hud_panel := _helpers.find_node(layer, VnTopHudConfigScript.PANEL_IMAGE_NAME) as TextureRect
	var date_label := _helpers.find_node(layer, VnTopHudConfigScript.DATE_LABEL_NAME) as Label
	var dialogue_label := _helpers.find_node(layer, VnDialogueBoxConfigScript.DIALOGUE_LABEL_NAME) as Label

	_expect(background != null and background.texture != null, "morning briefing should load the configured background")
	_expect(protagonist != null and protagonist.texture != null, "morning briefing should show the configured protagonist")
	_expect(hud_panel != null and hud_panel.texture != null, "morning briefing should show the top HUD image panel")
	_expect(date_label != null and date_label.text.contains("2016-07-02"), "morning briefing should set the morning date label")
	_expect(date_label.text.contains("토요일 아침"), "morning briefing should localize the weekday label")
	_expect(_helpers.find_node(layer, VnTopHudConfigScript.BUTTON_ROW_NAME) == null, "morning briefing should hide top buttons")
	_expect(dialogue_label != null and not dialogue_label.text.is_empty(), "morning briefing should start story dialogue")
	_expect(dialogue_label.text.contains("장이 쉬는 날"), "closed-day morning briefing should acknowledge market closure")
	_expect(not dialogue_label.text.contains("계좌는 어제보다"), "closed-day morning briefing should not use trading-day account copy")

	layer.queue_free()
	await process_frame


func _verify_market_fixed_context_briefing() -> void:
	var layer := MorningBriefingLayerScene.instantiate()
	root.add_child(layer)
	await process_frame
	await process_frame

	layer.play("2020-03-13", "Friday", true, {
		GameDayProgressKeysScript.KEY_TODAY: {
			GameStateContextKeysScript.KEY_MARKET: {
				DayEventKeysScript.KEY_MARKET_FIXED_EVENT: {
					DayEventKeysScript.KEY_NAME_KO: "코로나19 서킷브레이커"
				}
			}
		}
	})
	await process_frame

	var dialogue_label := _helpers.find_node(layer, VnDialogueBoxConfigScript.DIALOGUE_LABEL_NAME) as Label
	_expect(dialogue_label != null and dialogue_label.text.contains("시장 뉴스"), "market-event morning briefing should mention market news")
	_expect(dialogue_label.text.contains("코로나19 서킷브레이커"), "market-event morning briefing should name the fixed event")

	layer.queue_free()
	await process_frame


func _verify_salary_context_briefing() -> void:
	var layer := MorningBriefingLayerScene.instantiate()
	root.add_child(layer)
	await process_frame
	await process_frame

	layer.play("2016-07-26", "Tuesday", true, {
		GameDayProgressKeysScript.KEY_PREVIOUS_DAY_RESULT: {
			DayEventKeysScript.KEY_WEEKDAY_EVENTS: [
				{
					DayEventKeysScript.KEY_EVENT: {
						DayEventKeysScript.KEY_ID: "monthly_salary_2016_07",
						DayEventKeysScript.KEY_NAME_KO: "월급 입금",
						DayEventKeysScript.KEY_TAGS: ["salary", "income", "monthly"]
					}
				}
			],
			DayEventKeysScript.KEY_STATUS: {
				PlayerStatusKeysScript.KEY_HEALTH: 90,
				PlayerStatusKeysScript.KEY_FATIGUE: 10
			}
		}
	})
	await process_frame

	var dialogue_label := _helpers.find_node(layer, VnDialogueBoxConfigScript.DIALOGUE_LABEL_NAME) as Label
	_expect(dialogue_label != null and dialogue_label.text.contains("월급 입금"), "salary morning briefing should mention the previous salary event")
	_expect(dialogue_label.text.contains("투자"), "salary morning briefing should connect salary to investment planning")

	layer.queue_free()
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
