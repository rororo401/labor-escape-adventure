extends "res://scripts/tests/test_scene_tree.gd"

const UiTweenPropertyConfigScript := preload("res://scripts/ui/ui_tween_property_config.gd")


func _initialize() -> void:
	_expect(UiTweenPropertyConfigScript.PROPERTY_MODULATE_ALPHA == "modulate:a", "modulate alpha tween property should stay stable")
	_expect(UiTweenPropertyConfigScript.PROPERTY_POSITION_Y == "position:y", "position-y tween property should stay stable")
	_expect(UiTweenPropertyConfigScript.PROPERTY_SCALE == "scale", "scale tween property should stay stable")

	print("UI tween property config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
