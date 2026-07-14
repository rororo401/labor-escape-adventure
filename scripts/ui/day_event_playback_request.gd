class_name DayEventPlaybackRequest
extends RefCounted

const CharacterOutfitSeasonScript := preload("res://scripts/core/character_outfit_season.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")

const KEY_BACKGROUND_PATH := DayEventKeysScript.KEY_CG_PATH
const KEY_DIALOGUE := DayEventKeysScript.KEY_DIALOGUE
const KEY_SPEAKER_NAME := DayEventKeysScript.KEY_NAME_KO
const KEY_SUMMARY := DayEventKeysScript.KEY_SUMMARY_KO
const KEY_PLAYBACK_MODE := "playback_mode"
const KEY_STANDING_BACKGROUND_PATH := "standing_background_path"
const KEY_STANDING_OUTFIT := "standing_outfit"
const KEY_STANDING_EXPRESSION := "standing_expression"
const KEY_NEWS_SPEAKER_NAME := "news_speaker_name"
const KEY_STANDING_SPEAKER_NAME := "standing_speaker_name"
const EVENT_CG_ROOT := "res://assets/events/"
const SUMMER_EVENT_CG_ROOT := "res://assets/events_summer/"
const SLEEP_EVENT_CG_PATH := "res://assets/backgrounds/home/sleeping_night_event.png"
const SLEEP_EVENT_CG_PATH_SUMMER := "res://assets/backgrounds/home/sleeping_night_event_summer.png"
const PLAYBACK_CG_THEN_STANDING := "cg_then_standing"
const DEFAULT_STANDING_BACKGROUND_PATH := "res://assets/backgrounds/market/morning_market_room.png"
const DEFAULT_STANDING_OUTFIT := "homewear"
const DEFAULT_STANDING_EXPRESSION := "neutral"
const DEFAULT_NEWS_SPEAKER_NAME := "시장 뉴스"
const DEFAULT_STANDING_SPEAKER_NAME := "나"


static func background_path(event: Dictionary, default_background_path: String, date: String = "") -> String:
	return seasonal_background_path(String(event.get(KEY_BACKGROUND_PATH, default_background_path)), date)


static func event_for_date(event: Dictionary, date: String) -> Dictionary:
	var resolved := event.duplicate(true)
	var cg_path := String(resolved.get(KEY_BACKGROUND_PATH, ""))
	if not cg_path.is_empty():
		resolved[KEY_BACKGROUND_PATH] = seasonal_background_path(cg_path, date)
	return resolved


static func playback_steps(event: Dictionary, default_background_path: String, date: String = "") -> Array[Dictionary]:
	var lines := dialogue_lines(event)
	if String(event.get(KEY_PLAYBACK_MODE, "")) != PLAYBACK_CG_THEN_STANDING:
		return _line_steps(lines)
	if lines.is_empty():
		return []

	var steps: Array[Dictionary] = []
	steps.append({
		VnStoryKeysScript.KEY_TEXT: lines[0],
		VnStoryKeysScript.KEY_SPEAKER_NAME: String(event.get(KEY_NEWS_SPEAKER_NAME, DEFAULT_NEWS_SPEAKER_NAME)),
		VnStoryKeysScript.KEY_BACKGROUND_PATH: background_path(event, default_background_path, date),
		VnStoryKeysScript.KEY_CHARACTER_VISIBLE: false
	})

	var standing_background := seasonal_background_path(String(event.get(
		KEY_STANDING_BACKGROUND_PATH,
		DEFAULT_STANDING_BACKGROUND_PATH
	)), date)
	var standing_outfit := String(event.get(KEY_STANDING_OUTFIT, DEFAULT_STANDING_OUTFIT))
	var standing_expression := String(event.get(KEY_STANDING_EXPRESSION, DEFAULT_STANDING_EXPRESSION))
	for index in range(1, lines.size()):
		steps.append({
			VnStoryKeysScript.KEY_TEXT: lines[index],
			VnStoryKeysScript.KEY_SPEAKER_NAME: String(event.get(KEY_STANDING_SPEAKER_NAME, DEFAULT_STANDING_SPEAKER_NAME)),
			VnStoryKeysScript.KEY_BACKGROUND_PATH: standing_background,
			VnStoryKeysScript.KEY_CHARACTER_VISIBLE: true,
			VnStoryKeysScript.KEY_OUTFIT: standing_outfit,
			VnStoryKeysScript.KEY_EXPRESSION: standing_expression
		})
	return steps


static func should_show_character(event: Dictionary) -> bool:
	return String(event.get(KEY_PLAYBACK_MODE, "")) == PLAYBACK_CG_THEN_STANDING


static func seasonal_background_path(cg_path: String, date: String) -> String:
	if cg_path.is_empty() or not CharacterOutfitSeasonScript.is_summer_date(date):
		return cg_path
	if cg_path == SLEEP_EVENT_CG_PATH:
		return SLEEP_EVENT_CG_PATH_SUMMER if _path_exists(SLEEP_EVENT_CG_PATH_SUMMER) else cg_path
	if not cg_path.begins_with(EVENT_CG_ROOT):
		return cg_path

	var summer_path := SUMMER_EVENT_CG_ROOT + cg_path.substr(EVENT_CG_ROOT.length())
	return summer_path if _path_exists(summer_path) else cg_path


static func _path_exists(path: String) -> bool:
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)


static func speaker_name(event: Dictionary) -> String:
	return String(event.get(KEY_SPEAKER_NAME, ""))


static func dialogue_lines(event: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	for line in event.get(KEY_DIALOGUE, []):
		var text := String(line)
		if not text.is_empty():
			lines.append(text)
	if lines.is_empty():
		var summary := String(event.get(KEY_SUMMARY, ""))
		if not summary.is_empty():
			lines.append(summary)
	return lines


static func _line_steps(lines: Array[String]) -> Array[Dictionary]:
	var steps: Array[Dictionary] = []
	for line in lines:
		steps.append({VnStoryKeysScript.KEY_TEXT: line})
	return steps
