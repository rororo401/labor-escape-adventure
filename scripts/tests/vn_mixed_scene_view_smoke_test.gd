extends "res://scripts/tests/test_scene_tree.gd"

const VnMixedSceneViewScript := preload("res://scripts/ui/vn_mixed_scene_view.gd")
const VnMixedSceneViewConfigScript := preload("res://scripts/ui/vn_mixed_scene_view_config.gd")
const VnStoryKeysScript := preload("res://scripts/core/vn_story_keys.gd")
const VnDialogueBoxConfigScript := preload("res://scripts/ui/vn_dialogue_box_config.gd")
const VnStepSequenceScript := preload("res://scripts/ui/vn_step_sequence.gd")
const PlayerStatusKeysScript := preload("res://scripts/core/player_status_keys.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")

const OFFICE_BACKGROUND_PATH := "res://assets/backgrounds/work/startup_office_morning.png"
const EVENT_BACKGROUND_PATH := "res://assets/backgrounds/work/office_phone_call_event.png"

var _failed := false


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var host := Control.new()
	host.size = Vector2(720, 1280)
	root.add_child(host)
	await process_frame

	var view = VnMixedSceneViewScript.new()
	var refs: Dictionary = view.build(host, {
		VnStoryKeysScript.KEY_BACKGROUND_NAME: "TestSceneBackground",
		VnStoryKeysScript.KEY_BACKGROUND_PATH: OFFICE_BACKGROUND_PATH,
		VnStoryKeysScript.KEY_DATE_TEXT: "D-Day  테스트",
		VnStoryKeysScript.KEY_CHARACTER_NAME: "TestProtagonistBust",
		VnStoryKeysScript.KEY_SPEAKER_NAME: "나",
		VnStoryKeysScript.KEY_HUD_OPTIONS: {
			VnTopHudConfigScript.OPTION_STATUS: {
				PlayerStatusKeysScript.KEY_HEALTH: 70,
				PlayerStatusKeysScript.KEY_MOOD: 44,
				PlayerStatusKeysScript.KEY_FATIGUE: 12
			}
		},
		VnStoryKeysScript.KEY_DIALOGUE_OPTIONS: {
			VnDialogueBoxConfigScript.OPTION_NAME_WIDTH: 190.0
		}
	})
	var background := refs.get(VnMixedSceneViewConfigScript.KEY_BACKGROUND_RECT) as TextureRect
	var protagonist := refs.get(VnMixedSceneViewConfigScript.KEY_CHARACTER_TEXTURE_RECT) as TextureRect
	var date_label := refs.get(VnMixedSceneViewConfigScript.KEY_DATE_LABEL) as Label
	var status_bars: Dictionary = refs.get(VnMixedSceneViewConfigScript.KEY_STATUS_BARS, {})
	var name_label := refs.get(VnMixedSceneViewConfigScript.KEY_NAME_LABEL) as Label
	var dialogue_label := refs.get(VnMixedSceneViewConfigScript.KEY_DIALOGUE_LABEL) as Label

	_expect(background != null and background.name == "TestSceneBackground", "mixed view should create the named background")
	_expect(background.texture != null, "mixed view should load the initial background")
	_expect(protagonist != null and protagonist.name == "TestProtagonistBust", "mixed view should create the protagonist bust")
	_expect(date_label != null and date_label.text == "D-Day  테스트", "mixed view should create the HUD date label")
	_expect(Dictionary(status_bars.get(PlayerStatusKeysScript.KEY_MOOD, {})).get("value") != null, "mixed view should create HUD status bars")
	_expect(name_label != null and name_label.text == "나", "mixed view should create the speaker label")
	_expect(dialogue_label != null, "mixed view should create the dialogue label")

	var sequence = VnStepSequenceScript.new()
	view.bind_sequence(sequence, 120.0)
	sequence.set_steps([{VnStoryKeysScript.KEY_TEXT: "테스트 대사"}])
	_expect(dialogue_label.text == "테스트 대사", "mixed view should bind the step sequence to the dialogue label")

	view.set_speaker_name("AA부장")
	_expect(name_label.text == "AA부장", "mixed view should update the speaker label")
	view.set_date_text("D-Day  오전")
	_expect(date_label.text == "D-Day  오전", "mixed view should update the date label")
	view.set_status_bars({PlayerStatusKeysScript.KEY_MOOD: 67})
	var mood_value := Dictionary(status_bars.get(PlayerStatusKeysScript.KEY_MOOD, {})).get("value") as Label
	_expect(mood_value != null and mood_value.text == "67", "mixed view should update HUD status bars")

	view.apply_step_visual(host, {
		VnStoryKeysScript.KEY_BACKGROUND_PATH: EVENT_BACKGROUND_PATH,
		VnStoryKeysScript.KEY_DATE_TEXT: "D-Day  회사",
		VnStoryKeysScript.KEY_CHARACTER_VISIBLE: false
	}, {})
	_expect(background.texture != null, "mixed view should keep a background texture after visual changes")
	_expect(date_label.text == "D-Day  회사", "mixed view should apply visual HUD text")
	_expect(not protagonist.visible, "mixed view should hide the protagonist for CG-only beats")

	view.apply_step_visual(host, {
		VnStoryKeysScript.KEY_BACKGROUND_PATH: OFFICE_BACKGROUND_PATH,
		VnStoryKeysScript.KEY_DATE_TEXT: "D-Day  사무실",
		VnStoryKeysScript.KEY_CHARACTER_VISIBLE: true,
		VnStoryKeysScript.KEY_DEFAULT_OUTFIT: "casual_default"
	}, {
		VnStoryKeysScript.KEY_EXPRESSION: "smile"
	})
	_expect(protagonist.visible, "mixed view should show the protagonist for standing beats")
	_expect(protagonist.texture != null, "mixed view should apply a standing texture")
	_expect(date_label.text == "D-Day  사무실", "mixed view should update HUD text again")

	host.free()

	var cg_host := Control.new()
	cg_host.size = Vector2(720, 1280)
	root.add_child(cg_host)
	var cg_view = VnMixedSceneViewScript.new()
	var cg_refs: Dictionary = cg_view.build(cg_host, {
		VnStoryKeysScript.KEY_BACKGROUND_NAME: "CgOnlyBackground",
		VnStoryKeysScript.KEY_BACKGROUND_PATH: EVENT_BACKGROUND_PATH,
		VnStoryKeysScript.KEY_SHOW_HUD: false,
		VnStoryKeysScript.KEY_SHOW_CHARACTER: false,
		VnStoryKeysScript.KEY_SPEAKER_NAME: "이벤트",
		VnStoryKeysScript.KEY_DIALOGUE_OPTIONS: {
			VnDialogueBoxConfigScript.OPTION_NAME_LABEL_NAME: "CgTitle",
			VnDialogueBoxConfigScript.OPTION_DIALOGUE_LABEL_NAME: "CgDialogue"
		}
	})
	_expect(cg_refs.get(VnMixedSceneViewConfigScript.KEY_BACKGROUND_RECT) != null, "CG-only mixed view should still create a background")
	_expect(cg_refs.get(VnMixedSceneViewConfigScript.KEY_DATE_LABEL) == null, "CG-only mixed view should skip the HUD date label")
	_expect(cg_refs.get(VnMixedSceneViewConfigScript.KEY_CHARACTER_TEXTURE_RECT) == null, "CG-only mixed view should skip the standing character")
	_expect(cg_refs.get(VnMixedSceneViewConfigScript.KEY_NAME_LABEL) != null, "CG-only mixed view should still create a title label")
	_expect(cg_refs.get(VnMixedSceneViewConfigScript.KEY_DIALOGUE_LABEL) != null, "CG-only mixed view should still create dialogue text")
	cg_host.free()

	var default_host := Control.new()
	default_host.size = Vector2(720, 1280)
	root.add_child(default_host)
	var default_view = VnMixedSceneViewScript.new()
	var default_refs: Dictionary = default_view.build(default_host)
	var default_background := default_refs.get(VnMixedSceneViewConfigScript.KEY_BACKGROUND_RECT) as TextureRect
	var default_character := default_refs.get(VnMixedSceneViewConfigScript.KEY_CHARACTER_TEXTURE_RECT) as TextureRect
	var default_date := default_refs.get(VnMixedSceneViewConfigScript.KEY_DATE_LABEL) as Label
	var default_name := default_refs.get(VnMixedSceneViewConfigScript.KEY_NAME_LABEL) as Label
	_expect(default_background != null and default_background.name == VnMixedSceneViewConfigScript.DEFAULT_BACKGROUND_NAME, "mixed view should use the configured default background name")
	_expect(default_character != null and default_character.name == VnMixedSceneViewConfigScript.DEFAULT_CHARACTER_NAME, "mixed view should use the configured default character name")
	_expect(default_date != null and default_date.text == VnMixedSceneViewConfigScript.DEFAULT_DATE_TEXT, "mixed view should use the configured default date text")
	_expect(default_name != null and default_name.text == VnMixedSceneViewConfigScript.DEFAULT_SPEAKER_NAME, "mixed view should use the configured default speaker")
	default_host.free()

	if _failed:
		fail_test()
		return
	print("VN mixed scene view smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
