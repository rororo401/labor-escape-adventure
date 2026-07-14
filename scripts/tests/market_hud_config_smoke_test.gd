extends "res://scripts/tests/test_scene_tree.gd"

const MarketHudConfigScript := preload("res://scripts/ui/market_hud_config.gd")
const PanelLayoutHelpersScript := preload("res://scripts/ui/panel_layout_helpers.gd")
const VnTopHudConfigScript := preload("res://scripts/ui/vn_top_hud_config.gd")


func _initialize() -> void:
	_expect(MarketHudConfigScript.HUD_NAME == "MarketHud", "HUD node name should stay stable")
	_expect(MarketHudConfigScript.TOP_PANEL_IMAGE_NAME == VnTopHudConfigScript.PANEL_IMAGE_NAME, "top panel image name should use the shared top-HUD node name")
	_expect(MarketHudConfigScript.DATE_LABEL_NAME == VnTopHudConfigScript.DATE_LABEL_NAME, "date label name should use the shared top-HUD node name")
	_expect(MarketHudConfigScript.TOP_BUTTONS_NAME == VnTopHudConfigScript.BUTTON_ROW_NAME, "top button row name should use the shared top-HUD node name")
	_expect(MarketHudConfigScript.STATUS_PANEL_NAME == "StatusPanel", "status panel name should stay stable")
	_expect(MarketHudConfigScript.MENU_BUTTON_NAME == VnTopHudConfigScript.MENU_BUTTON_NAME, "menu button name should use the shared top-HUD node name")
	_expect(MarketHudConfigScript.SETTINGS_BUTTON_NAME == VnTopHudConfigScript.SETTINGS_BUTTON_NAME, "settings button name should use the shared top-HUD node name")
	_expect(MarketHudConfigScript.TOP_PANEL_TEXTURE_PATH == "res://assets/ui/top_status_panel_v2.png", "top panel texture should use the upgraded no-navy-border asset")
	_expect(MarketHudConfigScript.TOP_PANEL_POSITION == VnTopHudConfigScript.PANEL_POSITION, "top panel position should use shared top-HUD position")
	_expect(MarketHudConfigScript.TOP_PANEL_SIZE == Vector2(688, 82), "top panel should have room for two HUD text rows")
	_expect(MarketHudConfigScript.DATE_LABEL_POSITION == VnTopHudConfigScript.DATE_LABEL_POSITION, "market date should share the aligned top-HUD position")
	_expect(MarketHudConfigScript.DATE_LABEL_SIZE == Vector2(500, VnTopHudConfigScript.DATE_LABEL_HEIGHT), "date label should have enough width before the top buttons")
	_expect(MarketHudConfigScript.DATE_LABEL_OUTLINE_SIZE == 0, "market date label should not use a navy outline")
	_expect(MarketHudConfigScript.STATUS_BARS_POSITION == Vector2(44, 54), "status bars should sit on the second HUD row")
	_expect(MarketHudConfigScript.TOP_BUTTONS_POSITION == Vector2(572, 24), "top button row should be vertically centered in the taller top panel")
	_expect(MarketHudConfigScript.TOP_BUTTONS_SIZE == VnTopHudConfigScript.BUTTON_ROW_SIZE, "top button row size should use the shared top-HUD size")
	_expect(MarketHudConfigScript.TOP_BUTTONS_SEPARATION == VnTopHudConfigScript.BUTTON_ROW_SEPARATION, "top button row separation should use the shared top-HUD separation")
	_expect(MarketHudConfigScript.STATUS_PANEL_POSITION == Vector2(22, 104), "status panel should sit below the taller top HUD")
	_expect(MarketHudConfigScript.STATUS_PANEL_SIZE == Vector2(676, 52), "status panel size should stay stable")
	_expect(int(MarketHudConfigScript.STATUS_ROW_MARGIN.get(PanelLayoutHelpersScript.KEY_LEFT, 0)) == MarketHudConfigScript.STATUS_ROW_MARGIN_LEFT, "status row margin dictionary should mirror left margin")
	_expect(int(MarketHudConfigScript.STATUS_ROW_MARGIN.get(PanelLayoutHelpersScript.KEY_BOTTOM, 0)) == MarketHudConfigScript.STATUS_ROW_MARGIN_BOTTOM, "status row margin dictionary should mirror bottom margin")
	_expect(MarketHudConfigScript.STATUS_LABEL_SIZE == Vector2(315, 38), "status label size should stay stable")
	_expect(MarketHudConfigScript.STATUS_CASH_LABEL_OFFSET == Vector2(10, 0), "cash label offset should stay stable")

	print("Market HUD config smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
