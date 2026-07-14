class_name MarketScreenSelectionPresenter
extends RefCounted

const MarketInteractionStateScript := preload("res://scripts/ui/market_interaction_state.gd")


static func select_stock(runtime_state, order_panel, market_context: Dictionary, ticker: String) -> Dictionary:
	var patch := MarketInteractionStateScript.stock_selected(market_context, ticker)
	_apply_and_refresh(runtime_state, order_panel, patch)
	return patch


static func increase_quantity(runtime_state, order_panel) -> Dictionary:
	var quantity := 1 if runtime_state == null else int(runtime_state.quantity)
	var patch := MarketInteractionStateScript.quantity_increased(quantity)
	_apply_and_refresh(runtime_state, order_panel, patch)
	return patch


static func decrease_quantity(runtime_state, order_panel) -> Dictionary:
	var quantity := 1 if runtime_state == null else int(runtime_state.quantity)
	var patch := MarketInteractionStateScript.quantity_decreased(quantity)
	_apply_and_refresh(runtime_state, order_panel, patch)
	return patch


static func refresh_selected_panel(runtime_state, order_panel) -> void:
	if runtime_state == null or order_panel == null:
		return
	order_panel.set_selected_stock(runtime_state.selected_stock, runtime_state.quantity)


static func _apply_and_refresh(runtime_state, order_panel, patch: Dictionary) -> void:
	if runtime_state != null:
		runtime_state.apply(patch)
	refresh_selected_panel(runtime_state, order_panel)
