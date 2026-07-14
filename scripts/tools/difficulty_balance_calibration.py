#!/usr/bin/env python3
"""Reproducible 10-year difficulty clear-rate calibration.

The simulator keeps the shipped starting cash, historical open/close prices,
monthly salary dates and order constraints. Player decisions are compressed to
monthly strategy actions so 8 strategies x 500 seeds can be compared quickly.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import random
from dataclasses import dataclass, field
from pathlib import Path
from statistics import median
from typing import Iterable


PROJECT_ROOT = Path(__file__).resolve().parents[2]
COMPANIES_PATH = PROJECT_ROOT / "data/market/companies.json"
STARTING_CASH = 5_000_000
TARGET_NET_WORTH = 1_000_000_000
LEVERAGE_TRIGGER_NET_WORTH = 3_000_000
LEVERAGE_DURATION_CALENDAR_DAYS = 365

STRATEGIES = (
    "cash_conservative",
    "equal_three",
    "equal_five",
    "monthly_random",
    "momentum",
    "loss_averaging",
    "annual_rebalance",
    "single_stock",
)

STRATEGY_LABELS = {
    "cash_conservative": "현금 비중이 큰 보수형",
    "equal_three": "3종목 균등 적립형",
    "equal_five": "5종목 균등 적립형",
    "monthly_random": "월 1회 무작위 종목 적립형",
    "momentum": "수익 종목 추세 추종형",
    "loss_averaging": "손실 종목 물타기형",
    "annual_rebalance": "연 1회 리밸런싱형",
    "single_stock": "단일 종목 장기 보유형",
}


def stable_hash(text: str) -> int:
    state = 0
    for byte in text.encode("utf-8"):
        state = (state * 131 + byte) % 1_000_003
    return state


def salary_base_for_month(date: str) -> int:
    return 500_000 + (stable_hash(date[:7]) % 31) * 10_000


def seeded_rng(strategy: str, seed: int) -> random.Random:
    digest = hashlib.sha256(f"{strategy}:{seed}".encode("utf-8")).digest()
    return random.Random(int.from_bytes(digest[:8], "big"))


@dataclass(frozen=True)
class PriceBook:
    tickers: tuple[str, ...]
    dates: tuple[str, ...]
    opens: dict[str, tuple[int, ...]]
    closes: dict[str, tuple[int, ...]]
    payday_indices: tuple[int, ...]
    digest: str

    @classmethod
    def load(cls) -> "PriceBook":
        companies = json.loads(COMPANIES_PATH.read_bytes())["companies"]
        digest = hashlib.sha256()
        tickers: list[str] = []
        dates: list[str] = []
        opens: dict[str, tuple[int, ...]] = {}
        closes: dict[str, tuple[int, ...]] = {}

        for company in companies:
            ticker = str(company["ticker"])
            path = PROJECT_ROOT / str(company["source_file"])
            raw = path.read_bytes()
            digest.update(ticker.encode("ascii"))
            digest.update(raw)
            rows = list(csv.DictReader(raw.decode("utf-8").splitlines()))
            row_dates = [str(row["date"]) for row in rows]
            if not dates:
                dates = row_dates
            elif row_dates != dates:
                raise ValueError(f"price date mismatch: {ticker}")
            tickers.append(ticker)
            opens[ticker] = tuple(int(float(row["open"])) for row in rows)
            closes[ticker] = tuple(int(float(row["close"])) for row in rows)

        payday_indices: list[int] = []
        seen_months: set[str] = set()
        for index, date in enumerate(dates):
            month = date[:7]
            if int(date[8:10]) >= 25 and month not in seen_months:
                payday_indices.append(index)
                seen_months.add(month)

        return cls(
            tuple(tickers),
            tuple(dates),
            opens,
            closes,
            tuple(payday_indices),
            digest.hexdigest(),
        )


@dataclass
class Portfolio:
    cash: int = STARTING_CASH
    quantities: dict[str, int] = field(default_factory=dict)
    average_costs: dict[str, int] = field(default_factory=dict)

    def buy_budget(self, book: PriceBook, ticker: str, index: int, budget: int) -> None:
        price = book.opens[ticker][index]
        if price <= 0:
            return
        spendable = min(max(0, int(budget)), self.cash - 1)
        quantity = max(0, spendable // price)
        if quantity <= 0:
            return
        old_quantity = self.quantities.get(ticker, 0)
        old_cost = old_quantity * self.average_costs.get(ticker, 0)
        new_quantity = old_quantity + quantity
        self.quantities[ticker] = new_quantity
        self.average_costs[ticker] = (old_cost + quantity * price) // new_quantity
        self.cash -= quantity * price

    def sell_all(self, book: PriceBook, ticker: str, index: int) -> None:
        quantity = self.quantities.get(ticker, 0)
        price = book.opens[ticker][index]
        if quantity <= 0 or price <= 0:
            return
        self.cash += quantity * price
        self.quantities.pop(ticker, None)
        self.average_costs.pop(ticker, None)

    def sell_everything(self, book: PriceBook, index: int) -> None:
        for ticker in tuple(self.quantities):
            self.sell_all(book, ticker, index)

    def net_worth(self, book: PriceBook, index: int, close: bool = True) -> int:
        price_table = book.closes if close else book.opens
        return self.cash + sum(
            quantity * max(0, price_table[ticker][index])
            for ticker, quantity in self.quantities.items()
        )


@dataclass
class StrategyState:
    strategy: str
    rng: random.Random
    universe: tuple[str, ...] = ()

    @classmethod
    def create(cls, book: PriceBook, strategy: str, seed: int) -> "StrategyState":
        rng = seeded_rng(strategy, seed)
        if strategy == "cash_conservative":
            universe = tuple(rng.sample(book.tickers, 3))
        elif strategy == "equal_three":
            universe = tuple(rng.sample(book.tickers, 3))
        elif strategy in ("equal_five", "loss_averaging", "annual_rebalance"):
            universe = tuple(rng.sample(book.tickers, 5))
        elif strategy == "momentum":
            universe = tuple(rng.sample(book.tickers, 10))
        elif strategy == "single_stock":
            universe = (rng.choice(book.tickers),)
        else:
            universe = ()
        return cls(strategy, rng, universe)

    def initial_action(self, book: PriceBook, portfolio: Portfolio) -> None:
        if self.strategy == "cash_conservative":
            allocate_equal(book, portfolio, self.universe, 0, 0.30)
        elif self.strategy in ("equal_three", "equal_five", "loss_averaging", "annual_rebalance"):
            allocate_equal(book, portfolio, self.universe, 0)
        elif self.strategy == "monthly_random":
            portfolio.buy_budget(book, self.rng.choice(book.tickers), 0, portfolio.cash)
        elif self.strategy == "momentum":
            portfolio.buy_budget(book, self.rng.choice(self.universe), 0, portfolio.cash)
        elif self.strategy == "single_stock":
            portfolio.buy_budget(book, self.universe[0], 0, portfolio.cash)

    def payday_action(self, book: PriceBook, portfolio: Portfolio, index: int) -> None:
        if self.strategy == "cash_conservative":
            allocate_equal(book, portfolio, self.universe, index, 0.30)
        elif self.strategy in ("equal_three", "equal_five"):
            allocate_equal(book, portfolio, self.universe, index)
        elif self.strategy == "monthly_random":
            portfolio.buy_budget(book, self.rng.choice(book.tickers), index, portfolio.cash)
        elif self.strategy == "momentum":
            lookback = max(0, index - 126)
            winner = max(
                self.universe,
                key=lambda ticker: trailing_ratio(book, ticker, index, lookback),
            )
            portfolio.sell_everything(book, index)
            portfolio.buy_budget(book, winner, index, portfolio.cash)
        elif self.strategy == "loss_averaging":
            loser = min(
                self.universe,
                key=lambda ticker: unrealized_ratio(book, portfolio, ticker, index),
            )
            portfolio.buy_budget(book, loser, index, portfolio.cash)
        elif self.strategy == "annual_rebalance":
            if book.dates[index][5:7] == "01":
                portfolio.sell_everything(book, index)
            allocate_equal(book, portfolio, self.universe, index)
        elif self.strategy == "single_stock":
            portfolio.buy_budget(book, self.universe[0], index, portfolio.cash)


def allocate_equal(
    book: PriceBook,
    portfolio: Portfolio,
    tickers: Iterable[str],
    index: int,
    fraction: float = 1.0,
) -> None:
    selected = tuple(tickers)
    if not selected:
        return
    budget = int(portfolio.cash * fraction) // len(selected)
    for ticker in selected:
        portfolio.buy_budget(book, ticker, index, budget)


def trailing_ratio(book: PriceBook, ticker: str, index: int, lookback: int) -> float:
    current = book.opens[ticker][index]
    previous = book.opens[ticker][lookback]
    if current <= 0 or previous <= 0:
        return -1.0
    return current / previous


def unrealized_ratio(book: PriceBook, portfolio: Portfolio, ticker: str, index: int) -> float:
    current = book.opens[ticker][index]
    if current <= 0:
        return float("inf")
    return current / max(1, portfolio.average_costs.get(ticker, current))


def run_sample(
    book: PriceBook,
    strategy: str,
    seed: int,
    multiplier: float,
    easy_rescue: bool,
) -> dict[str, object]:
    portfolio = Portfolio()
    state = StrategyState.create(book, strategy, seed)
    state.initial_action(book, portfolio)
    payday_set = set(book.payday_indices)
    rescue_used = False
    blessing_start_ordinal = -1
    blessing_end_ordinal = -1
    reference_net_worth = 0
    rescue_bonus = 0

    for index, date in enumerate(book.dates):
        external_cash = 0
        if index in payday_set:
            external_cash = round(salary_base_for_month(date) * multiplier)
            portfolio.cash += external_cash
            state.payday_action(book, portfolio, index)

        if not easy_rescue:
            continue
        ordinal = date_to_ordinal(date)
        current_net_worth = portfolio.net_worth(book, index)
        if rescue_used and blessing_start_ordinal <= ordinal < blessing_end_ordinal:
            market_profit = current_net_worth - reference_net_worth - external_cash
            bonus = max(0, market_profit)
            if bonus > 0:
                portfolio.cash += bonus
                rescue_bonus += bonus
                current_net_worth += bonus
            reference_net_worth = current_net_worth
        if not rescue_used and current_net_worth <= LEVERAGE_TRIGGER_NET_WORTH:
            rescue_used = True
            blessing_start_ordinal = ordinal + 1
            blessing_end_ordinal = blessing_start_ordinal + LEVERAGE_DURATION_CALENDAR_DAYS
            reference_net_worth = current_net_worth

    final_net_worth = portfolio.net_worth(book, len(book.dates) - 1)
    return {
        "clear": final_net_worth >= TARGET_NET_WORTH,
        "final_net_worth": final_net_worth,
        "universe": state.universe,
        "rescue_used": rescue_used,
        "rescue_bonus": rescue_bonus,
    }


def date_to_ordinal(date: str) -> int:
    # Gregorian ordinal conversion without a datetime object in the hot loop.
    year, month, day = (int(part) for part in date.split("-"))
    if month < 3:
        year -= 1
        month += 12
    return 365 * year + year // 4 - year // 100 + year // 400 + (153 * (month - 3) + 2) // 5 + day


def percentile(sorted_values: list[int], fraction: float) -> int:
    if not sorted_values:
        return 0
    index = round((len(sorted_values) - 1) * fraction)
    return sorted_values[index]


def calibrate(book: PriceBook, seeds: int, multipliers: dict[str, float]) -> dict[str, object]:
    difficulties: dict[str, object] = {}
    for difficulty in ("hard", "normal", "easy"):
        multiplier = multipliers[difficulty]
        by_strategy: dict[str, object] = {}
        total_clears = 0
        rescue_uses = 0
        rescue_bonus = 0
        for strategy in STRATEGIES:
            values: list[int] = []
            clear_universes: list[set[str]] = []
            clears = 0
            for seed in range(seeds):
                result = run_sample(book, strategy, seed, multiplier, difficulty == "easy")
                net_worth = int(result["final_net_worth"])
                values.append(net_worth)
                if bool(result["clear"]):
                    clears += 1
                    clear_universes.append(set(result["universe"]))
                rescue_uses += int(bool(result["rescue_used"]))
                rescue_bonus += int(result["rescue_bonus"])
            values.sort()
            total_clears += clears
            required_tickers = set.intersection(*clear_universes) if clear_universes else set()
            by_strategy[strategy] = {
                "label_ko": STRATEGY_LABELS[strategy],
                "samples": seeds,
                "clears": clears,
                "clear_rate": clears / seeds,
                "median_net_worth": int(median(values)),
                "p10_net_worth": percentile(values, 0.10),
                "p90_net_worth": percentile(values, 0.90),
                "required_tickers_for_all_clears": sorted(required_tickers),
            }
        sample_count = seeds * len(STRATEGIES)
        difficulties[difficulty] = {
            "salary_multiplier": multiplier,
            "samples": sample_count,
            "clears": total_clears,
            "clear_rate": total_clears / sample_count,
            "rescue_uses": rescue_uses if difficulty == "easy" else 0,
            "rescue_bonus_total": rescue_bonus if difficulty == "easy" else 0,
            "strategies": by_strategy,
        }

    hard_rate = float(difficulties["hard"]["clear_rate"])
    normal_rate = float(difficulties["normal"]["clear_rate"])
    easy_rate = float(difficulties["easy"]["clear_rate"])
    normal_min = min(1.0, hard_rate * 3.5)
    normal_max = min(1.0, hard_rate * 4.5)
    easy_min = min(1.0, hard_rate * 5.5)
    easy_max = min(1.0, hard_rate * 6.5)
    normal_strategies = difficulties["normal"]["strategies"]
    easy_strategies = difficulties["easy"]["strategies"]
    normal_equal_independent = all(
        int(normal_strategies[key]["clears"]) > 0
        and not normal_strategies[key]["required_tickers_for_all_clears"]
        for key in ("equal_three", "equal_five")
    )
    easy_non_cash_strategy_clears = sum(
        int(easy_strategies[key]["clears"]) > 0
        for key in STRATEGIES
        if key != "cash_conservative"
    )
    return {
        "schema_version": 1,
        "price_data_sha256": book.digest,
        "seed_count_per_strategy": seeds,
        "strategy_count": len(STRATEGIES),
        "target_net_worth": TARGET_NET_WORTH,
        "difficulties": difficulties,
        "criteria": {
            "normal_rate_min": normal_min,
            "normal_rate_max": normal_max,
            "easy_rate_min": easy_min,
            "easy_rate_max": easy_max,
            "normal_rate_pass": normal_min <= normal_rate <= normal_max,
            "easy_rate_pass": easy_min <= easy_rate <= easy_max,
            "normal_equal_portfolios_without_required_ticker_pass": normal_equal_independent,
            "easy_non_cash_strategies_with_clears": easy_non_cash_strategy_clears,
            "easy_strategy_coverage_pass": easy_non_cash_strategy_clears >= 4,
        },
        "ratios_to_hard": {
            "normal": normal_rate / hard_rate if hard_rate > 0 else 0.0,
            "easy": easy_rate / hard_rate if hard_rate > 0 else 0.0,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--seeds", type=int, default=500)
    parser.add_argument("--hard", type=float, default=1.0)
    parser.add_argument("--normal", type=float, default=2.75)
    parser.add_argument("--easy", type=float, default=7.0)
    parser.add_argument("--compact", action="store_true")
    args = parser.parse_args()
    if args.seeds <= 0:
        parser.error("--seeds must be positive")
    book = PriceBook.load()
    report = calibrate(
        book,
        args.seeds,
        {"hard": args.hard, "normal": args.normal, "easy": args.easy},
    )
    print(json.dumps(report, ensure_ascii=False, indent=None if args.compact else 2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
