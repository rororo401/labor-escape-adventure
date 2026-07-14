#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fetch Korean stock game data from public web endpoints.

Outputs:
  data/market/companies.json
  data/market/source_meta.json
  data/market/trading_calendar.csv
  data/market/trading_days.csv
  data/market/non_trading_days.csv
  data/raw/prices/{ticker}.csv
"""

from __future__ import annotations

import csv
import json
import re
import time
from dataclasses import dataclass
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Iterable
from urllib.error import URLError
from urllib.request import Request, urlopen


START_DATE = date(2016, 7, 1)
END_DATE = date(2026, 6, 30)
REQUEST_PAUSE_SECONDS = 0.12

ROOT = Path(__file__).resolve().parents[1]
MARKET_DIR = ROOT / "data" / "market"
PRICE_DIR = ROOT / "data" / "raw" / "prices"

USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"


@dataclass(frozen=True)
class Company:
    ticker: str
    name_ko: str
    sector_hint: str


COMPANIES: tuple[Company, ...] = (
    Company("005930", "삼성전자", "반도체/전자"),
    Company("000660", "SK하이닉스", "반도체"),
    Company("009150", "삼성전기", "전자부품"),
    Company("005380", "현대차", "자동차"),
    Company("032830", "삼성생명", "보험"),
    Company("034020", "두산에너빌리티", "에너지/기계"),
    Company("000270", "기아", "자동차"),
    Company("012450", "한화에어로스페이스", "방산/항공"),
    Company("012330", "현대모비스", "자동차부품"),
    Company("068270", "셀트리온", "바이오"),
    Company("006400", "삼성SDI", "2차전지"),
    Company("010120", "LS ELECTRIC", "전력기기"),
    Company("066570", "LG전자", "가전/전자"),
    Company("035420", "NAVER", "인터넷/플랫폼"),
    Company("042660", "한화오션", "조선"),
    Company("000810", "삼성화재", "보험"),
    Company("009540", "HD한국조선해양", "조선"),
    Company("042700", "한미반도체", "반도체장비"),
    Company("006800", "미래에셋증권", "증권"),
    Company("015760", "한국전력", "전력/유틸리티"),
    Company("011070", "LG이노텍", "전자부품"),
    Company("010130", "고려아연", "비철금속"),
    Company("010140", "삼성중공업", "조선"),
    Company("051910", "LG화학", "화학/2차전지소재"),
    Company("017670", "SK텔레콤", "통신"),
    Company("064350", "현대로템", "철도/방산"),
    Company("033780", "KT&G", "담배/건강기능식품"),
    Company("011200", "HMM", "해운"),
    Company("096770", "SK이노베이션", "정유/화학/배터리"),
    Company("024110", "기업은행", "은행"),
)


def yyyymmdd(d: date) -> str:
    return d.strftime("%Y%m%d")


def iso_date(s: str) -> str:
    return f"{s[:4]}-{s[4:6]}-{s[6:8]}"


def daterange(start: date, end: date) -> Iterable[date]:
    current = start
    while current <= end:
        yield current
        current += timedelta(days=1)


def fetch_text(url: str, *, accept: str = "*/*", retries: int = 3) -> str:
    headers = {
        "User-Agent": USER_AGENT,
        "Accept": accept,
        "Referer": "https://finance.naver.com/",
    }
    last_error: Exception | None = None
    for attempt in range(1, retries + 1):
        try:
            request = Request(url, headers=headers)
            with urlopen(request, timeout=30) as response:
                return response.read().decode("utf-8", errors="replace")
        except (URLError, TimeoutError) as exc:
            last_error = exc
            if attempt < retries:
                time.sleep(0.5 * attempt)
    raise RuntimeError(f"Failed to fetch {url}: {last_error}")


def fetch_json(url: str) -> object:
    return json.loads(fetch_text(url, accept="application/json"))


def fetch_price_rows(ticker: str) -> list[dict[str, object]]:
    url = (
        "https://api.finance.naver.com/siseJson.naver"
        f"?symbol={ticker}&requestType=1"
        f"&startTime={yyyymmdd(START_DATE)}"
        f"&endTime={yyyymmdd(END_DATE)}"
        "&timeframe=day"
    )
    text = fetch_text(url)
    pattern = re.compile(
        r'\["(?P<date>\d{8})",\s*'
        r"(?P<open>\d+),\s*"
        r"(?P<high>\d+),\s*"
        r"(?P<low>\d+),\s*"
        r"(?P<close>\d+),\s*"
        r"(?P<volume>\d+),\s*"
        r"(?P<foreign>[0-9.]+)"
        r"\]"
    )
    rows: list[dict[str, object]] = []
    for match in pattern.finditer(text):
        rows.append(
            {
                "date": iso_date(match.group("date")),
                "open": int(match.group("open")),
                "high": int(match.group("high")),
                "low": int(match.group("low")),
                "close": int(match.group("close")),
                "volume": int(match.group("volume")),
                "foreign_ownership_ratio": float(match.group("foreign")),
            }
        )
    return rows


def fetch_public_holidays() -> dict[str, str]:
    holidays: dict[str, str] = {}
    for year in range(START_DATE.year, END_DATE.year + 1):
        url = f"https://date.nager.at/api/v3/PublicHolidays/{year}/KR"
        try:
            payload = fetch_json(url)
        except RuntimeError:
            payload = []
        if isinstance(payload, list):
            for item in payload:
                if isinstance(item, dict) and item.get("date"):
                    local_name = str(item.get("localName") or item.get("name") or "공휴일")
                    holidays[str(item["date"])] = local_name
        time.sleep(REQUEST_PAUSE_SECONDS)

    # Exchange-specific closures and public/temporary holidays that public APIs
    # may omit or rename. These labels are for gameplay calendar flavor.
    manual = {
        "2016-12-30": "연말 증시 휴장일",
        "2017-05-01": "근로자의날",
        "2017-05-09": "제19대 대통령 선거일",
        "2017-10-02": "임시공휴일",
        "2017-10-06": "대체공휴일",
        "2017-12-29": "연말 증시 휴장일",
        "2018-05-01": "근로자의날",
        "2018-06-13": "제7회 지방선거일",
        "2018-12-31": "연말 증시 휴장일",
        "2019-05-01": "근로자의날",
        "2019-12-31": "연말 증시 휴장일",
        "2020-04-15": "제21대 국회의원 선거일",
        "2020-05-01": "근로자의날",
        "2020-08-17": "임시공휴일",
        "2020-12-31": "연말 증시 휴장일",
        "2021-08-16": "대체공휴일",
        "2021-10-04": "대체공휴일",
        "2021-10-11": "대체공휴일",
        "2021-12-31": "연말 증시 휴장일",
        "2022-03-09": "제20대 대통령 선거일",
        "2022-06-01": "제8회 지방선거일",
        "2022-12-30": "연말 증시 휴장일",
        "2023-05-01": "근로자의날",
        "2023-10-02": "임시공휴일",
        "2023-12-29": "연말 증시 휴장일",
        "2024-04-10": "제22대 국회의원 선거일",
        "2024-05-01": "근로자의날",
        "2024-10-01": "임시공휴일",
        "2024-12-31": "연말 증시 휴장일",
        "2025-01-27": "임시공휴일",
        "2025-05-01": "근로자의날",
        "2025-05-06": "대체공휴일",
        "2025-06-03": "제21대 대통령 선거일",
        "2025-10-08": "대체공휴일",
        "2025-12-31": "연말 증시 휴장일",
        "2026-03-02": "대체공휴일",
        "2026-05-25": "대체공휴일",
    }
    holidays.update(manual)
    return holidays


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    MARKET_DIR.mkdir(parents=True, exist_ok=True)
    PRICE_DIR.mkdir(parents=True, exist_ok=True)

    selected_tickers = {company.ticker for company in COMPANIES}
    for stale_file in PRICE_DIR.glob("*.csv"):
        if stale_file.stem not in selected_tickers:
            stale_file.unlink()

    company_metadata: list[dict[str, object]] = []
    trading_dates: set[str] = set()

    for company in COMPANIES:
        rows = fetch_price_rows(company.ticker)
        if not rows:
            raise RuntimeError(f"No daily rows fetched for {company.ticker} {company.name_ko}")

        write_csv(
            PRICE_DIR / f"{company.ticker}.csv",
            rows,
            ["date", "open", "high", "low", "close", "volume", "foreign_ownership_ratio"],
        )
        trading_dates.update(str(row["date"]) for row in rows)

        company_metadata.append(
            {
                "ticker": company.ticker,
                "real_name_ko": company.name_ko,
                "display_name_ko": company.name_ko,
                "sector_hint": company.sector_hint,
                "first_date": rows[0]["date"],
                "last_date": rows[-1]["date"],
                "daily_rows": len(rows),
                "source_file": f"data/raw/prices/{company.ticker}.csv",
            }
        )
        print(f"{company.ticker} {company.name_ko}: {len(rows)} rows")
        time.sleep(REQUEST_PAUSE_SECONDS)

    holiday_names = fetch_public_holidays()

    calendar_rows: list[dict[str, object]] = []
    trading_day_rows: list[dict[str, object]] = []
    non_trading_rows: list[dict[str, object]] = []
    for current in daterange(START_DATE, END_DATE):
        ds = current.isoformat()
        weekday = current.strftime("%A")
        is_weekend = current.weekday() >= 5
        is_trading_day = ds in trading_dates
        reason = ""
        name = ""
        if not is_trading_day:
            if is_weekend:
                reason = "weekend"
                name = "주말"
            elif ds in holiday_names:
                reason = "holiday"
                name = holiday_names[ds]
            else:
                reason = "market_closure"
                name = "증시 휴장일"

        row = {
            "date": ds,
            "weekday": weekday,
            "is_trading_day": "true" if is_trading_day else "false",
            "reason": reason,
            "name": name,
        }
        calendar_rows.append(row)
        if is_trading_day:
            trading_day_rows.append({"date": ds, "weekday": weekday})
        else:
            non_trading_rows.append(row)

    write_csv(
        MARKET_DIR / "trading_calendar.csv",
        calendar_rows,
        ["date", "weekday", "is_trading_day", "reason", "name"],
    )
    write_csv(MARKET_DIR / "trading_days.csv", trading_day_rows, ["date", "weekday"])
    write_csv(
        MARKET_DIR / "non_trading_days.csv",
        non_trading_rows,
        ["date", "weekday", "is_trading_day", "reason", "name"],
    )

    companies_payload = {
        "debug_real_name_mode": True,
        "alias_file": "data/market/company_aliases.json",
        "selection_basis": "KOSPI market capitalization near 2026-06-30 close, excluding preferred shares, ETFs, and holding-company style names.",
        "companies": company_metadata,
    }
    (MARKET_DIR / "companies.json").write_text(
        json.dumps(companies_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    source_payload = {
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "range": {"start": START_DATE.isoformat(), "end": END_DATE.isoformat()},
        "price_source": "https://api.finance.naver.com/siseJson.naver",
        "holiday_source": "https://date.nager.at/api/v3/PublicHolidays/{year}/KR plus manual KRX market-closure labels",
        "trading_calendar_method": "Union of fetched stock daily dates; all other calendar dates are marked non-trading.",
        "company_count": len(COMPANIES),
        "trading_day_count": len(trading_day_rows),
        "non_trading_day_count": len(non_trading_rows),
    }
    (MARKET_DIR / "source_meta.json").write_text(
        json.dumps(source_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"Trading days: {len(trading_day_rows)}")
    print(f"Non-trading days: {len(non_trading_rows)}")
    print(f"Wrote {MARKET_DIR}")
    print(f"Wrote {PRICE_DIR}")


if __name__ == "__main__":
    main()
