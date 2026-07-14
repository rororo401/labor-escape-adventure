class_name VisualNovelEventLayerConfig
extends RefCounted

const VnTypewriterConfigScript := preload("res://scripts/ui/vn_typewriter_config.gd")

const LAYER_NAME := "DayEventCgLayer"
const LAYER_Z_INDEX := 100
const LAYER_ALPHA := 1.0
const FALLBACK_SIZE := Vector2(720, 1280)
const FADE_OUT_DURATION := 0.16
const OPTION_SKIP_FINISH_FADE := "skip_finish_fade"

const BACKGROUND_NAME := "EventCG"
const SHOW_HUD := false
const SHOW_CHARACTER := false
const TITLE_LABEL_NAME := "EventTitle"
const TITLE_LABEL_WIDTH := 340.0
const DIALOGUE_LABEL_NAME := "EventDialogue"

const CHARACTERS_PER_SECOND := VnTypewriterConfigScript.DEFAULT_CHARACTERS_PER_SECOND
