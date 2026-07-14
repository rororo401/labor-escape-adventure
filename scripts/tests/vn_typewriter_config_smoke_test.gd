extends "res://scripts/tests/test_scene_tree.gd"

const VnTypewriterConfigScript := preload("res://scripts/ui/vn_typewriter_config.gd")


func _initialize() -> void:
	_expect(VnTypewriterConfigScript.DEFAULT_CHARACTERS_PER_SECOND == 88.0, "default typewriter speed should stay stable")
	_expect(VnTypewriterConfigScript.AUTO_ADVANCE_DELAY_SECONDS == 0.9, "auto advance should wait briefly after a complete line")

	print("VN typewriter config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
