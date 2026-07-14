#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json
import sys


ROOT = Path(__file__).resolve().parents[2]
SOURCE_PATH = ROOT / "data/game/company_work_variants_text_catalog.generated.json"
DAY_EVENTS_PATH = ROOT / "data/game/day_events.json"
COMPANY_WORK_GROUP = "company_work"
COMPANY_WORK_MODE = "auto_trading"
COMPANY_WORK_CATEGORY_ID = "company_work"
COMPANY_WORK_CATEGORY_KO = "회사 기본업무"
COMPANY_WORK_COOLDOWN_DAYS = 120


def main() -> int:
    if not SOURCE_PATH.exists():
        print(f"missing source catalog: {SOURCE_PATH.relative_to(ROOT)}", file=sys.stderr)
        return 1
    source = json.loads(SOURCE_PATH.read_text(encoding="utf-8"))
    variants = source.get("variants", [])
    errors = _validate_variants(variants)
    if errors:
        _print_errors(errors)
        return 1

    day_events = json.loads(DAY_EVENTS_PATH.read_text(encoding="utf-8"))
    day_actions = day_events.setdefault("day_actions", [])
    existing_ids = {str(row.get("id", "")) for row in day_actions if isinstance(row, dict)}
    promoted = [_promote_variant(row) for row in variants]

    added = 0
    replaced = 0
    by_id = {str(row.get("id", "")): index for index, row in enumerate(day_actions) if isinstance(row, dict)}
    for event in promoted:
        event_id = event["id"]
        if event_id in by_id:
            day_actions[by_id[event_id]] = event
            replaced += 1
            continue
        if event_id in existing_ids:
            print(f"duplicate day action id outside index: {event_id}", file=sys.stderr)
            return 1
        day_actions.append(event)
        existing_ids.add(event_id)
        by_id[event_id] = len(day_actions) - 1
        added += 1

    DAY_EVENTS_PATH.write_text(json.dumps(day_events, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({
        "added": added,
        "replaced": replaced,
        "day_actions": len(day_actions),
        "company_work_variants": len(promoted),
    }, ensure_ascii=False, sort_keys=True))
    return 0


def _validate_variants(variants: list[dict]) -> list[str]:
    errors: list[str] = []
    if len(variants) != 200:
        errors.append(f"company work variant count should be 200, got {len(variants)}")
    seen: set[str] = set()
    for row in variants:
        event_id = str(row.get("id", ""))
        if not event_id:
            errors.append("variant missing id")
            continue
        if event_id in seen:
            errors.append(f"duplicate variant id: {event_id}")
        seen.add(event_id)
        for key in ["name_ko", "summary_ko", "dialogue_ko", "tags", "cash_delta", "health_delta", "mood_delta", "fatigue_delta"]:
            if key not in row:
                errors.append(f"{event_id} missing {key}")
        if len(row.get("dialogue_ko", [])) != 3:
            errors.append(f"{event_id} should have exactly 3 dialogue lines")
        cg_path = ROOT / "assets/events/company_work/phase5" / f"{event_id}.png"
        if not cg_path.exists():
            errors.append(f"{event_id} missing CG file: {cg_path.relative_to(ROOT)}")
    return errors


def _promote_variant(row: dict) -> dict:
    event_id = str(row["id"])
    event = {
        "id": event_id,
        "name_ko": row["name_ko"],
        "summary_ko": row["summary_ko"],
        "tags": row.get("tags", []),
        "cooldown_days": COMPANY_WORK_COOLDOWN_DAYS,
        "weight": 1,
        "rarity": "common",
        "cg_path": f"res://assets/events/company_work/phase5/{event_id}.png",
        "dialogue": row["dialogue_ko"],
        "effects": {
            "cash_delta": row.get("cash_delta", 0),
            "health_delta": row.get("health_delta", 0),
            "mood_delta": row.get("mood_delta", 0),
            "fatigue_delta": row.get("fatigue_delta", 0),
        },
        "mode": COMPANY_WORK_MODE,
        "group": COMPANY_WORK_GROUP,
        "category_id": COMPANY_WORK_CATEGORY_ID,
        "category_ko": COMPANY_WORK_CATEGORY_KO,
        "bucket_id": row.get("bucket_id", ""),
        "bucket_ko": row.get("bucket_ko", ""),
        "tone": row.get("tone", ""),
    }
    return event


def _print_errors(errors: list[str]) -> None:
    for error in errors:
        print(error, file=sys.stderr)


if __name__ == "__main__":
    raise SystemExit(main())
