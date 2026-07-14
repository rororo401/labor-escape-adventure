class_name HudStatusBars
extends RefCounted

const HudStatusBarsConfigScript := preload("res://scripts/ui/hud_status_bars_config.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")


static func add_to(parent: Control, status: Dictionary = {}, position_value: Vector2 = HudStatusBarsConfigScript.POSITION) -> Dictionary:
	var root := Control.new()
	root.name = HudStatusBarsConfigScript.ROOT_NAME
	root.position = position_value
	parent.add_child(root)

	var rows := {}
	for index in HudStatusBarsConfigScript.STATUS_KEYS.size():
		var key := String(HudStatusBarsConfigScript.STATUS_KEYS[index])
		rows[key] = _add_row(root, key, index)
		if index < HudStatusBarsConfigScript.STATUS_KEYS.size() - 1:
			_add_separator(root, index)

	update(rows, status)
	return rows


static func update(rows: Dictionary, status: Dictionary) -> void:
	for index in HudStatusBarsConfigScript.STATUS_KEYS.size():
		var key := String(HudStatusBarsConfigScript.STATUS_KEYS[index])
		var value := int(status.get(key, HudStatusBarsConfigScript.DEFAULT_VALUES[index]))
		_update_row(Dictionary(rows.get(key, {})), value)


static func _add_row(parent: Control, key: String, index: int) -> Dictionary:
	var origin := Vector2(index * HudStatusBarsConfigScript.ITEM_GAP, 0)

	var label := _make_label(
		String(HudStatusBarsConfigScript.STATUS_LABELS[index]),
		origin,
		HudStatusBarsConfigScript.LABEL_SIZE,
		HudStatusBarsConfigScript.LABEL_COLOR
	)
	label.name = HudStatusBarsConfigScript.LABEL_NAME_FORMAT % [index + 1]
	parent.add_child(label)

	var bar_bg := ColorRect.new()
	bar_bg.name = HudStatusBarsConfigScript.BAR_BACKGROUND_NAME_FORMAT % [index + 1]
	bar_bg.position = origin + HudStatusBarsConfigScript.BAR_OFFSET
	bar_bg.size = HudStatusBarsConfigScript.BAR_SIZE
	bar_bg.color = HudStatusBarsConfigScript.BAR_BACKGROUND_COLOR
	parent.add_child(bar_bg)

	var bar_fill := ColorRect.new()
	bar_fill.name = HudStatusBarsConfigScript.BAR_FILL_NAME_FORMAT % [index + 1]
	bar_fill.position = bar_bg.position
	bar_fill.size = Vector2.ZERO
	bar_fill.color = HudStatusBarsConfigScript.STATUS_COLORS[index]
	parent.add_child(bar_fill)

	var value_label := _make_label(
		"",
		origin + HudStatusBarsConfigScript.VALUE_OFFSET,
		HudStatusBarsConfigScript.VALUE_SIZE,
		HudStatusBarsConfigScript.VALUE_COLOR
	)
	value_label.name = HudStatusBarsConfigScript.VALUE_NAME_FORMAT % [index + 1]
	TextThemeHelpersScript.apply_alignment(value_label, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER)
	parent.add_child(value_label)

	return {
		"key": key,
		"fill": bar_fill,
		"value": value_label
	}


static func _add_separator(parent: Control, index: int) -> void:
	var origin := Vector2(index * HudStatusBarsConfigScript.ITEM_GAP, 0)
	var separator := _make_label(
		HudStatusBarsConfigScript.SEPARATOR_TEXT,
		origin + HudStatusBarsConfigScript.SEPARATOR_OFFSET,
		HudStatusBarsConfigScript.SEPARATOR_SIZE,
		HudStatusBarsConfigScript.SEPARATOR_COLOR
	)
	separator.name = HudStatusBarsConfigScript.SEPARATOR_NAME_FORMAT % [index + 1]
	TextThemeHelpersScript.apply_alignment(separator, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	parent.add_child(separator)


static func _update_row(row: Dictionary, value: int) -> void:
	var clamped := clampi(value, 0, 100)
	var fill := row.get("fill") as ColorRect
	if fill != null:
		fill.size = Vector2(HudStatusBarsConfigScript.BAR_SIZE.x * float(clamped) / 100.0, HudStatusBarsConfigScript.BAR_SIZE.y)
	var value_label := row.get("value") as Label
	if value_label != null:
		value_label.text = "%d" % clamped


static func _make_label(text: String, position_value: Vector2, size_value: Vector2, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position_value
	label.size = size_value
	TextThemeHelpersScript.apply_ui_text_style(label, HudStatusBarsConfigScript.FONT_SIZE, color)
	TextThemeHelpersScript.apply_outline(
		label,
		HudStatusBarsConfigScript.TEXT_OUTLINE_COLOR,
		HudStatusBarsConfigScript.TEXT_OUTLINE_SIZE
	)
	TextThemeHelpersScript.center_vertical(label)
	return label
