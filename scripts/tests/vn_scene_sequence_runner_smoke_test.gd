extends "res://scripts/tests/test_scene_tree.gd"

const VnSceneSequenceRunnerScript := preload("res://scripts/ui/vn_scene_sequence_runner.gd")
const VnStepSequenceScript := preload("res://scripts/ui/vn_step_sequence.gd")


func _initialize() -> void:
	var label := Label.new()
	root.add_child(label)

	var runner = VnSceneSequenceRunnerScript.new()
	var changed_steps: Array[String] = []
	var finish_count := [0]
	runner.connect_step_changed(func(step: Dictionary, _index: int) -> void:
		changed_steps.append(String(step.get("id", "")))
	)
	runner.finished.connect(func() -> void:
		finish_count[0] += 1
	)
	runner.bind_label(label, 1.0)
	runner.set_steps([
		{
			"id": "first",
			"text": "첫 번째 문장"
		},
		{
			"id": "second",
			"text": "두 번째 문장"
		}
	])

	_expect(changed_steps == ["first"], "runner should forward the first step change")
	_expect(label.text == "첫 번째 문장", "runner should render the first line")

	var first_result: int = runner.handle_input(_left_click())
	_expect(first_result == VnStepSequenceScript.ADVANCE_INCOMPLETE, "first input should complete the current typewriter text")
	_expect(label.visible_characters == label.text.length(), "first input should reveal the whole current line")

	var second_result: int = runner.handle_input(_left_click())
	_expect(second_result == VnStepSequenceScript.ADVANCE_LINE_CHANGED, "second input should move to the next step")
	_expect(changed_steps == ["first", "second"], "runner should forward the next step change")
	_expect(label.text == "두 번째 문장", "runner should render the second line")

	runner.handle_input(_left_click())
	var finish_result: int = runner.handle_input(_left_click())
	_expect(finish_result == VnStepSequenceScript.ADVANCE_FINISHED, "runner should report finished after the final complete line")
	_expect(int(finish_count[0]) == 1, "runner should emit finished once")

	runner.block()
	var blocked_result: int = runner.handle_input(_left_click())
	_expect(blocked_result == VnStepSequenceScript.ADVANCE_INCOMPLETE, "blocked runner should ignore input")
	_expect(int(finish_count[0]) == 1, "blocked runner should not emit another finish")

	_verify_auto_advance()

	print("VN scene sequence runner smoke test passed.")
	finish_test()


func _left_click() -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	return event


func _verify_auto_advance() -> void:
	var label := Label.new()
	root.add_child(label)
	var runner = VnSceneSequenceRunnerScript.new()
	var finished_count := [0]
	runner.finished.connect(func() -> void:
		finished_count[0] += 1
	)
	runner.bind_label(label, 1000.0)
	runner.set_steps([{"text": "첫 줄"}, {"text": "둘째 줄"}])
	runner.set_auto_advance_enabled(true)
	runner.update(0.1)
	runner.update(1.0)
	_expect(runner.get_current_index() == 1, "auto advance should move after the complete-line delay")
	runner.update(0.1)
	runner.update(1.0)
	_expect(int(finished_count[0]) == 1, "auto advance should finish the final line")

	var paused_label := Label.new()
	root.add_child(paused_label)
	var paused_runner = VnSceneSequenceRunnerScript.new()
	paused_runner.bind_label(paused_label, 1000.0)
	paused_runner.set_steps([{"text": "멈춤"}, {"text": "넘어가면 안 됨"}])
	paused_runner.set_auto_advance_enabled(true)
	paused_runner.pause_auto_advance()
	paused_runner.update(0.1)
	paused_runner.update(2.0)
	_expect(paused_runner.get_current_index() == 0, "paused auto advance should not cross an error or choice boundary")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
