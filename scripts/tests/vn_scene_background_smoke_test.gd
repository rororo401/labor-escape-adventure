extends "res://scripts/tests/test_scene_tree.gd"

const VnSceneBackgroundScript := preload("res://scripts/ui/vn_scene_background.gd")
const TestAssetPathsScript := preload("res://scripts/tests/test_asset_paths.gd")

const BACKGROUND_PATH := TestAssetPathsScript.HOME_PROLOGUE_BACKGROUND


func _initialize() -> void:
	var parent := Control.new()
	parent.size = Vector2(720, 1280)
	root.add_child(parent)

	var background := VnSceneBackgroundScript.add_to(parent, "TestBackground", BACKGROUND_PATH)
	_expect(background.name == "TestBackground", "background helper should preserve node name")
	_expect(background.get_parent() == parent, "background helper should attach to parent")
	_expect(background.texture != null, "background helper should load texture")
	_expect(background.expand_mode == TextureRect.EXPAND_IGNORE_SIZE, "background helper should use ignore-size expand mode")
	_expect(background.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "background helper should cover the viewport")
	_expect(background.anchor_left == 0.0 and background.anchor_top == 0.0, "background helper should anchor to top-left")
	_expect(background.anchor_right == 1.0 and background.anchor_bottom == 1.0, "background helper should anchor to bottom-right")
	_expect(background.size == parent.size, "background helper should immediately match parent size")

	VnSceneBackgroundScript.set_texture(background, TestAssetPathsScript.HOME_MORNING_BACKGROUND)
	_expect(background.texture != null, "background helper should replace texture")
	_expect(background.size == parent.size, "background helper should preserve parent-sized coverage after texture replacement")
	var replaced_texture := background.texture

	VnSceneBackgroundScript.set_texture(background, "")
	_expect(background.texture == replaced_texture, "background helper should ignore empty texture paths")

	parent.free()
	print("VN scene background smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
