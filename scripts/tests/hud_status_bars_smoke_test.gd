extends "res://scripts/tests/test_scene_tree.gd"

const HudStatusBarsScript := preload("res://scripts/ui/hud_status_bars.gd")
const HudStatusBarsConfigScript := preload("res://scripts/ui/hud_status_bars_config.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")


func _initialize() -> void:
	var host := Control.new()
	root.add_child(host)
	var rows := HudStatusBarsScript.add_to(host, {
		PlayerStatusKeysScript.KEY_HEALTH: 80,
		PlayerStatusKeysScript.KEY_MOOD: 60,
		PlayerStatusKeysScript.KEY_FATIGUE: 35
	})

	var root_node := host.get_node_or_null(HudStatusBarsConfigScript.ROOT_NAME) as Control
	_expect(root_node != null, "HUD status bars should create a root node")
	_expect(root_node.position == HudStatusBarsConfigScript.POSITION, "HUD status bars should use configured position")
	_expect(HudStatusBarsConfigScript.FONT_SIZE == 18, "HUD status labels should use the enlarged font size")

	var health_row := Dictionary(rows.get(PlayerStatusKeysScript.KEY_HEALTH, {}))
	var mood_row := Dictionary(rows.get(PlayerStatusKeysScript.KEY_MOOD, {}))
	var fatigue_row := Dictionary(rows.get(PlayerStatusKeysScript.KEY_FATIGUE, {}))
	var health_value := health_row.get("value") as Label
	var health_fill := health_row.get("fill") as ColorRect
	var mood_fill := mood_row.get("fill") as ColorRect
	var fatigue_fill := fatigue_row.get("fill") as ColorRect
	var mood_label := root_node.get_node_or_null(HudStatusBarsConfigScript.LABEL_NAME_FORMAT % [2]) as Label
	var fatigue_label := root_node.get_node_or_null(HudStatusBarsConfigScript.LABEL_NAME_FORMAT % [3]) as Label
	var first_separator := root_node.get_node_or_null(HudStatusBarsConfigScript.SEPARATOR_NAME_FORMAT % [1]) as Label
	var second_separator := root_node.get_node_or_null(HudStatusBarsConfigScript.SEPARATOR_NAME_FORMAT % [2]) as Label
	_expect(health_value != null and health_value.text == "80", "HUD status bars should render health value")
	_expect(health_fill != null and int(health_fill.size.x) == int(HudStatusBarsConfigScript.BAR_SIZE.x * 0.8), "HUD status bars should render health fill width")
	_expect(mood_fill != null and fatigue_fill != null, "HUD status bars should render all three fills")
	_expect(health_fill.position.y == mood_fill.position.y and mood_fill.position.y == fatigue_fill.position.y, "HUD status bars should keep all bars on one line")
	_expect(health_fill.position.x < mood_fill.position.x and mood_fill.position.x < fatigue_fill.position.x, "HUD status bars should lay out left to right")
	_expect(health_value != null and mood_label != null and health_value.position.x + health_value.size.x <= mood_label.position.x, "HUD status bar value should not overlap the next label")
	_expect(mood_label != null and fatigue_label != null and fatigue_label.position.x - mood_label.position.x == HudStatusBarsConfigScript.ITEM_GAP, "HUD status bars should keep configured spacing between status items")
	_expect(first_separator != null and first_separator.text == HudStatusBarsConfigScript.SEPARATOR_TEXT, "HUD status bars should separate health and mood")
	_expect(second_separator != null and second_separator.text == HudStatusBarsConfigScript.SEPARATOR_TEXT, "HUD status bars should separate mood and fatigue")
	_expect(first_separator.position.x > health_value.position.x and first_separator.position.x < mood_label.position.x, "first separator should sit between health and mood")
	_expect(second_separator.position.x > mood_label.position.x and second_separator.position.x < fatigue_label.position.x, "second separator should sit between mood and fatigue")

	HudStatusBarsScript.update(rows, {PlayerStatusKeysScript.KEY_HEALTH: 120})
	_expect(health_value.text == "100", "HUD status bars should clamp values above 100")
	_expect(int(health_fill.size.x) == int(HudStatusBarsConfigScript.BAR_SIZE.x), "HUD status bars should clamp fill width")

	host.free()
	print("HUD status bars smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
