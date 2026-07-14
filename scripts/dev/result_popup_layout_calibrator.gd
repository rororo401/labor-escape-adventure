extends Control

const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DeveloperUiHelpersScript := preload("res://scripts/dev/developer_ui_helpers.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const ResultPopupLayoutStoreScript := preload("res://scripts/ui/result_popup_layout_store.gd")
const ResultPopupOverlayConfigScript := preload("res://scripts/ui/result_popup_overlay_config.gd")
const ResultPopupOverlayScript := preload("res://scripts/ui/result_popup_overlay.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")

const DEVELOPER_MODE_SCENE_PATH := UiScenePathsScript.DEVELOPER_MODE
const DESIGN_VIEWPORT_WIDTH := 720.0
const PANEL_POSITION := Vector2(24, 854)
const PANEL_SIZE := Vector2(672, 380)
const PANEL_SAFE_MARGIN_X := 24
const PANEL_MARGIN := {
	PanelLayoutHelpersScript.KEY_LEFT: 18,
	PanelLayoutHelpersScript.KEY_TOP: 14,
	PanelLayoutHelpersScript.KEY_RIGHT: 18,
	PanelLayoutHelpersScript.KEY_BOTTOM: 14
}
const FIELD_WIDTH := 126
const FIELD_HEIGHT := 46

var _store = ResultPopupLayoutStoreScript.new()
var _layout := {}
var _popup: ResultPopupOverlay
var _status_label: Label
var _inputs := {}
var _active_input_key := "panel_x"


func _ready() -> void:
	_layout = _store.load_layout()
	_build_screen()
	_apply_inputs()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_go_back()
			return
		var delta := _nudge_delta(_active_input_key, event.keycode)
		if delta != 0:
			get_viewport().set_input_as_handled()
			_nudge_input(_active_input_key, delta)


func _build_screen() -> void:
	var background := TextureRect.new()
	background.name = "ResultPopupCalibratorBackground"
	UiHelpers.apply_cover_texture(background, UiBackgroundPathsScript.HOME_MORNING_BRIEFING)
	add_child(background)

	_popup = ResultPopupOverlayScript.new()
	_popup.build()
	_popup.name = "ResultPopupCalibratorPreview"
	add_child(_popup)
	_popup.show_result(_sample_result())
	_popup.set_layout_override(_layout)

	var panel := PanelContainer.new()
	panel.name = "ResultPopupCalibratorPanel"
	var panel_size := _fit_panel_size()
	panel.position = _fit_panel_position(panel_size)
	panel.size = panel_size
	panel.custom_minimum_size = panel_size
	DeveloperUiHelpersScript.apply_panel_style(panel, Color("#fff8e8ee"), Color("#d8925c"))
	add_child(panel)

	var layout_box := PanelLayoutHelpersScript.add_margin_layout(
		panel,
		panel_size,
		PANEL_MARGIN,
		10
	)

	var title := DeveloperUiHelpersScript.make_label(24, Color("#33231e"))
	title.text = "오늘의 변화 위치 조정"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.apply_horizontal_alignment(title, HORIZONTAL_ALIGNMENT_CENTER)
	layout_box.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(_panel_content_width(panel_size), 198)
	UiHelpers.disable_horizontal_scroll(scroll)
	layout_box.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 4
	PanelLayoutHelpersScript.apply_separation(grid, 8)
	scroll.add_child(grid)

	_add_field(grid, "panel_x", ResultPopupOverlayConfigScript.KEY_PANEL_POSITION, ResultPopupOverlayConfigScript.KEY_X)
	_add_field(grid, "panel_y", ResultPopupOverlayConfigScript.KEY_PANEL_POSITION, ResultPopupOverlayConfigScript.KEY_Y)
	_add_field(grid, "title_x", ResultPopupOverlayConfigScript.KEY_TITLE_POSITION, ResultPopupOverlayConfigScript.KEY_X)
	_add_field(grid, "title_y", ResultPopupOverlayConfigScript.KEY_TITLE_POSITION, ResultPopupOverlayConfigScript.KEY_Y)
	_add_scalar_field(grid, "label_x", ResultPopupOverlayConfigScript.KEY_ROW_LABEL_X)
	_add_scalar_field(grid, "value_x", ResultPopupOverlayConfigScript.KEY_ROW_VALUE_X)
	for index in ResultPopupOverlayConfigScript.RESULT_ROW_COUNT:
		_add_row_y_field(grid, "row%d_y" % [index + 1], index)
	_add_field(grid, "button_x", ResultPopupOverlayConfigScript.KEY_CLOSE_BUTTON_POSITION, ResultPopupOverlayConfigScript.KEY_X)
	_add_field(grid, "button_y", ResultPopupOverlayConfigScript.KEY_CLOSE_BUTTON_POSITION, ResultPopupOverlayConfigScript.KEY_Y)

	var action_row := PanelLayoutHelpersScript.make_row(10)
	layout_box.add_child(action_row)

	var apply_button := DeveloperUiHelpersScript.make_tool_button("적용", Vector2(120, 48), 20)
	apply_button.pressed.connect(_apply_inputs)
	action_row.add_child(apply_button)

	var save_button := DeveloperUiHelpersScript.make_tool_button("저장", Vector2(120, 48), 20)
	save_button.pressed.connect(_save_layout)
	action_row.add_child(save_button)

	var reset_button := DeveloperUiHelpersScript.make_tool_button("기본값", Vector2(120, 48), 20)
	reset_button.pressed.connect(_reset_defaults)
	action_row.add_child(reset_button)

	var back_button := DeveloperUiHelpersScript.make_tool_button("뒤로", Vector2(120, 48), 20)
	back_button.pressed.connect(_go_back)
	action_row.add_child(back_button)

	_status_label = DeveloperUiHelpersScript.make_label(16, Color("#8b4b3f"))
	_status_label.text = "값을 바꾸면 미리보기에 바로 적용된다."
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout_box.add_child(_status_label)

	var first_input := _inputs.get(_active_input_key) as LineEdit
	if first_input != null:
		first_input.grab_focus()


func _add_field(parent: Control, label_text: String, vector_key: String, axis_key: String) -> void:
	var vector := ResultPopupLayoutStoreScript.vector_from_payload(_layout.get(vector_key, {}), Vector2.ZERO)
	_add_input(parent, label_text, vector.x if axis_key == ResultPopupOverlayConfigScript.KEY_X else vector.y)


func _add_scalar_field(parent: Control, label_text: String, layout_key: String) -> void:
	_add_input(parent, label_text, float(_layout.get(layout_key, 0.0)))


func _add_row_y_field(parent: Control, label_text: String, index: int) -> void:
	var row_y: Array = _layout.get(ResultPopupOverlayConfigScript.KEY_ROW_Y, ResultPopupOverlayConfigScript.ROW_Y)
	_add_input(parent, label_text, float(row_y[index]))


func _add_input(parent: Control, label_text: String, value: float) -> void:
	var label := DeveloperUiHelpersScript.make_label(15, Color("#5f443b"))
	label.text = label_text
	label.custom_minimum_size = Vector2(118, FIELD_HEIGHT)
	parent.add_child(label)

	var input := LineEdit.new()
	input.name = "%sInput" % label_text
	input.text = _format_number(value)
	input.custom_minimum_size = Vector2(FIELD_WIDTH, FIELD_HEIGHT)
	DeveloperUiHelpersScript.style_line_edit(input)
	input.focus_entered.connect(func() -> void:
		_active_input_key = label_text
	)
	input.gui_input.connect(func(event: InputEvent) -> void:
		_handle_field_gui_input(label_text, input, event)
	)
	input.text_changed.connect(func(_text: String) -> void:
		_apply_inputs()
	)
	parent.add_child(input)
	_inputs[label_text] = input


func _handle_field_gui_input(field_key: String, input: LineEdit, event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var delta := _nudge_delta(field_key, event.keycode)
		if delta != 0:
			input.accept_event()
			_nudge_input(field_key, delta)


func _nudge_delta(field_key: String, keycode: int) -> int:
	if field_key.ends_with("_x"):
		if keycode == KEY_LEFT:
			return -1
		if keycode == KEY_RIGHT:
			return 1
	if field_key.ends_with("_y"):
		if keycode == KEY_UP:
			return -1
		if keycode == KEY_DOWN:
			return 1
	return 0


func _nudge_input(field_key: String, delta: int) -> void:
	var input := _inputs.get(field_key) as LineEdit
	if input == null:
		return
	_active_input_key = field_key
	var value := _input_float(field_key, 0.0) + float(delta)
	input.text = _format_number(value)
	input.caret_column = input.text.length()
	_apply_inputs()
	if _status_label != null:
		_status_label.text = "%s: %s" % [field_key, input.text]


func _apply_inputs() -> void:
	if _popup == null:
		return
	_layout = ResultPopupLayoutStoreScript.normalize_layout(_read_layout())
	_popup.set_layout_override(_layout)
	if _status_label != null:
		_status_label.text = "미리보기 적용됨. 저장하면 게임 결과창에도 적용된다."


func _save_layout() -> void:
	_apply_inputs()
	if _store.save_layout(_layout):
		_status_label.text = "저장됨: %s / %s" % [_store.user_path, _store.default_path]
	else:
		_status_label.text = "저장 실패: %s" % _store.user_path


func _reset_defaults() -> void:
	_layout = ResultPopupOverlayConfigScript.default_layout()
	_set_inputs_from_layout()
	_apply_inputs()
	if _status_label != null:
		_status_label.text = "기본값으로 되돌림. 저장하려면 저장 버튼을 눌러줘."


func _set_inputs_from_layout() -> void:
	_set_input("panel_x", _vector_value(ResultPopupOverlayConfigScript.KEY_PANEL_POSITION).x)
	_set_input("panel_y", _vector_value(ResultPopupOverlayConfigScript.KEY_PANEL_POSITION).y)
	_set_input("title_x", _vector_value(ResultPopupOverlayConfigScript.KEY_TITLE_POSITION).x)
	_set_input("title_y", _vector_value(ResultPopupOverlayConfigScript.KEY_TITLE_POSITION).y)
	_set_input("label_x", float(_layout.get(ResultPopupOverlayConfigScript.KEY_ROW_LABEL_X, ResultPopupOverlayConfigScript.ROW_LABEL_X)))
	_set_input("value_x", float(_layout.get(ResultPopupOverlayConfigScript.KEY_ROW_VALUE_X, ResultPopupOverlayConfigScript.ROW_VALUE_X)))
	var row_y: Array = _layout.get(ResultPopupOverlayConfigScript.KEY_ROW_Y, ResultPopupOverlayConfigScript.ROW_Y)
	for index in ResultPopupOverlayConfigScript.RESULT_ROW_COUNT:
		_set_input("row%d_y" % [index + 1], float(row_y[index]))
	_set_input("button_x", _vector_value(ResultPopupOverlayConfigScript.KEY_CLOSE_BUTTON_POSITION).x)
	_set_input("button_y", _vector_value(ResultPopupOverlayConfigScript.KEY_CLOSE_BUTTON_POSITION).y)


func _set_input(key: String, value: float) -> void:
	var input := _inputs.get(key) as LineEdit
	if input != null:
		input.text = _format_number(value)


func _read_layout() -> Dictionary:
	var row_y: Array = []
	for index in ResultPopupOverlayConfigScript.RESULT_ROW_COUNT:
		row_y.append(_input_float("row%d_y" % [index + 1], ResultPopupOverlayConfigScript.ROW_Y[index]))
	return {
		ResultPopupOverlayConfigScript.KEY_PANEL_POSITION: {
			ResultPopupOverlayConfigScript.KEY_X: _input_float("panel_x", ResultPopupOverlayConfigScript.PANEL_POSITION.x),
			ResultPopupOverlayConfigScript.KEY_Y: _input_float("panel_y", ResultPopupOverlayConfigScript.PANEL_POSITION.y)
		},
		ResultPopupOverlayConfigScript.KEY_TITLE_POSITION: {
			ResultPopupOverlayConfigScript.KEY_X: _input_float("title_x", ResultPopupOverlayConfigScript.TITLE_POSITION.x),
			ResultPopupOverlayConfigScript.KEY_Y: _input_float("title_y", ResultPopupOverlayConfigScript.TITLE_POSITION.y)
		},
		ResultPopupOverlayConfigScript.KEY_ROW_LABEL_X: _input_float("label_x", ResultPopupOverlayConfigScript.ROW_LABEL_X),
		ResultPopupOverlayConfigScript.KEY_ROW_VALUE_X: _input_float("value_x", ResultPopupOverlayConfigScript.ROW_VALUE_X),
		ResultPopupOverlayConfigScript.KEY_ROW_Y: row_y,
		ResultPopupOverlayConfigScript.KEY_CLOSE_BUTTON_POSITION: {
			ResultPopupOverlayConfigScript.KEY_X: _input_float("button_x", ResultPopupOverlayConfigScript.CLOSE_BUTTON_POSITION.x),
			ResultPopupOverlayConfigScript.KEY_Y: _input_float("button_y", ResultPopupOverlayConfigScript.CLOSE_BUTTON_POSITION.y)
		}
	}


func _input_float(key: String, fallback: float) -> float:
	var input := _inputs.get(key) as LineEdit
	if input == null:
		return fallback
	var text := input.text.strip_edges()
	if text.is_empty() or not text.is_valid_float():
		return fallback
	return text.to_float()


func _vector_value(key: String) -> Vector2:
	var defaults := ResultPopupOverlayConfigScript.default_layout()
	return ResultPopupLayoutStoreScript.vector_from_payload(_layout.get(key, defaults.get(key, {})), Vector2.ZERO)


func _sample_result() -> Dictionary:
	return {
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
			PlayerStatusKeysScript.KEY_INVESTMENT_ASSETS: 29320,
			PlayerStatusKeysScript.KEY_NET_WORTH: 5160780
		}
	}


func _format_number(value: float) -> String:
	return "%d" % int(round(value))


func _go_back() -> void:
	get_tree().change_scene_to_file(DEVELOPER_MODE_SCENE_PATH)


func _fit_panel_size() -> Vector2:
	var layout_width := _layout_width()
	if layout_width <= 0.0:
		return PANEL_SIZE
	var max_width := maxf(1.0, layout_width - float(PANEL_SAFE_MARGIN_X * 2))
	return Vector2(minf(PANEL_SIZE.x, max_width), PANEL_SIZE.y)


func _fit_panel_position(panel_size: Vector2) -> Vector2:
	var layout_width := _layout_width()
	if layout_width <= 0.0:
		return PANEL_POSITION
	var x := maxf(0.0, (layout_width - panel_size.x) * 0.5)
	return Vector2(x, PANEL_POSITION.y)


func _layout_width() -> float:
	var viewport_width := get_viewport_rect().size.x
	if viewport_width <= 0.0:
		return DESIGN_VIEWPORT_WIDTH
	return minf(viewport_width, DESIGN_VIEWPORT_WIDTH)


func _panel_content_width(panel_size: Vector2) -> float:
	return maxf(1.0, panel_size.x
		- float(PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0))
		- float(PANEL_MARGIN.get(PanelLayoutHelpersScript.KEY_RIGHT, 0))
	)
