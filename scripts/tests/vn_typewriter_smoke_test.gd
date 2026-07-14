extends "res://scripts/tests/test_scene_tree.gd"

const VnTypewriterScript := preload("res://scripts/ui/vn_typewriter.gd")


func _initialize() -> void:
	var label := Label.new()
	root.add_child(label)
	await process_frame

	var typewriter = VnTypewriterScript.new()
	typewriter.bind(label, 10.0)
	typewriter.show("abcdef")
	_expect(label.text == "abcdef", "typewriter should set label text")
	_expect(label.visible_characters == 0, "typewriter should start hidden")
	_expect(not typewriter.is_complete(), "typewriter line should start incomplete")

	typewriter.update(0.2)
	_expect(label.visible_characters == 2, "typewriter should reveal characters by speed")
	_expect(not typewriter.consume_advance(), "first advance should complete the current line")
	_expect(label.visible_characters == 6, "advance should reveal the full current line")
	_expect(typewriter.consume_advance(), "second advance should allow caller to move on")

	typewriter.show_complete("오류 메시지")
	_expect(label.text == "오류 메시지", "complete text should replace label text")
	_expect(label.visible_characters == "오류 메시지".length(), "complete text should be fully visible")

	print("VN typewriter smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
