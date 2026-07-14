class_name GameDifficulty
extends RefCounted

const EASY := "easy"
const NORMAL := "normal"
const HARD := "hard"
const IDS := [EASY, NORMAL, HARD]
const DEFAULT := HARD

# The goal and historical prices never change. Difficulty only changes the
# monthly amount available for investment; these are calibration values, not
# claimed clear-rate multipliers.
const SALARY_MULTIPLIERS := {
	HARD: 1.0,
	NORMAL: 2.75,
	EASY: 7.0
}


static func normalize(difficulty: String) -> String:
	return difficulty if IDS.has(difficulty) else DEFAULT


static func salary_multiplier(difficulty: String) -> float:
	return float(SALARY_MULTIPLIERS.get(normalize(difficulty), 1.0))


static func display_name(difficulty: String) -> String:
	match normalize(difficulty):
		EASY:
			return "이지"
		NORMAL:
			return "노멀"
		_:
			return "하드"


static func description(difficulty: String) -> String:
	match normalize(difficulty):
		EASY:
			return "월 투자 가능 금액 7배 · 자산이 크게 줄면 한 번뿐인 비밀 구제"
		NORMAL:
			return "월 투자 가능 금액 2.75배 · 강세주 몰입 없이도 목표를 노릴 수 있는 기준"
		_:
			return "기존 밸런스 · 제한된 자금으로 10억에 도전"
