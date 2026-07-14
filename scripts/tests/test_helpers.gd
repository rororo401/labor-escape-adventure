extends RefCounted

const GameSessionAccessScript := preload("res://scripts/core/game_session_access.gd")


func get_game_session(root: Node) -> Node:
	return GameSessionAccessScript.get_from_node(root)


func find_node(root: Node, node_name: String) -> Node:
	if root == null:
		return null
	if root.name == node_name:
		return root
	for child: Node in root.get_children():
		var found: Node = find_node(child, node_name)
		if found != null:
			return found
	return null


func find_button_containing(root: Node, text: String) -> Button:
	if root == null:
		return null
	if root is Button:
		var button := root as Button
		if button.text.contains(text):
			return button
	for child: Node in root.get_children():
		var found: Button = find_button_containing(child, text)
		if found != null:
			return found
	return null


func find_closed_date_with_choice(game, category_id: String, action_id: String, fallback_date: String = "") -> String:
	if not game.setup("2016-07-01"):
		return fallback_date
	for index in game.calendar.count():
		var day: Dictionary = game.calendar.get_day(index)
		if bool(day.get("is_trading_day", true)):
			continue
		game.day_index = index
		var choices: Array = game.get_closed_day_choices(category_id, 4)
		for choice: Dictionary in choices:
			if String(choice.get("id", "")) == action_id:
				return String(day.get("date", ""))
	return fallback_date


func ids_from_items(items: Array) -> Array[String]:
	var ids: Array[String] = []
	for item: Dictionary in items:
		ids.append(String(item.get("id", "")))
	return ids
