class_name ProfileFormTextState
extends RefCounted

const ProfileFormTextStateConfigScript := preload("res://scripts/ui/profile_form_text_state_config.gd")

const GOAL_TITLE := "10억 모으기 게임"
const GOAL_SUBTITLE := "순자산 10억을 모아 경제적 자유를 얻자"
const FORM_TITLE := "프로필 설정"
const NAME_LABEL := "이름"
const NAME_PLACEHOLDER := "이름을 입력하세요"
const SUBMIT_TEXT := "시작하기"


static func name_input_text(profile, default_name: String) -> String:
	var name := String(profile.player_name)
	return "" if name == default_name else name


static func profile_summary(profile) -> String:
	return "나이  %s\n직업  %s" % [
		String(profile.age_band),
		String(profile.job_title)
	]


static func header_labels() -> Array[Dictionary]:
	return [
		{
			ProfileFormTextStateConfigScript.KEY_TEXT: GOAL_TITLE,
			ProfileFormTextStateConfigScript.KEY_FONT_SIZE: 42,
			ProfileFormTextStateConfigScript.KEY_COLOR: Color("#3b2d29"),
			ProfileFormTextStateConfigScript.KEY_ALIGNMENT: HORIZONTAL_ALIGNMENT_CENTER,
			ProfileFormTextStateConfigScript.KEY_OUTLINE: true
		},
		{
			ProfileFormTextStateConfigScript.KEY_TEXT: GOAL_SUBTITLE,
			ProfileFormTextStateConfigScript.KEY_FONT_SIZE: 23,
			ProfileFormTextStateConfigScript.KEY_COLOR: Color("#6c5248"),
			ProfileFormTextStateConfigScript.KEY_ALIGNMENT: HORIZONTAL_ALIGNMENT_CENTER
		},
		{
			ProfileFormTextStateConfigScript.KEY_TEXT: FORM_TITLE,
			ProfileFormTextStateConfigScript.KEY_FONT_SIZE: 30,
			ProfileFormTextStateConfigScript.KEY_COLOR: Color("#40312d"),
			ProfileFormTextStateConfigScript.KEY_ALIGNMENT: HORIZONTAL_ALIGNMENT_CENTER
		},
		{
			ProfileFormTextStateConfigScript.KEY_TEXT: NAME_LABEL,
			ProfileFormTextStateConfigScript.KEY_FONT_SIZE: 24,
			ProfileFormTextStateConfigScript.KEY_COLOR: Color("#6c5248"),
			ProfileFormTextStateConfigScript.KEY_ALIGNMENT: HORIZONTAL_ALIGNMENT_LEFT
		}
	]
