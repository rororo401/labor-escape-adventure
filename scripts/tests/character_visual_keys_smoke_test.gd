extends "res://scripts/tests/test_scene_tree.gd"

const CharacterVisualKeysScript := preload("res://scripts/core/character_visual_keys.gd")


func _initialize() -> void:
	_expect(CharacterVisualKeysScript.KEY_OUTFIT == "outfit", "outfit visual key should stay stable")
	_expect(CharacterVisualKeysScript.KEY_EXPRESSION == "expression", "expression visual key should stay stable")
	_expect(CharacterVisualKeysScript.KEY_DEFAULT_OUTFIT == "default_outfit", "default outfit visual key should stay stable")
	_expect(CharacterVisualKeysScript.KEY_DEFAULT_EXPRESSION == "default_expression", "default expression visual key should stay stable")

	print("Character visual keys smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
