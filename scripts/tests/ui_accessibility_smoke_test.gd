extends "res://scripts/tests/test_scene_tree.gd"

const UiAccessibilityScript := preload("res://scripts/ui/ui_accessibility.gd")


func _initialize() -> void:
	_expect(is_equal_approx(UiAccessibilityScript.normalize_text_scale(0.8), 1.0), "text scale should not shrink below layout baseline")
	_expect(is_equal_approx(UiAccessibilityScript.normalize_text_scale(1.07), 1.05), "text scale should snap to supported steps")
	_expect(is_equal_approx(UiAccessibilityScript.normalize_text_scale(1.4), 1.1), "text scale should not exceed validated layout limit")

	var panel := Control.new()
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 20)
	panel.add_child(label)
	UiAccessibilityScript.apply_text_scale_to_subtree(panel, 1.1)
	_expect(label.get_theme_font_size("font_size") == 22, "text scale should enlarge explicit label size")
	UiAccessibilityScript.apply_text_scale_to_subtree(panel, 1.0)
	_expect(label.get_theme_font_size("font_size") == 20, "text scale should restore the original size without compounding")

	var rich_text := RichTextLabel.new()
	rich_text.add_theme_font_size_override("normal_font_size", 18)
	panel.add_child(rich_text)
	UiAccessibilityScript.apply_text_scale_to_subtree(rich_text, 1.1)
	_expect(rich_text.get_theme_font_size("normal_font_size") == 20, "text scale should support rich text labels")
	panel.free()

	print("UI accessibility smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
