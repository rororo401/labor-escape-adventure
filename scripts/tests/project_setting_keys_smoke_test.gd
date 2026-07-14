extends "res://scripts/tests/test_scene_tree.gd"

const ProjectSettingKeysScript := preload("res://scripts/core/project_setting_keys.gd")


func _initialize() -> void:
	_expect(ProjectSettingKeysScript.DEV_SESSION_STORE_PATH == "labor_escape/dev_session_store_path", "developer session-store setting key should stay stable")
	_expect(ProjectSettingKeysScript.SHOW_DEVELOPER_QUICK_LAUNCH == "labor_escape/show_developer_quick_launch", "developer quick-launch setting key should stay stable")

	print("Project setting keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
