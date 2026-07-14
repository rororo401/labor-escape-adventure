class_name GameRunStatistics
extends RefCounted

const MarketDataKeysScript := preload("res://scripts/core/market/market_data_keys.gd")

const KEY_SAVE := "run_statistics"
const KEY_HIGHEST_NET_WORTH := "highest_net_worth"
const KEY_TOTAL_EVENT_COUNT := "total_event_count"
const KEY_MOST_HELD_TICKER := "most_held_ticker"
const KEY_MOST_HELD_QUANTITY := "most_held_quantity"
const KEY_MOST_HELD_NAME_KO := "most_held_name_ko"
const KEY_TOTAL_INVESTMENT_PROFIT := "total_investment_profit"

var highest_net_worth := 0
var total_event_count := 0
var most_held_ticker := ""
var most_held_quantity := 0


func reset(starting_net_worth: int) -> void:
	highest_net_worth = maxi(0, starting_net_worth)
	total_event_count = 0
	most_held_ticker = ""
	most_held_quantity = 0


func record_net_worth(net_worth: int) -> void:
	highest_net_worth = maxi(highest_net_worth, net_worth)


func record_event() -> void:
	total_event_count += 1


func record_positions(positions: Dictionary) -> void:
	for ticker_value in positions:
		var ticker := String(ticker_value)
		var position := Dictionary(positions.get(ticker_value, {}))
		var quantity := int(position.get(MarketDataKeysScript.KEY_QUANTITY, 0))
		if quantity > most_held_quantity:
			most_held_ticker = ticker
			most_held_quantity = quantity


func to_dict() -> Dictionary:
	return {
		KEY_HIGHEST_NET_WORTH: highest_net_worth,
		KEY_TOTAL_EVENT_COUNT: total_event_count,
		KEY_MOST_HELD_TICKER: most_held_ticker,
		KEY_MOST_HELD_QUANTITY: most_held_quantity
	}


func load_from_dict(data: Dictionary) -> void:
	highest_net_worth = maxi(0, int(data.get(KEY_HIGHEST_NET_WORTH, 0)))
	total_event_count = maxi(0, int(data.get(KEY_TOTAL_EVENT_COUNT, 0)))
	most_held_ticker = String(data.get(KEY_MOST_HELD_TICKER, ""))
	most_held_quantity = maxi(0, int(data.get(KEY_MOST_HELD_QUANTITY, 0)))
	if most_held_quantity == 0:
		most_held_ticker = ""


func ending_snapshot(total_investment_profit: int, most_held_name_ko: String) -> Dictionary:
	return {
		KEY_HIGHEST_NET_WORTH: highest_net_worth,
		KEY_TOTAL_INVESTMENT_PROFIT: total_investment_profit,
		KEY_TOTAL_EVENT_COUNT: total_event_count,
		KEY_MOST_HELD_TICKER: most_held_ticker,
		KEY_MOST_HELD_NAME_KO: most_held_name_ko,
		KEY_MOST_HELD_QUANTITY: most_held_quantity
	}
