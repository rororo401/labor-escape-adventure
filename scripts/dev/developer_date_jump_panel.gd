class_name DeveloperDateJumpPanel
extends VBoxContainer

signal standing_calibrator_requested
signal result_popup_calibrator_requested
signal date_jump_requested(date: String)

const DeveloperDateJumpPanelConfigScript := preload("res://scripts/dev/developer_date_jump_panel_config.gd")
const DeveloperUiHelpersScript := preload("res://scripts/dev/developer_ui_helpers.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")

const FIRST_FRIDAY_DATE := DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_DATE
const FIRST_SATURDAY_DATE := DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_DATE

var _date_input: LineEdit


func build(default_jump_date: String = FIRST_SATURDAY_DATE) -> void:
	name = DeveloperDateJumpPanelConfigScript.PANEL_NAME
	PanelLayoutHelpersScript.apply_separation(self, DeveloperDateJumpPanelConfigScript.PANEL_SEPARATION)

	var standing_button := DeveloperUiHelpersScript.make_menu_button(DeveloperDateJumpPanelConfigScript.STANDING_BUTTON_TEXT)
	standing_button.name = DeveloperDateJumpPanelConfigScript.STANDING_BUTTON_NAME
	standing_button.pressed.connect(func() -> void:
		standing_calibrator_requested.emit()
	)
	add_child(standing_button)

	var result_popup_button := DeveloperUiHelpersScript.make_menu_button(DeveloperDateJumpPanelConfigScript.RESULT_POPUP_BUTTON_TEXT)
	result_popup_button.name = DeveloperDateJumpPanelConfigScript.RESULT_POPUP_BUTTON_NAME
	result_popup_button.pressed.connect(func() -> void:
		result_popup_calibrator_requested.emit()
	)
	add_child(result_popup_button)

	var first_friday_button := DeveloperUiHelpersScript.make_menu_button(DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_BUTTON_TEXT)
	first_friday_button.name = DeveloperDateJumpPanelConfigScript.FIRST_FRIDAY_BUTTON_NAME
	first_friday_button.pressed.connect(func() -> void:
		date_jump_requested.emit(FIRST_FRIDAY_DATE)
	)
	add_child(first_friday_button)

	var first_saturday_button := DeveloperUiHelpersScript.make_menu_button(DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_BUTTON_TEXT)
	first_saturday_button.name = DeveloperDateJumpPanelConfigScript.FIRST_SATURDAY_BUTTON_NAME
	first_saturday_button.pressed.connect(func() -> void:
		date_jump_requested.emit(FIRST_SATURDAY_DATE)
	)
	add_child(first_saturday_button)

	var baseline_label := DeveloperUiHelpersScript.make_label(
		DeveloperDateJumpPanelConfigScript.BASELINE_FONT_SIZE,
		DeveloperDateJumpPanelConfigScript.BASELINE_COLOR
	)
	baseline_label.name = DeveloperDateJumpPanelConfigScript.BASELINE_LABEL_NAME
	baseline_label.text = DeveloperDateJumpPanelConfigScript.BASELINE_TEXT
	baseline_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	baseline_label.custom_minimum_size = DeveloperDateJumpPanelConfigScript.BASELINE_LABEL_SIZE
	add_child(baseline_label)

	var date_row := HBoxContainer.new()
	date_row.name = DeveloperDateJumpPanelConfigScript.DATE_ROW_NAME
	PanelLayoutHelpersScript.apply_separation(date_row, DeveloperDateJumpPanelConfigScript.DATE_ROW_SEPARATION)
	add_child(date_row)

	_date_input = LineEdit.new()
	_date_input.name = DeveloperDateJumpPanelConfigScript.DATE_INPUT_NAME
	_date_input.text = default_jump_date if not default_jump_date.strip_edges().is_empty() else FIRST_SATURDAY_DATE
	_date_input.placeholder_text = DeveloperDateJumpPanelConfigScript.DATE_PLACEHOLDER
	_date_input.custom_minimum_size = DeveloperDateJumpPanelConfigScript.DATE_INPUT_SIZE
	DeveloperUiHelpersScript.style_line_edit(_date_input)
	_date_input.text_submitted.connect(func(_text: String) -> void:
		_request_input_date_jump()
	)
	date_row.add_child(_date_input)

	var date_jump_button := DeveloperUiHelpersScript.make_compact_button(DeveloperDateJumpPanelConfigScript.DATE_BUTTON_TEXT)
	date_jump_button.name = DeveloperDateJumpPanelConfigScript.DATE_BUTTON_NAME
	date_jump_button.pressed.connect(_request_input_date_jump)
	date_row.add_child(date_jump_button)


func _request_input_date_jump() -> void:
	if _date_input == null:
		date_jump_requested.emit("")
		return
	date_jump_requested.emit(_date_input.text.strip_edges())
