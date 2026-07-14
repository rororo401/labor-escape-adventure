extends Control

signal finished

const GameDateFormatterScript := preload("res://scripts/core/game_date_formatter.gd")
const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const MorningBriefingLayerConfigScript := preload("res://scripts/ui/morning_briefing_layer_config.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const UiTweenPropertyConfigScript := preload("res://scripts/ui/ui_tween_property_config.gd")
const UiMotionScript := preload("res://scripts/ui/ui_motion.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const VnStoryRuntimeScript := preload("res://scripts/core/vn_story_runtime.gd")
const VnMixedSceneViewScript := preload("res://scripts/ui/vn_mixed_scene_view.gd")
const VnSceneSequenceRunnerScript := preload("res://scripts/ui/vn_scene_sequence_runner.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")

var _is_finishing := false
var _vn_runner = VnSceneSequenceRunnerScript.new()

var _story_runtime = VnStoryRuntimeScript.new()
var _scene_view = VnMixedSceneViewScript.new()
var _current_date := ""
var _is_trading_day := true
var _morning_context: Dictionary = {}


func _ready() -> void:
	_story_runtime.load(MorningBriefingLayerConfigScript.VN_STORIES_PATH)
	_build_layer()
	_vn_runner.connect_step_changed(_on_step_changed)
	_vn_runner.finished.connect(_finish)


func play(date: String, weekday: String, is_trading_day: bool = true, morning_context: Dictionary = {}) -> void:
	_current_date = date
	_is_trading_day = is_trading_day
	_morning_context = morning_context.duplicate(true)
	_scene_view.set_date_text(GameDateFormatterScript.morning_label(date, weekday))
	_vn_runner.set_steps(_steps_for_day())


func _process(delta: float) -> void:
	_vn_runner.update(delta)


func _input(event: InputEvent) -> void:
	_vn_runner.handle_input(event, get_viewport())


func _build_layer() -> void:
	_scene_view.build(self, {
		VnStoryKeysScript.KEY_BACKGROUND_NAME: MorningBriefingLayerConfigScript.BACKGROUND_NAME,
		VnStoryKeysScript.KEY_BACKGROUND_PATH: MorningBriefingLayerConfigScript.BACKGROUND_PATH,
		VnStoryKeysScript.KEY_SHOW_TOP_BUTTONS: MorningBriefingLayerConfigScript.SHOW_TOP_BUTTONS,
		VnStoryKeysScript.KEY_CHARACTER_NAME: MorningBriefingLayerConfigScript.CHARACTER_NAME,
		VnStoryKeysScript.KEY_SPEAKER_NAME: _story_runtime.player_name(),
		VnStoryKeysScript.KEY_HUD_OPTIONS: {
			VnTopHudConfigScript.OPTION_STATUS: _current_status()
		}
	})
	_vn_runner.bind_to_view(_scene_view)


func _on_step_changed(step: Dictionary, _index: int) -> void:
	_set_character_expression(
		String(step.get(VnStoryKeysScript.KEY_OUTFIT, MorningBriefingLayerConfigScript.DEFAULT_OUTFIT)),
		String(step.get(VnStoryKeysScript.KEY_EXPRESSION, MorningBriefingLayerConfigScript.DEFAULT_EXPRESSION))
	)


func _set_character_expression(outfit_id: String, expression_id: String) -> void:
	_scene_view.apply_character(self, outfit_id, expression_id, _current_date)


func _current_status() -> Dictionary:
	var game_session := GameSessionAccessScript.get_from_node(self)
	if game_session == null or not GameSessionAccessScript.is_ready(game_session):
		return {}
	return game_session.get_game().status.to_dict()


func _story_id_for_day() -> String:
	return MorningBriefingLayerConfigScript.TRADING_DAY_STORY_ID if _is_trading_day else MorningBriefingLayerConfigScript.CLOSED_DAY_STORY_ID


func _steps_for_day() -> Array[Dictionary]:
	var steps := _story_runtime.get_steps(_story_id_for_day())
	var context_step := _context_step()
	if context_step.is_empty():
		return steps
	var contextual_steps: Array[Dictionary] = [context_step]
	contextual_steps.append_array(steps)
	return contextual_steps


func _context_step() -> Dictionary:
	var today := Dictionary(_morning_context.get(GameDayProgressKeysScript.KEY_TODAY, {}))
	var previous_result := Dictionary(_morning_context.get(GameDayProgressKeysScript.KEY_PREVIOUS_DAY_RESULT, {}))
	var today_step := _today_context_step(today)
	if not today_step.is_empty():
		return today_step
	return _previous_result_step(previous_result)


func _today_context_step(today: Dictionary) -> Dictionary:
	var market := Dictionary(today.get(GameStateContextKeysScript.KEY_MARKET, {}))
	var fixed_event := Dictionary(market.get(DayEventKeysScript.KEY_MARKET_FIXED_EVENT, {}))
	if not fixed_event.is_empty():
		return _make_context_step(
			"surprised",
			"아침부터 시장 뉴스 알림이 심상치 않다. 오늘은 %s 이야기를 먼저 확인하고 움직여야겠다." % String(fixed_event.get(DayEventKeysScript.KEY_NAME_KO, "큰 시장 뉴스"))
		)
	if not _is_trading_day:
		var closed_name := String(today.get(GameStateContextKeysScript.KEY_CLOSED_NAME, ""))
		if not closed_name.is_empty():
			return _make_context_step(
				"neutral",
				"달력을 보자마자 오늘은 %s라는 걸 알았다. 장은 쉬니까, 오늘 하루는 생활 쪽으로 먼저 정하자." % closed_name
			)
	return {}


func _previous_result_step(previous_result: Dictionary) -> Dictionary:
	var salary_name := _salary_event_name(previous_result)
	if not salary_name.is_empty():
		return _make_context_step(
			"smile",
			"어제 %s이 들어왔다. 생활비를 빼고 남은 돈을 어디까지 투자에 보탤지 차분히 정해야겠다." % salary_name
		)
	var status := Dictionary(previous_result.get(DayEventKeysScript.KEY_STATUS, {}))
	var fatigue := int(status.get(PlayerStatusKeysScript.KEY_FATIGUE, 0))
	var health := int(status.get(PlayerStatusKeysScript.KEY_HEALTH, 100))
	if health <= MorningBriefingLayerConfigScript.LOW_HEALTH_THRESHOLD:
		return _make_context_step(
			"worried",
			"몸 상태가 꽤 좋지 않다. 오늘은 돈보다도 건강을 먼저 챙기지 않으면 안 되겠다."
		)
	if fatigue >= MorningBriefingLayerConfigScript.HIGH_FATIGUE_THRESHOLD:
		return _make_context_step(
			"worried",
			"피로가 많이 쌓였다. 오늘은 무리해서 버티기보다 하루 끝에 남을 체력을 생각해야겠다."
		)
	return {}


func _salary_event_name(previous_result: Dictionary) -> String:
	for row in previous_result.get(DayEventKeysScript.KEY_WEEKDAY_EVENTS, []):
		var event := Dictionary(Dictionary(row).get(DayEventKeysScript.KEY_EVENT, {}))
		var event_id := String(event.get(DayEventKeysScript.KEY_ID, ""))
		var tags: Array = event.get(DayEventKeysScript.KEY_TAGS, [])
		if event_id.begins_with(MorningBriefingLayerConfigScript.MONTHLY_SALARY_EVENT_ID_PREFIX) or tags.has("salary"):
			return String(event.get(DayEventKeysScript.KEY_NAME_KO, "월급"))
	return ""


func _make_context_step(expression_id: String, text: String) -> Dictionary:
	return {
		VnStoryKeysScript.KEY_OUTFIT: MorningBriefingLayerConfigScript.DEFAULT_OUTFIT,
		VnStoryKeysScript.KEY_EXPRESSION: expression_id,
		VnStoryKeysScript.KEY_TEXT: text
	}


func _finish() -> void:
	if _is_finishing:
		return
	_is_finishing = true
	_vn_runner.block()
	var tween := create_tween()
	tween.tween_property(self, UiTweenPropertyConfigScript.PROPERTY_MODULATE_ALPHA, 0.0, UiMotionScript.transition_duration(self, MorningBriefingLayerConfigScript.FADE_OUT_DURATION))
	tween.tween_callback(func():
		finished.emit()
		queue_free()
	)
