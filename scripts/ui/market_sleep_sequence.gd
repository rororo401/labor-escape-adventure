class_name MarketSleepSequence
extends Control

signal sleep_intro_finished
signal date_transition_finished
signal morning_finished

const DateTransitionScene := preload("res://scenes/transition/DateTransitionLayer.tscn")
const MorningBriefingScene := preload("res://scenes/day/MorningBriefingLayer.tscn")
const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const MarketSleepSequenceConfigScript := preload("res://scripts/ui/market_sleep_sequence_config.gd")
const UiTweenPropertyConfigScript := preload("res://scripts/ui/ui_tween_property_config.gd")
const UiMotionScript := preload("res://scripts/ui/ui_motion.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var _sleep_layer: Control
var _transition: Control
var _sleep_intro_date := ""


func _ready() -> void:
	UiHelpers.apply_full_rect(self)
	_apply_viewport_size(self)


func play_sleep_intro(date: String = "") -> void:
	_sleep_intro_date = date
	_sleep_layer = Control.new()
	_sleep_layer.name = MarketSleepSequenceConfigScript.SLEEP_LAYER_NAME
	_apply_viewport_size(_sleep_layer)
	_sleep_layer.modulate.a = 0.0
	add_child(_sleep_layer)

	_add_sleep_event_cg()

	var tween := create_tween()
	tween.tween_property(_sleep_layer, UiTweenPropertyConfigScript.PROPERTY_MODULATE_ALPHA, 1.0, UiMotionScript.transition_duration(self, MarketSleepSequenceConfigScript.SLEEP_FADE_IN_DURATION))
	tween.tween_interval(UiMotionScript.hold_duration(self, MarketSleepSequenceConfigScript.SLEEP_HOLD_DURATION))
	await tween.finished
	sleep_intro_finished.emit()


func play_date_transition(result: Dictionary) -> void:
	_transition = DateTransitionScene.instantiate()
	add_child(_transition)
	_transition.keep_covered_on_finish = true
	_transition.play(
		String(result.get(GameDayProgressKeysScript.KEY_FROM_DATE, "")),
		String(result.get(GameDayProgressKeysScript.KEY_TO_DATE, "")),
		String(result.get(GameDayProgressKeysScript.KEY_TO_WEEKDAY, ""))
	)
	await _transition.covered
	if is_instance_valid(_sleep_layer):
		_sleep_layer.queue_free()
	await _transition.finished
	date_transition_finished.emit()


func continue_date_transition() -> void:
	if is_instance_valid(_transition):
		_transition.continue_now()


func play_morning(result: Dictionary) -> void:
	var morning = MorningBriefingScene.instantiate()
	var today := Dictionary(result.get(GameDayProgressKeysScript.KEY_TODAY, {}))
	add_child(morning)
	morning.play(
		String(result.get(GameDayProgressKeysScript.KEY_TO_DATE, "")),
		String(result.get(GameDayProgressKeysScript.KEY_TO_WEEKDAY, "")),
		bool(today.get(GameStateContextKeysScript.KEY_IS_TRADING_DAY, true)),
		result
	)
	if is_instance_valid(_transition):
		_transition.queue_free()
	await morning.finished
	morning_finished.emit()
	queue_free()


func cancel_after_error(duration: float = MarketSleepSequenceConfigScript.CANCEL_FADE_DURATION) -> void:
	if _sleep_layer == null or not is_instance_valid(_sleep_layer):
		queue_free()
		return

	var tween := create_tween()
	tween.tween_property(_sleep_layer, UiTweenPropertyConfigScript.PROPERTY_MODULATE_ALPHA, 0.0, UiMotionScript.transition_duration(self, duration))
	tween.tween_callback(queue_free)
	await tween.finished


func _apply_viewport_size(control: Control) -> void:
	var viewport := get_viewport()
	var viewport_size := viewport.get_visible_rect().size if viewport != null else Vector2.ZERO
	control.size = viewport_size if viewport_size.x > 0.0 and viewport_size.y > 0.0 else MarketSleepSequenceConfigScript.FALLBACK_SIZE


func _add_sleep_event_cg() -> void:
	var sleep_cg := TextureRect.new()
	sleep_cg.name = MarketSleepSequenceConfigScript.SLEEP_EVENT_CG_NAME
	sleep_cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sleep_cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sleep_cg.size = _sleep_layer.size
	var sleep_cg_path := MarketSleepSequenceConfigScript.sleep_event_cg_path_for_date(_sleep_intro_date)
	sleep_cg.set_meta("source_path", sleep_cg_path)
	sleep_cg.texture = UiHelpers.load_texture(sleep_cg_path)
	_sleep_layer.add_child(sleep_cg)
