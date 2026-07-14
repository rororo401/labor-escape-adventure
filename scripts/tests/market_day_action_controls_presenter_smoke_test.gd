extends "res://scripts/tests/test_scene_tree.gd"

const ClosedDayPanelScript := preload("res://scripts/ui/closed_day_panel.gd")
const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")
const MarketDayActionControlsPresenterScript := preload("res://scripts/ui/market_day_action_controls_presenter.gd")
const MarketOrderPanelScript := preload("res://scripts/ui/market_order_panel.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	var order_panel = MarketOrderPanelScript.new()
	order_panel.build()
	root.add_child(order_panel)
	var closed_panel = ClosedDayPanelScript.new()
	closed_panel.build()
	root.add_child(closed_panel)
	await process_frame

	var state := {
		MarketDayActionOptionsConfigScript.KEY_ACTION_LABELS: ["청소하기", "알바하기"],
		MarketDayActionOptionsConfigScript.KEY_ORDER_ACTIONS_DISABLED: false,
		MarketDayActionOptionsConfigScript.KEY_ACTION_SELECTED_INDEX: 1,
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES: [
			{MarketDayActionOptionsConfigScript.ACTION_ID: "stay_home", MarketDayActionOptionsConfigScript.ACTION_NAME: "집에 있기"},
			{MarketDayActionOptionsConfigScript.ACTION_ID: "go_out", MarketDayActionOptionsConfigScript.ACTION_NAME: "외출하기"}
		],
		MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID: "go_out",
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED: false,
		MarketDayActionOptionsConfigScript.KEY_CHOICES: [
			{MarketDayActionOptionsConfigScript.ACTION_ID: "part_time", MarketDayActionOptionsConfigScript.ACTION_NAME: "알바하기", "summary_ko": "시드머니 보충"},
			{MarketDayActionOptionsConfigScript.ACTION_ID: "river_walk", MarketDayActionOptionsConfigScript.ACTION_NAME: "한강 산책", "summary_ko": "기분 전환"}
		],
		MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID: "river_walk",
		MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED: false
	}
	MarketDayActionControlsPresenterScript.apply(order_panel, closed_panel, state)
	await process_frame

	var action_option := _find_option_button(order_panel)
	var category_row := _helpers.find_node(closed_panel, "ClosedDayCategoryRow")
	var choice_grid := _helpers.find_node(closed_panel, "ClosedDayChoiceGrid")
	_expect(action_option != null, "order panel should expose a day-action option button")
	_expect(action_option.item_count == 2, "presenter should render order-panel action labels")
	_expect(action_option.selected == 1, "presenter should preserve selected order action index")
	_expect(not action_option.disabled, "presenter should enable order actions")
	_expect(category_row != null and category_row.get_child_count() == 2, "presenter should render closed-day categories")
	_expect(choice_grid != null and choice_grid.get_child_count() == 2, "presenter should render closed-day choices")

	MarketDayActionControlsPresenterScript.apply(order_panel, closed_panel, {
		MarketDayActionOptionsConfigScript.KEY_ACTION_LABELS: ["대기"],
		MarketDayActionOptionsConfigScript.KEY_ORDER_ACTIONS_DISABLED: true,
		MarketDayActionOptionsConfigScript.KEY_ACTION_SELECTED_INDEX: MarketDayActionOptionsConfigScript.DEFAULT_SELECTED_INDEX,
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES: [],
		MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID: MarketDayActionOptionsConfigScript.EMPTY_ID,
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED: true,
		MarketDayActionOptionsConfigScript.KEY_CHOICES: [],
		MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID: MarketDayActionOptionsConfigScript.EMPTY_ID,
		MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED: true
	})
	await process_frame
	_expect(action_option.item_count == 1, "presenter should replace old order actions")
	_expect(action_option.disabled, "presenter should disable order actions")
	_expect(category_row.get_child_count() == 0, "presenter should clear old categories")
	_expect(choice_grid.get_child_count() == 0, "presenter should clear old choices")

	MarketDayActionControlsPresenterScript.apply(null, null, {})
	MarketDayActionControlsPresenterScript.apply_closed_day_panel(null, {})

	print("Market day-action controls presenter smoke test passed.")
	finish_test()


func _find_option_button(root_node: Node) -> OptionButton:
	if root_node is OptionButton:
		return root_node as OptionButton
	for child in root_node.get_children():
		var found := _find_option_button(child)
		if found != null:
			return found
	return null


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
