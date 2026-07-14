extends "res://scripts/tests/test_scene_tree.gd"

const EventCgGalleryOverlayScript := preload("res://scripts/ui/event_cg_gallery_overlay.gd")
const EventCgGalleryOverlayConfigScript := preload("res://scripts/ui/event_cg_gallery_overlay_config.gd")
const EventCgGalleryStoreScript := preload("res://scripts/core/event_cg_gallery_store.gd")
const DayEventKeysScript := preload("res://scripts/core/dayflow/day_event_keys.gd")
const TestAssetPathsScript := preload("res://scripts/tests/test_asset_paths.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

const TEST_PATH := "user://event_cg_gallery_overlay_smoke_test.json"

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	_remove_test_file()

	var store = EventCgGalleryStoreScript.new()
	store.save_path = TEST_PATH
	store.unlock_event_cg({
		DayEventKeysScript.KEY_ID: "album_test",
		DayEventKeysScript.KEY_NAME_KO: "앨범 테스트",
		DayEventKeysScript.KEY_CG_PATH: TestAssetPathsScript.HOME_MORNING_BACKGROUND
	}, TestAssetPathsScript.HOME_MORNING_BACKGROUND, "2016-07-01")

	var overlay = EventCgGalleryOverlayScript.new()
	overlay.gallery_store = store
	overlay.build()
	root.add_child(overlay)
	await process_frame

	_expect(not overlay.visible, "gallery overlay should start hidden")
	overlay.show_gallery()
	await process_frame
	_expect(overlay.visible, "gallery overlay should become visible")
	_expect(_helpers.find_node(overlay, EventCgGalleryOverlayConfigScript.PANEL_NAME) != null, "gallery overlay should render panel")
	var grid := _helpers.find_node(overlay, EventCgGalleryOverlayConfigScript.GRID_NAME) as GridContainer
	_expect(grid != null, "gallery overlay should render grid")
	var count_label := _helpers.find_node(overlay, EventCgGalleryOverlayConfigScript.COUNT_LABEL_NAME) as Label
	_expect(count_label != null and count_label.text == "1장", "gallery overlay should show unlocked count")
	_expect(_helpers.find_node(overlay, EventCgGalleryOverlayConfigScript.EMPTY_LABEL_NAME).visible == false, "gallery overlay should hide empty copy when entries exist")
	var card := grid.get_child(0) as Button
	_expect(card != null, "gallery overlay should render an entry card")
	_expect(card.accessibility_name == "앨범 테스트 CG 보기", "gallery card should expose its event title to accessibility tools")
	card.emit_signal("pressed")
	await process_frame
	var preview := _helpers.find_node(overlay, EventCgGalleryOverlayConfigScript.PREVIEW_BACKDROP_NAME) as Control
	_expect(preview != null and preview.visible, "gallery card should open preview")

	var many_entries: Array[Dictionary] = []
	for index in 500:
		many_entries.append({
			EventCgGalleryStoreScript.KEY_NAME_KO: "가상 앨범 %d" % index,
			EventCgGalleryStoreScript.KEY_CG_PATH: TestAssetPathsScript.HOME_MORNING_BACKGROUND
		})
	overlay.call("_populate_entries", many_entries)
	await process_frame
	_expect(grid.get_child_count() == EventCgGalleryOverlayConfigScript.PAGE_SIZE, "large gallery should create only one page of cards")
	_expect(count_label.text == "500장", "large gallery should keep the total unlock count")
	var page_label := _helpers.find_node(overlay, EventCgGalleryOverlayConfigScript.PAGE_LABEL_NAME) as Label
	var next_button := _helpers.find_node(overlay, EventCgGalleryOverlayConfigScript.NEXT_PAGE_BUTTON_NAME) as Button
	_expect(page_label != null and page_label.text == "1 / 125", "large gallery should show page count")
	_expect(next_button != null and not next_button.disabled, "large gallery should allow the next page")
	next_button.emit_signal("pressed")
	await process_frame
	_expect(page_label.text == "2 / 125", "next button should move one page")
	_expect(grid.get_child_count() == EventCgGalleryOverlayConfigScript.PAGE_SIZE, "page change should keep card count bounded")
	_expect(_helpers.find_node(grid, "EventCgGalleryCard4") != null, "second page should start at the next entry")

	_remove_test_file()
	print("Event CG gallery overlay smoke test passed.")
	finish_test()


func _remove_test_file() -> void:
	var absolute_path := ProjectSettings.globalize_path(TEST_PATH)
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(absolute_path)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		_remove_test_file()
		fail_test()
