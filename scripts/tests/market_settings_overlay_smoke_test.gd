extends "res://scripts/tests/test_scene_tree.gd"

const MarketSettingsOverlayConfigScript := preload("res://scripts/ui/market_settings_overlay_config.gd")
const MarketSettingsOverlayScript := preload("res://scripts/ui/market_settings_overlay.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()
var _save_count := 0
var _gallery_count := 0
var _title_count := 0


func _initialize() -> void:
	root.size = Vector2i(720, 1280)

	var overlay := MarketSettingsOverlayScript.new()
	overlay.build()
	overlay.save_slots_requested.connect(func() -> void:
		_save_count += 1
	)
	overlay.gallery_requested.connect(func() -> void:
		_gallery_count += 1
	)
	overlay.title_requested.connect(func() -> void:
		_title_count += 1
	)
	root.add_child(overlay)
	await process_frame

	_expect(not overlay.visible, "settings overlay should start hidden")
	overlay.show_for_game(FakeGame.new(false))
	_expect(overlay.visible, "settings overlay should become visible")
	_expect(_helpers.find_node(overlay, MarketSettingsOverlayConfigScript.PANEL_NAME) != null, "settings overlay should render panel")

	var save_button := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.SAVE_BUTTON_NAME) as Button
	var gallery_button := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.GALLERY_BUTTON_NAME) as Button
	var title_button := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.TITLE_BUTTON_NAME) as Button
	var close_button := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.CLOSE_BUTTON_NAME) as Button
	var message_label := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.MESSAGE_LABEL_NAME) as Label
	var music_toggle := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.MUSIC_TOGGLE_NAME) as CheckButton
	var music_slider := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.MUSIC_VOLUME_SLIDER_NAME) as HSlider
	var music_value := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.MUSIC_VOLUME_VALUE_NAME) as Label
	var text_scale_option := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.TEXT_SCALE_OPTION_NAME) as OptionButton
	var reduced_motion_toggle := _helpers.find_node(overlay, MarketSettingsOverlayConfigScript.REDUCED_MOTION_TOGGLE_NAME) as CheckButton
	_expect(save_button != null, "settings overlay should have save button")
	_expect(gallery_button != null, "settings overlay should have gallery button")
	_expect(title_button != null, "settings overlay should have title button")
	_expect(close_button != null, "settings overlay should have close button")
	_expect(music_toggle != null, "settings overlay should have music toggle")
	_expect(music_slider != null, "settings overlay should have music volume slider")
	_expect(music_value != null, "settings overlay should have music volume value")
	_expect(text_scale_option != null, "settings overlay should have text scale option")
	_expect(reduced_motion_toggle != null, "settings overlay should have reduced motion toggle")
	_expect(music_slider.min_value == 0.0 and music_slider.max_value == 100.0, "music slider should use percent range")
	_expect(music_value.text.ends_with("%"), "music volume should display percent")
	_expect(text_scale_option.item_count == 3, "text scale option should expose three safe sizes")
	_expect(reduced_motion_toggle.tooltip_text.contains("전환"), "reduced motion option should explain its scope")

	save_button.emit_signal("pressed")
	_expect(_save_count == 1, "save button should emit save request")

	gallery_button.emit_signal("pressed")
	_expect(_gallery_count == 1, "gallery button should emit gallery request")

	title_button.emit_signal("pressed")
	_expect(_title_count == 0, "first title press should ask for confirmation when day is not completed")
	_expect(message_label.text.contains("한 번 더"), "first title press should show confirmation message")
	title_button.emit_signal("pressed")
	_expect(_title_count == 1, "second title press should emit title request")

	close_button.emit_signal("pressed")
	_expect(not overlay.visible, "close button should hide settings overlay")

	print("Market settings overlay smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakeGame:
	var day_completed := false

	func _init(next_day_completed: bool) -> void:
		day_completed = next_day_completed
