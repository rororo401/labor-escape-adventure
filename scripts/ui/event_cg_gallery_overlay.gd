class_name EventCgGalleryOverlay
extends Control

const EventCgGalleryOverlayConfigScript := preload("res://scripts/ui/event_cg_gallery_overlay_config.gd")
const EventCgGalleryStoreScript := preload("res://scripts/core/event_cg_gallery_store.gd")
const MarketUiStyleScript := preload("res://scripts/ui/market_ui_style.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")
const TextThemeHelpersScript := preload("res://scripts/ui/text_theme_helpers.gd")
const UiHelpers := preload("res://scripts/ui/ui_helpers.gd")

var gallery_store = EventCgGalleryStoreScript.new()
var _grid: GridContainer
var _count_label: Label
var _empty_label: Label
var _preview_layer: Control
var _preview_image: TextureRect
var _preview_title: Label
var _previous_page_button: Button
var _next_page_button: Button
var _page_label: Label
var _entries: Array[Dictionary] = []
var _page_index := 0


func build() -> void:
	name = EventCgGalleryOverlayConfigScript.OVERLAY_NAME
	UiHelpers.apply_full_rect(self)
	UiHelpers.stop_mouse(self)
	visible = false

	var backdrop := ColorRect.new()
	backdrop.name = EventCgGalleryOverlayConfigScript.BACKDROP_NAME
	UiHelpers.apply_full_rect(backdrop)
	backdrop.color = EventCgGalleryOverlayConfigScript.BACKDROP_COLOR
	add_child(backdrop)

	var panel := Panel.new()
	panel.name = EventCgGalleryOverlayConfigScript.PANEL_NAME
	panel.position = EventCgGalleryOverlayConfigScript.PANEL_POSITION
	panel.size = EventCgGalleryOverlayConfigScript.PANEL_SIZE
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)

	var title := _make_label(
		EventCgGalleryOverlayConfigScript.TITLE_TEXT,
		EventCgGalleryOverlayConfigScript.TITLE_POSITION,
		EventCgGalleryOverlayConfigScript.TITLE_SIZE,
		EventCgGalleryOverlayConfigScript.TITLE_FONT_SIZE,
		EventCgGalleryOverlayConfigScript.TITLE_COLOR
	)
	title.name = EventCgGalleryOverlayConfigScript.TITLE_LABEL_NAME
	add_child(title)

	_count_label = _make_label(
		"",
		EventCgGalleryOverlayConfigScript.COUNT_POSITION,
		EventCgGalleryOverlayConfigScript.COUNT_SIZE,
		EventCgGalleryOverlayConfigScript.COUNT_FONT_SIZE,
		EventCgGalleryOverlayConfigScript.TEXT_COLOR
	)
	_count_label.name = EventCgGalleryOverlayConfigScript.COUNT_LABEL_NAME
	TextThemeHelpersScript.apply_alignment(_count_label, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER)
	add_child(_count_label)

	var close_button := _make_button(
		EventCgGalleryOverlayConfigScript.CLOSE_BUTTON_NAME,
		EventCgGalleryOverlayConfigScript.CLOSE_TEXT,
		EventCgGalleryOverlayConfigScript.CLOSE_POSITION,
		EventCgGalleryOverlayConfigScript.CLOSE_SIZE
	)
	close_button.pressed.connect(hide)
	add_child(close_button)

	var scroll := ScrollContainer.new()
	scroll.name = EventCgGalleryOverlayConfigScript.SCROLL_NAME
	scroll.position = EventCgGalleryOverlayConfigScript.SCROLL_POSITION
	scroll.size = EventCgGalleryOverlayConfigScript.SCROLL_SIZE
	UiHelpers.disable_horizontal_scroll(scroll)
	add_child(scroll)

	_grid = GridContainer.new()
	_grid.name = EventCgGalleryOverlayConfigScript.GRID_NAME
	_grid.columns = EventCgGalleryOverlayConfigScript.GRID_COLUMNS
	PanelLayoutHelpersScript.apply_separation(_grid, EventCgGalleryOverlayConfigScript.GRID_SEPARATION)
	scroll.add_child(_grid)

	_empty_label = _make_label(
		EventCgGalleryOverlayConfigScript.EMPTY_TEXT,
		EventCgGalleryOverlayConfigScript.EMPTY_POSITION,
		EventCgGalleryOverlayConfigScript.EMPTY_SIZE,
		EventCgGalleryOverlayConfigScript.EMPTY_FONT_SIZE,
		EventCgGalleryOverlayConfigScript.TEXT_COLOR
	)
	_empty_label.name = EventCgGalleryOverlayConfigScript.EMPTY_LABEL_NAME
	_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.apply_alignment(_empty_label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(_empty_label)

	_build_page_controls()

	_build_preview_layer()


func show_gallery() -> void:
	visible = true
	_populate_entries(gallery_store.get_unlocked_entries())
	if _preview_layer != null:
		_preview_layer.visible = false


func _populate_entries(entries: Array[Dictionary]) -> void:
	_entries.assign(entries)
	_page_index = 0
	_render_page()


func _render_page() -> void:
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	if _count_label != null:
		_count_label.text = EventCgGalleryOverlayConfigScript.COUNT_FORMAT % _entries.size()
	if _empty_label != null:
		_empty_label.visible = _entries.is_empty()

	var start_index := _page_index * EventCgGalleryOverlayConfigScript.PAGE_SIZE
	var end_index := mini(start_index + EventCgGalleryOverlayConfigScript.PAGE_SIZE, _entries.size())
	for entry_index in range(start_index, end_index):
		_grid.add_child(_make_entry_card(_entries[entry_index], entry_index))
	_update_page_controls()


func _make_entry_card(entry: Dictionary, entry_index: int) -> Button:
	var card := Button.new()
	card.name = "EventCgGalleryCard%d" % entry_index
	card.custom_minimum_size = EventCgGalleryOverlayConfigScript.CARD_SIZE
	card.text = ""
	var accessibility_text := "%s CG 보기" % _entry_title(entry)
	card.accessibility_name = accessibility_text
	card.tooltip_text = accessibility_text
	StyleboxThemeHelpersScript.apply_button_styles(
		card,
		UiHelpers.panel_style(Color("#fffdf8"), Color("#d5bda8"), Color("#00000012"), 4, Vector2(0, 2)),
		UiHelpers.panel_style(Color("#fff7e8"), Color("#9b715f"), Color("#00000018"), 5, Vector2(0, 2)),
		UiHelpers.panel_style(Color("#f2e2d0"), Color("#7a5748"), Color("#00000010"), 3, Vector2.ZERO)
	)

	var image := TextureRect.new()
	image.name = "EventCgGalleryThumbnail%d" % entry_index
	image.position = Vector2(10, 10)
	image.size = EventCgGalleryOverlayConfigScript.THUMB_SIZE
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.texture = _load_thumbnail(String(entry.get(EventCgGalleryStoreScript.KEY_CG_PATH, "")))
	card.add_child(image)

	var label := _make_label(
		_entry_title(entry),
		Vector2(10, 344),
		EventCgGalleryOverlayConfigScript.CARD_LABEL_SIZE,
		EventCgGalleryOverlayConfigScript.CARD_FONT_SIZE,
		EventCgGalleryOverlayConfigScript.TEXT_COLOR
	)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.apply_alignment(label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	card.add_child(label)

	card.pressed.connect(_show_preview.bind(entry))
	return card


func _build_page_controls() -> void:
	_previous_page_button = _make_button(
		EventCgGalleryOverlayConfigScript.PREVIOUS_PAGE_BUTTON_NAME,
		"이전",
		EventCgGalleryOverlayConfigScript.PREVIOUS_PAGE_POSITION,
		EventCgGalleryOverlayConfigScript.PAGE_BUTTON_SIZE
	)
	_previous_page_button.pressed.connect(_change_page.bind(-1))
	add_child(_previous_page_button)

	_page_label = _make_label(
		"",
		EventCgGalleryOverlayConfigScript.PAGE_LABEL_POSITION,
		EventCgGalleryOverlayConfigScript.PAGE_LABEL_SIZE,
		EventCgGalleryOverlayConfigScript.BUTTON_FONT_SIZE,
		EventCgGalleryOverlayConfigScript.TEXT_COLOR
	)
	_page_label.name = EventCgGalleryOverlayConfigScript.PAGE_LABEL_NAME
	TextThemeHelpersScript.apply_alignment(_page_label, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	add_child(_page_label)

	_next_page_button = _make_button(
		EventCgGalleryOverlayConfigScript.NEXT_PAGE_BUTTON_NAME,
		"다음",
		EventCgGalleryOverlayConfigScript.NEXT_PAGE_POSITION,
		EventCgGalleryOverlayConfigScript.PAGE_BUTTON_SIZE
	)
	_next_page_button.pressed.connect(_change_page.bind(1))
	add_child(_next_page_button)


func _change_page(delta: int) -> void:
	var page_count := _page_count()
	if page_count <= 0:
		return
	_page_index = clampi(_page_index + delta, 0, page_count - 1)
	_render_page()


func _update_page_controls() -> void:
	var page_count := _page_count()
	if _page_label != null:
		_page_label.text = EventCgGalleryOverlayConfigScript.PAGE_FORMAT % [0 if page_count == 0 else _page_index + 1, page_count]
	if _previous_page_button != null:
		_previous_page_button.disabled = _page_index <= 0
	if _next_page_button != null:
		_next_page_button.disabled = page_count == 0 or _page_index >= page_count - 1


func _page_count() -> int:
	if _entries.is_empty():
		return 0
	return ceili(float(_entries.size()) / float(EventCgGalleryOverlayConfigScript.PAGE_SIZE))


func _load_thumbnail(path: String) -> Texture2D:
	if path.is_empty():
		return null
	var image := Image.load_from_file(path)
	if image == null or image.is_empty():
		return UiHelpers.load_texture(path)
	image.resize(
		int(EventCgGalleryOverlayConfigScript.THUMB_SIZE.x),
		int(EventCgGalleryOverlayConfigScript.THUMB_SIZE.y),
		Image.INTERPOLATE_LANCZOS
	)
	return ImageTexture.create_from_image(image)


func _build_preview_layer() -> void:
	_preview_layer = Control.new()
	_preview_layer.name = EventCgGalleryOverlayConfigScript.PREVIEW_BACKDROP_NAME
	UiHelpers.apply_full_rect(_preview_layer)
	UiHelpers.stop_mouse(_preview_layer)
	_preview_layer.visible = false
	add_child(_preview_layer)

	var backdrop := ColorRect.new()
	UiHelpers.apply_full_rect(backdrop)
	backdrop.color = Color("#0c0907ee")
	_preview_layer.add_child(backdrop)

	_preview_image = TextureRect.new()
	_preview_image.name = EventCgGalleryOverlayConfigScript.PREVIEW_IMAGE_NAME
	_preview_image.position = EventCgGalleryOverlayConfigScript.PREVIEW_IMAGE_POSITION
	_preview_image.size = EventCgGalleryOverlayConfigScript.PREVIEW_IMAGE_SIZE
	_preview_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview_layer.add_child(_preview_image)

	_preview_title = _make_label(
		"",
		EventCgGalleryOverlayConfigScript.PREVIEW_TITLE_POSITION,
		EventCgGalleryOverlayConfigScript.PREVIEW_TITLE_SIZE,
		EventCgGalleryOverlayConfigScript.BUTTON_FONT_SIZE,
		Color("#fff8ed")
	)
	_preview_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	TextThemeHelpersScript.apply_alignment(_preview_title, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER)
	_preview_layer.add_child(_preview_title)

	var close_button := _make_button(
		"EventCgGalleryPreviewCloseButton",
		EventCgGalleryOverlayConfigScript.PREVIEW_CLOSE_TEXT,
		EventCgGalleryOverlayConfigScript.PREVIEW_CLOSE_POSITION,
		EventCgGalleryOverlayConfigScript.PREVIEW_CLOSE_SIZE
	)
	close_button.pressed.connect(func() -> void:
		_preview_layer.visible = false
	)
	_preview_layer.add_child(close_button)


func _show_preview(entry: Dictionary) -> void:
	_preview_image.texture = UiHelpers.load_texture(String(entry.get(EventCgGalleryStoreScript.KEY_CG_PATH, "")))
	_preview_title.text = _entry_title(entry)
	_preview_layer.visible = true


func _entry_title(entry: Dictionary) -> String:
	var title := String(entry.get(EventCgGalleryStoreScript.KEY_NAME_KO, ""))
	return EventCgGalleryOverlayConfigScript.UNTITLED_TEXT if title.is_empty() else title


func _make_label(text: String, position_value: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := MarketUiStyleScript.make_label(font_size, color)
	label.text = text
	label.position = position_value
	label.size = size_value
	return label


func _make_button(button_name: String, text: String, position_value: Vector2, size_value: Vector2) -> Button:
	var button := MarketUiStyleScript.make_soft_button(text, size_value, EventCgGalleryOverlayConfigScript.BUTTON_FONT_SIZE)
	button.name = button_name
	button.position = position_value
	return button


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = EventCgGalleryOverlayConfigScript.PANEL_COLOR
	style.border_color = EventCgGalleryOverlayConfigScript.PANEL_BORDER_COLOR
	style.set_border_width_all(EventCgGalleryOverlayConfigScript.PANEL_BORDER_WIDTH)
	style.set_corner_radius_all(EventCgGalleryOverlayConfigScript.PANEL_CORNER_RADIUS)
	return style
