class_name ClosedDayButtonList
extends RefCounted

const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const ClosedDayButtonItemStateConfigScript := preload("res://scripts/ui/closed_day_button_item_state_config.gd")
const ClosedDayButtonItemStateScript := preload("res://scripts/ui/closed_day_button_item_state.gd")
const ClosedDayButtonListConfigScript := preload("res://scripts/ui/closed_day_button_list_config.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")

var _buttons: Array[Button] = []
var _item_ids: Array[String] = []


func render_categories(
	container: Container,
	categories: Array,
	selected_category_id: String,
	disabled: bool,
	selected_callback: Callable
) -> bool:
	if container == null:
		return false

	_clear_container(container)
	var selected_exists := ClosedDayButtonItemStateScript.has_item_id(categories, selected_category_id)
	for category in categories:
		var state := ClosedDayButtonItemStateScript.category(category)
		var category_id := String(state.get(ClosedDayButtonItemStateConfigScript.KEY_ID, ClosedDayButtonItemStateConfigScript.EMPTY_ID))
		var button := _make_button(
			String(state.get(ClosedDayButtonItemStateConfigScript.KEY_LABEL, ClosedDayButtonItemStateConfigScript.EMPTY_LABEL)),
			ClosedDayButtonListConfigScript.CATEGORY_BUTTON_SIZE,
			ClosedDayButtonListConfigScript.CATEGORY_BUTTON_FONT_SIZE,
			disabled
		)
		_apply_selection(button, category_id == selected_category_id)
		_connect_selection(button, category_id, selected_callback)
		container.add_child(button)
		_buttons.append(button)
		_item_ids.append(category_id)
	return selected_exists


func render_choices(
	container: Container,
	choices: Array,
	selected_action_id: String,
	disabled: bool,
	selected_callback: Callable
) -> void:
	if container == null:
		return

	_clear_container(container)
	for action in choices:
		var state := ClosedDayButtonItemStateScript.choice(action)
		var action_id := String(state.get(ClosedDayButtonItemStateConfigScript.KEY_ID, ClosedDayButtonItemStateConfigScript.EMPTY_ID))
		var button := _make_button(
			String(state.get(ClosedDayButtonItemStateConfigScript.KEY_LABEL, ClosedDayButtonItemStateConfigScript.EMPTY_LABEL)),
			ClosedDayButtonListConfigScript.CHOICE_BUTTON_SIZE,
			ClosedDayButtonListConfigScript.CHOICE_BUTTON_FONT_SIZE,
			disabled
		)
		button.tooltip_text = String(state.get(ClosedDayButtonItemStateConfigScript.KEY_TOOLTIP, ClosedDayButtonItemStateConfigScript.EMPTY_LABEL))
		_apply_selection(button, action_id == selected_action_id)
		_connect_selection(button, action_id, selected_callback)
		container.add_child(button)
		_buttons.append(button)
		_item_ids.append(action_id)


func select_item(item_id: String) -> void:
	for index in _buttons.size():
		var selected := index < _item_ids.size() and _item_ids[index] == item_id
		_apply_selection(_buttons[index], selected)


func set_disabled(disabled: bool) -> void:
	for button in _buttons:
		button.disabled = disabled


func _clear_container(container: Container) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	_buttons.clear()
	_item_ids.clear()


func _make_button(text: String, min_size: Vector2, font_size: int, disabled: bool) -> Button:
	var button := MarketUiStyleScript.make_soft_button(text, min_size, font_size)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.disabled = disabled
	return button


func _connect_selection(button: Button, item_id: String, selected_callback: Callable) -> void:
	if not selected_callback.is_valid():
		return
	var captured_id := item_id
	button.pressed.connect(func() -> void:
		selected_callback.call(captured_id)
	)


func _apply_selection(button: Button, selected: bool) -> void:
	if button == null:
		return
	if selected:
		StyleboxThemeHelpersScript.apply_style(button, StyleboxThemeHelpersScript.STYLE_NORMAL, MarketUiStyleScript.button_style(
			ClosedDayButtonListConfigScript.SELECTED_NORMAL_COLOR,
			ClosedDayButtonListConfigScript.SELECTED_NORMAL_BORDER
		))
		StyleboxThemeHelpersScript.apply_style(button, StyleboxThemeHelpersScript.STYLE_HOVER, MarketUiStyleScript.button_style(
			ClosedDayButtonListConfigScript.SELECTED_HOVER_COLOR,
			ClosedDayButtonListConfigScript.SELECTED_HOVER_BORDER
		))
		TextThemeHelpersScript.apply_font_color(button, ClosedDayButtonListConfigScript.SELECTED_TEXT_COLOR)
		TextThemeHelpersScript.apply_hover_font_color(button, ClosedDayButtonListConfigScript.SELECTED_HOVER_TEXT_COLOR)
	else:
		StyleboxThemeHelpersScript.apply_style(button, StyleboxThemeHelpersScript.STYLE_NORMAL, MarketUiStyleScript.button_style(
			ClosedDayButtonListConfigScript.NORMAL_COLOR,
			ClosedDayButtonListConfigScript.NORMAL_BORDER
		))
		StyleboxThemeHelpersScript.apply_style(button, StyleboxThemeHelpersScript.STYLE_HOVER, MarketUiStyleScript.button_style(
			ClosedDayButtonListConfigScript.HOVER_COLOR,
			ClosedDayButtonListConfigScript.HOVER_BORDER
		))
		TextThemeHelpersScript.apply_font_color(button, ClosedDayButtonListConfigScript.TEXT_COLOR)
		TextThemeHelpersScript.apply_hover_font_color(button, ClosedDayButtonListConfigScript.HOVER_TEXT_COLOR)
