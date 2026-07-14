extends "res://scripts/tests/test_scene_tree.gd"

const VnStepSequenceScript := preload("res://scripts/ui/vn_step_sequence.gd")


func _initialize() -> void:
	var label := Label.new()
	root.add_child(label)

	var sequence = VnStepSequenceScript.new()
	var changed_steps: Array[String] = []
	sequence.bind(label, 1.0)
	sequence.step_changed.connect(func(step: Dictionary, _index: int) -> void:
		changed_steps.append(String(step.get("id", "")))
	)
	sequence.set_steps([
		{
			"id": "first",
			"text": "첫 번째 문장"
		},
		{
			"id": "second",
			"text": "두 번째 문장"
		}
	])

	_expect(changed_steps == ["first"], "sequence should emit the first step immediately")
	_expect(label.text == "첫 번째 문장", "sequence should render the first line")
	_expect(label.visible_characters == 0, "sequence should start with hidden characters")

	var first_advance: int = sequence.advance()
	_expect(first_advance == VnStepSequenceScript.ADVANCE_INCOMPLETE, "first advance should complete the typewriter")
	_expect(label.visible_characters == label.text.length(), "first advance should reveal the whole current line")

	var second_advance: int = sequence.advance()
	_expect(second_advance == VnStepSequenceScript.ADVANCE_LINE_CHANGED, "second advance should move to the next line")
	_expect(changed_steps == ["first", "second"], "sequence should emit the second step")
	_expect(label.text == "두 번째 문장", "sequence should render the second line")

	sequence.advance()
	var finish_advance: int = sequence.advance()
	_expect(finish_advance == VnStepSequenceScript.ADVANCE_FINISHED, "sequence should report finished after the final complete line")

	print("VN step sequence smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
