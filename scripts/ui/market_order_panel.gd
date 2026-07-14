class_name MarketOrderPanel
extends Control

signal quantity_increase_requested
signal quantity_decrease_requested
signal order_requested(side: String)
signal day_action_selected(index: int)
signal flow_requested

const MarketOrderPanelStockStateScript := preload("res://scripts/ui/market_order_panel_stock_state.gd")
const MarketOrderPanelStockStateConfigScript := preload("res://scripts/ui/market_order_panel_stock_state_config.gd")
const FlowButtonStateConfigScript := preload("res://scripts/ui/flow_button_state_config.gd")
const MarketOrderPanelDayActionStateConfigScript := preload("res://scripts/ui/market_order_panel_day_action_state_config.gd")
const MarketOrderPanelDayActionStateScript := preload("res://scripts/ui/market_order_panel_day_action_state.gd")
const MarketOrderPanelConfigScript := preload("res://scripts/ui/market_order_panel_config.gd")
const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const MarketOrderFlowButtonStateScript := preload("res://scripts/ui/market_order_flow_button_state.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")

var _selected_name_label: Label
var _selected_price_label: Label
var _selected_held_label: Label
var _quantity_label: Label
var _day_action_option: OptionButton
var _buy_button: Button
var _sell_button: Button
var _flow_button: Button
var _message_label: Label


func build() -> void:
	name = MarketOrderPanelConfigScript.PANEL_NAME
	position = MarketOrderPanelConfigScript.PANEL_POSITION
	size = MarketOrderPanelConfigScript.PANEL_SIZE
	custom_minimum_size = MarketOrderPanelConfigScript.PANEL_SIZE

	var layout := PanelLayoutHelpersScript.add_margin_layout(
		self,
		size,
		MarketOrderPanelConfigScript.PANEL_MARGIN,
		MarketOrderPanelConfigScript.LAYOUT_SEPARATION
	)

	_selected_name_label = _make_title_label()
	_selected_price_label = _make_body_label(MarketOrderPanelConfigScript.PRICE_FONT_SIZE)
	_selected_held_label = _make_body_label(MarketOrderPanelConfigScript.HELD_FONT_SIZE)
	layout.add_child(_selected_name_label)
	layout.add_child(_selected_price_label)
	layout.add_child(_selected_held_label)

	var quantity_row := PanelLayoutHelpersScript.make_row(MarketOrderPanelConfigScript.ROW_SEPARATION)
	layout.add_child(quantity_row)
	quantity_row.add_child(_make_action_button(MarketOrderPanelConfigScript.DECREASE_LABEL, func() -> void:
		quantity_decrease_requested.emit()
	))
	_quantity_label = _make_body_label(MarketOrderPanelConfigScript.QUANTITY_FONT_SIZE)
	TextThemeHelpersScript.apply_horizontal_alignment(_quantity_label, HORIZONTAL_ALIGNMENT_CENTER)
	_quantity_label.custom_minimum_size = MarketOrderPanelConfigScript.QUANTITY_LABEL_SIZE
	quantity_row.add_child(_quantity_label)
	quantity_row.add_child(_make_action_button(MarketOrderPanelConfigScript.INCREASE_LABEL, func() -> void:
		quantity_increase_requested.emit()
	))

	var order_row := PanelLayoutHelpersScript.make_row(MarketOrderPanelConfigScript.ROW_SEPARATION)
	layout.add_child(order_row)
	_buy_button = _make_order_button(MarketOrderPanelConfigScript.BUY_LABEL, MarketOrderPanelConfigScript.SIDE_BUY)
	_sell_button = _make_order_button(MarketOrderPanelConfigScript.SELL_LABEL, MarketOrderPanelConfigScript.SIDE_SELL)
	order_row.add_child(_buy_button)
	order_row.add_child(_sell_button)

	var action_row := PanelLayoutHelpersScript.make_row(MarketOrderPanelConfigScript.ROW_SEPARATION)
	layout.add_child(action_row)

	var action_label := _make_body_label(MarketOrderPanelConfigScript.ACTION_LABEL_FONT_SIZE)
	action_label.text = MarketOrderPanelConfigScript.TODAY_LABEL
	action_label.custom_minimum_size = MarketOrderPanelConfigScript.ACTION_LABEL_SIZE
	TextThemeHelpersScript.center_vertical(action_label)
	action_row.add_child(action_label)

	_day_action_option = MarketUiStyleScript.make_option_button(MarketOrderPanelConfigScript.ACTION_OPTION_SIZE)
	_day_action_option.item_selected.connect(func(index: int) -> void:
		day_action_selected.emit(index)
	)
	action_row.add_child(_day_action_option)

	_flow_button = MarketUiStyleScript.make_primary_button(MarketOrderPanelConfigScript.DEFAULT_FLOW_TEXT, MarketOrderPanelConfigScript.FLOW_BUTTON_SIZE)
	_flow_button.pressed.connect(func() -> void:
		flow_requested.emit()
	)
	layout.add_child(_flow_button)

	_message_label = _make_body_label(MarketOrderPanelConfigScript.MESSAGE_FONT_SIZE)
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.custom_minimum_size = MarketOrderPanelConfigScript.MESSAGE_LABEL_SIZE
	layout.add_child(_message_label)


func set_selected_stock(stock: Dictionary, quantity: int) -> void:
	var state := MarketOrderPanelStockStateScript.selected_stock_texts(stock, quantity)
	_selected_name_label.text = String(state.get(MarketOrderPanelStockStateConfigScript.KEY_NAME, MarketOrderPanelStockStateConfigScript.EMPTY_TEXT))
	_selected_price_label.text = String(state.get(MarketOrderPanelStockStateConfigScript.KEY_PRICE, MarketOrderPanelStockStateConfigScript.EMPTY_TEXT))
	_selected_held_label.text = String(state.get(MarketOrderPanelStockStateConfigScript.KEY_HOLDING, MarketOrderPanelStockStateConfigScript.EMPTY_TEXT))
	_quantity_label.text = String(state.get(MarketOrderPanelStockStateConfigScript.KEY_QUANTITY, MarketOrderPanelStockStateConfigScript.EMPTY_TEXT))


func set_day_actions(labels: Array, disabled: bool, selected_index: int = 0) -> void:
	if _day_action_option == null:
		return

	var state := MarketOrderPanelDayActionStateScript.build(labels, disabled, selected_index)
	var normalized_labels: Array = state.get(MarketOrderPanelDayActionStateConfigScript.KEY_LABELS, [])
	_day_action_option.clear()
	for label in normalized_labels:
		_day_action_option.add_item(String(label))
	if bool(state.get(MarketOrderPanelDayActionStateConfigScript.KEY_HAS_SELECTION, false)):
		_day_action_option.select(int(state.get(
			MarketOrderPanelDayActionStateConfigScript.KEY_SELECTED_INDEX,
			MarketOrderPanelDayActionStateConfigScript.DEFAULT_SELECTED_INDEX
		)))
	_day_action_option.disabled = bool(state.get(MarketOrderPanelDayActionStateConfigScript.KEY_DISABLED, true))


func set_message(text: String) -> void:
	if _message_label != null:
		_message_label.text = text


func update_trade_buttons(can_trade: bool) -> void:
	if _buy_button != null:
		_buy_button.disabled = not can_trade
	if _sell_button != null:
		_sell_button.disabled = not can_trade


func update_flow_button(
	game_finished: bool,
	game_clear: bool,
	game_over: bool,
	day_completed: bool,
	sleep_sequence: bool,
	ready_text: String = ""
) -> void:
	if _flow_button == null:
		return

	var resolved_ready_text := MarketOrderPanelConfigScript.DEFAULT_FLOW_TEXT if ready_text.is_empty() else ready_text
	var state := MarketOrderFlowButtonStateScript.build(
		game_finished,
		game_clear,
		game_over,
		day_completed,
		sleep_sequence,
		resolved_ready_text
	)
	_flow_button.text = String(state.get(FlowButtonStateConfigScript.KEY_TEXT, FlowButtonStateConfigScript.EMPTY_TEXT))
	_flow_button.disabled = bool(state.get(FlowButtonStateConfigScript.KEY_DISABLED, FlowButtonStateConfigScript.DEFAULT_DISABLED))


func _make_order_button(label: String, side: String) -> Button:
	var button := MarketUiStyleScript.make_order_button(label, side, MarketOrderPanelConfigScript.ORDER_BUTTON_SIZE)
	button.pressed.connect(func() -> void:
		order_requested.emit(side)
	)
	return button


func _make_action_button(label: String, pressed_callback: Callable) -> Button:
	var button := MarketUiStyleScript.make_stepper_button(label, MarketOrderPanelConfigScript.QUANTITY_BUTTON_SIZE)
	button.pressed.connect(pressed_callback)
	return button


func _make_title_label() -> Label:
	return MarketUiStyleScript.make_label(MarketOrderPanelConfigScript.TITLE_FONT_SIZE, MarketOrderPanelConfigScript.TITLE_COLOR)


func _make_body_label(size: int) -> Label:
	return MarketUiStyleScript.make_label(size, MarketOrderPanelConfigScript.BODY_COLOR)
