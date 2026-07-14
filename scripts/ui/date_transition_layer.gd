extends Control

signal finished
signal covered

const DateTransitionDisplayStateScript := preload("res://scripts/ui/date_transition_display_state.gd")
const DateTransitionDisplayStateConfigScript := preload("res://scripts/ui/date_transition_display_state_config.gd")
const DateTransitionLayerConfigScript := preload("res://scripts/ui/date_transition_layer_config.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiTweenPropertyConfigScript := preload("res://scripts/ui/ui_tween_property_config.gd")
const UiMotionScript := preload("res://scripts/ui/ui_motion.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")
const VnInputHelperScript := preload("res://scripts/ui/vn_input_helper.gd")
const VnSceneBackgroundScript := preload("res://scripts/ui/vn_scene_background.gd")

var _date_label: Label
var _weekday_label: Label
var _stamp_label: Label
var _can_continue := false
var _is_finishing := false
var keep_covered_on_finish := false


func _ready() -> void:
	UiHelpers.apply_full_rect(self)
	_apply_viewport_size()
	_build_layer()
	modulate.a = 0.0


func play(from_date: String, to_date: String, weekday: String) -> void:
	_can_continue = false
	_is_finishing = false
	_apply_display_state(DateTransitionDisplayStateScript.closing_state(from_date))

	var tween := create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, UiTweenPropertyConfigScript.PROPERTY_MODULATE_ALPHA, 1.0, UiMotionScript.transition_duration(self, DateTransitionLayerConfigScript.FADE_IN_DURATION))
	tween.tween_callback(_emit_covered)
	tween.tween_interval(UiMotionScript.hold_duration(self, DateTransitionLayerConfigScript.COVERED_HOLD_DURATION))
	tween.tween_callback(_snap_to_new_date.bind(to_date, weekday))
	tween.tween_property(_date_label, UiTweenPropertyConfigScript.PROPERTY_SCALE, DateTransitionLayerConfigScript.DATE_POP_SCALE, UiMotionScript.transition_duration(self, DateTransitionLayerConfigScript.DATE_POP_UP_DURATION)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_date_label, UiTweenPropertyConfigScript.PROPERTY_SCALE, Vector2.ONE, UiMotionScript.transition_duration(self, DateTransitionLayerConfigScript.DATE_POP_DOWN_DURATION)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_enable_continue)


func _input(event: InputEvent) -> void:
	if not _can_continue or _is_finishing:
		return
	if VnInputHelperScript.is_advance_event(event):
		get_viewport().set_input_as_handled()
		continue_now()


func continue_now() -> void:
	if not _can_continue or _is_finishing:
		return

	_is_finishing = true
	_can_continue = false
	if keep_covered_on_finish:
		_finish()
		return
	var tween := create_tween()
	tween.tween_property(self, UiTweenPropertyConfigScript.PROPERTY_MODULATE_ALPHA, 0.0, UiMotionScript.transition_duration(self, DateTransitionLayerConfigScript.FADE_OUT_DURATION))
	tween.tween_callback(_finish)


func _build_layer() -> void:
	VnSceneBackgroundScript.add_to(
		self,
		DateTransitionLayerConfigScript.BACKGROUND_NAME,
		DateTransitionLayerConfigScript.BACKGROUND_PATH
	)

	_date_label = Label.new()
	_date_label.name = DateTransitionLayerConfigScript.DATE_LABEL_NAME
	_date_label.position = DateTransitionLayerConfigScript.DATE_LABEL_POSITION
	_date_label.size = DateTransitionLayerConfigScript.DATE_LABEL_SIZE
	_date_label.pivot_offset = DateTransitionLayerConfigScript.DATE_LABEL_PIVOT
	TextThemeHelpersScript.center_text(_date_label)
	TextThemeHelpersScript.apply_ui_text_style(
		_date_label,
		DateTransitionLayerConfigScript.DATE_FONT_SIZE,
		DateTransitionLayerConfigScript.DATE_TEXT_COLOR
	)
	TextThemeHelpersScript.apply_outline(
		_date_label,
		DateTransitionLayerConfigScript.DATE_OUTLINE_COLOR,
		DateTransitionLayerConfigScript.DATE_OUTLINE_SIZE
	)
	add_child(_date_label)

	_weekday_label = Label.new()
	_weekday_label.name = DateTransitionLayerConfigScript.WEEKDAY_LABEL_NAME
	_weekday_label.position = DateTransitionLayerConfigScript.WEEKDAY_LABEL_POSITION
	_weekday_label.size = DateTransitionLayerConfigScript.WEEKDAY_LABEL_SIZE
	TextThemeHelpersScript.center_text(_weekday_label)
	TextThemeHelpersScript.apply_ui_text_style(
		_weekday_label,
		DateTransitionLayerConfigScript.WEEKDAY_FONT_SIZE,
		DateTransitionLayerConfigScript.WEEKDAY_TEXT_COLOR
	)
	add_child(_weekday_label)

	_stamp_label = Label.new()
	_stamp_label.name = DateTransitionLayerConfigScript.STAMP_LABEL_NAME
	_stamp_label.position = DateTransitionLayerConfigScript.STAMP_LABEL_POSITION
	_stamp_label.size = DateTransitionLayerConfigScript.STAMP_LABEL_SIZE
	_stamp_label.rotation_degrees = DateTransitionLayerConfigScript.STAMP_ROTATION_DEGREES
	TextThemeHelpersScript.center_text(_stamp_label)
	TextThemeHelpersScript.apply_ui_text_style(
		_stamp_label,
		DateTransitionLayerConfigScript.STAMP_FONT_SIZE,
		DateTransitionLayerConfigScript.STAMP_TEXT_COLOR
	)
	TextThemeHelpersScript.apply_outline(
		_stamp_label,
		DateTransitionLayerConfigScript.STAMP_OUTLINE_COLOR,
		DateTransitionLayerConfigScript.STAMP_OUTLINE_SIZE
	)
	add_child(_stamp_label)


func _snap_to_new_date(to_date: String, weekday: String) -> void:
	_apply_display_state(DateTransitionDisplayStateScript.morning_state(to_date, weekday))


func _apply_display_state(state: Dictionary) -> void:
	_date_label.text = String(state.get(DateTransitionDisplayStateConfigScript.KEY_DATE_TEXT, DateTransitionDisplayStateConfigScript.EMPTY_TEXT))
	_weekday_label.text = String(state.get(DateTransitionDisplayStateConfigScript.KEY_WEEKDAY_TEXT, DateTransitionDisplayStateConfigScript.EMPTY_TEXT))
	_stamp_label.text = String(state.get(DateTransitionDisplayStateConfigScript.KEY_STAMP_TEXT, DateTransitionDisplayStateConfigScript.EMPTY_TEXT))


func _enable_continue() -> void:
	_can_continue = true


func _finish() -> void:
	finished.emit()
	if not keep_covered_on_finish:
		queue_free()


func _apply_viewport_size() -> void:
	var viewport := get_viewport()
	var viewport_size := viewport.get_visible_rect().size if viewport != null else Vector2.ZERO
	size = viewport_size if viewport_size.x > 0.0 and viewport_size.y > 0.0 else DateTransitionLayerConfigScript.FALLBACK_SIZE


func _emit_covered() -> void:
	covered.emit()
