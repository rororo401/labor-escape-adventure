class_name MarketSettingsOverlayConfig
extends RefCounted

const OVERLAY_NAME := "MarketSettingsOverlay"
const BACKDROP_NAME := "MarketSettingsBackdrop"
const PANEL_NAME := "MarketSettingsPanel"
const TITLE_LABEL_NAME := "MarketSettingsTitle"
const MESSAGE_LABEL_NAME := "MarketSettingsMessage"
const AUDIO_SECTION_LABEL_NAME := "MarketSettingsAudioLabel"
const MUSIC_TOGGLE_NAME := "MarketSettingsMusicToggle"
const MUSIC_VOLUME_LABEL_NAME := "MarketSettingsMusicVolumeLabel"
const MUSIC_VOLUME_SLIDER_NAME := "MarketSettingsMusicVolumeSlider"
const MUSIC_VOLUME_VALUE_NAME := "MarketSettingsMusicVolumeValue"
const ACCESSIBILITY_SECTION_LABEL_NAME := "MarketSettingsAccessibilityLabel"
const TEXT_SCALE_LABEL_NAME := "MarketSettingsTextScaleLabel"
const TEXT_SCALE_OPTION_NAME := "MarketSettingsTextScaleOption"
const REDUCED_MOTION_TOGGLE_NAME := "MarketSettingsReducedMotionToggle"
const SAVE_BUTTON_NAME := "MarketSettingsSaveButton"
const GALLERY_BUTTON_NAME := "MarketSettingsGalleryButton"
const TITLE_BUTTON_NAME := "MarketSettingsTitleButton"
const CLOSE_BUTTON_NAME := "MarketSettingsCloseButton"

const BACKDROP_COLOR := Color("#22191599")
const PANEL_POSITION := Vector2(92, 210)
const PANEL_SIZE := Vector2(536, 840)
const PANEL_COLOR := Color("#fff4e4f2")
const PANEL_BORDER_COLOR := Color("#7a5748")
const PANEL_BORDER_WIDTH := 2
const PANEL_CORNER_RADIUS := 8

const TITLE_POSITION := Vector2(132, 235)
const TITLE_SIZE := Vector2(456, 44)
const TITLE_FONT_SIZE := 30
const TITLE_COLOR := Color("#51392f")

const MESSAGE_POSITION := Vector2(150, 282)
const MESSAGE_SIZE := Vector2(420, 62)
const MESSAGE_FONT_SIZE := 19
const MESSAGE_COLOR := Color("#6a4c40")

const AUDIO_SECTION_POSITION := Vector2(150, 350)
const AUDIO_SECTION_SIZE := Vector2(420, 34)
const AUDIO_SECTION_FONT_SIZE := 21

const MUSIC_TOGGLE_POSITION := Vector2(160, 390)
const MUSIC_TOGGLE_SIZE := Vector2(400, 44)
const MUSIC_TOGGLE_FONT_SIZE := 21

const MUSIC_VOLUME_LABEL_POSITION := Vector2(160, 440)
const MUSIC_VOLUME_LABEL_SIZE := Vector2(92, 44)
const MUSIC_VOLUME_SLIDER_POSITION := Vector2(252, 444)
const MUSIC_VOLUME_SLIDER_SIZE := Vector2(244, 36)
const MUSIC_VOLUME_VALUE_POSITION := Vector2(502, 440)
const MUSIC_VOLUME_VALUE_SIZE := Vector2(70, 44)
const MUSIC_VOLUME_FONT_SIZE := 19

const ACCESSIBILITY_SECTION_POSITION := Vector2(150, 502)
const ACCESSIBILITY_SECTION_SIZE := Vector2(420, 34)
const ACCESSIBILITY_SECTION_FONT_SIZE := 21

const TEXT_SCALE_LABEL_POSITION := Vector2(160, 542)
const TEXT_SCALE_LABEL_SIZE := Vector2(170, 48)
const TEXT_SCALE_OPTION_POSITION := Vector2(338, 542)
const TEXT_SCALE_OPTION_SIZE := Vector2(234, 48)
const TEXT_SCALE_FONT_SIZE := 19
const TEXT_SCALE_VALUES := [1.0, 1.05, 1.1]
const TEXT_SCALE_LABELS := ["기본 (100%)", "크게 (105%)", "아주 크게 (110%)"]

const REDUCED_MOTION_TOGGLE_POSITION := Vector2(160, 600)
const REDUCED_MOTION_TOGGLE_SIZE := Vector2(412, 44)
const REDUCED_MOTION_FONT_SIZE := 20

const BUTTON_SIZE := Vector2(360, 54)
const BUTTON_X := 180
const SAVE_BUTTON_Y := 680
const GALLERY_BUTTON_Y := 746
const TITLE_BUTTON_Y := 812
const CLOSE_BUTTON_Y := 878
const BUTTON_FONT_SIZE := 22

const DEFAULT_MESSAGE := "게임 설정"
const SAVE_SUCCESS_MESSAGE := "저장 완료"
const SAVE_FAILED_MESSAGE := "저장하지 못했어"
const TITLE_CONFIRM_MESSAGE := "오늘을 마무리하지 않았어. 한 번 더 누르면 타이틀로 돌아가."
