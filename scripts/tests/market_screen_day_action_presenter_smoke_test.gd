extends "res://scripts/tests/test_scene_tree.gd"

const GameStateScript := preload("res://scripts/core/game_state.gd")
const MarketDayActionOptionsConfigScript := preload("res://scripts/ui/market_day_action_options_config.gd")
const MarketDayActionSelectionResultConfigScript := preload("res://scripts/ui/market_day_action_selection_result_config.gd")
const MarketScreenDayActionPresenterScript := preload("res://scripts/ui/market_screen_day_action_presenter.gd")
const MarketScreenRuntimeStateScript := preload("res://scripts/ui/market_screen_runtime_state.gd")
const TestHelpersScript := preload("res://scripts/tests/test_helpers.gd")

var _helpers := TestHelpersScript.new()


func _initialize() -> void:
	_verify_option_state_application()
	_verify_refresh_and_index_application()
	_verify_selection_application()
	print("Market screen day-action presenter smoke test passed.")
	finish_test()


func _verify_option_state_application() -> void:
	var runtime_state = MarketScreenRuntimeStateScript.new()
	runtime_state.selected_closed_day_category_id = "stay_home"
	runtime_state.selected_day_action_id = "cleaning"
	var day_action_ids: Array[String] = ["cleaning"]
	var order_panel = FakeOrderPanel.new()
	var closed_panel = FakeClosedDayPanel.new()

	MarketScreenDayActionPresenterScript.apply_option_state(
		runtime_state,
		day_action_ids,
		order_panel,
		closed_panel,
		{
			MarketDayActionOptionsConfigScript.KEY_ACTION_IDS: ["part_time", "river_walk"],
			MarketDayActionOptionsConfigScript.KEY_ACTION_LABELS: ["알바하기", "한강 산책"],
			MarketDayActionOptionsConfigScript.KEY_ORDER_ACTIONS_DISABLED: false,
			MarketDayActionOptionsConfigScript.KEY_ACTION_SELECTED_INDEX: 1,
			MarketDayActionOptionsConfigScript.KEY_CATEGORIES: [{MarketDayActionOptionsConfigScript.ACTION_ID: "go_out", MarketDayActionOptionsConfigScript.ACTION_NAME: "외출하기"}],
			MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID: "go_out",
			MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED: false,
			MarketDayActionOptionsConfigScript.KEY_CHOICES: [{MarketDayActionOptionsConfigScript.ACTION_ID: "river_walk", MarketDayActionOptionsConfigScript.ACTION_NAME: "한강 산책"}],
			MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID: "river_walk",
			MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED: true
		}
	)

	_expect(runtime_state.selected_closed_day_category_id == "go_out", "presenter should update selected category")
	_expect(runtime_state.selected_day_action_id == "river_walk", "presenter should update selected action")
	_expect(day_action_ids == ["part_time", "river_walk"], "presenter should replace day action ids")
	_expect(order_panel.labels == ["알바하기", "한강 산책"], "presenter should render order actions")
	_expect(not order_panel.disabled, "presenter should apply order action disabled state")
	_expect(order_panel.selected_index == 1, "presenter should apply order action selected index")
	_expect(closed_panel.selected_category_id == "go_out", "presenter should render selected category")
	_expect(closed_panel.selected_action_id == "river_walk", "presenter should render selected choice")
	_expect(closed_panel.choices_disabled, "presenter should apply choice disabled state")

	MarketScreenDayActionPresenterScript.apply_option_state(
		runtime_state,
		day_action_ids,
		null,
		null,
		{MarketDayActionOptionsConfigScript.KEY_ACTION_IDS: ["cleaning"]}
	)
	_expect(runtime_state.selected_closed_day_category_id == "go_out", "missing category should preserve runtime category")
	_expect(runtime_state.selected_day_action_id == "river_walk", "missing action should preserve runtime action")
	_expect(day_action_ids == ["cleaning"], "presenter should still update day action ids without panels")

	MarketScreenDayActionPresenterScript.apply_closed_day_panel(closed_panel, {
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES: [],
		MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID: MarketDayActionOptionsConfigScript.EMPTY_ID,
		MarketDayActionOptionsConfigScript.KEY_CATEGORIES_DISABLED: true,
		MarketDayActionOptionsConfigScript.KEY_CHOICES: [],
		MarketDayActionOptionsConfigScript.KEY_SELECTED_ACTION_ID: MarketDayActionOptionsConfigScript.EMPTY_ID,
		MarketDayActionOptionsConfigScript.KEY_CHOICES_DISABLED: false
	})
	_expect(closed_panel.categories_disabled, "closed-day panel helper should apply category disabled state")
	_expect(not closed_panel.choices_disabled, "closed-day panel helper should apply choice disabled state")
	MarketScreenDayActionPresenterScript.apply_closed_day_panel(null, {})


func _verify_refresh_and_index_application() -> void:
	var game := GameStateScript.new()
	var closed_date := _helpers.find_closed_date_with_choice(game, "go_out", "part_time", "2016-07-02")
	_expect(game.setup(closed_date), "game should set up a closed day for refresh")
	var runtime_state = MarketScreenRuntimeStateScript.new()
	runtime_state.selected_closed_day_category_id = "go_out"
	var day_action_ids: Array[String] = []
	var order_panel = FakeOrderPanel.new()
	var closed_panel = FakeClosedDayPanel.new()

	var state := MarketScreenDayActionPresenterScript.refresh_options(
		runtime_state,
		day_action_ids,
		order_panel,
		closed_panel,
		game
	)
	_expect(String(state.get(MarketDayActionOptionsConfigScript.KEY_SELECTED_CATEGORY_ID, "")) == "go_out", "refresh should preserve selected category")
	_expect(not day_action_ids.is_empty(), "refresh should populate day action ids")
	_expect(order_panel.labels.size() == day_action_ids.size(), "refresh should render order-panel action labels")
	_expect(closed_panel.selected_category_id == "go_out", "refresh should render selected category")

	var selected_id := MarketScreenDayActionPresenterScript.select_action_index(runtime_state, day_action_ids, 0)
	_expect(selected_id == day_action_ids[0], "valid index should return matching action id")
	_expect(runtime_state.selected_day_action_id == selected_id, "valid index should update runtime action")

	var preserved_id := MarketScreenDayActionPresenterScript.select_action_index(runtime_state, day_action_ids, 999)
	_expect(preserved_id == selected_id, "invalid index should preserve current action id")
	_expect(runtime_state.selected_day_action_id == selected_id, "invalid index should keep runtime action")


func _verify_selection_application() -> void:
	var game := GameStateScript.new()
	var closed_date := _helpers.find_closed_date_with_choice(game, "go_out", "part_time", "2016-07-02")
	_expect(game.setup(closed_date), "game should set up a closed day with part-time work")
	var runtime_state = MarketScreenRuntimeStateScript.new()
	var order_panel = FakeOrderPanel.new()
	var closed_panel = FakeClosedDayPanel.new()

	var category := MarketScreenDayActionPresenterScript.select_category(
		runtime_state,
		order_panel,
		closed_panel,
		game,
		"go_out"
	)
	_expect(bool(category.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, false)), "category selection should be accepted")
	_expect(runtime_state.selected_closed_day_category_id == "go_out", "category selection should update runtime category")
	_expect(runtime_state.selected_day_action_id.is_empty(), "category selection should clear runtime action")
	_expect(closed_panel.selected_category_id == "go_out", "category selection should render selected category")

	var selected_action_id := String(Dictionary(closed_panel.choices[0]).get(MarketDayActionOptionsConfigScript.ACTION_ID, ""))
	var action := MarketScreenDayActionPresenterScript.select_action(
		runtime_state,
		order_panel,
		closed_panel,
		game,
		selected_action_id
	)
	_expect(bool(action.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, false)), "action selection should be accepted")
	_expect(runtime_state.selected_day_action_id == selected_action_id, "action selection should update runtime action")
	_expect(closed_panel.selected_via_button == selected_action_id, "action selection should select the panel button")
	_expect(order_panel.message.contains("로 하루를 보내기로 했다"), "action selection should update order message")
	_expect(closed_panel.message == order_panel.message, "action selection should update closed-day message")

	var start := MarketScreenDayActionPresenterScript.start_action(
		runtime_state,
		order_panel,
		closed_panel,
		game,
		selected_action_id
	)
	_expect(bool(start.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, false)), "action start should be accepted")
	_expect(runtime_state.is_completing_day, "action start should set completing state")
	_expect(closed_panel.choice_buttons_disabled, "action start should disable choice buttons")

	var blocked := MarketScreenDayActionPresenterScript.select_action(runtime_state, order_panel, closed_panel, game, selected_action_id)
	_expect(not bool(blocked.get(MarketDayActionSelectionResultConfigScript.KEY_ACCEPTED, true)), "action selection should be blocked while completing")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()


class FakeOrderPanel:
	var labels: Array = []
	var disabled := true
	var selected_index := 0
	var message := ""

	func set_day_actions(next_labels: Array, next_disabled: bool, next_selected_index: int) -> void:
		labels = next_labels.duplicate()
		disabled = next_disabled
		selected_index = next_selected_index

	func set_message(text: String) -> void:
		message = text


class FakeClosedDayPanel:
	var categories: Array = []
	var selected_category_id := ""
	var categories_disabled := false
	var choices: Array = []
	var selected_action_id := ""
	var selected_via_button := ""
	var choices_disabled := false
	var message := ""
	var choice_buttons_disabled := false

	func render_categories(next_categories: Array, next_selected_category_id: String, next_disabled: bool) -> void:
		categories = next_categories.duplicate(true)
		selected_category_id = next_selected_category_id
		categories_disabled = next_disabled

	func render_choices(next_choices: Array, next_selected_action_id: String, next_disabled: bool) -> void:
		choices = next_choices.duplicate(true)
		selected_action_id = next_selected_action_id
		choices_disabled = next_disabled

	func select_action(action_id: String) -> void:
		selected_via_button = action_id

	func set_message(text: String) -> void:
		message = text

	func set_choice_buttons_disabled(disabled: bool) -> void:
		choice_buttons_disabled = disabled
