class_name MarketSleepFlow
extends RefCounted

const MarketDayResultStateScript := preload("res://scripts/ui/market_day_result_state.gd")
const GameDayProgressKeysScript := preload("res://scripts/core/dayflow/game_day_progress_keys.gd")
const GameStateContextKeysScript := preload("res://scripts/core/game_state_context_keys.gd")
const MarketSleepFlowConfigScript := preload("res://scripts/ui/market_sleep_flow_config.gd")
const MarketSleepSequenceScript := preload("res://scripts/ui/market_sleep_sequence.gd")

var _sleep_sequence: Control


func play_until_transition(parent: Node, game) -> Dictionary:
	var start_state := MarketDayResultStateScript.sleep_start_state()
	if parent == null or game == null:
		return MarketSleepFlowConfigScript.sleep_error_result(
			start_state,
			MarketDayResultStateScript.sleep_error_state(MarketSleepFlowConfigScript.DEFAULT_MISSING_GAME_ERROR)
		)

	_sleep_sequence = _make_sleep_sequence()
	parent.add_child(_sleep_sequence)
	var today := Dictionary(game.get_today_context())
	await _sleep_sequence.play_sleep_intro(String(today.get(GameStateContextKeysScript.KEY_DATE, "")))

	var result: Dictionary = game.sleep_to_next_day()
	if not result.get(MarketSleepFlowConfigScript.KEY_OK, false):
		var error_state := MarketDayResultStateScript.sleep_error_state(String(result.get(GameDayProgressKeysScript.KEY_ERROR, "")))
		await _sleep_sequence.cancel_after_error()
		return MarketSleepFlowConfigScript.sleep_error_result(start_state, error_state, result)

	await _sleep_sequence.play_date_transition(result)
	return MarketSleepFlowConfigScript.sleep_transition_result(
		start_state,
		MarketDayResultStateScript.after_sleep_transition_state(),
		result
	)


func play_morning(result: Dictionary) -> Dictionary:
	if is_instance_valid(_sleep_sequence):
		await _sleep_sequence.play_morning(result)
	return MarketDayResultStateScript.after_sleep_morning_state()


func _make_sleep_sequence() -> Control:
	return MarketSleepSequenceScript.new()
