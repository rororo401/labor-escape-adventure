extends "res://scripts/tests/test_scene_tree.gd"

const CharacterOutfitSeasonScript := preload("res://scripts/core/character_outfit_season.gd")


func _initialize() -> void:
	_expect(CharacterOutfitSeasonScript.is_summer_date("2016-06-01"), "June should use summer outfits")
	_expect(CharacterOutfitSeasonScript.is_summer_date("2016-09-30"), "September should use summer outfits")
	_expect(not CharacterOutfitSeasonScript.is_summer_date("2016-10-01"), "October should use base outfits")
	_expect(not CharacterOutfitSeasonScript.is_summer_date("2016-05-31"), "May should use base outfits")
	_expect(not CharacterOutfitSeasonScript.is_summer_date("bad-date"), "invalid dates should not use summer outfits")

	_expect(
		CharacterOutfitSeasonScript.outfit_for_date("casual_default", "2016-07-01") == "summer_office",
		"summer trading dates should map office outfit to summer office"
	)
	_expect(
		CharacterOutfitSeasonScript.outfit_for_date("homewear", "2016-07-01") == "summer_homewear",
		"summer dates should map homewear to summer homewear"
	)
	_expect(
		CharacterOutfitSeasonScript.outfit_for_date("summer_office", "2016-12-01") == "casual_default",
		"winter dates should map summer office back to base office"
	)
	_expect(
		CharacterOutfitSeasonScript.outfit_for_date("summer_homewear", "2016-12-01") == "homewear",
		"winter dates should map summer homewear back to base homewear"
	)
	_expect(
		CharacterOutfitSeasonScript.outfit_for_date("special_outfit", "2016-07-01") == "special_outfit",
		"unknown outfits should pass through unchanged"
	)

	print("Character outfit season smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
