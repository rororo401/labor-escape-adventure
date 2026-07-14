extends "res://scripts/tests/test_scene_tree.gd"

const WindowAspectRatioGuardScript := preload("res://scripts/ui/window_aspect_ratio_guard.gd")


func _initialize() -> void:
	_expect(
		WindowAspectRatioGuardScript.should_manage_window("macos", true),
		"desktop builds should enforce the fixed window aspect"
	)
	_expect(
		not WindowAspectRatioGuardScript.should_manage_window("android", false),
		"mobile builds should not attempt to resize the system-managed window"
	)
	_expect(
		not WindowAspectRatioGuardScript.should_manage_window("headless", true),
		"headless runs should skip window management"
	)
	_expect(
		WindowAspectRatioGuardScript.calculate_constrained_size(Vector2i(900, 1280), Vector2i(720, 1280)) == Vector2i(900, 1600),
		"width-only resizing should update height to preserve 9:16"
	)
	_expect(
		WindowAspectRatioGuardScript.calculate_constrained_size(Vector2i(720, 1600), Vector2i(720, 1280)) == Vector2i(900, 1600),
		"height-only resizing should update width to preserve 9:16"
	)
	_expect(
		WindowAspectRatioGuardScript.calculate_constrained_size(Vector2i(800, 1424), Vector2i(720, 1280)) == Vector2i(801, 1424),
		"nearby free-form sizes should still snap to the fixed aspect"
	)
	_expect(
		WindowAspectRatioGuardScript.calculate_constrained_size(Vector2i(180, 320), Vector2i(360, 640)) == Vector2i(360, 640),
		"window resizing should keep a readable minimum size"
	)
	_expect(
		ProjectSettings.get_setting("display/window/stretch/aspect") == "keep",
		"project content should retain the design aspect while resizing"
	)
	_expect(
		bool(ProjectSettings.get_setting("display/window/size/resizable", false)),
		"desktop window should remain user-resizable"
	)
	_expect(
		String(ProjectSettings.get_setting("autoload/WindowAspectRatioGuard", "")) == "*res://scripts/ui/window_aspect_ratio_guard.gd",
		"aspect-ratio guard should run across every scene"
	)

	print("Window aspect ratio guard smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
