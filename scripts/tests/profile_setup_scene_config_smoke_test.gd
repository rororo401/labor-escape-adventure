extends "res://scripts/tests/test_scene_tree.gd"

const ProfileSetupSceneConfigScript := preload("res://scripts/ui/profile_setup_scene_config.gd")
const UiBackgroundPathsScript := preload("res://scripts/ui/ui_background_paths.gd")
const UiScenePathsScript := preload("res://scripts/ui/ui_scene_paths.gd")


func _initialize() -> void:
	_expect(ProfileSetupSceneConfigScript.BACKGROUND_NAME == "ProfileBackground", "profile background node name should stay stable")
	_expect(ProfileSetupSceneConfigScript.BACKGROUND_PATH == UiBackgroundPathsScript.HOME_PROLOGUE_LIVING_ROOM, "profile background path should use the shared background path")
	_expect(ProfileSetupSceneConfigScript.PROLOGUE_SCENE_PATH == UiScenePathsScript.PROLOGUE, "prologue scene path should use the shared scene path")
	_expect(ProfileSetupSceneConfigScript.EMPTY_NAME_MESSAGE == "이름을 입력해줘.", "empty-name message should stay stable")

	print("Profile setup scene config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
