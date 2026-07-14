extends "res://scripts/tests/test_scene_tree.gd"

const GameDifficultyScript := preload("res://scripts/core/game_difficulty.gd")

const BASELINE_PATH := "res://data/game/difficulty_balance_baseline.json"
const COMPANIES_PATH := "res://data/market/companies.json"
const EXPECTED_SEEDS_PER_STRATEGY := 500
const EXPECTED_STRATEGY_COUNT := 8
const EXPECTED_TARGET_NET_WORTH := 1000000000


func _initialize() -> void:
	var baseline := _load_json(BASELINE_PATH)
	_expect(not baseline.is_empty(), "difficulty calibration baseline should load")
	_expect(int(baseline.get("schema_version", 0)) == 1, "difficulty baseline schema should be supported")
	_expect(int(baseline.get("seed_count_per_strategy", 0)) == EXPECTED_SEEDS_PER_STRATEGY, "difficulty baseline should keep 500 seeds per strategy")
	_expect(int(baseline.get("strategy_count", 0)) == EXPECTED_STRATEGY_COUNT, "difficulty baseline should keep all eight strategies")
	_expect(int(baseline.get("target_net_worth", 0)) == EXPECTED_TARGET_NET_WORTH, "difficulty baseline should keep the 1B target")
	_expect(String(baseline.get("price_data_sha256", "")) == _price_data_digest(), "price data changed; rerun difficulty calibration before accepting the new baseline")

	var difficulties := Dictionary(baseline.get("difficulties", {}))
	var hard := Dictionary(difficulties.get(GameDifficultyScript.HARD, {}))
	var normal := Dictionary(difficulties.get(GameDifficultyScript.NORMAL, {}))
	var easy := Dictionary(difficulties.get(GameDifficultyScript.EASY, {}))
	_verify_difficulty_row(hard, GameDifficultyScript.salary_multiplier(GameDifficultyScript.HARD), "hard")
	_verify_difficulty_row(normal, GameDifficultyScript.salary_multiplier(GameDifficultyScript.NORMAL), "normal")
	_verify_difficulty_row(easy, GameDifficultyScript.salary_multiplier(GameDifficultyScript.EASY), "easy")

	var hard_rate := float(hard.get("clear_rate", 0.0))
	var normal_rate := float(normal.get("clear_rate", 0.0))
	var easy_rate := float(easy.get("clear_rate", 0.0))
	_expect(normal_rate >= minf(1.0, hard_rate * 3.5), "normal clear rate should be at least 3.5x hard")
	_expect(normal_rate <= minf(1.0, hard_rate * 4.5), "normal clear rate should be at most 4.5x hard")
	_expect(easy_rate >= minf(1.0, hard_rate * 5.5), "easy clear rate should be at least 5.5x hard")
	_expect(easy_rate <= minf(1.0, hard_rate * 6.5), "easy clear rate should be at most 6.5x hard")

	var normal_strategies := Dictionary(normal.get("strategies", {}))
	for strategy_id in ["equal_three", "equal_five"]:
		var row := Dictionary(normal_strategies.get(strategy_id, {}))
		_expect(int(row.get("clears", 0)) > 0, "%s should have normal clear samples" % strategy_id)
		_expect(Array(row.get("required_tickers_for_all_clears", [])).is_empty(), "%s should not require one specific ticker for every normal clear" % strategy_id)

	var easy_strategy_coverage := 0
	for strategy_id in Dictionary(easy.get("strategies", {})):
		if String(strategy_id) == "cash_conservative":
			continue
		if int(Dictionary(easy.get("strategies", {})).get(strategy_id, {}).get("clears", 0)) > 0:
			easy_strategy_coverage += 1
	_expect(easy_strategy_coverage >= 4, "easy should clear in at least half of the non-cash strategies")

	print("Difficulty balance baseline smoke test passed.")
	finish_test()


func _verify_difficulty_row(row: Dictionary, multiplier: float, label: String) -> void:
	_expect(not row.is_empty(), "%s calibration row should exist" % label)
	_expect(is_equal_approx(float(row.get("salary_multiplier", -1.0)), multiplier), "%s calibration multiplier should match runtime" % label)
	var strategies := Dictionary(row.get("strategies", {}))
	_expect(strategies.size() == EXPECTED_STRATEGY_COUNT, "%s should include all eight strategies" % label)
	var clears := 0
	for strategy_id in strategies:
		clears += int(Dictionary(strategies.get(strategy_id, {})).get("clears", 0))
	var samples := EXPECTED_SEEDS_PER_STRATEGY * EXPECTED_STRATEGY_COUNT
	_expect(int(row.get("samples", 0)) == samples, "%s sample count should remain fixed" % label)
	_expect(int(row.get("clears", -1)) == clears, "%s aggregate clears should equal strategy rows" % label)
	_expect(is_equal_approx(float(row.get("clear_rate", -1.0)), float(clears) / float(samples)), "%s clear rate should match its counts" % label)


func _price_data_digest() -> String:
	var companies = JSON.parse_string(FileAccess.get_file_as_string(COMPANIES_PATH))
	if typeof(companies) != TYPE_DICTIONARY:
		return ""
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	for item in Array(Dictionary(companies).get("companies", [])):
		var company := Dictionary(item)
		var ticker := String(company.get("ticker", ""))
		var source_file := String(company.get("source_file", ""))
		if ticker.is_empty() or source_file.is_empty():
			return ""
		context.update(ticker.to_utf8_buffer())
		context.update(FileAccess.get_file_as_bytes("res://%s" % source_file.trim_prefix("res://")))
	return context.finish().hex_encode()


func _load_json(path: String) -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return Dictionary(parsed) if typeof(parsed) == TYPE_DICTIONARY else {}


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		fail_test()
