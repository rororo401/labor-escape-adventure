extends RefCounted

const StyleboxThemeHelpersScript := preload("res://scripts/ui/stylebox_theme_helpers.gd")

const DEFAULT_UI_FONT_PATH := "res://assets/fonts/Pretendard-Regular.otf"
const NAME_TAG_FONT_PATH := "res://assets/fonts/Jua-Regular.ttf"


static func apply_full_rect(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_FULL_RECT)


static func ignore_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE


static func pass_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_PASS


static func stop_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_STOP


static func disable_horizontal_scroll(scroll: ScrollContainer) -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED


static func apply_cover_texture(texture_rect: TextureRect, texture_path: String = "") -> void:
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	apply_full_rect(texture_rect)
	if not texture_path.is_empty():
		texture_rect.texture = load_texture(texture_path)


static func load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var imported_texture := load(path) as Texture2D
		if imported_texture != null:
			return imported_texture

	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_error("Could not load image: %s" % path)
		return null
	return ImageTexture.create_from_image(image)


static func make_ui_font(font_path: String = DEFAULT_UI_FONT_PATH) -> Font:
	var font_file := load(font_path) as FontFile
	if font_file != null:
		return font_file

	var font := SystemFont.new()
	font.font_names = PackedStringArray([
		"Pretendard",
		"Apple SD Gothic Neo",
		"Noto Sans CJK KR",
		"Arial Unicode MS",
		"Helvetica"
	])
	font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	return font


static func make_name_tag_font() -> Font:
	var font_file := load(NAME_TAG_FONT_PATH) as FontFile
	if font_file != null:
		return font_file

	var font := SystemFont.new()
	font.font_names = PackedStringArray([
		"Jua",
		"Pretendard",
		"Apple SD Gothic Neo",
		"Noto Sans CJK KR",
		"Arial Unicode MS",
		"Helvetica"
	])
	font.font_weight = 700
	font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	return font


static func panel_style(
	color: Color,
	border: Color,
	shadow_color: Color = Color("#00000022"),
	shadow_size: int = 8,
	shadow_offset: Vector2 = Vector2(0, 3)
) -> StyleBoxFlat:
	return StyleboxThemeHelpersScript.make_flat_style(
		color,
		border,
		2,
		8,
		shadow_color,
		shadow_size,
		shadow_offset
	)


static func button_style(color: Color, border: Color, horizontal_margin: int = 14) -> StyleBoxFlat:
	var style := panel_style(color, border, Color.TRANSPARENT, 0, Vector2.ZERO)
	StyleboxThemeHelpersScript.apply_horizontal_content_margin(style, horizontal_margin)
	return style
