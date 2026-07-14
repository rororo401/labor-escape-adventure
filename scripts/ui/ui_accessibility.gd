class_name UiAccessibility
extends RefCounted

const MIN_TEXT_SCALE := 1.0
const MAX_TEXT_SCALE := 1.1
const DEFAULT_TEXT_SCALE := 1.0
const TEXT_SCALE_STEP := 0.05
const BASE_SIZE_META_PREFIX := "accessibility_base_font_size_"


static func normalize_text_scale(value: float) -> float:
	var clamped := clampf(value, MIN_TEXT_SCALE, MAX_TEXT_SCALE)
	return snappedf(clamped, TEXT_SCALE_STEP)


static func apply_text_scale_to_subtree(root: Node, scale: float) -> void:
	if root == null or not is_instance_valid(root):
		return
	var normalized := normalize_text_scale(scale)
	_apply_to_node(root, normalized)
	for child in root.get_children():
		apply_text_scale_to_subtree(child, normalized)


static func _apply_to_node(node: Node, scale: float) -> void:
	if not node is Control:
		return
	var control := node as Control
	if control is RichTextLabel:
		for property_name in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size", "mono_font_size"]:
			_apply_font_size(control, property_name, scale)
		return
	if control is Label or control is Button or control is LineEdit or control is TextEdit:
		_apply_font_size(control, "font_size", scale)


static func _apply_font_size(control: Control, property_name: String, scale: float) -> void:
	var meta_key := BASE_SIZE_META_PREFIX + property_name
	var base_size: int
	if control.has_meta(meta_key):
		base_size = int(control.get_meta(meta_key))
	else:
		base_size = control.get_theme_font_size(property_name)
		if base_size <= 0:
			return
		control.set_meta(meta_key, base_size)
	control.add_theme_font_size_override(property_name, maxi(1, roundi(float(base_size) * scale)))
