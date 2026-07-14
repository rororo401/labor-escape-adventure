extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperDayActionPreviewPanelConfigScript := preload("res://scripts/dev/developer_day_action_preview_panel_config.gd")
const DeveloperDayActionPreviewPanelScript := preload("res://scripts/dev/developer_day_action_preview_panel.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()
var _previewed_ids: Array[String] = []
var _messages: Array[String] = []


func _initialize() -> void:
	var panel := DeveloperDayActionPreviewPanelScript.new()
	root.add_child(panel)
	panel.build()
	panel.day_action_preview_requested.connect(func(event: Dictionary) -> void:
		_previewed_ids.append(String(event.get(DayEventKeysScript.KEY_ID, "")))
	)
	panel.status_message_requested.connect(func(text: String) -> void:
		_messages.append(text)
	)
	await process_frame

	_expect(panel.name == DeveloperDayActionPreviewPanelConfigScript.PANEL_NAME, "panel should use configured name")
	_expect(panel.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == DeveloperDayActionPreviewPanelConfigScript.PANEL_SEPARATION, "panel should use configured separation")
	_expect(_find_label_with_text(panel, DeveloperDayActionPreviewPanelConfigScript.TITLE_TEXT) != null, "panel should render configured title")

	var preview_row := _helpers.find_node(panel, DeveloperDayActionPreviewPanelConfigScript.PREVIEW_ROW_NAME) as HBoxContainer
	var quick_row := _helpers.find_node(panel, DeveloperDayActionPreviewPanelConfigScript.QUICK_ROW_NAME) as HBoxContainer
	var option := _helpers.find_node(panel, DeveloperDayActionPreviewPanelConfigScript.PREVIEW_OPTION_NAME) as OptionButton
	var preview_button := _helpers.find_node(panel, DeveloperDayActionPreviewPanelConfigScript.PREVIEW_BUTTON_NAME) as Button
	_expect(preview_row != null and preview_row.get_theme_constant(PanelLayoutHelpersScript.THEME_SEPARATION) == DeveloperDayActionPreviewPanelConfigScript.ROW_SEPARATION, "preview row should use configured separation")
	_expect(quick_row != null and quick_row.get_child_count() == DeveloperDayActionPreviewPanelConfigScript.QUICK_PREVIEWS.size(), "quick row should render configured quick buttons")
	_expect(option != null and option.custom_minimum_size == DeveloperDayActionPreviewPanelConfigScript.OPTION_SIZE, "option should use configured size")
	_expect(option != null and not option.fit_to_longest_item, "option should not widen the developer panel for long event names")
	_expect(option.get_combined_minimum_size().x <= DeveloperDayActionPreviewPanelConfigScript.OPTION_SIZE.x, "option minimum width should stay within configured size")
	_expect(option.item_count > 0, "option should list closed-day events")
	_expect(preview_button != null and preview_button.text == DeveloperDayActionPreviewPanelConfigScript.PREVIEW_BUTTON_TEXT, "preview button should use configured copy")

	for preview: Dictionary in DeveloperDayActionPreviewPanelConfigScript.QUICK_PREVIEWS:
		var button := _helpers.find_node(panel, String(preview.get(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_BUTTON_NAME, ""))) as Button
		_expect(button != null and button.text == String(preview.get(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_TEXT, "")), "quick preview button should use configured copy")

	(_helpers.find_node(panel, String(Dictionary(DeveloperDayActionPreviewPanelConfigScript.QUICK_PREVIEWS[0]).get(DeveloperDayActionPreviewPanelConfigScript.QUICK_KEY_BUTTON_NAME, ""))) as Button).pressed.emit()
	await process_frame
	_expect(_previewed_ids.has("part_time"), "quick preview should emit configured part-time action")

	preview_button.pressed.emit()
	await process_frame
	_expect(not _previewed_ids.is_empty() or not _messages.is_empty(), "main preview button should emit a preview or message")

	print("Developer day-action preview panel view smoke test passed.")
	finish_test()


func _find_label_with_text(root_node: Node, text: String) -> Label:
	if root_node is Label:
		var label := root_node as Label
		if label.text == text:
			return label
	for child in root_node.get_children():
		var found := _find_label_with_text(child, text)
		if found != null:
			return found
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
