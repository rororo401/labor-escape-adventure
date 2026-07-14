extends "res://scripts/tests/test_scene_tree.gd"

const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")
const TestAssetPathsScript := preload("res://scripts/tests/test_asset_paths.gd")
const VisualNovelEventLayerScript := preload("res://scripts/ui/visual_novel_event_layer.gd")
const VisualNovelEventLayerConfigScript := preload("res://scripts/ui/visual_novel_event_layer_config.gd")

const BACKGROUND_PATH := TestAssetPathsScript.HOME_MORNING_BACKGROUND

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var layer: Control = VisualNovelEventLayerScript.new()
	root.add_child(layer)
	var lines: Array[String] = ["첫 줄"]
	layer.play(BACKGROUND_PATH, "테스트 이벤트", lines)
	await process_frame

	_expect(layer.name == VisualNovelEventLayerConfigScript.LAYER_NAME, "event layer should use the configured node name")
	_expect(layer.mouse_filter == Control.MOUSE_FILTER_STOP, "event layer should stop mouse input")
	_expect(layer.z_index == VisualNovelEventLayerConfigScript.LAYER_Z_INDEX, "event layer should use the configured z-index")
	_expect(layer.size.x > 0.0 and layer.size.y > 0.0, "event layer should resolve a non-empty viewport or fallback size")
	_expect(layer.size.y >= VisualNovelEventLayerConfigScript.FALLBACK_SIZE.y, "event layer should preserve portrait-height coverage")
	_expect(layer.modulate.a == VisualNovelEventLayerConfigScript.LAYER_ALPHA, "event layer should start opaque")
	_expect(_helpers.find_node(root, VisualNovelEventLayerConfigScript.BACKGROUND_NAME) != null, "event layer should create the configured CG background")
	var title := _helpers.find_node(root, VisualNovelEventLayerConfigScript.TITLE_LABEL_NAME) as Label
	var dialogue := _helpers.find_node(root, VisualNovelEventLayerConfigScript.DIALOGUE_LABEL_NAME) as Label
	_expect(title != null and title.text == "테스트 이벤트", "event layer should create the configured title label")
	_expect(title.size.x == VisualNovelEventLayerConfigScript.TITLE_LABEL_WIDTH, "event layer title should use configured width")
	_expect(dialogue != null and dialogue.text == "첫 줄", "event layer should create the configured dialogue label")

	var transition_state := {"started": false, "finished": false}
	layer.finish_transition_started.connect(func() -> void:
		transition_state["started"] = true
		transition_state["finished_when_started"] = bool(transition_state.get("finished", false))
	, CONNECT_ONE_SHOT)
	layer.finished.connect(func() -> void:
		transition_state["finished"] = true
	, CONNECT_ONE_SHOT)
	layer.call("_advance")
	await process_frame
	layer.call("_advance")
	await layer.finished
	_expect(bool(transition_state.get("started", false)), "final event should announce its fade before exposing the market")
	_expect(not bool(transition_state.get("finished_when_started", true)), "result transition should start before the event layer is removed")

	var instant_layer: Control = VisualNovelEventLayerScript.new()
	root.add_child(instant_layer)
	var instant_lines: Array[String] = ["다음 이벤트로"]
	var instant_state := {"finished": false}
	instant_layer.finished.connect(func() -> void:
		instant_state["finished"] = true
	, CONNECT_ONE_SHOT)
	instant_layer.play(BACKGROUND_PATH, "연속 이벤트", instant_lines, {
		VisualNovelEventLayerConfigScript.OPTION_SKIP_FINISH_FADE: true
	})
	await process_frame
	instant_layer.call("_advance")
	await process_frame
	if not bool(instant_state.get("finished", false)):
		instant_layer.call("_advance")
	await process_frame
	_expect(bool(instant_state.get("finished", false)), "intermediate event should emit finished immediately")
	_expect(not is_instance_valid(instant_layer) or instant_layer.modulate.a == VisualNovelEventLayerConfigScript.LAYER_ALPHA, "intermediate event should finish without a fade-to-underlay frame")

	print("Visual novel event layer smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
