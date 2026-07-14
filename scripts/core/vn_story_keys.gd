class_name VnStoryKeys
extends RefCounted

const DisplayPayloadKeysScript := preload("res://scripts/core/display_payload_keys.gd")
const CharacterVisualKeysScript := preload("res://scripts/core/character_visual_keys.gd")
const LocalizedPayloadKeysScript := preload("res://scripts/core/localized_payload_keys.gd")
const TextPayloadKeysScript := preload("res://scripts/core/text_payload_keys.gd")

const KEY_STORIES := "stories"
const KEY_VISUALS := "visuals"
const KEY_DEFAULT_MODE := "default_mode"
const KEY_MODES := "modes"

const KEY_MODE := "mode"
const KEY_SPEAKER := "speaker"
const KEY_SPEAKER_NAME := "speaker_name"
const KEY_TEXT := TextPayloadKeysScript.KEY_TEXT
const KEY_OUTFIT := CharacterVisualKeysScript.KEY_OUTFIT
const KEY_EXPRESSION := CharacterVisualKeysScript.KEY_EXPRESSION

const KEY_BACKGROUND_NAME := "background_name"
const KEY_BACKGROUND_PATH := "background_path"
const KEY_CHARACTER_NAME := "character_name"
const KEY_SHOW_HUD := "show_hud"
const KEY_SHOW_TOP_BUTTONS := "show_top_buttons"
const KEY_SHOW_CHARACTER := "show_character"
const KEY_CHARACTER_VISIBLE := "character_visible"
const KEY_DATE_TEXT := DisplayPayloadKeysScript.KEY_DATE_TEXT
const KEY_HUD_OPTIONS := "hud_options"
const KEY_DIALOGUE_OPTIONS := "dialogue_options"

const KEY_DEFAULT_OUTFIT := CharacterVisualKeysScript.KEY_DEFAULT_OUTFIT
const KEY_DEFAULT_EXPRESSION := CharacterVisualKeysScript.KEY_DEFAULT_EXPRESSION

const EVENT_KEY_CG_PATH := "cg_path"
const EVENT_KEY_DIALOGUE := "dialogue"
const EVENT_KEY_NAME_KO := LocalizedPayloadKeysScript.KEY_NAME_KO
const EVENT_KEY_SUMMARY_KO := LocalizedPayloadKeysScript.KEY_SUMMARY_KO
