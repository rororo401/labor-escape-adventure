extends "res://scripts/tests/test_scene_tree.gd"

const DateTransitionLayerConfigScript := preload("res://scripts/ui/date_transition_layer_config.gd")
const DateTransitionScene := preload("res://scenes/transition/DateTransitionLayer.tscn")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var layer: Control = DateTransitionScene.instantiate()
	root.add_child(layer)
	await process_frame
	_assert_configured_nodes(layer)

	layer.play("2016-07-01", "2016-07-02", "Saturday")
	await create_timer(1.0).timeout
	var date_label := _helpers.find_node(layer, DateTransitionLayerConfigScript.DATE_LABEL_NAME) as Label
	var weekday_label := _helpers.find_node(layer, DateTransitionLayerConfigScript.WEEKDAY_LABEL_NAME) as Label
	var stamp_label := _helpers.find_node(layer, DateTransitionLayerConfigScript.STAMP_LABEL_NAME) as Label
	_expect(date_label.text == "2016.07.02", "date transition should snap to the new date")
	_expect(weekday_label.text == "토요일 아침", "date transition should snap to the morning weekday")
	_expect(stamp_label.text == "새로운 하루!", "date transition should show the configured morning stamp")

	layer.continue_now()
	await layer.finished
	print("Date transition smoke test passed.")
	finish_test()


func _assert_configured_nodes(layer: Control) -> void:
	var background := _helpers.find_node(layer, DateTransitionLayerConfigScript.BACKGROUND_NAME) as TextureRect
	var date_label := _helpers.find_node(layer, DateTransitionLayerConfigScript.DATE_LABEL_NAME) as Label
	var weekday_label := _helpers.find_node(layer, DateTransitionLayerConfigScript.WEEKDAY_LABEL_NAME) as Label
	var stamp_label := _helpers.find_node(layer, DateTransitionLayerConfigScript.STAMP_LABEL_NAME) as Label
	_expect(layer.size.x > 0.0 and layer.size.y > 0.0, "date transition layer should resolve a non-empty viewport or fallback size")
	_expect(layer.size.y >= DateTransitionLayerConfigScript.FALLBACK_SIZE.y, "date transition layer should preserve portrait-height coverage")
	_expect(background != null, "date transition should render configured background")
	_expect(background.texture != null, "date transition background should load a texture")
	_expect(background.size.x > 0.0 and background.size.y > 0.0, "date transition background should cover a non-empty area")
	_expect(date_label != null and date_label.position == DateTransitionLayerConfigScript.DATE_LABEL_POSITION, "date label should use configured position")
	_expect(date_label.size == DateTransitionLayerConfigScript.DATE_LABEL_SIZE, "date label should use configured size")
	_expect(date_label.get_theme_color(TextThemeHelpersScript.THEME_FONT_OUTLINE_COLOR) == DateTransitionLayerConfigScript.DATE_OUTLINE_COLOR, "date label should use configured outline color")
	_expect(date_label.get_theme_constant(TextThemeHelpersScript.THEME_OUTLINE_SIZE) == DateTransitionLayerConfigScript.DATE_OUTLINE_SIZE, "date label should use configured outline size")
	_expect(weekday_label != null and weekday_label.position == DateTransitionLayerConfigScript.WEEKDAY_LABEL_POSITION, "weekday label should use configured position")
	_expect(stamp_label != null and is_equal_approx(stamp_label.rotation_degrees, DateTransitionLayerConfigScript.STAMP_ROTATION_DEGREES), "stamp label should use configured rotation")
	_expect(stamp_label.get_theme_color(TextThemeHelpersScript.THEME_FONT_OUTLINE_COLOR) == DateTransitionLayerConfigScript.STAMP_OUTLINE_COLOR, "stamp label should use configured outline color")
	_expect(stamp_label.get_theme_constant(TextThemeHelpersScript.THEME_OUTLINE_SIZE) == DateTransitionLayerConfigScript.STAMP_OUTLINE_SIZE, "stamp label should use configured outline size")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
