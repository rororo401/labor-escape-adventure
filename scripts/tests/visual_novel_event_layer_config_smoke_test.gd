extends "res://scripts/tests/test_scene_tree.gd"

const VisualNovelEventLayerConfigScript := preload("res://scripts/ui/visual_novel_event_layer_config.gd")
const VnTypewriterConfigScript := preload("res://scripts/ui/vn_typewriter_config.gd")


func _initialize() -> void:
	_expect(VisualNovelEventLayerConfigScript.LAYER_NAME == "DayEventCgLayer", "event layer name should stay stable")
	_expect(VisualNovelEventLayerConfigScript.LAYER_Z_INDEX == 100, "event layer z-index should stay stable")
	_expect(VisualNovelEventLayerConfigScript.LAYER_ALPHA == 1.0, "event layer alpha should start opaque")
	_expect(VisualNovelEventLayerConfigScript.FALLBACK_SIZE == Vector2(720, 1280), "event layer fallback size should match portrait viewport")
	_expect(VisualNovelEventLayerConfigScript.FADE_OUT_DURATION == 0.16, "event layer fade duration should stay stable")
	_expect(VisualNovelEventLayerConfigScript.BACKGROUND_NAME == "EventCG", "event CG node name should stay stable")
	_expect(not VisualNovelEventLayerConfigScript.SHOW_HUD, "event layer should hide HUD by default")
	_expect(not VisualNovelEventLayerConfigScript.SHOW_CHARACTER, "event layer should hide standing character by default")
	_expect(VisualNovelEventLayerConfigScript.TITLE_LABEL_NAME == "EventTitle", "event title node name should stay stable")
	_expect(VisualNovelEventLayerConfigScript.TITLE_LABEL_WIDTH == 340.0, "event title width should fit the wider name tag")
	_expect(VisualNovelEventLayerConfigScript.DIALOGUE_LABEL_NAME == "EventDialogue", "event dialogue node name should stay stable")
	_expect(
		VisualNovelEventLayerConfigScript.CHARACTERS_PER_SECOND == VnTypewriterConfigScript.DEFAULT_CHARACTERS_PER_SECOND,
		"event layer should share the VN typewriter default speed"
	)

	print("Visual novel event layer config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
