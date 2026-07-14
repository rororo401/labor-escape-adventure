class_name EndingOverlay
extends Control

signal title_requested
signal new_game_requested

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const BadEndingStoryScript := preload("res://scripts/core/bad_ending_story.gd")
const EndingOverlayConfigScript := preload("res://scripts/ui/ending_overlay_config.gd")
const MarketUiFormatScript := preload("res://scripts/ui/market_ui_format.gd")
const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")
const GameRunStatisticsScript := preload("res://scripts/core/game_run_statistics.gd")

var _title_label: Label
var _subtitle_label: Label
var _net_worth_label: Label
var _body_label: Label
var _statistics_label: Label


func build() -> void:
	name = EndingOverlayConfigScript.OVERLAY_NAME
	UiHelpers.apply_full_rect(self)
	UiHelpers.stop_mouse(self)
	visible = false

	var backdrop := ColorRect.new()
	backdrop.name = EndingOverlayConfigScript.BACKDROP_NAME
	UiHelpers.apply_full_rect(backdrop)
	backdrop.color = EndingOverlayConfigScript.BACKDROP_COLOR
	add_child(backdrop)

	var panel := Panel.new()
	panel.name = EndingOverlayConfigScript.PANEL_NAME
	panel.position = EndingOverlayConfigScript.PANEL_POSITION
	panel.size = EndingOverlayConfigScript.PANEL_SIZE
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)

	_title_label = _make_label("", EndingOverlayConfigScript.TITLE_POSITION, EndingOverlayConfigScript.TITLE_SIZE, EndingOverlayConfigScript.TITLE_FONT_SIZE, EndingOverlayConfigScript.TITLE_COLOR)
	_title_label.name = EndingOverlayConfigScript.TITLE_LABEL_NAME
	TextThemeHelpersScript.apply_alignment(_title_label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(_title_label)

	_subtitle_label = _make_label("", EndingOverlayConfigScript.SUBTITLE_POSITION, EndingOverlayConfigScript.SUBTITLE_SIZE, EndingOverlayConfigScript.SUBTITLE_FONT_SIZE, EndingOverlayConfigScript.SUBTITLE_COLOR)
	_subtitle_label.name = EndingOverlayConfigScript.SUBTITLE_LABEL_NAME
	TextThemeHelpersScript.apply_alignment(_subtitle_label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(_subtitle_label)

	_net_worth_label = _make_label("", EndingOverlayConfigScript.NET_WORTH_POSITION, EndingOverlayConfigScript.NET_WORTH_SIZE, EndingOverlayConfigScript.NET_WORTH_FONT_SIZE, EndingOverlayConfigScript.NET_WORTH_COLOR)
	_net_worth_label.name = EndingOverlayConfigScript.NET_WORTH_LABEL_NAME
	TextThemeHelpersScript.apply_alignment(_net_worth_label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(_net_worth_label)

	_statistics_label = _make_label("", EndingOverlayConfigScript.STATISTICS_POSITION, EndingOverlayConfigScript.STATISTICS_SIZE, EndingOverlayConfigScript.STATISTICS_FONT_SIZE, EndingOverlayConfigScript.STATISTICS_COLOR)
	_statistics_label.name = EndingOverlayConfigScript.STATISTICS_LABEL_NAME
	_statistics_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.apply_alignment(_statistics_label, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER)
	add_child(_statistics_label)

	_body_label = _make_label("", EndingOverlayConfigScript.BODY_POSITION, EndingOverlayConfigScript.BODY_SIZE, EndingOverlayConfigScript.BODY_FONT_SIZE, EndingOverlayConfigScript.BODY_COLOR)
	_body_label.name = EndingOverlayConfigScript.BODY_LABEL_NAME
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.apply_alignment(_body_label, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_TOP)
	add_child(_body_label)

	_add_button(EndingOverlayConfigScript.TITLE_BUTTON_NAME, "타이틀로", EndingOverlayConfigScript.TITLE_BUTTON_Y, _on_title_pressed)
	_add_button(EndingOverlayConfigScript.NEW_GAME_BUTTON_NAME, "새 게임", EndingOverlayConfigScript.NEW_GAME_BUTTON_Y, _on_new_game_pressed)


func show_result(result: Dictionary) -> void:
	if not bool(result.get(DayEventKeysScript.KEY_GAME_FINISHED, false)):
		return
	var status := Dictionary(result.get(DayEventKeysScript.KEY_STATUS, {}))
	var net_worth := int(status.get(PlayerStatusKeysScript.KEY_NET_WORTH, 0))
	var clear := bool(result.get(PlayerStatusKeysScript.KEY_GAME_CLEAR, false))
	var final_bad := String(result.get(PlayerStatusKeysScript.KEY_GAME_OVER_REASON, "")) == PlayerStatusKeysScript.GAME_OVER_REASON_FINAL_BAD_ENDING
	var title := _ending_title(result, clear, final_bad)

	_title_label.text = title
	_subtitle_label.text = "최종 결과" if clear or final_bad else "게임 종료"
	_net_worth_label.text = "최종 순자산  %s" % MarketUiFormatScript.format_won(net_worth)
	_statistics_label.text = _statistics_text(Dictionary(result.get(GameRunStatisticsScript.KEY_SAVE, {})), net_worth)
	_body_label.text = _ending_body(result, title, net_worth, clear, final_bad)
	visible = true


func _ending_title(result: Dictionary, clear: bool, final_bad: bool) -> String:
	if clear:
		return EndingOverlayConfigScript.CLEAR_TITLE
	if final_bad:
		return String(result.get(PlayerStatusKeysScript.KEY_ENDING_TITLE_KO, EndingOverlayConfigScript.BAD_TITLE_FALLBACK))
	return EndingOverlayConfigScript.GAME_OVER_TITLE_FALLBACK


func _ending_body(result: Dictionary, title: String, net_worth: int, clear: bool, final_bad: bool) -> String:
	if clear:
		return "경제적 자유인지는 아직 잘 모르겠다.\n\n그래도 10년 동안 세운 목표는 진짜로 이뤘다.\n\n오늘은 연차다. 내일 일은 내일 생각하자."
	if final_bad:
		return BadEndingStoryScript.summary_body(
			String(result.get(PlayerStatusKeysScript.KEY_ENDING_ROUTE, "")),
			MarketUiFormatScript.format_won(net_worth)
		)
	return "여기서 게임이 멈췄다.\n\n이번 기록은 끝났지만, 다음 시작에서는 다른 선택을 할 수 있다."


func _statistics_text(statistics: Dictionary, final_net_worth: int) -> String:
	var highest_net_worth := int(statistics.get(GameRunStatisticsScript.KEY_HIGHEST_NET_WORTH, final_net_worth))
	var investment_profit := int(statistics.get(GameRunStatisticsScript.KEY_TOTAL_INVESTMENT_PROFIT, 0))
	var event_count := int(statistics.get(GameRunStatisticsScript.KEY_TOTAL_EVENT_COUNT, 0))
	var stock_name := String(statistics.get(GameRunStatisticsScript.KEY_MOST_HELD_NAME_KO, ""))
	var ticker := String(statistics.get(GameRunStatisticsScript.KEY_MOST_HELD_TICKER, ""))
	var quantity := int(statistics.get(GameRunStatisticsScript.KEY_MOST_HELD_QUANTITY, 0))
	if stock_name.is_empty():
		stock_name = ticker
	var holding_text := "없음" if stock_name.is_empty() or quantity <= 0 else "%s · %d주" % [stock_name, quantity]
	return "최고 순자산  %s\n투자 손익  %s\n가장 많이 보유  %s\n겪은 이벤트  %s회" % [
		MarketUiFormatScript.format_won(highest_net_worth),
		_signed_won(investment_profit),
		holding_text,
		MarketUiFormatScript.format_won(event_count).trim_suffix("원")
	]


func _signed_won(value: int) -> String:
	var formatted := MarketUiFormatScript.format_won(value)
	return "+%s" % formatted if value > 0 else formatted


func _on_title_pressed() -> void:
	title_requested.emit()


func _on_new_game_pressed() -> void:
	new_game_requested.emit()


func _add_button(button_name: String, text: String, y: float, callback: Callable) -> Button:
	var button := MarketUiStyleScript.make_soft_button(text, EndingOverlayConfigScript.BUTTON_SIZE, EndingOverlayConfigScript.BUTTON_FONT_SIZE)
	button.name = button_name
	button.position = Vector2(EndingOverlayConfigScript.BUTTON_X, y)
	if callback.is_valid():
		button.pressed.connect(callback)
	add_child(button)
	return button


func _make_label(text: String, position_value: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := MarketUiStyleScript.make_label(font_size, color)
	label.text = text
	label.position = position_value
	label.size = size_value
	return label


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = EndingOverlayConfigScript.PANEL_COLOR
	style.border_color = EndingOverlayConfigScript.PANEL_BORDER_COLOR
	style.set_border_width_all(EndingOverlayConfigScript.PANEL_BORDER_WIDTH)
	style.set_corner_radius_all(EndingOverlayConfigScript.PANEL_CORNER_RADIUS)
	return style
