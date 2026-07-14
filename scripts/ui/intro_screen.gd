extends Control

const DeveloperSessionStoreScript := preload("res://scripts/dev/developer_session_store.gd")
const IntroScreenConfigScript := preload("res://scripts/ui/intro_screen_config.gd")
const IntroTitleViewConfigScript := preload("res://scripts/ui/intro_title_view_config.gd")
const IntroTitleViewScript := preload("res://scripts/ui/intro_title_view.gd")
const EventCgGalleryOverlayScript := preload("res://scripts/ui/event_cg_gallery_overlay.gd")
const UiTweenPropertyConfigScript := preload("res://scripts/ui/ui_tween_property_config.gd")
const UiMotionScript := preload("res://scripts/ui/ui_motion.gd")

var _title_logo: TextureRect
var _start_button: Button
var _start_button_frame: Control
var _continue_button: Button
var _continue_button_frame: Control
var _gallery_button: Button
var _gallery_button_frame: Control
var _developer_quick_button: Button
var _gallery_overlay
var _button_press_tweens: Dictionary = {}
var _title_view = IntroTitleViewScript.new()
var _developer_session_store = _make_developer_session_store()


func _ready() -> void:
	_build_screen()
	_prepare_animations.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(IntroScreenConfigScript.DEVELOPER_MODE_SCENE_PATH)


func _build_screen() -> void:
	var nodes := _title_view.build(self, {
		IntroTitleViewConfigScript.OPTION_BACKGROUND_PATH: IntroScreenConfigScript.BACKGROUND_PATH,
			IntroTitleViewConfigScript.OPTION_TITLE_LOGO_PATH: IntroScreenConfigScript.TITLE_LOGO_PATH,
			IntroTitleViewConfigScript.OPTION_START_BUTTON_PATH: IntroScreenConfigScript.START_BUTTON_PATH,
			IntroTitleViewConfigScript.OPTION_SHOW_CONTINUE_BUTTON: _has_saved_progress(),
			IntroTitleViewConfigScript.OPTION_CONTINUE_BUTTON_PATH: IntroScreenConfigScript.CONTINUE_BUTTON_PATH,
			IntroTitleViewConfigScript.OPTION_CONTINUE_TEXT: IntroScreenConfigScript.CONTINUE_TEXT,
			IntroTitleViewConfigScript.OPTION_SHOW_GALLERY_BUTTON: true,
			IntroTitleViewConfigScript.OPTION_GALLERY_BUTTON_PATH: IntroScreenConfigScript.GALLERY_BUTTON_PATH,
			IntroTitleViewConfigScript.OPTION_GALLERY_TEXT: IntroScreenConfigScript.GALLERY_TEXT,
			IntroTitleViewConfigScript.OPTION_SHOW_DEVELOPER_QUICK_LAUNCH: _should_show_developer_quick_launch(),
			IntroTitleViewConfigScript.OPTION_DEVELOPER_QUICK_TEXT: IntroScreenConfigScript.DEVELOPER_QUICK_TEXT_PREFIX + _load_developer_run_date()
		}, {
			IntroTitleViewConfigScript.CALLBACK_START_PRESSED: _on_start_button_pressed,
			IntroTitleViewConfigScript.CALLBACK_CONTINUE_PRESSED: _on_continue_button_pressed,
			IntroTitleViewConfigScript.CALLBACK_GALLERY_PRESSED: _on_gallery_button_pressed,
			IntroTitleViewConfigScript.CALLBACK_DEVELOPER_QUICK_LAUNCH_PRESSED: _on_developer_quick_launch_pressed
		})
	_title_logo = nodes.get(IntroTitleViewConfigScript.KEY_TITLE_LOGO)
	_start_button_frame = nodes.get(IntroTitleViewConfigScript.KEY_START_BUTTON_FRAME)
	_start_button = nodes.get(IntroTitleViewConfigScript.KEY_START_BUTTON)
	_continue_button = nodes.get(IntroTitleViewConfigScript.KEY_CONTINUE_BUTTON)
	_continue_button_frame = _continue_button.get_parent() as Control if _continue_button != null else null
	_gallery_button = nodes.get(IntroTitleViewConfigScript.KEY_GALLERY_BUTTON)
	_gallery_button_frame = _gallery_button.get_parent() as Control if _gallery_button != null else null
	_developer_quick_button = nodes.get(IntroTitleViewConfigScript.KEY_DEVELOPER_QUICK_BUTTON)
	_bind_button_press_feedback(_start_button, _start_button_frame)
	_bind_button_press_feedback(_continue_button, _continue_button_frame)
	_bind_button_press_feedback(_gallery_button, _gallery_button_frame)
	_gallery_overlay = EventCgGalleryOverlayScript.new()
	_gallery_overlay.build()
	add_child(_gallery_overlay)


func _prepare_animations() -> void:
	await get_tree().process_frame
	_title_logo.pivot_offset = _title_logo.size / 2.0
	_prepare_button_frame(_start_button_frame)
	_prepare_button_frame(_continue_button_frame)
	_prepare_button_frame(_gallery_button_frame)
	_start_logo_float()


func _start_logo_float() -> void:
	if _title_logo == null:
		return
	if UiMotionScript.is_reduced(self):
		_title_logo.scale = Vector2.ONE
		return

	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_title_logo, UiTweenPropertyConfigScript.PROPERTY_POSITION_Y, _title_logo.position.y - IntroScreenConfigScript.LOGO_FLOAT_UP_OFFSET, IntroScreenConfigScript.LOGO_FLOAT_DURATION)
	tween.tween_property(_title_logo, UiTweenPropertyConfigScript.PROPERTY_POSITION_Y, _title_logo.position.y + IntroScreenConfigScript.LOGO_FLOAT_DOWN_OFFSET, IntroScreenConfigScript.LOGO_FLOAT_DURATION)


func _bind_button_press_feedback(button: Button, frame: Control) -> void:
	if button == null or frame == null:
		return
	button.button_down.connect(_play_button_press.bind(frame))


func _prepare_button_frame(frame: Control) -> void:
	if frame != null:
		frame.pivot_offset = frame.size / 2.0


func _play_button_press(frame: Control) -> void:
	if frame == null:
		return
	if UiMotionScript.is_reduced(self):
		frame.scale = Vector2.ONE
		return

	var frame_id := frame.get_instance_id()
	var previous_tween := _button_press_tweens.get(frame_id) as Tween
	if previous_tween != null and previous_tween.is_running():
		previous_tween.kill()
		frame.scale = Vector2.ONE

	var tween := create_tween()
	_button_press_tweens[frame_id] = tween
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(frame, UiTweenPropertyConfigScript.PROPERTY_SCALE, IntroScreenConfigScript.START_BUTTON_PRESSED_SCALE, IntroScreenConfigScript.START_BUTTON_PRESS_DOWN_DURATION)
	tween.tween_property(frame, UiTweenPropertyConfigScript.PROPERTY_SCALE, Vector2.ONE, IntroScreenConfigScript.START_BUTTON_PRESS_UP_DURATION)
	tween.finished.connect(_on_button_press_finished.bind(frame_id, tween))


func _on_button_press_finished(frame_id: int, tween: Tween) -> void:
	if _button_press_tweens.get(frame_id) == tween:
		_button_press_tweens.erase(frame_id)


func _on_start_button_pressed() -> void:
	_start_button.disabled = true
	await get_tree().create_timer(UiMotionScript.transition_duration(self, IntroScreenConfigScript.START_SCENE_CHANGE_DELAY)).timeout
	get_tree().change_scene_to_file(IntroScreenConfigScript.PROFILE_SCENE_PATH)


func _on_continue_button_pressed() -> void:
	if _continue_button != null:
		_continue_button.disabled = true
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null:
		_restore_continue_button_after_failure()
		return
	var result: Dictionary = game_session.load_saved_game()
	if not bool(result.get("ok", false)):
		_restore_continue_button_after_failure()
		return
	get_tree().change_scene_to_file(IntroScreenConfigScript.MARKET_SCENE_PATH)


func _on_gallery_button_pressed() -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session != null and game_session.has_method("sync_event_history_to_gallery"):
		game_session.sync_event_history_to_gallery()
	if _gallery_overlay != null:
		_gallery_overlay.show_gallery()


func _on_developer_quick_launch_pressed() -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null:
		return
	var date := _load_developer_run_date()
	if not game_session.start_new_game(date):
		return
	get_tree().change_scene_to_file(IntroScreenConfigScript.MARKET_SCENE_PATH)


func _load_developer_run_date() -> String:
	return _developer_session_store.load_last_jump_date(IntroScreenConfigScript.DEFAULT_DEVELOPER_RUN_DATE)


func _should_show_developer_quick_launch() -> bool:
	return bool(ProjectSettings.get_setting(IntroScreenConfigScript.SHOW_DEVELOPER_QUICK_LAUNCH_SETTING, false))


func _has_saved_progress() -> bool:
	var game_session := get_node_or_null("/root/GameSession")
	return game_session != null and game_session.has_saved_progress()


func _restore_continue_button_after_failure() -> void:
	if _continue_button == null:
		return
	_continue_button.disabled = false
	_continue_button.text = IntroScreenConfigScript.CONTINUE_FAILED_TEXT


func _make_developer_session_store():
	var store = DeveloperSessionStoreScript.new()
	var override_path := String(ProjectSettings.get_setting(IntroScreenConfigScript.DEV_SESSION_STORE_PATH_SETTING, ""))
	if not override_path.is_empty():
		store.store_path = override_path
	return store
