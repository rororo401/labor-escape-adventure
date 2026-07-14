class_name StandingCalibratorView
extends RefCounted

const DeveloperUiHelpersScript := preload("res://scripts/dev/developer_ui_helpers.gd")
const CharacterAssetKeysScript := preload("res://scripts/core/character_asset_keys.gd")
const StandingCalibratorDisplayStateScript := preload("res://scripts/dev/standing_calibrator_display_state.gd")
const StandingCalibratorViewConfigScript := preload("res://scripts/dev/standing_calibrator_view_config.gd")
const StandingBustLayoutScript := preload("res://scripts/core/standing_bust_layout.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")


static func build(host: Node, background_path: String, entries: Array[Dictionary], callbacks: Dictionary = {}) -> Dictionary:
	var background := _make_background(background_path)
	host.add_child(background)

	var character_rect := _make_character_rect()
	host.add_child(character_rect)

	var panel := _make_panel()
	host.add_child(panel)

	var layout_box := _make_panel_layout(panel)
	var entry_label := DeveloperUiHelpersScript.make_label(
		StandingCalibratorViewConfigScript.ENTRY_LABEL_FONT_SIZE,
		StandingCalibratorViewConfigScript.ENTRY_LABEL_COLOR
	)
	entry_label.name = StandingCalibratorViewConfigScript.ENTRY_LABEL_NAME
	entry_label.text = StandingCalibratorViewConfigScript.ENTRY_LABEL_TEXT
	layout_box.add_child(entry_label)

	var button_grid := _make_button_grid(layout_box)
	var entry_buttons: Array[Button] = _make_entry_buttons(button_grid, entries, callbacks.get(StandingCalibratorViewConfigScript.CALLBACK_SELECT_ENTRY, Callable()))

	var action_row := PanelLayoutHelpersScript.make_row(StandingCalibratorViewConfigScript.ACTION_ROW_SEPARATION)
	layout_box.add_child(action_row)

	var confirm_button := _make_action_button(
		StandingCalibratorViewConfigScript.CONFIRM_BUTTON_NAME,
		StandingCalibratorViewConfigScript.CONFIRM_BUTTON_TEXT,
		StandingCalibratorViewConfigScript.CONFIRM_BUTTON_SIZE,
		callbacks.get(StandingCalibratorViewConfigScript.CALLBACK_CONFIRM, Callable())
	)
	action_row.add_child(confirm_button)

	var reset_button := _make_action_button(
		StandingCalibratorViewConfigScript.RESET_BUTTON_NAME,
		StandingCalibratorViewConfigScript.RESET_BUTTON_TEXT,
		StandingCalibratorViewConfigScript.RESET_BUTTON_SIZE,
		callbacks.get(StandingCalibratorViewConfigScript.CALLBACK_RESET, Callable())
	)
	action_row.add_child(reset_button)

	var back_button := _make_action_button(
		StandingCalibratorViewConfigScript.BACK_BUTTON_NAME,
		StandingCalibratorViewConfigScript.BACK_BUTTON_TEXT,
		StandingCalibratorViewConfigScript.BACK_BUTTON_SIZE,
		callbacks.get(StandingCalibratorViewConfigScript.CALLBACK_BACK, Callable())
	)
	action_row.add_child(back_button)

	var offset_label := DeveloperUiHelpersScript.make_label(
		StandingCalibratorViewConfigScript.OFFSET_LABEL_FONT_SIZE,
		StandingCalibratorViewConfigScript.OFFSET_LABEL_COLOR
	)
	offset_label.name = StandingCalibratorViewConfigScript.OFFSET_LABEL_NAME
	offset_label.text = ""
	action_row.add_child(offset_label)

	var save_label := DeveloperUiHelpersScript.make_label(
		StandingCalibratorViewConfigScript.SAVE_LABEL_FONT_SIZE,
		StandingCalibratorViewConfigScript.SAVE_LABEL_COLOR
	)
	save_label.name = StandingCalibratorViewConfigScript.SAVE_LABEL_NAME
	save_label.text = StandingCalibratorDisplayStateScript.INITIAL_HELP_TEXT
	layout_box.add_child(save_label)

	return {
		StandingCalibratorViewConfigScript.KEY_CHARACTER_RECT: character_rect,
		StandingCalibratorViewConfigScript.KEY_ENTRY_LABEL: entry_label,
		StandingCalibratorViewConfigScript.KEY_OFFSET_LABEL: offset_label,
		StandingCalibratorViewConfigScript.KEY_SAVE_LABEL: save_label,
		StandingCalibratorViewConfigScript.KEY_ENTRY_BUTTONS: entry_buttons,
		StandingCalibratorViewConfigScript.KEY_PANEL: panel
	}


static func _make_background(background_path: String) -> TextureRect:
	var background := TextureRect.new()
	background.name = StandingCalibratorViewConfigScript.BACKGROUND_NAME
	UiHelpers.apply_cover_texture(background, background_path)
	return background


static func _make_character_rect() -> TextureRect:
	var character_rect := TextureRect.new()
	character_rect.name = StandingCalibratorViewConfigScript.CHARACTER_RECT_NAME
	character_rect.size = StandingBustLayoutScript.BUST_SIZE
	character_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	character_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return character_rect


static func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = StandingCalibratorViewConfigScript.PANEL_NAME
	panel.position = StandingCalibratorViewConfigScript.PANEL_POSITION
	panel.size = StandingCalibratorViewConfigScript.PANEL_SIZE
	panel.custom_minimum_size = StandingCalibratorViewConfigScript.PANEL_SIZE
	DeveloperUiHelpersScript.apply_panel_style(
		panel,
		StandingCalibratorViewConfigScript.PANEL_COLOR,
		StandingCalibratorViewConfigScript.PANEL_BORDER_COLOR
	)
	return panel


static func _make_panel_layout(panel: PanelContainer) -> VBoxContainer:
	return PanelLayoutHelpersScript.add_margin_layout(
		panel,
		StandingCalibratorViewConfigScript.PANEL_SIZE,
		StandingCalibratorViewConfigScript.PANEL_MARGIN,
		StandingCalibratorViewConfigScript.LAYOUT_SEPARATION
	)


static func _make_button_grid(layout_box: VBoxContainer) -> GridContainer:
	var scroll := ScrollContainer.new()
	scroll.name = StandingCalibratorViewConfigScript.BUTTON_SCROLL_NAME
	scroll.custom_minimum_size = StandingCalibratorViewConfigScript.BUTTON_SCROLL_SIZE
	UiHelpers.disable_horizontal_scroll(scroll)
	layout_box.add_child(scroll)

	var button_grid := PanelLayoutHelpersScript.make_grid(
		StandingCalibratorViewConfigScript.BUTTON_GRID_COLUMNS,
		StandingCalibratorViewConfigScript.BUTTON_GRID_SEPARATION,
		StandingCalibratorViewConfigScript.BUTTON_GRID_NAME
	)
	scroll.add_child(button_grid)
	return button_grid


static func _make_entry_buttons(button_grid: GridContainer, entries: Array[Dictionary], select_callback: Callable) -> Array[Button]:
	var buttons: Array[Button] = []
	for index in entries.size():
		var entry: Dictionary = entries[index]
		var button := DeveloperUiHelpersScript.make_tool_button(
			"%02d %s" % [index + 1, String(entry.get(CharacterAssetKeysScript.ENTRY_LABEL, ""))],
			StandingCalibratorViewConfigScript.ENTRY_BUTTON_SIZE
		)
		button.clip_text = true
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.name = StandingCalibratorViewConfigScript.ENTRY_BUTTON_NAME_FORMAT % [index + 1]
		_connect_pressed(button, select_callback.bind(index))
		button_grid.add_child(button)
		buttons.append(button)
	return buttons


static func _make_action_button(node_name: String, text: String, min_size: Vector2, callback: Callable) -> Button:
	var button := DeveloperUiHelpersScript.make_tool_button(text, min_size)
	button.name = node_name
	_connect_pressed(button, callback)
	return button


static func _connect_pressed(button: Button, callback: Callable) -> void:
	if callback.is_valid():
		button.pressed.connect(callback)
