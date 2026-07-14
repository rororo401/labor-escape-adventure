class_name ProfileSetupSceneConfig
extends RefCounted

const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")

const BACKGROUND_NAME := "ProfileBackground"
const BACKGROUND_PATH := UiBackgroundPathsScript.HOME_PROLOGUE_LIVING_ROOM
const PROLOGUE_SCENE_PATH := UiScenePathsScript.PROLOGUE

const EMPTY_NAME_MESSAGE := "이름을 입력해줘."
