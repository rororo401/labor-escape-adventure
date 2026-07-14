class_name VnMixedSceneViewConfig
extends RefCounted

const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const UiNodeRefKeysScript := preload("res://scripts/ui/ui_node_ref_keys.gd")
const UiPayloadKeysScript := preload("res://scripts/ui/ui_payload_keys.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")

const DEFAULT_BACKGROUND_NAME := "SceneBackground"
const DEFAULT_BACKGROUND_PATH := UiPayloadKeysScript.EMPTY_MESSAGE
const DEFAULT_DATE_TEXT := UiPayloadKeysScript.EMPTY_MESSAGE
const DEFAULT_SHOW_HUD := true
const DEFAULT_SHOW_TOP_BUTTONS := true
const DEFAULT_SHOW_CHARACTER := true
const DEFAULT_CHARACTER_NAME := "ProtagonistBust"
const DEFAULT_SPEAKER_NAME := UiPayloadKeysScript.EMPTY_MESSAGE

const DEFAULT_CHARACTER_VISIBLE := true
const DEFAULT_OUTFIT := GameStateConfigScript.DEFAULT_PROTAGONIST_OUTFIT_ID
const DEFAULT_EXPRESSION := GameStateConfigScript.DEFAULT_PROTAGONIST_EXPRESSION_ID

const KEY_BACKGROUND_RECT := UiNodeRefKeysScript.KEY_BACKGROUND_RECT
const KEY_CHARACTER_TEXTURE_RECT := "character_texture_rect"
const KEY_DATE_LABEL := VnTopHudConfigScript.KEY_DATE_LABEL
const KEY_STATUS_BARS := VnTopHudConfigScript.KEY_STATUS_BARS
const KEY_NAME_LABEL := VnDialogueBoxConfigScript.KEY_NAME_LABEL
const KEY_DIALOGUE_LABEL := VnDialogueBoxConfigScript.KEY_DIALOGUE_LABEL
