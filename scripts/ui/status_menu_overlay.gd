class_name StatusMenuOverlay
extends Control

const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const StatusMenuOverlayConfigScript := preload("res://scripts/ui/status_menu_overlay_config.gd")
const MarketUiFormatScript := preload("res://scripts/ui/market_ui_format.gd")
const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")

var _money_labels: Array[Label] = []
var _money_values: Array[Label] = []
var _gauge_rows: Dictionary = {}
var _note_label: Label


func build() -> void:
	name = StatusMenuOverlayConfigScript.OVERLAY_NAME
	UiHelpers.apply_full_rect(self)
	UiHelpers.stop_mouse(self)
	visible = false

	var backdrop := ColorRect.new()
	backdrop.name = StatusMenuOverlayConfigScript.BACKDROP_NAME
	UiHelpers.apply_full_rect(backdrop)
	backdrop.color = StatusMenuOverlayConfigScript.BACKDROP_COLOR
	add_child(backdrop)

	var panel := TextureRect.new()
	panel.name = StatusMenuOverlayConfigScript.PANEL_IMAGE_NAME
	panel.position = StatusMenuOverlayConfigScript.PANEL_POSITION
	panel.size = StatusMenuOverlayConfigScript.PANEL_SIZE
	panel.texture = UiHelpers.load_texture(StatusMenuOverlayConfigScript.PANEL_TEXTURE_PATH)
	panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(panel)

	var title := _make_label(
		"상태와 자산",
		StatusMenuOverlayConfigScript.TITLE_POSITION,
		StatusMenuOverlayConfigScript.TITLE_SIZE,
		StatusMenuOverlayConfigScript.TITLE_FONT_SIZE,
		StatusMenuOverlayConfigScript.TITLE_COLOR
	)
	title.name = StatusMenuOverlayConfigScript.TITLE_LABEL_NAME
	TextThemeHelpersScript.apply_alignment(title, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(title)

	var close_button := MarketUiStyleScript.make_soft_button("닫기", StatusMenuOverlayConfigScript.CLOSE_BUTTON_SIZE, 18)
	close_button.name = StatusMenuOverlayConfigScript.CLOSE_BUTTON_NAME
	close_button.position = StatusMenuOverlayConfigScript.CLOSE_BUTTON_POSITION
	close_button.pressed.connect(hide)
	add_child(close_button)

	for index in 4:
		var row_y := int(StatusMenuOverlayConfigScript.MONEY_ROW_Y[index])
		var label := _make_label(
			"",
			Vector2(StatusMenuOverlayConfigScript.MONEY_LABEL_X, row_y),
			StatusMenuOverlayConfigScript.MONEY_LABEL_SIZE,
			StatusMenuOverlayConfigScript.MONEY_FONT_SIZE,
			StatusMenuOverlayConfigScript.MONEY_COLOR
		)
		_money_labels.append(label)
		add_child(label)
		var value := _make_label(
			"",
			Vector2(StatusMenuOverlayConfigScript.MONEY_VALUE_X, row_y),
			StatusMenuOverlayConfigScript.MONEY_VALUE_SIZE,
			StatusMenuOverlayConfigScript.MONEY_FONT_SIZE,
			StatusMenuOverlayConfigScript.MONEY_COLOR
		)
		TextThemeHelpersScript.apply_alignment(value, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER)
		_money_values.append(value)
		add_child(value)

	_add_gauge_row(PlayerStatusKeysScript.KEY_HEALTH, "건강", 0, StatusMenuOverlayConfigScript.GAUGE_HEALTH_COLOR)
	_add_gauge_row(PlayerStatusKeysScript.KEY_MOOD, "기분", 1, StatusMenuOverlayConfigScript.GAUGE_MOOD_COLOR)
	_add_gauge_row(PlayerStatusKeysScript.KEY_FATIGUE, "피로", 2, StatusMenuOverlayConfigScript.GAUGE_FATIGUE_COLOR)

	_note_label = _make_label(
		"",
		StatusMenuOverlayConfigScript.NOTE_POSITION,
		StatusMenuOverlayConfigScript.NOTE_SIZE,
		StatusMenuOverlayConfigScript.NOTE_FONT_SIZE,
		StatusMenuOverlayConfigScript.NOTE_COLOR
	)
	_note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_note_label)


func show_for_game(game) -> void:
	if game == null:
		return
	update_from_status(
		game.status.to_dict(),
		game.has_method("is_leverage_blessing_active") and bool(game.is_leverage_blessing_active())
	)
	visible = true


func update_from_status(status: Dictionary, leverage_blessing_active: bool = false) -> void:
	var cash := int(status.get(PlayerStatusKeysScript.KEY_CASH, 0))
	var investment_assets := int(status.get(PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS, 0))
	var net_worth := int(status.get(PlayerStatusKeysScript.KEY_NET_WORTH, cash + investment_assets))
	var target_remaining := int(status.get(PlayerStatusKeysScript.KEY_TARGET_REMAINING, 0))

	_set_money_label(0, "현금", MarketUiFormatScript.format_won(cash))
	_set_money_label(1, "투자자산", MarketUiFormatScript.format_won(investment_assets))
	_set_money_label(2, "순자산", MarketUiFormatScript.format_won(net_worth))
	_set_money_label(3, "10억까지", MarketUiFormatScript.format_won(target_remaining))

	_update_gauge(PlayerStatusKeysScript.KEY_HEALTH, int(status.get(PlayerStatusKeysScript.KEY_HEALTH, 0)))
	_update_gauge(PlayerStatusKeysScript.KEY_MOOD, int(status.get(PlayerStatusKeysScript.KEY_MOOD, 0)))
	_update_gauge(PlayerStatusKeysScript.KEY_FATIGUE, int(status.get(PlayerStatusKeysScript.KEY_FATIGUE, 0)))

	if _note_label != null:
		_note_label.text = _status_note(status, leverage_blessing_active)


func _set_money_label(index: int, label_text: String, value_text: String) -> void:
	if index < 0 or index >= _money_labels.size():
		return
	_money_labels[index].text = label_text
	if index < _money_values.size():
		_money_values[index].text = value_text


func _add_gauge_row(key: String, label_text: String, index: int, fill_color: Color) -> void:
	var origin := StatusMenuOverlayConfigScript.GAUGE_SECTION_ORIGIN + Vector2(0, index * StatusMenuOverlayConfigScript.GAUGE_ROW_GAP)
	var label := _make_label(
		label_text,
		origin,
		StatusMenuOverlayConfigScript.GAUGE_LABEL_SIZE,
		StatusMenuOverlayConfigScript.GAUGE_FONT_SIZE,
		StatusMenuOverlayConfigScript.GAUGE_LABEL_COLOR
	)
	add_child(label)

	var bar_bg := ColorRect.new()
	bar_bg.position = origin + StatusMenuOverlayConfigScript.GAUGE_BAR_OFFSET
	bar_bg.size = StatusMenuOverlayConfigScript.GAUGE_BAR_SIZE
	bar_bg.color = StatusMenuOverlayConfigScript.GAUGE_BACKGROUND_COLOR
	add_child(bar_bg)

	var bar_fill := ColorRect.new()
	bar_fill.position = bar_bg.position
	bar_fill.size = Vector2(0, StatusMenuOverlayConfigScript.GAUGE_BAR_SIZE.y)
	bar_fill.color = fill_color
	add_child(bar_fill)

	var value := _make_label(
		"",
		origin + StatusMenuOverlayConfigScript.GAUGE_VALUE_OFFSET,
		StatusMenuOverlayConfigScript.GAUGE_VALUE_SIZE,
		StatusMenuOverlayConfigScript.GAUGE_FONT_SIZE,
		StatusMenuOverlayConfigScript.GAUGE_VALUE_COLOR
	)
	TextThemeHelpersScript.apply_alignment(value, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER)
	add_child(value)

	_gauge_rows[key] = {
		"fill": bar_fill,
		"value": value
	}


func _update_gauge(key: String, value: int) -> void:
	var row := Dictionary(_gauge_rows.get(key, {}))
	if row.is_empty():
		return
	var clamped := clampi(value, 0, 100)
	var fill := row.get("fill") as ColorRect
	if fill != null:
		fill.size.x = StatusMenuOverlayConfigScript.GAUGE_BAR_SIZE.x * float(clamped) / 100.0
	var value_label := row.get("value") as Label
	if value_label != null:
		value_label.text = "%d" % clamped


func _status_note(status: Dictionary, leverage_blessing_active: bool = false) -> String:
	if leverage_blessing_active:
		return "레버리지의 여신이 지켜보는 동안, 자산이 벌어들인 좋은 결실은 한 번 더 겹쳐진다."
	var health := int(status.get(PlayerStatusKeysScript.KEY_HEALTH, 0))
	var fatigue := int(status.get(PlayerStatusKeysScript.KEY_FATIGUE, 0))
	if health <= 35:
		return "건강이 낮아. 0이 되면 게임오버라 회복 행동을 먼저 챙기는 게 좋아."
	if fatigue >= 95:
		return "피로가 매우 높아. 평일에는 무리하면 강제 휴식이 발생할 수 있어."
	if fatigue >= 85:
		return "피로가 조금 쌓였어. 컨디션을 보면서 가끔 가벼운 하루를 섞어도 좋아."
	return "아직 큰 위험 신호는 없어. 돈과 컨디션 균형을 보면서 움직이자."


func _make_label(text: String, position_value: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := MarketUiStyleScript.make_label(font_size, color)
	label.text = text
	label.position = position_value
	label.size = size_value
	TextThemeHelpersScript.center_vertical(label)
	return label
