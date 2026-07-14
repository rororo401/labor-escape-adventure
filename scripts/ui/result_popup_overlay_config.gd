class_name ResultPopupOverlayConfig
extends RefCounted

const OVERLAY_NAME := "ResultPopupOverlay"
const PANEL_IMAGE_NAME := "ResultReceiptPanel"
const BACKDROP_NAME := "ResultPopupBackdrop"
const CLOSE_BUTTON_NAME := "ResultPopupCloseButton"
const TITLE_LABEL_NAME := "ResultPopupTitle"

const PANEL_TEXTURE_PATH := "res://assets/ui/status/result_receipt_panel.png"
const USER_OVERRIDE_PATH := "user://result_popup_layout_overrides.json"
const DEFAULT_OVERRIDE_PATH := "res://data/game/result_popup_layout_overrides.generated.json"

const KEY_VERSION := "version"
const KEY_NOTE := "note"
const KEY_LAYOUT := "layout"
const KEY_X := "x"
const KEY_Y := "y"
const KEY_PANEL_POSITION := "panel_position"
const KEY_TITLE_POSITION := "title_position"
const KEY_ROW_LABEL_X := "row_label_x"
const KEY_ROW_VALUE_X := "row_value_x"
const KEY_ROW_Y := "row_y"
const KEY_CLOSE_BUTTON_POSITION := "close_button_position"

const BACKDROP_COLOR := Color("#fff1dcdd")

const PANEL_POSITION := Vector2(82, 226)
const PANEL_SIZE := Vector2(556, 706)
const TITLE_POSITION := Vector2(202, 326)
const TITLE_SIZE := Vector2(316, 48)
const TITLE_FONT_SIZE := 26
const TITLE_COLOR := Color("#5b3d36")

const ROW_LABEL_X := 228
const ROW_VALUE_X := 328
const RESULT_ROW_COUNT := 7
const ROW_Y := [448, 496, 544, 592, 640, 688, 736]
const ROW_LABEL_SIZE := Vector2(116, 32)
const ROW_VALUE_SIZE := Vector2(130, 32)
const ROW_FONT_SIZE := 20
const ROW_LABEL_COLOR := Color("#5f443b")
const ROW_VALUE_COLOR := Color("#4a3832")
const ACTIVITY_VALUE_X := ROW_VALUE_X
const ACTIVITY_VALUE_Y_OFFSET := -6
const ACTIVITY_VALUE_SIZE := Vector2(258, 44)
const ACTIVITY_FONT_SIZE := 15
const ACTIVITY_MAX_LINES := 2

const CLOSE_BUTTON_POSITION := Vector2(252, 794)
const CLOSE_BUTTON_SIZE := Vector2(216, 56)
const CLOSE_BUTTON_FONT_SIZE := 22
const CLOSE_BUTTON_TEXT_COLOR := Color("#6a4a40")


static func default_layout() -> Dictionary:
	return {
		KEY_PANEL_POSITION: {KEY_X: PANEL_POSITION.x, KEY_Y: PANEL_POSITION.y},
		KEY_TITLE_POSITION: {KEY_X: TITLE_POSITION.x, KEY_Y: TITLE_POSITION.y},
		KEY_ROW_LABEL_X: ROW_LABEL_X,
		KEY_ROW_VALUE_X: ROW_VALUE_X,
		KEY_ROW_Y: ROW_Y.duplicate(),
		KEY_CLOSE_BUTTON_POSITION: {KEY_X: CLOSE_BUTTON_POSITION.x, KEY_Y: CLOSE_BUTTON_POSITION.y}
	}
