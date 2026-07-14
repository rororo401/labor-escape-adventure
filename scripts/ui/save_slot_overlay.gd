class_name SaveSlotOverlay
extends Control

signal save_requested(kind: String, slot_index: int)
signal load_requested(kind: String, slot_index: int)

const GameSaveKeysScript := preload("res://scripts/core/save/game_save_keys.gd")
const GameSaveSlotStoreScript := preload("res://scripts/core/save/game_save_slot_store.gd")
const MarketUiFormatScript := preload("res://scripts/ui/market_ui_format.gd")
const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const SaveSlotOverlayConfigScript := preload("res://scripts/ui/save_slot_overlay_config.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var _message_label: Label
var _rows := {}
var _confirm_layer: Control
var _confirm_message: Label
var _confirm_accept_button: Button
var _pending_action := {}


func build() -> void:
	name = SaveSlotOverlayConfigScript.OVERLAY_NAME
	UiHelpers.apply_full_rect(self)
	UiHelpers.stop_mouse(self)
	visible = false

	var backdrop := ColorRect.new()
	backdrop.name = SaveSlotOverlayConfigScript.BACKDROP_NAME
	UiHelpers.apply_full_rect(backdrop)
	backdrop.color = SaveSlotOverlayConfigScript.BACKDROP_COLOR
	add_child(backdrop)

	var panel := Panel.new()
	panel.name = SaveSlotOverlayConfigScript.PANEL_NAME
	panel.position = SaveSlotOverlayConfigScript.PANEL_POSITION
	panel.size = SaveSlotOverlayConfigScript.PANEL_SIZE
	panel.add_theme_stylebox_override("panel", UiHelpers.panel_style(
		SaveSlotOverlayConfigScript.PANEL_COLOR,
		SaveSlotOverlayConfigScript.PANEL_BORDER_COLOR
	))
	add_child(panel)

	var title := _make_label("저장 / 불러오기", SaveSlotOverlayConfigScript.TITLE_POSITION, SaveSlotOverlayConfigScript.TITLE_SIZE, SaveSlotOverlayConfigScript.TITLE_FONT_SIZE)
	title.name = SaveSlotOverlayConfigScript.TITLE_NAME
	TextThemeHelpersScript.apply_alignment(title, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(title)

	_message_label = _make_label(SaveSlotOverlayConfigScript.DEFAULT_MESSAGE, SaveSlotOverlayConfigScript.MESSAGE_POSITION, SaveSlotOverlayConfigScript.MESSAGE_SIZE, SaveSlotOverlayConfigScript.MESSAGE_FONT_SIZE)
	_message_label.name = SaveSlotOverlayConfigScript.MESSAGE_NAME
	TextThemeHelpersScript.apply_alignment(_message_label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(_message_label)

	var row_index := 0
	for kind in [GameSaveSlotStoreScript.SLOT_KIND_MANUAL, GameSaveSlotStoreScript.SLOT_KIND_AUTO]:
		for slot_index in range(1, 4):
			_add_slot_row(kind, slot_index, row_index)
			row_index += 1

	var close_button := MarketUiStyleScript.make_soft_button("닫기", SaveSlotOverlayConfigScript.CLOSE_SIZE, SaveSlotOverlayConfigScript.CLOSE_FONT_SIZE)
	close_button.name = SaveSlotOverlayConfigScript.CLOSE_BUTTON_NAME
	close_button.position = SaveSlotOverlayConfigScript.CLOSE_POSITION
	close_button.pressed.connect(_hide_overlay)
	add_child(close_button)

	_build_confirmation()


func show_slots(summaries: Array[Dictionary]) -> void:
	_cancel_confirmation()
	var by_key := {}
	for summary in summaries:
		by_key[_slot_key(String(summary.get(GameSaveSlotStoreScript.KEY_KIND, "")), int(summary.get(GameSaveSlotStoreScript.KEY_INDEX, 0)))] = summary
	for key in _rows:
		_apply_summary(Dictionary(_rows.get(key, {})), Dictionary(by_key.get(key, {})))
	set_message(SaveSlotOverlayConfigScript.DEFAULT_MESSAGE)
	visible = true


func set_message(text: String) -> void:
	if _message_label != null:
		_message_label.text = text


func _add_slot_row(kind: String, slot_index: int, row_index: int) -> void:
	var row := Panel.new()
	var node_prefix := "%s%d" % [kind.capitalize(), slot_index]
	row.name = "%sRow" % node_prefix
	row.position = Vector2(
		SaveSlotOverlayConfigScript.ROW_X,
		SaveSlotOverlayConfigScript.ROW_START_Y + row_index * (SaveSlotOverlayConfigScript.ROW_HEIGHT + SaveSlotOverlayConfigScript.ROW_GAP)
	)
	row.size = SaveSlotOverlayConfigScript.ROW_SIZE
	row.add_theme_stylebox_override("panel", UiHelpers.panel_style(SaveSlotOverlayConfigScript.ROW_COLOR, SaveSlotOverlayConfigScript.ROW_BORDER_COLOR))
	add_child(row)

	var kind_text := "수동" if kind == GameSaveSlotStoreScript.SLOT_KIND_MANUAL else "자동"
	var title := _make_label("%s 저장 %d" % [kind_text, slot_index], SaveSlotOverlayConfigScript.ROW_TITLE_OFFSET, SaveSlotOverlayConfigScript.ROW_TITLE_SIZE, SaveSlotOverlayConfigScript.ROW_TITLE_FONT_SIZE)
	title.name = "%sTitle" % node_prefix
	row.add_child(title)
	var summary_label := _make_label(SaveSlotOverlayConfigScript.EMPTY_SUMMARY, SaveSlotOverlayConfigScript.ROW_SUMMARY_OFFSET, SaveSlotOverlayConfigScript.ROW_SUMMARY_SIZE, SaveSlotOverlayConfigScript.ROW_SUMMARY_FONT_SIZE)
	summary_label.name = "%sSummary" % node_prefix
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(summary_label)

	var save_button: Button = null
	if kind == GameSaveSlotStoreScript.SLOT_KIND_MANUAL:
		save_button = MarketUiStyleScript.make_soft_button("저장", SaveSlotOverlayConfigScript.ROW_BUTTON_SIZE, SaveSlotOverlayConfigScript.ROW_BUTTON_FONT_SIZE)
		save_button.name = "%sSaveButton" % node_prefix
		save_button.position = SaveSlotOverlayConfigScript.SAVE_BUTTON_OFFSET
		save_button.pressed.connect(_emit_save_requested.bind(kind, slot_index))
		row.add_child(save_button)

	var load_button := MarketUiStyleScript.make_soft_button("불러오기", SaveSlotOverlayConfigScript.ROW_BUTTON_SIZE, SaveSlotOverlayConfigScript.ROW_BUTTON_FONT_SIZE)
	load_button.name = "%sLoadButton" % node_prefix
	load_button.position = SaveSlotOverlayConfigScript.LOAD_BUTTON_OFFSET
	load_button.pressed.connect(_emit_load_requested.bind(kind, slot_index))
	row.add_child(load_button)

	_rows[_slot_key(kind, slot_index)] = {
		"summary": summary_label,
		"save": save_button,
		"load": load_button,
		"occupied": false,
		"valid": false
	}


func _apply_summary(row_refs: Dictionary, summary: Dictionary) -> void:
	var summary_label := row_refs.get("summary") as Label
	var load_button := row_refs.get("load") as Button
	var occupied := bool(summary.get(GameSaveSlotStoreScript.KEY_OCCUPIED, false))
	var valid := bool(summary.get(GameSaveSlotStoreScript.KEY_VALID, false))
	row_refs["occupied"] = occupied
	row_refs["valid"] = valid
	if load_button != null:
		load_button.disabled = not valid
	if summary_label == null:
		return
	if not occupied:
		summary_label.text = SaveSlotOverlayConfigScript.EMPTY_SUMMARY
		return
	if not valid:
		summary_label.text = SaveSlotOverlayConfigScript.INVALID_SUMMARY
		return
	var difficulty := _difficulty_text(String(summary.get(GameSaveSlotStoreScript.KEY_DIFFICULTY, GameSaveKeysScript.DIFFICULTY_HARD)))
	var saved_at := float(summary.get(GameSaveSlotStoreScript.KEY_SAVED_AT_UNIX, 0.0))
	var saved_text := "저장 시각 미상" if saved_at <= 0.0 else Time.get_datetime_string_from_unix_time(floori(saved_at), true).replace("T", " ")
	summary_label.text = "%s · 순자산 %s · %s\n%s" % [
		String(summary.get(GameSaveSlotStoreScript.KEY_CURRENT_DATE, "")),
		MarketUiFormatScript.format_won(int(summary.get(GameSaveSlotStoreScript.KEY_NET_WORTH, 0))),
		difficulty,
		saved_text
	]


func _difficulty_text(difficulty: String) -> String:
	match difficulty:
		GameSaveKeysScript.DIFFICULTY_EASY:
			return "이지"
		GameSaveKeysScript.DIFFICULTY_NORMAL:
			return "노멀"
		_:
			return "하드"


func _slot_key(kind: String, slot_index: int) -> String:
	return "%s:%d" % [kind, slot_index]


func _emit_save_requested(kind: String, slot_index: int) -> void:
	var row_refs := Dictionary(_rows.get(_slot_key(kind, slot_index), {}))
	if bool(row_refs.get("occupied", false)):
		_show_confirmation("save", kind, slot_index)
		return
	save_requested.emit(kind, slot_index)


func _emit_load_requested(kind: String, slot_index: int) -> void:
	var row_refs := Dictionary(_rows.get(_slot_key(kind, slot_index), {}))
	if not bool(row_refs.get("valid", false)):
		return
	_show_confirmation("load", kind, slot_index)


func _build_confirmation() -> void:
	_confirm_layer = Control.new()
	_confirm_layer.name = SaveSlotOverlayConfigScript.CONFIRM_LAYER_NAME
	UiHelpers.apply_full_rect(_confirm_layer)
	UiHelpers.stop_mouse(_confirm_layer)
	_confirm_layer.visible = false
	add_child(_confirm_layer)

	var backdrop := ColorRect.new()
	UiHelpers.apply_full_rect(backdrop)
	backdrop.color = SaveSlotOverlayConfigScript.CONFIRM_BACKDROP_COLOR
	_confirm_layer.add_child(backdrop)

	var panel := Panel.new()
	panel.name = SaveSlotOverlayConfigScript.CONFIRM_PANEL_NAME
	panel.position = SaveSlotOverlayConfigScript.CONFIRM_PANEL_POSITION
	panel.size = SaveSlotOverlayConfigScript.CONFIRM_PANEL_SIZE
	panel.add_theme_stylebox_override("panel", UiHelpers.panel_style(
		SaveSlotOverlayConfigScript.CONFIRM_PANEL_COLOR,
		SaveSlotOverlayConfigScript.CONFIRM_PANEL_BORDER_COLOR
	))
	_confirm_layer.add_child(panel)

	_confirm_message = _make_label("", SaveSlotOverlayConfigScript.CONFIRM_MESSAGE_POSITION, SaveSlotOverlayConfigScript.CONFIRM_MESSAGE_SIZE, SaveSlotOverlayConfigScript.CONFIRM_MESSAGE_FONT_SIZE)
	_confirm_message.name = SaveSlotOverlayConfigScript.CONFIRM_MESSAGE_NAME
	_confirm_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.apply_alignment(_confirm_message, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	_confirm_layer.add_child(_confirm_message)

	var cancel_button := MarketUiStyleScript.make_soft_button(SaveSlotOverlayConfigScript.CONFIRM_CANCEL_TEXT, SaveSlotOverlayConfigScript.CONFIRM_BUTTON_SIZE, SaveSlotOverlayConfigScript.CONFIRM_BUTTON_FONT_SIZE)
	cancel_button.name = SaveSlotOverlayConfigScript.CONFIRM_CANCEL_BUTTON_NAME
	cancel_button.position = SaveSlotOverlayConfigScript.CONFIRM_CANCEL_POSITION
	cancel_button.pressed.connect(_cancel_confirmation)
	_confirm_layer.add_child(cancel_button)

	_confirm_accept_button = MarketUiStyleScript.make_soft_button("", SaveSlotOverlayConfigScript.CONFIRM_BUTTON_SIZE, SaveSlotOverlayConfigScript.CONFIRM_BUTTON_FONT_SIZE)
	_confirm_accept_button.name = SaveSlotOverlayConfigScript.CONFIRM_ACCEPT_BUTTON_NAME
	_confirm_accept_button.position = SaveSlotOverlayConfigScript.CONFIRM_ACCEPT_POSITION
	_confirm_accept_button.pressed.connect(_accept_confirmation)
	_confirm_layer.add_child(_confirm_accept_button)


func _show_confirmation(action: String, kind: String, slot_index: int) -> void:
	_pending_action = {"action": action, "kind": kind, "slot_index": slot_index}
	var kind_text := "수동" if kind == GameSaveSlotStoreScript.SLOT_KIND_MANUAL else "자동"
	if action == "save":
		_confirm_message.text = "수동 저장 %d번의 기존 기록을\n덮어쓸까?" % slot_index
		_confirm_accept_button.text = SaveSlotOverlayConfigScript.CONFIRM_OVERWRITE_TEXT
	else:
		_confirm_message.text = "%s 저장 %d번을 불러올까?\n저장하지 않은 진행은 사라질 수 있어." % [kind_text, slot_index]
		_confirm_accept_button.text = SaveSlotOverlayConfigScript.CONFIRM_LOAD_TEXT
	_confirm_layer.visible = true


func _accept_confirmation() -> void:
	var pending := _pending_action.duplicate(true)
	_cancel_confirmation()
	var action := String(pending.get("action", ""))
	var kind := String(pending.get("kind", ""))
	var slot_index := int(pending.get("slot_index", 0))
	if action == "save":
		save_requested.emit(kind, slot_index)
	elif action == "load":
		load_requested.emit(kind, slot_index)


func _cancel_confirmation() -> void:
	_pending_action = {}
	if _confirm_layer != null:
		_confirm_layer.visible = false


func _hide_overlay() -> void:
	_cancel_confirmation()
	hide()


func _make_label(text: String, position_value: Vector2, size_value: Vector2, font_size: int) -> Label:
	var label := MarketUiStyleScript.make_label(font_size, SaveSlotOverlayConfigScript.TEXT_COLOR)
	label.text = text
	label.position = position_value
	label.size = size_value
	return label
