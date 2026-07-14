extends "res://scripts/tests/test_scene_tree.gd"

const StandingBustMetricsScript := preload("res://scripts/core/standing_bust_metrics.gd")


func _initialize() -> void:
	_verify_default_and_region_metrics()
	_verify_visible_center_values()
	_verify_image_alpha_scan()

	print("Standing bust metrics smoke test passed.")
	finish_test()


func _verify_default_and_region_metrics() -> void:
	var fallback := StandingBustMetricsScript.default_metrics(384.0, 430.0)
	_expect(float(fallback.get("source_width", 0.0)) == 384.0, "default metrics should keep source width")
	_expect(float(fallback.get("source_height", 0.0)) == 430.0, "default metrics should keep source height")
	_expect(float(fallback.get("visible_center_x", 0.0)) == 192.0, "default metrics should center by source width")

	var region := StandingBustMetricsScript.bust_region([10, 20, 300, 900], 430.0)
	_expect(region.position == Vector2(10, 20), "bust region should keep atlas origin")
	_expect(region.size == Vector2(300, 430), "bust region should clamp source height")


func _verify_visible_center_values() -> void:
	_expect(StandingBustMetricsScript.visible_center_from_values(100.0, []) == 50.0, "empty pixels should fallback to center")
	_expect(StandingBustMetricsScript.visible_center_from_values(100.0, [80, 10, 40]) == 40.0, "odd visible pixels should use median")
	_expect(StandingBustMetricsScript.visible_center_from_values(100.0, [80, 10, 40, 20]) == 30.0, "even visible pixels should average middle values")

	var metrics := StandingBustMetricsScript.metrics_from_visible_x_values(100.0, 50.0, [90, 30, 10])
	_expect(float(metrics.get("source_width", 0.0)) == 100.0, "metrics should keep source width")
	_expect(float(metrics.get("source_height", 0.0)) == 50.0, "metrics should keep source height")
	_expect(float(metrics.get("visible_center_x", 0.0)) == 30.0, "metrics should calculate visible center")


func _verify_image_alpha_scan() -> void:
	var image := Image.create(6, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.set_pixel(2, 1, Color(1, 1, 1, 0.5))
	image.set_pixel(4, 2, Color(1, 1, 1, 1.0))

	var region := Rect2(1, 1, 4, 2)
	var visible_x_values: Array = StandingBustMetricsScript.collect_visible_x_values(image, region)
	_expect(visible_x_values == [1, 3], "alpha scan should collect visible x offsets within the region")

	var metrics := StandingBustMetricsScript.metrics_from_image(image, region)
	_expect(float(metrics.get("visible_center_x", 0.0)) == 2.0, "image metrics should use visible x median")

	var full_metrics := StandingBustMetricsScript.metrics_from_image(image, Rect2())
	_expect(float(full_metrics.get("source_width", 0.0)) == 6.0, "empty image region should scan full image width")
	_expect(float(full_metrics.get("source_height", 0.0)) == 4.0, "empty image region should scan full image height")
	_expect(float(full_metrics.get("visible_center_x", 0.0)) == 3.0, "empty image region should use full-image visible center")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
