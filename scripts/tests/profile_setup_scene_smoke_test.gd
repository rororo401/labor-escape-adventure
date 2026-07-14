extends "res://scripts/tests/test_scene_tree.gd"

const ProfileSetupScene := preload("res://scenes/profile/ProfileSetupScene.tscn")
const ProfileFormConfigScript := preload("res://scripts/ui/profile_form_config.gd")
const ProfileSetupSceneConfigScript := preload("res://scripts/ui/profile_setup_scene_config.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)

	var scene := ProfileSetupScene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var background := _helpers.find_node(root, ProfileSetupSceneConfigScript.BACKGROUND_NAME) as TextureRect
	var name_input := _helpers.find_node(root, ProfileFormConfigScript.NAME_INPUT_NAME) as LineEdit
	var confirm_button := _helpers.find_node(root, ProfileFormConfigScript.CONFIRM_BUTTON_NAME) as Button
	_expect(background != null, "profile setup should create the configured background node")
	_expect(background.texture != null, "profile setup should load the configured background texture")
	_expect(name_input != null, "profile setup should expose the configured name input")
	_expect(confirm_button != null, "profile setup should expose the configured confirm button")

	name_input.text = " "
	confirm_button.emit_signal("pressed")
	await process_frame

	_expect(_find_label_containing(root, ProfileSetupSceneConfigScript.EMPTY_NAME_MESSAGE) != null, "profile setup should show the configured empty-name message")
	_expect(_helpers.find_node(root, "PrologueScene") == null, "profile setup should stay on the profile scene when the name is empty")

	print("Profile setup scene smoke test passed.")
	finish_test()


func _find_label_containing(root_node: Node, text: String) -> Label:
	if root_node == null:
		return null
	if root_node is Label:
		var label := root_node as Label
		if label.text.contains(text):
			return label
	for child: Node in root_node.get_children():
		var found := _find_label_containing(child, text)
		if found != null:
			return found
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
