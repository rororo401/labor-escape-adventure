class_name GameSessionAccess
extends RefCounted

const AUTOLOAD_NAME := "GameSession"
const KEY_SESSION := "session"
const KEY_GAME := "game"
const KEY_IS_READY := "is_ready"


static func get_from_tree(tree: SceneTree) -> Node:
	if tree == null or tree.root == null:
		return null
	return tree.root.get_node_or_null(AUTOLOAD_NAME)


static func get_from_node(node: Node) -> Node:
	if node == null:
		return null
	if not node.is_inside_tree():
		return node.get_node_or_null(AUTOLOAD_NAME)
	return get_from_tree(node.get_tree())


static func is_ready(session: Node) -> bool:
	return session != null and bool(session.get(KEY_IS_READY))
