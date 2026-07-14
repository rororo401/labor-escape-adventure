extends "res://scripts/tests/test_scene_tree.gd"

const ProtagonistStandingViewScript := preload("res://scripts/ui/protagonist_standing_view.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")

var _failed := false


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var host := Control.new()
	host.size = Vector2(720, 1280)
	root.add_child(host)
	await process_frame

	var standing_view = ProtagonistStandingViewScript.new()
	_expect(ProtagonistStandingViewScript.CHARACTER_ASSETS_PATH == GameStateConfigScript.CHARACTER_ASSETS_PATH, "standing view should use the shared character assets path")
	_expect(ProtagonistStandingViewScript.CHARACTER_ID == GameStateConfigScript.PROTAGONIST_CHARACTER_ID, "standing view should use the shared protagonist id")
	var rect: TextureRect = standing_view.add_to(host, "TestProtagonistBust")
	_expect(rect != null, "standing helper should create a TextureRect")
	_expect(rect.name == "TestProtagonistBust", "standing helper should preserve node name")
	_expect(rect.size == Vector2(808, 900), "standing helper should use shared bust size")

	var resolved: Dictionary = standing_view.apply(host, "homewear", "thinking")
	_expect(resolved.get("asset_ready", false), "standing helper should resolve a ready asset")
	_expect(resolved.get("outfit_id", "") == "homewear", "standing helper without date should keep the requested outfit")
	_expect(rect.texture != null, "standing helper should apply a texture")
	_expect(rect.position.x > -300.0 and rect.position.x < 300.0, "standing helper should keep the bust in the shared horizontal layout band")
	_expect(rect.position.y >= 100.0 and rect.position.y <= 500.0, "standing helper should keep the bust in the shared vertical layout band")

	var summer_resolved: Dictionary = standing_view.apply(host, "homewear", "thinking", "2016-07-02")
	_expect(summer_resolved.get("outfit_id", "") == "summer_homewear", "standing helper should map homewear to summer homewear on summer dates")
	_expect(rect.size.x <= host.size.x, "standing helper should keep the texture rect within the viewport width")
	_expect(rect.position.x >= -1.0 and rect.position.x + rect.size.x <= host.size.x + 1.0, "standing helper should not overflow horizontally after seasonal image layout")

	var winter_resolved: Dictionary = standing_view.apply(host, "summer_homewear", "thinking", "2016-12-02")
	_expect(winter_resolved.get("outfit_id", "") == "homewear", "standing helper should map summer homewear back to homewear on winter dates")

	if _failed:
		fail_test()
		return
	print("Protagonist standing view smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
