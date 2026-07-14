class_name ResultPopupOverlay
extends Control

signal closed

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultPopupLayoutStoreScript := preload("res://scripts/ui/result_popup_layout_store.gd")
const ResultPopupOverlayConfigScript := preload("res://scripts/ui/result_popup_overlay_config.gd")
const MarketUiFormatScript := preload("res://scripts/ui/market_ui_format.gd")
const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var _title_label: Label
var _row_labels: Array[Label] = []
var _row_values: Array[Label] = []
var _panel: TextureRect
var _close_button: Button
var _layout := {}


func build() -> void:
	name = ResultPopupOverlayConfigScript.OVERLAY_NAME
	UiHelpers.apply_full_rect(self)
	UiHelpers.stop_mouse(self)
	visible = false
	_layout = ResultPopupLayoutStoreScript.new().load_layout()

	var backdrop := ColorRect.new()
	backdrop.name = ResultPopupOverlayConfigScript.BACKDROP_NAME
	UiHelpers.apply_full_rect(backdrop)
	backdrop.color = ResultPopupOverlayConfigScript.BACKDROP_COLOR
	add_child(backdrop)

	_panel = TextureRect.new()
	_panel.name = ResultPopupOverlayConfigScript.PANEL_IMAGE_NAME
	_panel.position = _layout_vector(ResultPopupOverlayConfigScript.KEY_PANEL_POSITION, ResultPopupOverlayConfigScript.PANEL_POSITION)
	_panel.size = ResultPopupOverlayConfigScript.PANEL_SIZE
	_panel.texture = UiHelpers.load_texture(ResultPopupOverlayConfigScript.PANEL_TEXTURE_PATH)
	_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_panel.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(_panel)

	_title_label = MarketUiStyleScript.make_label(ResultPopupOverlayConfigScript.TITLE_FONT_SIZE, ResultPopupOverlayConfigScript.TITLE_COLOR)
	_title_label.name = ResultPopupOverlayConfigScript.TITLE_LABEL_NAME
	_title_label.position = _layout_vector(ResultPopupOverlayConfigScript.KEY_TITLE_POSITION, ResultPopupOverlayConfigScript.TITLE_POSITION)
	_title_label.size = ResultPopupOverlayConfigScript.TITLE_SIZE
	TextThemeHelpersScript.apply_alignment(_title_label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(_title_label)

	for index in ResultPopupOverlayConfigScript.ROW_Y.size():
		var row_y := _row_y(index)
		var label := _make_label(
			Vector2(_layout_float(ResultPopupOverlayConfigScript.KEY_ROW_LABEL_X, ResultPopupOverlayConfigScript.ROW_LABEL_X), row_y),
			ResultPopupOverlayConfigScript.ROW_LABEL_SIZE,
			ResultPopupOverlayConfigScript.ROW_FONT_SIZE,
			ResultPopupOverlayConfigScript.ROW_LABEL_COLOR
		)
		_row_labels.append(label)
		add_child(label)

		var value := _make_label(
			Vector2(_layout_float(ResultPopupOverlayConfigScript.KEY_ROW_VALUE_X, ResultPopupOverlayConfigScript.ROW_VALUE_X), row_y),
			ResultPopupOverlayConfigScript.ROW_VALUE_SIZE,
			ResultPopupOverlayConfigScript.ROW_FONT_SIZE,
			ResultPopupOverlayConfigScript.ROW_VALUE_COLOR
		)
		if index == 0:
			_configure_activity_value(value, row_y)
		else:
			TextThemeHelpersScript.apply_alignment(value, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER)
		_row_values.append(value)
		add_child(value)

	_close_button = _make_receipt_button()
	_close_button.name = ResultPopupOverlayConfigScript.CLOSE_BUTTON_NAME
	_close_button.position = _layout_vector(ResultPopupOverlayConfigScript.KEY_CLOSE_BUTTON_POSITION, ResultPopupOverlayConfigScript.CLOSE_BUTTON_POSITION)
	_close_button.pressed.connect(_close)
	add_child(_close_button)


func set_layout_override(layout: Dictionary) -> void:
	_layout = ResultPopupLayoutStoreScript.normalize_layout(layout)
	_apply_layout()


func show_result(result: Dictionary) -> void:
	if not bool(result.get(DayEventKeysScript.KEY_OK, false)):
		return
	if _title_label != null:
		_title_label.text = "오늘의 변화"
	_update_result_rows(result)
	visible = true


func _close() -> void:
	hide()
	closed.emit()


func _apply_layout() -> void:
	if _panel != null:
		_panel.position = _layout_vector(ResultPopupOverlayConfigScript.KEY_PANEL_POSITION, ResultPopupOverlayConfigScript.PANEL_POSITION)
	if _title_label != null:
		_title_label.position = _layout_vector(ResultPopupOverlayConfigScript.KEY_TITLE_POSITION, ResultPopupOverlayConfigScript.TITLE_POSITION)
	for index in _row_labels.size():
		var row_y := _row_y(index)
		_row_labels[index].position = Vector2(_layout_float(ResultPopupOverlayConfigScript.KEY_ROW_LABEL_X, ResultPopupOverlayConfigScript.ROW_LABEL_X), row_y)
		if index < _row_values.size():
			if index == 0:
				_apply_activity_value_layout(_row_values[index], row_y)
			else:
				_row_values[index].position = Vector2(_layout_float(ResultPopupOverlayConfigScript.KEY_ROW_VALUE_X, ResultPopupOverlayConfigScript.ROW_VALUE_X), row_y)
	if _close_button != null:
		_close_button.position = _layout_vector(ResultPopupOverlayConfigScript.KEY_CLOSE_BUTTON_POSITION, ResultPopupOverlayConfigScript.CLOSE_BUTTON_POSITION)


func _update_result_rows(result: Dictionary) -> void:
	var total := _total_delta(result)
	var status: Dictionary = result.get(DayEventKeysScript.KEY_STATUS, {})
	_set_row(0, "활동", _event_name(result))
	_set_row(1, "현금", _signed_won(int(total.get(PlayerStatusKeysScript.KEY_CASH, 0))))
	_set_row(2, "투자자산", MarketUiFormatScript.format_won(int(status.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, 0))))
	_set_row(3, "건강", _signed_plain(int(total.get(PlayerStatusKeysScript.KEY_HEALTH, 0))))
	_set_row(4, "기분", _signed_plain(int(total.get(PlayerStatusKeysScript.KEY_MOOD, 0))))
	_set_row(5, "피로", _signed_plain(int(total.get(PlayerStatusKeysScript.KEY_FATIGUE, 0))))
	_set_row(6, "순자산", MarketUiFormatScript.format_won(int(status.get(PlayerStatusKeysScript.KEY_NET_WORTH, 0))))


func _set_row(index: int, label_text: String, value_text: String) -> void:
	if index >= 0 and index < _row_labels.size():
		_row_labels[index].text = label_text
	if index >= 0 and index < _row_values.size():
		_row_values[index].text = value_text


func _layout_vector(key: String, fallback: Vector2) -> Vector2:
	return ResultPopupLayoutStoreScript.vector_from_payload(_layout.get(key, fallback), fallback)


func _layout_float(key: String, fallback: float) -> float:
	return float(_layout.get(key, fallback))


func _row_y(index: int) -> float:
	var row_y: Array = _layout.get(ResultPopupOverlayConfigScript.KEY_ROW_Y, ResultPopupOverlayConfigScript.ROW_Y)
	if index >= 0 and index < row_y.size():
		return float(row_y[index])
	return float(ResultPopupOverlayConfigScript.ROW_Y[index])


func _event_name(result: Dictionary) -> String:
	var day_event: Dictionary = Dictionary(result.get(DayEventKeysScript.KEY_DAY_ACTION, {})).get(DayEventKeysScript.KEY_EVENT, {})
	var day_names: Array[String] = []
	if not day_event.is_empty():
		day_names.append(String(day_event.get(DayEventKeysScript.KEY_NAME_KO, "하루 활동")))
	var market_fixed_event := Dictionary(
		Dictionary(result.get(DayEventKeysScript.KEY_MARKET_FIXED_EFFECT, {})).get(DayEventKeysScript.KEY_EVENT, {})
	)
	if not market_fixed_event.is_empty():
		day_names.append(String(market_fixed_event.get(DayEventKeysScript.KEY_NAME_KO, "시장 뉴스")))
	day_names.append_array(_event_names_from_rows(result.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []), "평일 사건"))
	var night_names := _event_names_from_rows(result.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []), "밤 이벤트")
	# When both periods exist, reserve exactly one visual line for each. This
	# prevents a long daytime list from wrapping over and hiding the night name.
	var split_periods := not day_names.is_empty() and not night_names.is_empty()
	var day_summary := _compact_event_names(day_names, split_periods)
	var night_summary := _compact_event_names(night_names, split_periods)
	if not day_summary.is_empty() and not night_summary.is_empty():
		return "%s\n%s" % [day_summary, night_summary]
	if not day_summary.is_empty():
		return day_summary
	if not night_summary.is_empty():
		return night_summary
	return "하루 정산"


func _event_names_from_rows(rows: Array, fallback_name: String) -> Array[String]:
	var names: Array[String] = []
	for row in rows:
		var event := Dictionary(Dictionary(row).get(DayEventKeysScript.KEY_EVENT, {}))
		if not event.is_empty():
			names.append(String(event.get(DayEventKeysScript.KEY_NAME_KO, fallback_name)))
	return names


func _compact_event_names(names: Array[String], single_line: bool = false) -> String:
	if names.is_empty():
		return ""
	if single_line and names.size() > 1:
		return "%s +%d" % [names[0], names.size() - 1]
	if names.size() <= 2:
		return " + ".join(names)
	return "%s + %s 외 %d건" % [names[0], names[1], names.size() - 2]


func _total_delta(result: Dictionary) -> Dictionary:
	var total := {
		PlayerStatusKeysScript.KEY_CASH: 0,
		PlayerStatusKeysScript.KEY_HEALTH: 0,
		PlayerStatusKeysScript.KEY_MOOD: 0,
		PlayerStatusKeysScript.KEY_FATIGUE: 0
	}
	_add_effect_delta(total, Dictionary(result.get(DayEventKeysScript.KEY_MARKET_FIXED_EFFECT, {})).get(DayEventKeysScript.KEY_EFFECT, {}))
	_add_effect_delta(total, result.get(DayEventKeysScript.KEY_LEVERAGE_BONUS_EFFECT, {}))
	_add_effect_delta(total, Dictionary(result.get(DayEventKeysScript.KEY_DAY_ACTION, {})).get(DayEventKeysScript.KEY_EFFECT, {}))
	for row in result.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []):
		_add_effect_delta(total, Dictionary(row).get(DayEventKeysScript.KEY_EFFECT, {}))
	for row in result.get(DayEventKeysScript.KEY_NIGHT_EVENTS, []):
		_add_effect_delta(total, Dictionary(row).get(DayEventKeysScript.KEY_EFFECT, {}))
	_add_effect_delta(total, result.get(DayEventKeysScript.KEY_END_OF_DAY_EFFECT, {}))
	return total


func _add_effect_delta(total: Dictionary, effect: Dictionary) -> void:
	var delta: Dictionary = Dictionary(effect.get(PlayerStatusKeysScript.KEY_DELTA, {}))
	for key in total.keys():
		total[key] = int(total.get(key, 0)) + int(delta.get(key, 0))


func _signed_plain(value: int) -> String:
	return "%s%d" % ["+" if value >= 0 else "", value]


func _signed_won(value: int) -> String:
	if value > 0:
		return "+%s" % MarketUiFormatScript.format_won(value)
	return MarketUiFormatScript.format_won(value)


func _make_label(position_value: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := MarketUiStyleScript.make_label(font_size, color)
	label.position = position_value
	label.size = size_value
	TextThemeHelpersScript.center_vertical(label)
	return label


func _configure_activity_value(label: Label, row_y: float) -> void:
	TextThemeHelpersScript.apply_font_size(label, ResultPopupOverlayConfigScript.ACTIVITY_FONT_SIZE)
	TextThemeHelpersScript.apply_alignment(label, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.max_lines_visible = ResultPopupOverlayConfigScript.ACTIVITY_MAX_LINES
	_apply_activity_value_layout(label, row_y)


func _apply_activity_value_layout(label: Label, row_y: float) -> void:
	label.position = Vector2(
		_layout_float(ResultPopupOverlayConfigScript.KEY_ROW_VALUE_X, ResultPopupOverlayConfigScript.ROW_VALUE_X),
		row_y + ResultPopupOverlayConfigScript.ACTIVITY_VALUE_Y_OFFSET
	)
	label.size = ResultPopupOverlayConfigScript.ACTIVITY_VALUE_SIZE


func _make_receipt_button() -> Button:
	var button := Button.new()
	button.text = "확인"
	button.size = ResultPopupOverlayConfigScript.CLOSE_BUTTON_SIZE
	TextThemeHelpersScript.apply_ui_text_style(
		button,
		ResultPopupOverlayConfigScript.CLOSE_BUTTON_FONT_SIZE,
		ResultPopupOverlayConfigScript.CLOSE_BUTTON_TEXT_COLOR
	)
	for style_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	return button
