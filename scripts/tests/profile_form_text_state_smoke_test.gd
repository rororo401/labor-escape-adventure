extends "res://scripts/tests/test_scene_tree.gd"

const PlayerProfileScript := preload("res://scripts/core/player_profile.gd")
const ProfileFormTextStateConfigScript := preload("res://scripts/ui/profile_form_text_state_config.gd")
const ProfileFormTextStateScript := preload("res://scripts/ui/profile_form_text_state.gd")


func _initialize() -> void:
	_verify_name_input_text()
	_verify_profile_summary()
	_verify_header_labels()

	print("Profile form text state smoke test passed.")
	finish_test()


func _verify_name_input_text() -> void:
	var profile = PlayerProfileScript.new()
	_expect(ProfileFormTextStateScript.name_input_text(profile, PlayerProfileScript.DEFAULT_NAME) == "", "default player name should leave input blank")
	profile.set_player_name("테스트 사용자")
	_expect(ProfileFormTextStateScript.name_input_text(profile, PlayerProfileScript.DEFAULT_NAME) == "테스트 사용자", "saved player name should prefill input")


func _verify_profile_summary() -> void:
	var profile = PlayerProfileScript.new()
	var summary := ProfileFormTextStateScript.profile_summary(profile)
	_expect(summary.contains("20대"), "profile summary should include age band")
	_expect(summary.contains("스타트업 사무직"), "profile summary should include job title")


func _verify_header_labels() -> void:
	var labels := ProfileFormTextStateScript.header_labels()
	_expect(labels.size() == 4, "profile form should expose four header labels")
	_expect(String(Dictionary(labels[0]).get(ProfileFormTextStateConfigScript.KEY_TEXT, "")) == "10억 모으기 게임", "first header should be game goal")
	_expect(bool(Dictionary(labels[0]).get(ProfileFormTextStateConfigScript.KEY_OUTLINE, false)), "goal title should request outline")
	_expect(String(Dictionary(labels[3]).get(ProfileFormTextStateConfigScript.KEY_TEXT, "")) == "이름", "last header should label name input")
	_expect(int(Dictionary(labels[0]).get(ProfileFormTextStateConfigScript.KEY_ALIGNMENT, HORIZONTAL_ALIGNMENT_LEFT)) == HORIZONTAL_ALIGNMENT_CENTER, "goal title should be centered")
	_expect(ProfileFormTextStateScript.NAME_PLACEHOLDER == "이름을 입력하세요", "placeholder copy should be centralized")
	_expect(ProfileFormTextStateScript.SUBMIT_TEXT == "시작하기", "submit copy should be centralized")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
