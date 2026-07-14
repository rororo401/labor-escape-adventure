extends Control

const DeveloperDateJumpPanelScript := preload("res://scripts/dev/developer_date_jump_panel.gd")
const DeveloperDayActionPreviewPanelScript := preload("res://scripts/dev/developer_day_action_preview_panel.gd")
const DeveloperModeSceneConfigScript := preload("res://scripts/dev/developer_mode_scene_config.gd")
const DeveloperSessionStoreScript := preload("res://scripts/dev/developer_session_store.gd")
const DeveloperUiHelpersScript := preload("res://scripts/dev/developer_ui_helpers.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const DayEventSceneRunnerScript := preload("res://scripts/ui/day_event_scene_runner.gd")
const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")
const GameStateGuardResultScript := preload("res://scripts/core/game_state_guard_result.gd")
const MarketDayFlowTextScript := preload("res://scripts/ui/market_day_flow_text.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var _message_label: Label
var _day_event_runner = DayEventSceneRunnerScript.new()
var _developer_session_store = _make_developer_session_store()


func _ready() -> void:
	_build_screen()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(DeveloperModeSceneConfigScript.INTRO_SCENE_PATH)


func _build_screen() -> void:
	var background := TextureRect.new()
	background.name = DeveloperModeSceneConfigScript.BACKGROUND_NAME
	UiHelpers.apply_cover_texture(background, DeveloperModeSceneConfigScript.BACKGROUND_PATH)
	add_child(background)

	var panel := PanelContainer.new()
	panel.name = DeveloperModeSceneConfigScript.PANEL_NAME
	var panel_size := _fit_panel_size()
	panel.position = _fit_panel_position(panel_size)
	panel.size = panel_size
	panel.custom_minimum_size = panel_size
	DeveloperUiHelpersScript.apply_panel_style(
		panel,
		DeveloperModeSceneConfigScript.PANEL_COLOR,
		DeveloperModeSceneConfigScript.PANEL_BORDER_COLOR
	)
	add_child(panel)

	var layout := PanelLayoutHelpersScript.add_margin_layout(
		panel,
		panel_size,
		DeveloperModeSceneConfigScript.PANEL_MARGIN,
		DeveloperModeSceneConfigScript.LAYOUT_SEPARATION
	)

	var title := DeveloperUiHelpersScript.make_label(
		DeveloperModeSceneConfigScript.TITLE_FONT_SIZE,
		DeveloperModeSceneConfigScript.TITLE_COLOR
	)
	title.text = DeveloperModeSceneConfigScript.TITLE_TEXT
	TextThemeHelpersScript.apply_horizontal_alignment(title, HORIZONTAL_ALIGNMENT_CENTER)
	layout.add_child(title)

	var subtitle := DeveloperUiHelpersScript.make_label(
		DeveloperModeSceneConfigScript.SUBTITLE_FONT_SIZE,
		DeveloperModeSceneConfigScript.SUBTITLE_COLOR
	)
	subtitle.text = DeveloperModeSceneConfigScript.SUBTITLE_TEXT
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.apply_horizontal_alignment(subtitle, HORIZONTAL_ALIGNMENT_CENTER)
	layout.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = DeveloperModeSceneConfigScript.HEADER_SPACER_SIZE
	layout.add_child(spacer)

	var date_jump_panel := DeveloperDateJumpPanelScript.new()
	date_jump_panel.build(_developer_session_store.load_last_jump_date(DeveloperDateJumpPanelScript.FIRST_SATURDAY_DATE))
	date_jump_panel.standing_calibrator_requested.connect(_open_standing_calibrator)
	date_jump_panel.result_popup_calibrator_requested.connect(_open_result_popup_calibrator)
	date_jump_panel.date_jump_requested.connect(_jump_to_market_date)
	layout.add_child(date_jump_panel)

	var preview_panel := DeveloperDayActionPreviewPanelScript.new()
	preview_panel.build()
	preview_panel.day_action_preview_requested.connect(_preview_day_action)
	preview_panel.status_message_requested.connect(_set_message)
	layout.add_child(preview_panel)

	_message_label = DeveloperUiHelpersScript.make_label(
		DeveloperModeSceneConfigScript.MESSAGE_FONT_SIZE,
		DeveloperModeSceneConfigScript.MESSAGE_COLOR
	)
	_message_label.name = DeveloperModeSceneConfigScript.MESSAGE_LABEL_NAME
	_message_label.text = ""
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.custom_minimum_size = DeveloperModeSceneConfigScript.MESSAGE_LABEL_SIZE
	layout.add_child(_message_label)

	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(bottom_spacer)

	var back_button := DeveloperUiHelpersScript.make_menu_button(DeveloperModeSceneConfigScript.BACK_BUTTON_TEXT)
	back_button.name = DeveloperModeSceneConfigScript.BACK_BUTTON_NAME
	back_button.pressed.connect(func():
		get_tree().change_scene_to_file(DeveloperModeSceneConfigScript.INTRO_SCENE_PATH)
	)
	layout.add_child(back_button)


func _open_standing_calibrator() -> void:
	get_tree().change_scene_to_file(DeveloperModeSceneConfigScript.STANDING_CALIBRATOR_SCENE_PATH)


func _open_result_popup_calibrator() -> void:
	get_tree().change_scene_to_file(DeveloperModeSceneConfigScript.RESULT_POPUP_CALIBRATOR_SCENE_PATH)


func _jump_to_market_date(date: String) -> void:
	if date.is_empty():
		_set_message("날짜를 입력해줘.")
		return
	var game_session := GameSessionAccessScript.get_from_node(self)
	if game_session == null:
		_set_message(MarketDayFlowTextScript.flow_error_message(GameStateGuardResultScript.ERROR_GAME_NOT_STARTED))
		return
	if not game_session.start_new_game(date):
		_set_message("달력에 없는 날짜야: %s" % date)
		return
	_developer_session_store.save_last_jump_date(date)
	get_tree().change_scene_to_file(DeveloperModeSceneConfigScript.MARKET_SCENE_PATH)


func _preview_day_action(event: Dictionary) -> void:
	if event.is_empty():
		_set_message("이벤트를 찾지 못했다.")
		return
	var layer: Control = _day_event_runner.begin(self, event, DeveloperModeSceneConfigScript.CLOSED_DAY_BACKGROUND_PATH)
	if layer == null:
		_set_message("이벤트 대사나 CG 정보를 확인하지 못했다: %s" % String(event.get(DayEventKeysScript.KEY_ID, "")))
		return
	_set_message("%s 미리보기 중" % String(event.get(DayEventKeysScript.KEY_NAME_KO, event.get(DayEventKeysScript.KEY_ID, ""))))


func _set_message(text: String) -> void:
	if _message_label != null:
		_message_label.text = text


func _fit_panel_size() -> Vector2:
	var layout_width := _layout_width()
	if layout_width <= 0.0:
		return DeveloperModeSceneConfigScript.PANEL_SIZE
	var max_width := maxf(1.0, layout_width - float(DeveloperModeSceneConfigScript.PANEL_SAFE_MARGIN_X * 2))
	return Vector2(
		minf(DeveloperModeSceneConfigScript.PANEL_SIZE.x, max_width),
		DeveloperModeSceneConfigScript.PANEL_SIZE.y
	)


func _fit_panel_position(panel_size: Vector2) -> Vector2:
	var layout_width := _layout_width()
	if layout_width <= 0.0:
		return DeveloperModeSceneConfigScript.PANEL_POSITION
	var x := maxf(0.0, (layout_width - panel_size.x) * 0.5)
	return Vector2(x, DeveloperModeSceneConfigScript.PANEL_POSITION.y)


func _layout_width() -> float:
	var viewport_width := _viewport_size().x
	if viewport_width <= 0.0:
		return DeveloperModeSceneConfigScript.DESIGN_VIEWPORT_WIDTH
	return minf(viewport_width, DeveloperModeSceneConfigScript.DESIGN_VIEWPORT_WIDTH)


func _viewport_size() -> Vector2:
	var viewport := get_viewport()
	if viewport == null:
		return Vector2.ZERO
	return viewport.get_visible_rect().size


func _make_developer_session_store():
	var store = DeveloperSessionStoreScript.new()
	var override_path := String(ProjectSettings.get_setting(DeveloperModeSceneConfigScript.DEV_SESSION_STORE_PATH_SETTING, ""))
	if not override_path.is_empty():
		store.store_path = override_path
	return store
