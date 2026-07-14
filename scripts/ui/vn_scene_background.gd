class_name VnSceneBackground
extends RefCounted

const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")


static func add_to(parent: Node, node_name: String, texture_path: String) -> TextureRect:
	var background := TextureRect.new()
	background.name = node_name
	UiHelpers.apply_cover_texture(background, texture_path)
	if parent != null:
		parent.add_child(background)
		_sync_to_parent_size(background, parent)
	return background


static func set_texture(background: TextureRect, texture_path: String) -> void:
	if background == null:
		return
	if texture_path.is_empty():
		return
	UiHelpers.apply_cover_texture(background, texture_path)
	_sync_to_parent_size(background, background.get_parent())


static func _sync_to_parent_size(background: TextureRect, parent: Node) -> void:
	var parent_control := parent as Control
	if parent_control == null:
		return

	if parent_control.size.x > 0.0 and parent_control.size.y > 0.0:
		background.size = parent_control.size
		return

	var viewport := parent_control.get_viewport()
	var viewport_size := viewport.get_visible_rect().size if viewport != null else Vector2.ZERO
	if viewport_size.x > 0.0 and viewport_size.y > 0.0:
		background.size = viewport_size
