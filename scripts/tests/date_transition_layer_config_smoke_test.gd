extends "res://scripts/tests/test_scene_tree.gd"

const DateTransitionLayerConfigScript := preload("res://scripts/ui/date_transition_layer_config.gd")
const UiCommonNodeNamesScript := preload("res://scripts/ui/ui_common_node_names.gd")


func _initialize() -> void:
	_expect(DateTransitionLayerConfigScript.BACKGROUND_NAME == "DateChangeBackground", "background node name should stay stable")
	_expect(DateTransitionLayerConfigScript.DATE_LABEL_NAME == UiCommonNodeNamesScript.DATE_LABEL_NAME, "date label name should use the shared UI node name")
	_expect(DateTransitionLayerConfigScript.WEEKDAY_LABEL_NAME == "WeekdayLabel", "weekday label name should stay stable")
	_expect(DateTransitionLayerConfigScript.STAMP_LABEL_NAME == "StampLabel", "stamp label name should stay stable")
	_expect(DateTransitionLayerConfigScript.FALLBACK_SIZE == Vector2(720, 1280), "date transition fallback size should match portrait viewport")
	_expect(DateTransitionLayerConfigScript.DATE_LABEL_POSITION == Vector2(70, 448), "date label position should preserve current layout")
	_expect(DateTransitionLayerConfigScript.DATE_LABEL_SIZE == Vector2(580, 116), "date label size should preserve current layout")
	_expect(DateTransitionLayerConfigScript.WEEKDAY_LABEL_POSITION == Vector2(70, 565), "weekday label position should preserve current layout")
	_expect(DateTransitionLayerConfigScript.STAMP_LABEL_SIZE.x >= 240.0, "stamp label should fit the longer morning copy")
	_expect(DateTransitionLayerConfigScript.STAMP_FONT_SIZE == 32, "stamp font size should fit the longer morning copy")
	_expect(DateTransitionLayerConfigScript.STAMP_ROTATION_DEGREES == -8, "stamp rotation should preserve current layout")
	_expect(DateTransitionLayerConfigScript.FADE_IN_DURATION == 0.18, "fade-in duration should preserve current timing")
	_expect(DateTransitionLayerConfigScript.COVERED_HOLD_DURATION == 0.28, "covered hold duration should preserve current timing")
	_expect(DateTransitionLayerConfigScript.DATE_POP_SCALE == Vector2(1.08, 1.08), "date pop scale should preserve current animation")
	_expect(DateTransitionLayerConfigScript.FADE_OUT_DURATION == 0.20, "fade-out duration should preserve current timing")

	print("Date transition layer config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
