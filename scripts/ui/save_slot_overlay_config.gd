class_name SaveSlotOverlayConfig
extends RefCounted

const OVERLAY_NAME := "SaveSlotOverlay"
const BACKDROP_NAME := "SaveSlotBackdrop"
const PANEL_NAME := "SaveSlotPanel"
const TITLE_NAME := "SaveSlotTitle"
const MESSAGE_NAME := "SaveSlotMessage"
const CLOSE_BUTTON_NAME := "SaveSlotCloseButton"
const CONFIRM_LAYER_NAME := "SaveSlotConfirmLayer"
const CONFIRM_PANEL_NAME := "SaveSlotConfirmPanel"
const CONFIRM_MESSAGE_NAME := "SaveSlotConfirmMessage"
const CONFIRM_CANCEL_BUTTON_NAME := "SaveSlotConfirmCancelButton"
const CONFIRM_ACCEPT_BUTTON_NAME := "SaveSlotConfirmAcceptButton"

const BACKDROP_COLOR := Color("#17110dcc")
const PANEL_POSITION := Vector2(34, 82)
const PANEL_SIZE := Vector2(652, 1116)
const PANEL_COLOR := Color("#fff8edf7")
const PANEL_BORDER_COLOR := Color("#7a5748")

const TITLE_POSITION := Vector2(74, 112)
const TITLE_SIZE := Vector2(572, 48)
const TITLE_FONT_SIZE := 30
const TITLE_COLOR := Color("#51392f")
const MESSAGE_POSITION := Vector2(74, 166)
const MESSAGE_SIZE := Vector2(572, 50)
const MESSAGE_FONT_SIZE := 17
const TEXT_COLOR := Color("#6a4c40")

const ROW_START_Y := 226.0
const ROW_HEIGHT := 136.0
const ROW_GAP := 10.0
const ROW_X := 62.0
const ROW_SIZE := Vector2(596, 136)
const ROW_COLOR := Color("#fffdf8")
const ROW_BORDER_COLOR := Color("#d5bda8")
const ROW_TITLE_OFFSET := Vector2(18, 12)
const ROW_TITLE_SIZE := Vector2(180, 32)
const ROW_TITLE_FONT_SIZE := 20
const ROW_SUMMARY_OFFSET := Vector2(18, 48)
const ROW_SUMMARY_SIZE := Vector2(370, 70)
const ROW_SUMMARY_FONT_SIZE := 16
const ROW_BUTTON_SIZE := Vector2(92, 44)
const LOAD_BUTTON_OFFSET := Vector2(486, 76)
const SAVE_BUTTON_OFFSET := Vector2(386, 76)
const ROW_BUTTON_FONT_SIZE := 17

const CLOSE_POSITION := Vector2(230, 1128)
const CLOSE_SIZE := Vector2(260, 52)
const CLOSE_FONT_SIZE := 20

const CONFIRM_BACKDROP_COLOR := Color("#17110de0")
const CONFIRM_PANEL_POSITION := Vector2(82, 430)
const CONFIRM_PANEL_SIZE := Vector2(556, 300)
const CONFIRM_PANEL_COLOR := Color("#fff8edf9")
const CONFIRM_PANEL_BORDER_COLOR := Color("#7a5748")
const CONFIRM_MESSAGE_POSITION := Vector2(122, 472)
const CONFIRM_MESSAGE_SIZE := Vector2(476, 108)
const CONFIRM_MESSAGE_FONT_SIZE := 21
const CONFIRM_BUTTON_SIZE := Vector2(210, 54)
const CONFIRM_CANCEL_POSITION := Vector2(122, 626)
const CONFIRM_ACCEPT_POSITION := Vector2(388, 626)
const CONFIRM_BUTTON_FONT_SIZE := 20

const DEFAULT_MESSAGE := "수동 저장 3개 · 자동 저장 3개"
const SAVE_SUCCESS_MESSAGE := "수동 저장 완료"
const SAVE_FAILED_MESSAGE := "저장하지 못했어"
const LOAD_FAILED_MESSAGE := "불러오지 못했어"
const EMPTY_SUMMARY := "비어 있음"
const INVALID_SUMMARY := "손상된 저장"
const CONFIRM_CANCEL_TEXT := "취소"
const CONFIRM_OVERWRITE_TEXT := "덮어쓰기"
const CONFIRM_LOAD_TEXT := "불러오기"
