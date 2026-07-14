class_name MarketUiStyle
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")
const MarketUiStyleConfigScript := preload("res://scripts/ui/market_ui_style_config.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")


static func make_panel_style(color: Color, border: Color) -> StyleBoxFlat:
	return UiHelpers.panel_style(color, border)


static func make_label(font_size: int, color: Color = MarketUiStyleConfigScript.DEFAULT_LABEL_COLOR) -> Label:
	var label := Label.new()
	TextThemeHelpersScript.apply_ui_text_style(label, font_size, color)
	return label


static func make_table_cell(
	text: String,
	width: float,
	align: HorizontalAlignment,
	font_size: int,
	color: Color
) -> Label:
	var label := make_label(font_size, color)
	label.text = text
	label.custom_minimum_size = Vector2(width, MarketUiStyleConfigScript.TABLE_CELL_HEIGHT)
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	TextThemeHelpersScript.apply_alignment(label, align, VERTICAL_ALIGNMENT_CENTER)
	label.clip_text = true
	return label


static func make_primary_button(text: String, min_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	TextThemeHelpersScript.apply_ui_text_style(button, MarketUiStyleConfigScript.PRIMARY_BUTTON_FONT_SIZE, MarketUiStyleConfigScript.PRIMARY_BUTTON_TEXT_COLOR)
	apply_button_styles(
		button,
		MarketUiStyleConfigScript.PRIMARY_BUTTON_NORMAL_COLOR,
		MarketUiStyleConfigScript.PRIMARY_BUTTON_NORMAL_BORDER,
		MarketUiStyleConfigScript.PRIMARY_BUTTON_HOVER_COLOR,
		MarketUiStyleConfigScript.PRIMARY_BUTTON_HOVER_BORDER,
		MarketUiStyleConfigScript.PRIMARY_BUTTON_PRESSED_COLOR,
		MarketUiStyleConfigScript.PRIMARY_BUTTON_PRESSED_BORDER
	)
	return button


static func make_option_button(min_size: Vector2, font_size: int = MarketUiStyleConfigScript.OPTION_BUTTON_FONT_SIZE) -> OptionButton:
	var option := OptionButton.new()
	option.custom_minimum_size = min_size
	TextThemeHelpersScript.apply_ui_text_style(option, font_size, MarketUiStyleConfigScript.OPTION_BUTTON_TEXT_COLOR)
	TextThemeHelpersScript.apply_hover_font_color(option, MarketUiStyleConfigScript.OPTION_BUTTON_TEXT_COLOR)
	var normal_style := button_style(MarketUiStyleConfigScript.OPTION_BUTTON_NORMAL_COLOR, MarketUiStyleConfigScript.OPTION_BUTTON_NORMAL_BORDER)
	StyleboxThemeHelpersScript.apply_style(option, StyleboxThemeHelpersScript.STYLE_NORMAL, normal_style)
	StyleboxThemeHelpersScript.apply_style(option, StyleboxThemeHelpersScript.STYLE_HOVER, button_style(MarketUiStyleConfigScript.OPTION_BUTTON_HOVER_COLOR, MarketUiStyleConfigScript.OPTION_BUTTON_HOVER_BORDER))
	StyleboxThemeHelpersScript.apply_style(option, StyleboxThemeHelpersScript.STYLE_FOCUS, normal_style)
	return option


static func make_order_button(text: String, side: String, min_size: Vector2) -> Button:
	var button := Button.new()
	button.name = MarketUiStyleConfigScript.ORDER_BUY_BUTTON_NAME if side == MarketDataKeysScript.SIDE_BUY else MarketUiStyleConfigScript.ORDER_SELL_BUTTON_NAME
	button.text = text
	button.custom_minimum_size = min_size
	TextThemeHelpersScript.apply_ui_text_style(button, MarketUiStyleConfigScript.ORDER_BUTTON_FONT_SIZE, MarketUiStyleConfigScript.ORDER_BUTTON_TEXT_COLOR)
	var color := MarketUiStyleConfigScript.ORDER_BUY_COLOR if side == MarketDataKeysScript.SIDE_BUY else MarketUiStyleConfigScript.ORDER_SELL_COLOR
	apply_button_styles(
		button,
		color,
		MarketUiStyleConfigScript.ORDER_BUTTON_BORDER,
		color.lightened(0.08),
		MarketUiStyleConfigScript.ORDER_BUTTON_HOVER_TEXT_COLOR,
		color.darkened(0.12),
		MarketUiStyleConfigScript.ORDER_BUTTON_PRESSED_TEXT_COLOR
	)
	return button


static func make_stepper_button(text: String, min_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	TextThemeHelpersScript.apply_ui_text_style(button, MarketUiStyleConfigScript.STEPPER_BUTTON_FONT_SIZE, MarketUiStyleConfigScript.STEPPER_BUTTON_TEXT_COLOR)
	apply_button_styles(
		button,
		MarketUiStyleConfigScript.STEPPER_NORMAL_COLOR,
		MarketUiStyleConfigScript.STEPPER_NORMAL_BORDER,
		MarketUiStyleConfigScript.STEPPER_HOVER_COLOR,
		MarketUiStyleConfigScript.STEPPER_HOVER_BORDER,
		MarketUiStyleConfigScript.STEPPER_PRESSED_COLOR,
		MarketUiStyleConfigScript.STEPPER_PRESSED_BORDER
	)
	return button


static func make_stock_row_button(text: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = MarketUiStyleConfigScript.STOCK_ROW_BUTTON_SIZE
	apply_button_styles(
		button,
		MarketUiStyleConfigScript.STOCK_ROW_NORMAL_COLOR,
		MarketUiStyleConfigScript.STOCK_ROW_NORMAL_BORDER,
		MarketUiStyleConfigScript.STOCK_ROW_HOVER_COLOR,
		MarketUiStyleConfigScript.STOCK_ROW_HOVER_BORDER,
		MarketUiStyleConfigScript.STOCK_ROW_PRESSED_COLOR,
		MarketUiStyleConfigScript.STOCK_ROW_PRESSED_BORDER
	)
	return button


static func make_top_icon_button(node_name: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.custom_minimum_size = MarketUiStyleConfigScript.TOP_ICON_BUTTON_SIZE
	UiHelpers.stop_mouse(button)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	if node_name == VnTopHudConfigScript.SETTINGS_BUTTON_NAME:
		button.texture_normal = UiHelpers.load_texture(VnTopHudConfigScript.SETTINGS_BUTTON_NORMAL_TEXTURE_PATH)
		button.texture_hover = UiHelpers.load_texture(VnTopHudConfigScript.SETTINGS_BUTTON_HOVER_TEXTURE_PATH)
		button.texture_pressed = UiHelpers.load_texture(VnTopHudConfigScript.SETTINGS_BUTTON_PRESSED_TEXTURE_PATH)
	else:
		button.texture_normal = UiHelpers.load_texture(VnTopHudConfigScript.MENU_BUTTON_NORMAL_TEXTURE_PATH)
		button.texture_hover = UiHelpers.load_texture(VnTopHudConfigScript.MENU_BUTTON_HOVER_TEXTURE_PATH)
		button.texture_pressed = UiHelpers.load_texture(VnTopHudConfigScript.MENU_BUTTON_PRESSED_TEXTURE_PATH)
	return button


static func make_soft_button(text: String, min_size: Vector2, font_size: int = MarketUiStyleConfigScript.SOFT_BUTTON_FONT_SIZE) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	TextThemeHelpersScript.apply_ui_text_style(button, font_size, MarketUiStyleConfigScript.SOFT_BUTTON_TEXT_COLOR)
	TextThemeHelpersScript.apply_hover_font_color(button, MarketUiStyleConfigScript.SOFT_BUTTON_HOVER_TEXT_COLOR)
	apply_button_styles(
		button,
		MarketUiStyleConfigScript.SOFT_NORMAL_COLOR,
		MarketUiStyleConfigScript.SOFT_NORMAL_BORDER,
		MarketUiStyleConfigScript.SOFT_HOVER_COLOR,
		MarketUiStyleConfigScript.SOFT_HOVER_BORDER,
		MarketUiStyleConfigScript.SOFT_PRESSED_COLOR,
		MarketUiStyleConfigScript.SOFT_PRESSED_BORDER
	)
	return button


static func apply_button_styles(
	button: Button,
	normal_color: Color,
	normal_border: Color,
	hover_color: Color,
	hover_border: Color,
	pressed_color: Color,
	pressed_border: Color
) -> void:
	var normal_style := button_style(normal_color, normal_border)
	StyleboxThemeHelpersScript.apply_button_styles(
		button,
		normal_style,
		button_style(hover_color, hover_border),
		button_style(pressed_color, pressed_border)
	)
	StyleboxThemeHelpersScript.apply_style(button, StyleboxThemeHelpersScript.STYLE_FOCUS, normal_style)


static func button_style(color: Color, border: Color) -> StyleBoxFlat:
	return UiHelpers.button_style(color, border)
