class_name ClosedDayPanel
extends PanelContainer

signal category_selected(category_id: String)
signal action_selected(action_id: String)
signal flow_requested

const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const FlowButtonStateConfigScript := preload("res://scripts/ui/flow_button_state_config.gd")
const ClosedDayFlowButtonStateScript := preload("res://scripts/ui/closed_day_flow_button_state.gd")
const ClosedDayButtonListScript := preload("res://scripts/ui/closed_day_button_list.gd")
const ClosedDayPanelConfigScript := preload("res://scripts/ui/closed_day_panel_config.gd")
const MarketFlowCopyScript := preload("res://scripts/ui/market_flow_copy.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")

var _title_label: Label
var _body_label: Label
var _category_row: HBoxContainer
var _choice_grid: GridContainer
var _flow_button: Button
var _message_label: Label
var _category_button_list = ClosedDayButtonListScript.new()
var _choice_button_list = ClosedDayButtonListScript.new()


func build() -> void:
	name = ClosedDayPanelConfigScript.PANEL_NAME
	position = ClosedDayPanelConfigScript.PANEL_POSITION
	size = ClosedDayPanelConfigScript.PANEL_SIZE
	custom_minimum_size = ClosedDayPanelConfigScript.PANEL_SIZE
	visible = false
	StyleboxThemeHelpersScript.apply_panel_style(
		self,
		MarketUiStyleScript.make_panel_style(
			ClosedDayPanelConfigScript.PANEL_COLOR,
			ClosedDayPanelConfigScript.PANEL_BORDER_COLOR
		)
	)

	var layout := PanelLayoutHelpersScript.add_margin_layout(
		self,
		size,
		ClosedDayPanelConfigScript.PANEL_MARGIN,
		ClosedDayPanelConfigScript.LAYOUT_SEPARATION
	)

	_title_label = _make_title_label()
	_title_label.text = ClosedDayPanelConfigScript.DEFAULT_TITLE
	layout.add_child(_title_label)

	_body_label = _make_body_label(ClosedDayPanelConfigScript.BODY_FONT_SIZE)
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.custom_minimum_size = ClosedDayPanelConfigScript.BODY_LABEL_SIZE
	layout.add_child(_body_label)

	_category_row = PanelLayoutHelpersScript.make_row(
		ClosedDayPanelConfigScript.ROW_SEPARATION,
		ClosedDayPanelConfigScript.CATEGORY_ROW_NAME
	)
	layout.add_child(_category_row)

	_choice_grid = PanelLayoutHelpersScript.make_grid(
		ClosedDayPanelConfigScript.GRID_COLUMNS,
		ClosedDayPanelConfigScript.ROW_SEPARATION,
		ClosedDayPanelConfigScript.CHOICE_GRID_NAME
	)
	layout.add_child(_choice_grid)

	_flow_button = MarketUiStyleScript.make_primary_button(MarketFlowCopyScript.DEFAULT_READY_TEXT, ClosedDayPanelConfigScript.FLOW_BUTTON_SIZE)
	_flow_button.name = ClosedDayPanelConfigScript.FLOW_BUTTON_NAME
	_flow_button.pressed.connect(func() -> void:
		flow_requested.emit()
	)
	layout.add_child(_flow_button)

	_message_label = _make_body_label(ClosedDayPanelConfigScript.MESSAGE_FONT_SIZE)
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.custom_minimum_size = ClosedDayPanelConfigScript.MESSAGE_LABEL_SIZE
	layout.add_child(_message_label)


func set_day_text(title: String, body: String) -> void:
	if _title_label != null:
		_title_label.text = title
	if _body_label != null:
		_body_label.text = body


func set_message(text: String) -> void:
	if _message_label != null:
		_message_label.text = text


func render_categories(categories: Array, selected_category_id: String, disabled: bool = false) -> bool:
	if _category_row == null:
		return false

	return _category_button_list.render_categories(
		_category_row,
		categories,
		selected_category_id,
		disabled,
		func(category_id: String) -> void:
			category_selected.emit(category_id)
	)


func render_choices(choices: Array, selected_action_id: String, disabled: bool = false) -> void:
	if _choice_grid == null:
		return

	_choice_button_list.render_choices(
		_choice_grid,
		choices,
		selected_action_id,
		disabled,
		func(action_id: String) -> void:
			action_selected.emit(action_id)
	)


func select_action(action_id: String) -> void:
	_choice_button_list.select_item(action_id)


func set_choice_buttons_disabled(disabled: bool) -> void:
	_category_button_list.set_disabled(disabled)
	_choice_button_list.set_disabled(disabled)


func update_flow_button(
	game_finished: bool,
	game_clear: bool,
	game_over: bool,
	day_completed: bool,
	sleep_sequence: bool,
	completing_day: bool,
	has_selection: bool
) -> void:
	if _flow_button == null:
		return

	var state := ClosedDayFlowButtonStateScript.build(
		game_finished,
		game_clear,
		game_over,
		day_completed,
		sleep_sequence,
		completing_day,
		has_selection
	)
	_flow_button.text = String(state.get(FlowButtonStateConfigScript.KEY_TEXT, FlowButtonStateConfigScript.EMPTY_TEXT))
	_flow_button.disabled = bool(state.get(FlowButtonStateConfigScript.KEY_DISABLED, FlowButtonStateConfigScript.DEFAULT_DISABLED))


func _make_title_label() -> Label:
	return MarketUiStyleScript.make_label(ClosedDayPanelConfigScript.TITLE_FONT_SIZE, ClosedDayPanelConfigScript.TITLE_COLOR)


func _make_body_label(size: int) -> Label:
	return MarketUiStyleScript.make_label(size, ClosedDayPanelConfigScript.BODY_COLOR)
