extends Node

const DESIGN_SIZE := Vector2i(720, 1280)
const MINIMUM_WINDOW_SIZE := Vector2i(360, 640)

var _last_window_size := DESIGN_SIZE
var _is_applying_size := false


func _ready() -> void:
	if not should_manage_window(DisplayServer.get_name(), OS.has_feature("pc")):
		return

	var window := get_tree().root
	window.content_scale_size = DESIGN_SIZE
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	window.min_size = MINIMUM_WINDOW_SIZE
	_last_window_size = window.size
	window.size_changed.connect(_on_window_size_changed)
	_constrain_window(window)


static func should_manage_window(display_server_name: String, is_pc: bool) -> bool:
	return display_server_name != "headless" and is_pc


func _on_window_size_changed() -> void:
	if _is_applying_size:
		return

	var window := get_tree().root
	if window.mode != Window.MODE_WINDOWED:
		_last_window_size = window.size
		return
	_constrain_window(window)


func _constrain_window(window: Window) -> void:
	var constrained := calculate_constrained_size(window.size, _last_window_size)
	_last_window_size = constrained
	if constrained == window.size:
		return

	_is_applying_size = true
	window.size = constrained
	_is_applying_size = false


static func calculate_constrained_size(current_size: Vector2i, previous_size: Vector2i) -> Vector2i:
	if current_size.x <= 0 or current_size.y <= 0:
		return MINIMUM_WINDOW_SIZE
	if _matches_design_aspect(current_size):
		return _at_least_minimum(current_size)

	var safe_previous := previous_size
	if safe_previous.x <= 0 or safe_previous.y <= 0:
		safe_previous = DESIGN_SIZE

	var width_change := absf(float(current_size.x - safe_previous.x) / float(safe_previous.x))
	var height_change := absf(float(current_size.y - safe_previous.y) / float(safe_previous.y))
	var constrained: Vector2i
	if width_change >= height_change:
		constrained = Vector2i(
			current_size.x,
			roundi(float(current_size.x) * float(DESIGN_SIZE.y) / float(DESIGN_SIZE.x))
		)
	else:
		constrained = Vector2i(
			roundi(float(current_size.y) * float(DESIGN_SIZE.x) / float(DESIGN_SIZE.y)),
			current_size.y
		)
	return _at_least_minimum(constrained)


static func _matches_design_aspect(size: Vector2i) -> bool:
	var expected_height := roundi(float(size.x) * float(DESIGN_SIZE.y) / float(DESIGN_SIZE.x))
	return absi(size.y - expected_height) <= 1


static func _at_least_minimum(size: Vector2i) -> Vector2i:
	if size.x < MINIMUM_WINDOW_SIZE.x or size.y < MINIMUM_WINDOW_SIZE.y:
		return MINIMUM_WINDOW_SIZE
	return size
