extends "res://scripts/tests/test_scene_tree.gd"

const NpcNameCatalogScript := preload("res://scripts/core/npc_name_catalog.gd")
const GameStateConfigScript := preload("res://scripts/core/game_state_config.gd")
const LocalizedPayloadKeysScript := preload("res://scripts/core/localized_payload_keys.gd")


func _initialize() -> void:
	_expect(NpcNameCatalogScript.KEY_NPCS == "npcs", "NPC list key should stay stable")
	_expect(NpcNameCatalogScript.KEY_DISPLAY_NAME_KO == LocalizedPayloadKeysScript.KEY_DISPLAY_NAME_KO, "NPC display-name key should use the shared localized payload key")
	_expect(NpcNameCatalogScript.DEFAULT_FALLBACK_NAME == "", "default fallback name should stay blank")

	var catalog = NpcNameCatalogScript.new()
	catalog.load_from_json(GameStateConfigScript.NPC_NAMES_PATH)

	_expect(not catalog.npcs.is_empty(), "NPC catalog should load names")
	_expect(catalog.get_display_name("box_trading_manager", "기본값") != "기본값", "known NPC should use catalog display name")
	_expect(catalog.get_display_name("missing_npc", "기본값") == "기본값", "missing NPC should use fallback display name")

	print("NPC name catalog smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
