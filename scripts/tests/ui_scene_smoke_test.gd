extends "res://scripts/tests/test_scene_tree.gd"

const DeveloperModeSceneConfigScript := preload("res://scripts/dev/developer_mode_scene_config.gd")
const IntroTitleViewConfigScript := preload("res://scripts/ui/intro_title_view_config.gd")
const ProfileFormConfigScript := preload("res://scripts/ui/profile_form_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const IntroScene := preload("res://scenes/intro/IntroScreen.tscn")
const ProfileScene := preload("res://scenes/profile/ProfileSetupScene.tscn")
const PrologueScene := preload("res://scenes/prologue/PrologueScene.tscn")
const FirstDayWorkScene := preload("res://scenes/day/FirstDayWorkScene.tscn")
const MorningBriefingScene := preload("res://scenes/day/MorningBriefingLayer.tscn")
const DeveloperModeScene := preload("res://scenes/dev/DeveloperModeScene.tscn")
const StandingCalibratorScene := preload("res://scenes/dev/StandingPositionCalibrator.tscn")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	await _assert_scene_node(IntroScene, IntroTitleViewConfigScript.BACKGROUND_NAME)
	await _assert_scene_node(ProfileScene, ProfileFormConfigScript.PANEL_NAME)
	await _assert_scene_node(PrologueScene, "DialogueBoxImage")
	await _assert_scene_node(FirstDayWorkScene, "DialogueBoxImage")
	await _assert_scene_node(MorningBriefingScene, "DialogueBoxImage")
	await _assert_scene_node(DeveloperModeScene, DeveloperModeSceneConfigScript.PANEL_NAME)
	await _assert_scene_node(StandingCalibratorScene, "CalibrationPanel")

	print("UI scene smoke test passed.")
	finish_test()


func _assert_scene_node(scene_resource: PackedScene, node_name: String) -> void:
	var scene := scene_resource.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var found: Node = _helpers.find_node(scene, node_name)
	_expect(found != null, "%s should exist" % node_name)
	scene.queue_free()
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
