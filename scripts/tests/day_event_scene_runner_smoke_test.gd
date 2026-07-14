extends "res://scripts/tests/test_scene_tree.gd"

const DayEventSceneRunnerScript := preload("res://scripts/ui/day_event_scene_runner.gd")
const TestAssetPathsScript := preload("res://scripts/tests/test_asset_paths.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	await process_frame
	var runner = DayEventSceneRunnerScript.new()
	var event := {
		"name_ko": "테스트 이벤트",
		"cg_path": TestAssetPathsScript.HOME_MORNING_BACKGROUND,
		"dialogue": ["첫 줄", "둘째 줄"],
		"summary_ko": "요약"
	}
	_expect(runner.dialogue_lines(event).size() == 2, "dialogue lines should prefer explicit dialogue")

	var fallback_event := {
		"name_ko": "요약 이벤트",
		"summary_ko": "요약만 있는 이벤트"
	}
	_expect(runner.dialogue_lines(fallback_event) == ["요약만 있는 이벤트"], "summary should be used as fallback dialogue")

	var layer := runner.begin(root, event, TestAssetPathsScript.HOME_PROLOGUE_BACKGROUND)
	_expect(layer != null, "event layer should be created")
	await process_frame
	_expect(_helpers.find_node(root, "DayEventCgLayer") != null, "event layer node should exist")
	_expect(_helpers.find_node(root, "EventCG") != null, "event CG should exist")
	_expect(_helpers.find_node(root, "EventDialogue") != null, "event dialogue should exist")
	for _index in 4:
		layer.call("_advance")
		await process_frame
	await layer.finished

	var market_event := {
		"name_ko": "시장 뉴스 테스트",
		"cg_path": TestAssetPathsScript.HOME_MORNING_BACKGROUND,
		"playback_mode": "cg_then_standing",
		"standing_background_path": TestAssetPathsScript.HOME_PROLOGUE_BACKGROUND,
		"standing_outfit": "homewear",
		"standing_expression": "neutral",
		"dialogue": ["뉴스 첫 줄", "내 대사"]
	}
	var market_layer := runner.begin(root, market_event, TestAssetPathsScript.HOME_PROLOGUE_BACKGROUND, Callable(), "2024-08-05")
	_expect(market_layer != null, "market fixed playback layer should be created")
	await process_frame
	var character := _helpers.find_node(market_layer, "ProtagonistBust")
	_expect(character != null and not character.visible, "market fixed first line should hide the standing character")
	market_layer.call("_advance")
	await process_frame
	market_layer.call("_advance")
	await process_frame
	_expect(character.visible, "market fixed second line should show the standing character")
	for _index in 3:
		market_layer.call("_advance")
		await process_frame
	await market_layer.finished

	print("Day event scene runner smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
