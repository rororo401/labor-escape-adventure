class_name DeveloperDayActionPreviewPanel
extends VBoxContainer

signal day_action_preview_requested(event: Dictionary)
signal status_message_requested(text: String)

const DayEventCatalogScript := preload("res://scripts/core/dayflow/day_event_catalog.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DeveloperDayActionPreviewPanelConfigScript := preload("res://scripts/dev/developer_day_action_preview_panel_config.gd")
const DeveloperUiHelpersScript := preload("res://scripts/dev/developer_ui_helpers.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")

const DAY_EVENTS_PATH := DeveloperDayActionPreviewPanelConfigScript.DAY_EVENTS_PATH

var _action_preview_option: OptionButton
var _preview_action_ids: Array[String] = []
var _day_events = DayEventCatalogScript.new()


func build() -> void:
	name = DeveloperDayActionPreviewPanelConfigScript.PANEL_NAME
	PanelLayoutHelpersScript.apply_separation(self, DeveloperDayActionPreviewPanelConfigScript.PANEL_SEPARATION)
	_day_events.load_from_json(DAY_EVENTS_PATH)

	var preview_label := DeveloperUiHelpersScript.make_label(
		DeveloperDayActionPreviewPanelConfigScript.TITLE_FONT_SIZE,
		DeveloperDayActionPreviewPanelConfigScript.TITLE_COLOR
	)
	preview_label.text = DeveloperDayActionPreviewPanelConfigScript.TITLE_TEXT
	add_child(preview_label)

	var preview_row := HBoxContainer.new()
	preview_row.name = DeveloperDayActionPreviewPanelConfigScript.PREVIEW_ROW_NAME
	PanelLayoutHelpersScript.apply_separation(preview_row, DeveloperDayActionPreviewPanelConfigScript.ROW_SEPARATION)
	add_child(preview_row)

	_action_preview_option = OptionButton.new()
	_action_preview_option.name = DeveloperDayActionPreviewPanelConfigScript.PREVIEW_OPTION_NAME
	_action_preview_option.fit_to_longest_item = false
	_action_preview_option.custom_minimum_size = DeveloperDayActionPreviewPanelConfigScript.OPTION_SIZE
	DeveloperUiHelpersScript.style_line_edit(_action_preview_option)
	TextThemeHelpersScript.apply_font_size(_action_preview_option, DeveloperDayActionPreviewPanelConfigScript.OPTION_FONT_SIZE)
	preview_row.add_child(_action_preview_option)
	_populate_action_preview_options()

	var preview_button := DeveloperUiHelpersScript.make_compact_button(DeveloperDayActionPreviewPanelConfigScript.PREVIEW_BUTTON_TEXT)
	preview_button.name = DeveloperDayActionPreviewPanelConfigScript.PREVIEW_BUTTON_NAME
	preview_button.pressed.connect(_preview_selected_day_action)
	preview_row.add_child(preview_button)

	var quick_row := HBoxContainer.new()
	quick_row.name = DeveloperDayActionPreviewPanelConfigScript.QUICK_ROW_NAME
	PanelLayoutHelpersScript.apply_separation(quick_row, DeveloperDayActionPreviewPanelConfigScript.ROW_SEPARATION)
	add_child(quick_row)

	for preview: Dictionary in DeveloperDayActionPreviewPanelConfigScript.QUICK_PREVIEWS:
		var quick_button := DeveloperUiHelpersScript.make_compact_button(String(preview.get(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_TEXT, "")))
		quick_button.name = String(preview.get(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_BUTTON_NAME, ""))
		quick_button.pressed.connect(_preview_day_action.bind(String(preview.get(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_ID, ""))))
		quick_row.add_child(quick_button)


func _populate_action_preview_options() -> void:
	if _action_preview_option == null:
		return

	_action_preview_option.clear()
	_preview_action_ids.clear()
	for action: Dictionary in _day_events.day_actions:
		if String(action.get(DayEventKeysScript.KEY_MODE, "")) != DeveloperDayActionPreviewPanelConfigScript.CHOICE_CLOSED_MODE:
			continue
		var action_id := String(action.get(DayEventKeysScript.KEY_ID, ""))
		if action_id.is_empty():
			continue
		_preview_action_ids.append(action_id)
		_action_preview_option.add_item("%s  [%s]" % [
			String(action.get(DayEventKeysScript.KEY_NAME_KO, action_id)),
			action_id
		])
	if _action_preview_option.item_count > 0:
		_action_preview_option.select(0)


func _preview_selected_day_action() -> void:
	if _action_preview_option == null:
		status_message_requested.emit("이벤트 선택기를 찾지 못했다.")
		return
	var index := _action_preview_option.selected
	if index < 0 or index >= _preview_action_ids.size():
		status_message_requested.emit("미리볼 이벤트를 선택해줘.")
		return
	_preview_day_action(_preview_action_ids[index])


func _preview_day_action(action_id: String) -> void:
	var event := _day_events.get_action(action_id)
	if event.is_empty():
		status_message_requested.emit("이벤트를 찾지 못했다: %s" % action_id)
		return
	day_action_preview_requested.emit(event)
