#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json
import re
import sys


ROOT = Path(__file__).resolve().parents[2]
SCRIPT_DOC_PATH = ROOT / "docs/gameplay/phase3_new_event_scripts.md"
DAY_EVENTS_PATH = ROOT / "data/game/day_events.json"

SECTION_TO_GROUP = {
    "집에 있기 신규 40개": "stay_home",
    "외출하기 신규 40개": "go_out",
    "평일 사건 신규 40개": "weekday",
    "밤/돌발 신규 40개": "night",
}
EXPECTED_GROUP_COUNTS = {
    "stay_home": 40,
    "go_out": 40,
    "weekday": 40,
    "night": 40,
}
TARGET_SECTION_BY_GROUP = {
    "stay_home": "day_actions",
    "go_out": "day_actions",
    "weekday": "weekday_events",
    "night": "night_events",
}
CATEGORY_LABELS = {
    "stay_home": "집에 있기",
    "go_out": "외출하기",
}


def main() -> int:
    phase3_events = _parse_phase3_scripts(SCRIPT_DOC_PATH.read_text(encoding="utf-8"))
    day_events = json.loads(DAY_EVENTS_PATH.read_text(encoding="utf-8"))

    errors = _validate_source_events(phase3_events)
    if errors:
        _print_errors(errors)
        return 1

    promoted = [_promote_event(event) for event in phase3_events]
    errors = _validate_promoted_events(day_events, promoted)
    if errors:
        _print_errors(errors)
        return 1

    for section in TARGET_SECTION_BY_GROUP.values():
        day_events.setdefault(section, [])

    existing_ids = _existing_ids(day_events)
    added_counts = {"day_actions": 0, "weekday_events": 0, "night_events": 0}
    skipped = 0
    for event in promoted:
        if event["id"] in existing_ids:
            skipped += 1
            continue
        section = TARGET_SECTION_BY_GROUP[event["_group"]]
        event.pop("_group")
        day_events[section].append(event)
        existing_ids.add(event["id"])
        added_counts[section] += 1

    DAY_EVENTS_PATH.write_text(json.dumps(day_events, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    counts = {
        "added": added_counts,
        "skipped_existing": skipped,
        "totals": {
            "day_actions": len(day_events.get("day_actions", [])),
            "weekday_events": len(day_events.get("weekday_events", [])),
            "night_events": len(day_events.get("night_events", [])),
        },
    }
    counts["totals"]["all_rows"] = sum(counts["totals"].values())
    print(json.dumps(counts, ensure_ascii=False, sort_keys=True))
    return 0


def _parse_phase3_scripts(text: str) -> list[dict]:
    events: list[dict] = []
    current_section = ""
    current: dict | None = None
    dialogue_mode = False
    for line in text.splitlines():
        if line.startswith("## "):
            if current is not None:
                events.append(current)
                current = None
            current_section = line[3:].strip()
            dialogue_mode = False
            continue
        if current_section not in SECTION_TO_GROUP:
            continue
        if line.startswith("### "):
            if current is not None:
                events.append(current)
            current = {
                "title_ko": line[4:].strip(),
                "group": SECTION_TO_GROUP[current_section],
                "dialogue": [],
            }
            dialogue_mode = False
            continue
        if current is None:
            continue
        if line.strip() == "대사:":
            dialogue_mode = True
            continue
        if dialogue_mode:
            match = re.match(r"^\d+\.\s*(.+)$", line.strip())
            if match:
                current["dialogue"].append(match.group(1).strip())
            continue
        _parse_bullet_field(current, line)
    if current is not None:
        events.append(current)
    return events


def _parse_bullet_field(event: dict, line: str) -> None:
    match = re.match(r"^- ([^:]+):\s*(.*)$", line)
    if not match:
        return
    key = match.group(1).strip()
    value = match.group(2).strip()
    if key in {"id", "group", "category_id", "rarity", "cg_path"}:
        event[key] = _strip_code(value)
    elif key == "tags":
        event[key] = _extract_code_values(value)
    elif key == "cooldown_days":
        event[key] = int(value)
    elif key == "conditions":
        event["conditions_text"] = _strip_code(value)
    elif key == "effects":
        event[key] = _parse_effects(value)


def _strip_code(value: str) -> str:
    if value.startswith("`") and value.endswith("`"):
        return value[1:-1]
    return value


def _extract_code_values(value: str) -> list[str]:
    values = re.findall(r"`([^`]+)`", value)
    if values:
        return values
    return [part.strip() for part in value.split(",") if part.strip()]


def _parse_effects(value: str) -> dict:
    effects = {}
    for key in ["cash_delta", "health_delta", "mood_delta", "fatigue_delta"]:
        match = re.search(rf"{key}:\s*(\[[^\]]+\]|-?\d+)", value)
        if not match:
            continue
        raw = match.group(1)
        effects[key] = json.loads(raw) if raw.startswith("[") else int(raw)
    return effects


def _promote_event(source: dict) -> dict:
    group = source["group"]
    event = {
        "id": source["id"],
        "name_ko": source["title_ko"],
        "summary_ko": _summary_for(source),
        "tags": source.get("tags", []),
        "cooldown_days": source.get("cooldown_days", 60),
        "weight": 1,
        "rarity": source.get("rarity", "common"),
        "cg_path": source["cg_path"],
        "dialogue": source.get("dialogue", []),
        "effects": source.get("effects", {}),
        "_group": group,
    }
    conditions_text = source.get("conditions_text", "")
    if conditions_text and conditions_text != "없음":
        event["conditions_text"] = conditions_text
    if group in {"stay_home", "go_out"}:
        event["mode"] = "choice_closed"
        event["category_id"] = source.get("category_id", group)
        event["category_ko"] = CATEGORY_LABELS.get(group, group)
    elif group == "weekday":
        event["mode"] = "weekday_random"
        event["chance"] = 0.04
        event["weekday_phase"] = ""
    elif group == "night":
        event["mode"] = "night_random"
        event["chance"] = 0.045
    return event


def _summary_for(source: dict) -> str:
    title = source.get("title_ko", "")
    group = source.get("group", "")
    if group == "stay_home":
        return "집에서 %s 시간을 보낸다." % title
    if group == "go_out":
        return "밖에서 %s 일정을 보낸다." % title
    if group == "weekday":
        return "평일 하루에 %s 일이 생긴다." % title
    if group == "night":
        return "밤에 %s 일이 생긴다." % title
    return title


def _validate_source_events(events: list[dict]) -> list[str]:
    errors: list[str] = []
    if len(events) != 160:
        errors.append(f"phase3 event count: expected 160, got {len(events)}")
    for group, expected in EXPECTED_GROUP_COUNTS.items():
        actual = sum(1 for event in events if event.get("group") == group)
        if actual != expected:
            errors.append(f"{group} count: expected {expected}, got {actual}")
    for event in events:
        event_id = event.get("id", "")
        for key in ["id", "title_ko", "group", "cg_path", "effects"]:
            if not event.get(key):
                errors.append(f"{event_id or event.get('title_ko', '<unknown>')} missing {key}")
        if len(event.get("dialogue", [])) < 4:
            errors.append(f"{event_id} should have at least 4 dialogue lines")
        if event.get("group") in {"stay_home", "go_out"} and event.get("category_id") != event.get("group"):
            errors.append(f"{event_id} category_id should match group")
        for effect_key in ["cash_delta", "health_delta", "mood_delta", "fatigue_delta"]:
            if effect_key not in event.get("effects", {}):
                errors.append(f"{event_id} missing effect {effect_key}")
        local_path = ROOT / str(event.get("cg_path", "")).replace("res://", "")
        if not local_path.exists():
            errors.append(f"{event_id} missing CG file: {local_path.relative_to(ROOT)}")
    for duplicate in _duplicates([event.get("id", "") for event in events]):
        errors.append(f"duplicate phase3 id: {duplicate}")
    for duplicate in _duplicates([event.get("cg_path", "") for event in events]):
        errors.append(f"duplicate phase3 cg_path: {duplicate}")
    return errors


def _validate_promoted_events(day_events: dict, promoted: list[dict]) -> list[str]:
    errors: list[str] = []
    current_by_id = {
        event.get("id", ""): event
        for section in ["day_actions", "weekday_events", "night_events"]
        for event in day_events.get(section, [])
        if event.get("id", "")
    }
    current_id_by_cg_path = {
        event.get("cg_path", ""): event.get("id", "")
        for section in ["day_actions", "weekday_events", "night_events"]
        for event in day_events.get(section, [])
        if event.get("cg_path", "")
    }
    for event in promoted:
        existing = current_by_id.get(event["id"])
        if existing and existing.get("cg_path", "") != event["cg_path"]:
            errors.append("phase3 id already exists with a different CG path: %s" % event["id"])
        existing_id = current_id_by_cg_path.get(event["cg_path"], "")
        if existing_id and existing_id != event["id"]:
            errors.append(
                "phase3 CG path is already used by another event: %s -> %s"
                % (event["cg_path"], existing_id)
            )
    return errors


def _existing_ids(day_events: dict) -> set[str]:
    return {
        event.get("id", "")
        for section in ["day_actions", "weekday_events", "night_events"]
        for event in day_events.get(section, [])
        if event.get("id", "")
    }


def _duplicates(values: list[str]) -> list[str]:
    seen = set()
    duplicates = set()
    for value in values:
        if value in seen:
            duplicates.add(value)
        seen.add(value)
    return sorted(duplicates)


def _print_errors(errors: list[str]) -> None:
    for error in errors:
        print(f"ERROR: {error}")


if __name__ == "__main__":
    sys.exit(main())
