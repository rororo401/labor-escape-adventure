class_name IntroTitleViewConfig
extends RefCounted

const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")

const BACKGROUND_NAME := "Background"
const CONTENT_NAME := "Content"
const LAYOUT_NAME := "MobileTitleLayout"
const TITLE_LOGO_NAME := "TitleLogo"
const START_BUTTON_FRAME_NAME := "StartButtonFrame"
const START_BUTTON_IMAGE_NAME := "StartButtonImage"
const START_BUTTON_HIT_AREA_NAME := "StartButtonHitArea"
const CONTINUE_BUTTON_FRAME_NAME := "ContinueButtonFrame"
const CONTINUE_BUTTON_IMAGE_NAME := "ContinueButtonImage"
const CONTINUE_BUTTON_NAME := "ContinueButton"
const GALLERY_BUTTON_FRAME_NAME := "GalleryButtonFrame"
const GALLERY_BUTTON_IMAGE_NAME := "GalleryButtonImage"
const GALLERY_BUTTON_NAME := "GalleryButton"
const DEVELOPER_QUICK_BUTTON_NAME := "DeveloperQuickLaunchButton"

const KEY_TITLE_LOGO := "title_logo"
const KEY_START_BUTTON_FRAME := "start_button_frame"
const KEY_START_BUTTON := "start_button"
const KEY_CONTINUE_BUTTON := "continue_button"
const KEY_GALLERY_BUTTON := "gallery_button"
const KEY_DEVELOPER_QUICK_BUTTON := "developer_quick_button"
const KEY_INTERNAL_FRAME := "frame"
const KEY_INTERNAL_BUTTON := "button"

const OPTION_BACKGROUND_PATH := "background_path"
const OPTION_TITLE_LOGO_PATH := "title_logo_path"
const OPTION_START_BUTTON_PATH := "start_button_path"
const OPTION_SHOW_CONTINUE_BUTTON := "show_continue_button"
const OPTION_CONTINUE_BUTTON_PATH := "continue_button_path"
const OPTION_CONTINUE_TEXT := "continue_text"
const OPTION_SHOW_GALLERY_BUTTON := "show_gallery_button"
const OPTION_GALLERY_BUTTON_PATH := "gallery_button_path"
const OPTION_GALLERY_TEXT := "gallery_text"
const OPTION_SHOW_DEVELOPER_QUICK_LAUNCH := "show_developer_quick_launch"
const OPTION_DEVELOPER_QUICK_TEXT := "developer_quick_text"

const CALLBACK_START_PRESSED := "start_pressed"
const CALLBACK_CONTINUE_PRESSED := "continue_pressed"
const CALLBACK_GALLERY_PRESSED := "gallery_pressed"
const CALLBACK_DEVELOPER_QUICK_LAUNCH_PRESSED := "developer_quick_launch_pressed"

const CONTENT_MARGIN := {
	PanelLayoutHelpersScript.KEY_LEFT: 32,
	PanelLayoutHelpersScript.KEY_TOP: 54,
	PanelLayoutHelpersScript.KEY_RIGHT: 32,
	PanelLayoutHelpersScript.KEY_BOTTOM: 28
}
const LAYOUT_SEPARATION := 10
const TOP_SPACER_SIZE := Vector2(1, 24)
const TITLE_LOGO_SIZE := Vector2(620, 330)
const START_BUTTON_FRAME_SIZE := Vector2(400, 72)
const CONTINUE_BUTTON_SIZE := Vector2(400, 72)
const GALLERY_BUTTON_SIZE := Vector2(400, 72)
const DEVELOPER_BUTTON_SIZE := Vector2(540, 56)

const CONTINUE_BUTTON_FONT_SIZE := 24
const GALLERY_BUTTON_FONT_SIZE := 22
const DEVELOPER_BUTTON_FONT_SIZE := 20
const CONTINUE_BUTTON_TEXT_COLOR := Color("#fffdf7")
const GALLERY_BUTTON_TEXT_COLOR := Color("#fffdf7")
const DEVELOPER_BUTTON_TEXT_COLOR := Color("#fffdf7")
const CONTINUE_BUTTON_DISABLED_TEXT_COLOR := Color("#8b7568")
const GALLERY_BUTTON_DISABLED_TEXT_COLOR := Color("#8b7568")
const DEVELOPER_BUTTON_DISABLED_TEXT_COLOR := Color("#8b7568")
const CONTINUE_BUTTON_NORMAL_COLOR := Color("#67523edd")
const CONTINUE_BUTTON_NORMAL_BORDER := Color("#f2e2cf")
const CONTINUE_BUTTON_HOVER_COLOR := Color("#755f49ee")
const CONTINUE_BUTTON_HOVER_BORDER := Color("#ffffff")
const CONTINUE_BUTTON_PRESSED_COLOR := Color("#4f3f31ee")
const CONTINUE_BUTTON_PRESSED_BORDER := Color("#ffffff")
const CONTINUE_BUTTON_DISABLED_COLOR := Color("#c9b8a3bb")
const CONTINUE_BUTTON_DISABLED_BORDER := Color("#f2e2cf")
const GALLERY_BUTTON_NORMAL_COLOR := Color("#6f5842dd")
const GALLERY_BUTTON_NORMAL_BORDER := Color("#f2e2cf")
const GALLERY_BUTTON_HOVER_COLOR := Color("#80664dee")
const GALLERY_BUTTON_HOVER_BORDER := Color("#ffffff")
const GALLERY_BUTTON_PRESSED_COLOR := Color("#554332ee")
const GALLERY_BUTTON_PRESSED_BORDER := Color("#ffffff")
const GALLERY_BUTTON_DISABLED_COLOR := Color("#c9b8a3bb")
const GALLERY_BUTTON_DISABLED_BORDER := Color("#f2e2cf")
const DEVELOPER_BUTTON_NORMAL_COLOR := Color("#42656add")
const DEVELOPER_BUTTON_NORMAL_BORDER := Color("#dbe9da")
const DEVELOPER_BUTTON_HOVER_COLOR := Color("#4d777dee")
const DEVELOPER_BUTTON_HOVER_BORDER := Color("#ffffff")
const DEVELOPER_BUTTON_PRESSED_COLOR := Color("#2f4d52ee")
const DEVELOPER_BUTTON_PRESSED_BORDER := Color("#ffffff")
const DEVELOPER_BUTTON_DISABLED_COLOR := Color("#c9b8a3bb")
const DEVELOPER_BUTTON_DISABLED_BORDER := Color("#f2e2cf")

const FOCUS_BORDER_COLOR := Color("#f2c14e")
const FOCUS_BORDER_WIDTH := 3
const FOCUS_CORNER_RADIUS := 8
const START_ACCESSIBILITY_TEXT := "시작하기"
