extends "res://scripts/tests/test_scene_tree.gd"

const MarketModeViewScript := preload("res://scripts/ui/market_mode_view.gd")
const TestAssetPathsScript := preload("res://scripts/tests/test_asset_paths.gd")

const MARKET_BACKGROUND_PATH := TestAssetPathsScript.MARKET_MORNING_BACKGROUND
const CLOSED_BACKGROUND_PATH := TestAssetPathsScript.HOME_MORNING_BACKGROUND


func _initialize() -> void:
	var host := Control.new()
	root.add_child(host)

	var stock_panel := Control.new()
	stock_panel.name = "StockPanel"
	var order_panel := Control.new()
	order_panel.name = "OrderPanel"
	var closed_panel := Control.new()
	closed_panel.name = "ClosedPanel"
	host.add_child(stock_panel)
	host.add_child(order_panel)
	host.add_child(closed_panel)

	var mode_view = MarketModeViewScript.new()
	var background := mode_view.build_background(host, MARKET_BACKGROUND_PATH, "TestMarketBackground")
	_expect(background.name == "TestMarketBackground", "mode view should preserve background node name")
	_expect(background.texture != null, "mode view should load the initial background")
	_expect(background.expand_mode == TextureRect.EXPAND_IGNORE_SIZE, "mode view background should ignore control size")
	_expect(background.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "mode view background should cover viewport")
	_expect(background.anchor_right == 1.0 and background.anchor_bottom == 1.0, "mode view background should fill parent")

	mode_view.set_panels([stock_panel, order_panel], [closed_panel])
	mode_view.apply_mode(true, MARKET_BACKGROUND_PATH, CLOSED_BACKGROUND_PATH)
	_expect(stock_panel.visible and order_panel.visible, "market panels should be visible when market is open")
	_expect(not closed_panel.visible, "closed-day panel should be hidden when market is open")
	_expect(background.texture != null, "market-open mode should keep a background texture")

	mode_view.apply_mode(false, MARKET_BACKGROUND_PATH, CLOSED_BACKGROUND_PATH)
	_expect(not stock_panel.visible and not order_panel.visible, "market panels should be hidden when market is closed")
	_expect(closed_panel.visible, "closed-day panel should be visible when market is closed")
	_expect(background.texture != null, "market-closed mode should keep a background texture")

	host.free()
	print("Market mode view smoke test passed.")
	finish_test()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
