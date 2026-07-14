class_name MarketSettingsOverlay
extends Control

signal save_slots_requested
signal gallery_requested
signal title_requested

const MarketSettingsOverlayConfigScript := preload("res://scripts/ui/market_settings_overlay_config.gd")
const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var _message_label: Label
var _music_toggle: CheckButton
var _music_volume_slider: HSlider
var _music_volume_value: Label
var _text_scale_option: OptionButton
var _reduced_motion_toggle: CheckButton
var _title_exit_confirmed := false
var _day_completed := false


func build() -> void:
	name = MarketSettingsOverlayConfigScript.OVERLAY_NAME
	UiHelpers.apply_full_rect(self)
	UiHelpers.stop_mouse(self)
	visible = false

	var backdrop := ColorRect.new()
	backdrop.name = MarketSettingsOverlayConfigScript.BACKDROP_NAME
	UiHelpers.apply_full_rect(backdrop)
	backdrop.color = MarketSettingsOverlayConfigScript.BACKDROP_COLOR
	add_child(backdrop)

	var panel := Panel.new()
	panel.name = MarketSettingsOverlayConfigScript.PANEL_NAME
	panel.position = MarketSettingsOverlayConfigScript.PANEL_POSITION
	panel.size = MarketSettingsOverlayConfigScript.PANEL_SIZE
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)

	var title := _make_label(
		"설정",
		MarketSettingsOverlayConfigScript.TITLE_POSITION,
		MarketSettingsOverlayConfigScript.TITLE_SIZE,
		MarketSettingsOverlayConfigScript.TITLE_FONT_SIZE,
		MarketSettingsOverlayConfigScript.TITLE_COLOR
	)
	title.name = MarketSettingsOverlayConfigScript.TITLE_LABEL_NAME
	TextThemeHelpersScript.apply_alignment(title, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(title)

	_message_label = _make_label(
		MarketSettingsOverlayConfigScript.DEFAULT_MESSAGE,
		MarketSettingsOverlayConfigScript.MESSAGE_POSITION,
		MarketSettingsOverlayConfigScript.MESSAGE_SIZE,
		MarketSettingsOverlayConfigScript.MESSAGE_FONT_SIZE,
		MarketSettingsOverlayConfigScript.MESSAGE_COLOR
	)
	_message_label.name = MarketSettingsOverlayConfigScript.MESSAGE_LABEL_NAME
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.apply_alignment(_message_label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(_message_label)

	_add_audio_controls()
	_add_accessibility_controls()

	_add_button(MarketSettingsOverlayConfigScript.SAVE_BUTTON_NAME, "저장 / 불러오기", MarketSettingsOverlayConfigScript.SAVE_BUTTON_Y, _on_save_pressed)
	_add_button(MarketSettingsOverlayConfigScript.GALLERY_BUTTON_NAME, "앨범", MarketSettingsOverlayConfigScript.GALLERY_BUTTON_Y, _on_gallery_pressed)
	_add_button(MarketSettingsOverlayConfigScript.TITLE_BUTTON_NAME, "타이틀로", MarketSettingsOverlayConfigScript.TITLE_BUTTON_Y, _on_title_pressed)
	_add_button(MarketSettingsOverlayConfigScript.CLOSE_BUTTON_NAME, "닫기", MarketSettingsOverlayConfigScript.CLOSE_BUTTON_Y, hide)


func show_for_game(game) -> void:
	_day_completed = game != null and bool(game.day_completed)
	_title_exit_confirmed = false
	set_message(MarketSettingsOverlayConfigScript.DEFAULT_MESSAGE)
	_sync_audio_controls()
	_sync_accessibility_controls()
	visible = true


func set_message(text: String) -> void:
	if _message_label != null:
		_message_label.text = text


func _on_save_pressed() -> void:
	_title_exit_confirmed = false
	save_slots_requested.emit()


func _on_gallery_pressed() -> void:
	_title_exit_confirmed = false
	gallery_requested.emit()


func _on_title_pressed() -> void:
	if not _day_completed and not _title_exit_confirmed:
		_title_exit_confirmed = true
		set_message(MarketSettingsOverlayConfigScript.TITLE_CONFIRM_MESSAGE)
		return
	title_requested.emit()


func _add_audio_controls() -> void:
	var section_label := _make_label(
		"오디오",
		MarketSettingsOverlayConfigScript.AUDIO_SECTION_POSITION,
		MarketSettingsOverlayConfigScript.AUDIO_SECTION_SIZE,
		MarketSettingsOverlayConfigScript.AUDIO_SECTION_FONT_SIZE,
		MarketSettingsOverlayConfigScript.TITLE_COLOR
	)
	section_label.name = MarketSettingsOverlayConfigScript.AUDIO_SECTION_LABEL_NAME
	add_child(section_label)

	_music_toggle = CheckButton.new()
	_music_toggle.name = MarketSettingsOverlayConfigScript.MUSIC_TOGGLE_NAME
	_music_toggle.text = "배경음악"
	_music_toggle.position = MarketSettingsOverlayConfigScript.MUSIC_TOGGLE_POSITION
	_music_toggle.size = MarketSettingsOverlayConfigScript.MUSIC_TOGGLE_SIZE
	TextThemeHelpersScript.apply_ui_text_style(
		_music_toggle,
		MarketSettingsOverlayConfigScript.MUSIC_TOGGLE_FONT_SIZE,
		MarketSettingsOverlayConfigScript.MESSAGE_COLOR
	)
	_music_toggle.add_theme_color_override("font_pressed_color", MarketSettingsOverlayConfigScript.MESSAGE_COLOR)
	_music_toggle.add_theme_color_override("font_hover_color", MarketSettingsOverlayConfigScript.MESSAGE_COLOR)
	_music_toggle.add_theme_color_override("font_hover_pressed_color", MarketSettingsOverlayConfigScript.MESSAGE_COLOR)
	_music_toggle.toggled.connect(_on_music_toggled)
	add_child(_music_toggle)

	var volume_label := _make_label(
		"볼륨",
		MarketSettingsOverlayConfigScript.MUSIC_VOLUME_LABEL_POSITION,
		MarketSettingsOverlayConfigScript.MUSIC_VOLUME_LABEL_SIZE,
		MarketSettingsOverlayConfigScript.MUSIC_VOLUME_FONT_SIZE,
		MarketSettingsOverlayConfigScript.MESSAGE_COLOR
	)
	volume_label.name = MarketSettingsOverlayConfigScript.MUSIC_VOLUME_LABEL_NAME
	TextThemeHelpersScript.apply_alignment(volume_label, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER)
	add_child(volume_label)

	_music_volume_slider = HSlider.new()
	_music_volume_slider.name = MarketSettingsOverlayConfigScript.MUSIC_VOLUME_SLIDER_NAME
	_music_volume_slider.position = MarketSettingsOverlayConfigScript.MUSIC_VOLUME_SLIDER_POSITION
	_music_volume_slider.size = MarketSettingsOverlayConfigScript.MUSIC_VOLUME_SLIDER_SIZE
	_music_volume_slider.min_value = 0.0
	_music_volume_slider.max_value = 100.0
	_music_volume_slider.step = 1.0
	_music_volume_slider.value_changed.connect(_on_music_volume_changed)
	add_child(_music_volume_slider)

	_music_volume_value = _make_label(
		"",
		MarketSettingsOverlayConfigScript.MUSIC_VOLUME_VALUE_POSITION,
		MarketSettingsOverlayConfigScript.MUSIC_VOLUME_VALUE_SIZE,
		MarketSettingsOverlayConfigScript.MUSIC_VOLUME_FONT_SIZE,
		MarketSettingsOverlayConfigScript.MESSAGE_COLOR
	)
	_music_volume_value.name = MarketSettingsOverlayConfigScript.MUSIC_VOLUME_VALUE_NAME
	TextThemeHelpersScript.apply_alignment(_music_volume_value, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER)
	add_child(_music_volume_value)
	_sync_audio_controls()


func _sync_audio_controls() -> void:
	if _music_toggle == null or _music_volume_slider == null:
		return
	var audio_manager: Node = _get_audio_manager()
	var enabled := true
	var volume := 55.0
	if audio_manager != null:
		if audio_manager.has_method("is_music_enabled"):
			enabled = bool(audio_manager.is_music_enabled())
		if audio_manager.has_method("get_music_volume_percent"):
			volume = float(audio_manager.get_music_volume_percent())
	_music_toggle.set_pressed_no_signal(enabled)
	_music_volume_slider.set_value_no_signal(volume)
	_music_volume_slider.editable = enabled
	_update_volume_label(volume)


func _on_music_toggled(enabled: bool) -> void:
	if _music_volume_slider != null:
		_music_volume_slider.editable = enabled
	var audio_manager: Node = _get_audio_manager()
	if audio_manager != null and audio_manager.has_method("set_music_enabled"):
		audio_manager.set_music_enabled(enabled)


func _on_music_volume_changed(value: float) -> void:
	_update_volume_label(value)
	var audio_manager: Node = _get_audio_manager()
	if audio_manager != null and audio_manager.has_method("set_music_volume_percent"):
		audio_manager.set_music_volume_percent(value)


func _update_volume_label(value: float) -> void:
	if _music_volume_value != null:
		_music_volume_value.text = "%d%%" % roundi(value)


func _get_audio_manager() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/AudioManager")


func _add_accessibility_controls() -> void:
	var section_label := _make_label(
		"화면",
		MarketSettingsOverlayConfigScript.ACCESSIBILITY_SECTION_POSITION,
		MarketSettingsOverlayConfigScript.ACCESSIBILITY_SECTION_SIZE,
		MarketSettingsOverlayConfigScript.ACCESSIBILITY_SECTION_FONT_SIZE,
		MarketSettingsOverlayConfigScript.TITLE_COLOR
	)
	section_label.name = MarketSettingsOverlayConfigScript.ACCESSIBILITY_SECTION_LABEL_NAME
	add_child(section_label)

	var text_scale_label := _make_label(
		"글자 크기",
		MarketSettingsOverlayConfigScript.TEXT_SCALE_LABEL_POSITION,
		MarketSettingsOverlayConfigScript.TEXT_SCALE_LABEL_SIZE,
		MarketSettingsOverlayConfigScript.TEXT_SCALE_FONT_SIZE,
		MarketSettingsOverlayConfigScript.MESSAGE_COLOR
	)
	text_scale_label.name = MarketSettingsOverlayConfigScript.TEXT_SCALE_LABEL_NAME
	TextThemeHelpersScript.apply_alignment(text_scale_label, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER)
	add_child(text_scale_label)

	_text_scale_option = MarketUiStyleScript.make_option_button(
		MarketSettingsOverlayConfigScript.TEXT_SCALE_OPTION_SIZE,
		MarketSettingsOverlayConfigScript.TEXT_SCALE_FONT_SIZE
	)
	_text_scale_option.name = MarketSettingsOverlayConfigScript.TEXT_SCALE_OPTION_NAME
	_text_scale_option.position = MarketSettingsOverlayConfigScript.TEXT_SCALE_OPTION_POSITION
	_text_scale_option.size = MarketSettingsOverlayConfigScript.TEXT_SCALE_OPTION_SIZE
	for label in MarketSettingsOverlayConfigScript.TEXT_SCALE_LABELS:
		_text_scale_option.add_item(String(label))
	_text_scale_option.item_selected.connect(_on_text_scale_selected)
	add_child(_text_scale_option)

	_reduced_motion_toggle = CheckButton.new()
	_reduced_motion_toggle.name = MarketSettingsOverlayConfigScript.REDUCED_MOTION_TOGGLE_NAME
	_reduced_motion_toggle.text = "모션 줄이기"
	_reduced_motion_toggle.tooltip_text = "화면 전환과 장식 애니메이션을 아주 짧게 표시해요."
	_reduced_motion_toggle.position = MarketSettingsOverlayConfigScript.REDUCED_MOTION_TOGGLE_POSITION
	_reduced_motion_toggle.size = MarketSettingsOverlayConfigScript.REDUCED_MOTION_TOGGLE_SIZE
	TextThemeHelpersScript.apply_ui_text_style(
		_reduced_motion_toggle,
		MarketSettingsOverlayConfigScript.REDUCED_MOTION_FONT_SIZE,
		MarketSettingsOverlayConfigScript.MESSAGE_COLOR
	)
	_reduced_motion_toggle.add_theme_color_override("font_pressed_color", MarketSettingsOverlayConfigScript.MESSAGE_COLOR)
	_reduced_motion_toggle.add_theme_color_override("font_hover_color", MarketSettingsOverlayConfigScript.MESSAGE_COLOR)
	_reduced_motion_toggle.add_theme_color_override("font_hover_pressed_color", MarketSettingsOverlayConfigScript.MESSAGE_COLOR)
	_reduced_motion_toggle.toggled.connect(_on_reduced_motion_toggled)
	add_child(_reduced_motion_toggle)
	_sync_accessibility_controls()


func _sync_accessibility_controls() -> void:
	if _text_scale_option == null or _reduced_motion_toggle == null:
		return
	var preferences := _get_game_preferences()
	var scale := 1.0
	var reduced := false
	if preferences != null:
		if preferences.has_method("get_ui_text_scale"):
			scale = float(preferences.get_ui_text_scale())
		if preferences.has_method("is_reduced_motion_enabled"):
			reduced = bool(preferences.is_reduced_motion_enabled())
	_text_scale_option.select(_closest_text_scale_index(scale))
	_reduced_motion_toggle.set_pressed_no_signal(reduced)


func _on_text_scale_selected(index: int) -> void:
	if index < 0 or index >= MarketSettingsOverlayConfigScript.TEXT_SCALE_VALUES.size():
		return
	var preferences := _get_game_preferences()
	if preferences != null and preferences.has_method("set_ui_text_scale"):
		preferences.set_ui_text_scale(float(MarketSettingsOverlayConfigScript.TEXT_SCALE_VALUES[index]))


func _on_reduced_motion_toggled(enabled: bool) -> void:
	var preferences := _get_game_preferences()
	if preferences != null and preferences.has_method("set_reduced_motion_enabled"):
		preferences.set_reduced_motion_enabled(enabled)


func _closest_text_scale_index(scale: float) -> int:
	var closest_index := 0
	var closest_distance := INF
	for index in MarketSettingsOverlayConfigScript.TEXT_SCALE_VALUES.size():
		var distance := absf(float(MarketSettingsOverlayConfigScript.TEXT_SCALE_VALUES[index]) - scale)
		if distance < closest_distance:
			closest_distance = distance
			closest_index = index
	return closest_index


func _get_game_preferences() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/GamePreferences")


func _add_button(button_name: String, text: String, y: float, callback: Callable) -> Button:
	var button := MarketUiStyleScript.make_soft_button(text, MarketSettingsOverlayConfigScript.BUTTON_SIZE, MarketSettingsOverlayConfigScript.BUTTON_FONT_SIZE)
	button.name = button_name
	button.position = Vector2(MarketSettingsOverlayConfigScript.BUTTON_X, y)
	if callback.is_valid():
		button.pressed.connect(callback)
	add_child(button)
	return button


func _make_label(text: String, position_value: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := MarketUiStyleScript.make_label(font_size, color)
	label.text = text
	label.position = position_value
	label.size = size_value
	return label


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = MarketSettingsOverlayConfigScript.PANEL_COLOR
	style.border_color = MarketSettingsOverlayConfigScript.PANEL_BORDER_COLOR
	style.set_border_width_all(MarketSettingsOverlayConfigScript.PANEL_BORDER_WIDTH)
	style.set_corner_radius_all(MarketSettingsOverlayConfigScript.PANEL_CORNER_RADIUS)
	return style
