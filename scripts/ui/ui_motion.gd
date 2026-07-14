class_name UiMotion
extends RefCounted

const REDUCED_TRANSITION_DURATION := 0.01
const REDUCED_HOLD_DURATION := 0.05


static func is_reduced(node: Node) -> bool:
	if node == null or not node.is_inside_tree():
		return false
	var preferences := node.get_node_or_null("/root/GamePreferences")
	return preferences != null \
		and preferences.has_method("is_reduced_motion_enabled") \
		and bool(preferences.is_reduced_motion_enabled())


static func transition_duration(node: Node, normal_duration: float) -> float:
	return duration_for(normal_duration, is_reduced(node), REDUCED_TRANSITION_DURATION)


static func hold_duration(node: Node, normal_duration: float) -> float:
	return duration_for(normal_duration, is_reduced(node), REDUCED_HOLD_DURATION)


static func duration_for(normal_duration: float, reduced: bool, reduced_maximum: float) -> float:
	if not reduced:
		return normal_duration
	return minf(normal_duration, reduced_maximum)
