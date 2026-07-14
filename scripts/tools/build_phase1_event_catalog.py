#!/usr/bin/env python3
from pathlib import Path
import csv
import json
import re
import sys


ROOT = Path(__file__).resolve().parents[2]
INVENTORY_PATH = ROOT / "docs/gameplay/phase1_130_event_inventory.md"
NEW_SCRIPT_PATH = ROOT / "docs/gameplay/phase1_new_event_scripts.md"
WEEKDAY_DOC_PATH = ROOT / "docs/gameplay/weekday_events.md"
DAY_EVENTS_PATH = ROOT / "data/game/day_events.json"
OUTPUT_PATH = ROOT / "data/game/phase1_event_catalog.generated.json"

SECTION_TO_GROUP = {
    "집에 있기 40개": "stay_home",
    "외출하기 40개": "go_out",
    "평일 사건 25개": "weekday",
    "밤/돌발 이벤트 25개": "night",
}
NEW_SCRIPT_SECTIONS = {
    "집에 있기 신규 26개",
    "외출하기 신규 24개",
    "평일 사건 신규 16개",
    "밤/돌발 신규 13개",
}
EXPECTED_GROUP_COUNTS = {
    "stay_home": 40,
    "go_out": 40,
    "weekday": 25,
    "night": 25,
}


def main() -> int:
    inventory = _parse_inventory(INVENTORY_PATH.read_text(encoding="utf-8"))
    new_scripts = _parse_new_scripts(NEW_SCRIPT_PATH.read_text(encoding="utf-8"))
    current_events = _load_current_events()
    weekday_doc = _parse_weekday_doc(WEEKDAY_DOC_PATH.read_text(encoding="utf-8"))

    errors = []
    rows = []
    for row in inventory:
        event_id = row["id"]
        merged = {
            "id": event_id,
            "name_ko": row["name_ko"],
            "group": row["group"],
            "tags": row["tags"],
            "cg_path": row["cg_path"],
            "cg_brief": row["cg_brief"],
            "source": "inventory",
        }
        source = new_scripts.get(event_id) or current_events.get(event_id) or weekday_doc.get(event_id)
        if source is None:
            errors.append(f"missing event script/data for {event_id}")
        else:
            merged.update(source)
            merged["source"] = source.get("source", merged["source"])
        rows.append(merged)

    _validate(rows, errors)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1

    payload = {
        "version": 1,
        "note": "Generated from phase1 event planning docs. Use as the staging catalog before promoting events into live day_events.json.",
        "counts": {
            "total": len(rows),
            **{group: sum(1 for row in rows if row["group"] == group) for group in EXPECTED_GROUP_COUNTS},
        },
        "events": rows,
    }
    OUTPUT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUTPUT_PATH.relative_to(ROOT)}")
    print(json.dumps(payload["counts"], ensure_ascii=False, sort_keys=True))
    return 0


def _parse_inventory(text: str) -> list[dict]:
    rows = []
    current_group = ""
    for line in text.splitlines():
        if line.startswith("## "):
            current_group = SECTION_TO_GROUP.get(line[3:].strip(), "")
            continue
        if not current_group or not line.startswith("|"):
            continue
        cells = _split_markdown_table_row(line)
        if not cells or not cells[0].isdigit():
            continue
        rows.append({
            "id": cells[1],
            "name_ko": cells[2],
            "group": current_group,
            "tags": _split_tags(cells[3]),
            "cg_path": _strip_code(cells[4]),
            "cg_brief": cells[5],
        })
    return rows


def _parse_new_scripts(text: str) -> dict[str, dict]:
    events = {}
    current_section = ""
    current_event = None
    dialogue_mode = False
    for line in text.splitlines():
        if line.startswith("## "):
            current_section = line[3:].strip()
            dialogue_mode = False
            continue
        if current_section not in NEW_SCRIPT_SECTIONS:
            continue
        if line.startswith("### "):
            if current_event is not None:
                events[current_event["id"]] = current_event
            current_event = {
                "title_ko": line[4:].strip(),
                "dialogue": [],
                "source": "phase1_new_event_scripts",
            }
            dialogue_mode = False
            continue
        if current_event is None:
            continue
        if line.strip() == "대사:":
            dialogue_mode = True
            continue
        if dialogue_mode:
            match = re.match(r"^\d+\.\s*(.+)$", line.strip())
            if match:
                current_event["dialogue"].append(match.group(1))
            continue
        _parse_bullet_field(current_event, line)
    if current_event is not None:
        events[current_event["id"]] = current_event
    return events


def _parse_bullet_field(event: dict, line: str) -> None:
    match = re.match(r"^- ([^:]+):\s*(.*)$", line)
    if not match:
        return
    key = match.group(1).strip()
    value = match.group(2).strip()
    if key == "id":
        event["id"] = _strip_code(value)
    elif key == "category_id":
        event["category_id"] = _strip_code(value)
    elif key == "tags":
        event["tags"] = _extract_code_values(value)
    elif key == "rarity":
        event["rarity"] = _strip_code(value)
    elif key == "cooldown_days":
        event["cooldown_days"] = int(value)
    elif key == "cg_path":
        event["cg_path"] = _strip_code(value)
    elif key == "effects":
        event["effects"] = _parse_effects(value)
    elif key == "image_prompt":
        event["image_prompt"] = value


def _parse_effects(value: str) -> dict:
    effects = {}
    for key in ["cash_delta", "health_delta", "mood_delta", "fatigue_delta"]:
        match = re.search(rf"{key}:\s*(\[[^\]]+\]|-?\d+)", value)
        if match:
            raw = match.group(1)
            effects[key] = json.loads(raw) if raw.startswith("[") else int(raw)
    return effects


def _load_current_events() -> dict[str, dict]:
    data = json.loads(DAY_EVENTS_PATH.read_text(encoding="utf-8"))
    rows = {}
    for section, mode in [("day_actions", "day_action"), ("night_events", "night")]:
        for event in data.get(section, []):
            event_id = event.get("id", "")
            if event_id:
                row = dict(event)
                row["source"] = f"data/game/day_events.json:{section}"
                row["catalog_mode"] = mode
                rows[event_id] = row
    return rows


def _parse_weekday_doc(text: str) -> dict[str, dict]:
    table_rows = _parse_weekday_table(text)
    scenes = _parse_weekday_scenes(text)
    rows = {}
    for event_id, row in table_rows.items():
        row["dialogue"] = scenes.get(row["name_ko"], [])
        row["source"] = "docs/gameplay/weekday_events.md"
        rows[event_id] = row
    return rows


def _parse_weekday_table(text: str) -> dict[str, dict]:
    rows = {}
    in_table = False
    for line in text.splitlines():
        if line.startswith("| id |"):
            in_table = True
            continue
        if in_table and line.startswith("## "):
            break
        if not in_table or not line.startswith("|"):
            continue
        cells = _split_markdown_table_row(line)
        if len(cells) < 11 or cells[0] in {"---", "id"}:
            continue
        event_id = cells[0]
        rows[event_id] = {
            "id": event_id,
            "name_ko": cells[1],
            "weekday_phase": cells[2],
            "conditions_text": cells[3],
            "effects": {
                "cash_delta": _parse_money(cells[4]),
                "health_delta": _parse_range_or_int(cells[5]),
                "mood_delta": _parse_range_or_int(cells[6]),
                "fatigue_delta": _parse_range_or_int(cells[7]),
            },
            "cg_id": cells[8],
            "status": cells[9],
            "notes": cells[10],
        }
    return rows


def _parse_weekday_scenes(text: str) -> dict[str, list[str]]:
    scenes = {}
    current = ""
    for line in text.splitlines():
        if line.startswith("### "):
            current = line[4:].strip()
            scenes[current] = []
            continue
        if current and line.startswith("- "):
            scenes[current].append(line[2:].strip())
    return scenes


def _validate(rows: list[dict], errors: list[str]) -> None:
    if len(rows) != 130:
        errors.append(f"total events: expected 130, got {len(rows)}")
    ids = [row.get("id", "") for row in rows]
    for duplicate in sorted({event_id for event_id in ids if ids.count(event_id) > 1}):
        errors.append(f"duplicate id: {duplicate}")
    cg_paths = [row.get("cg_path", "") for row in rows]
    for duplicate in sorted({path for path in cg_paths if cg_paths.count(path) > 1}):
        errors.append(f"duplicate cg_path: {duplicate}")
    for group, expected in EXPECTED_GROUP_COUNTS.items():
        actual = sum(1 for row in rows if row.get("group") == group)
        if actual != expected:
            errors.append(f"{group}: expected {expected}, got {actual}")
    for row in rows:
        event_id = row.get("id", "")
        if not row.get("name_ko"):
            errors.append(f"{event_id}: missing name_ko")
        if not row.get("cg_path"):
            errors.append(f"{event_id}: missing cg_path")
        if not row.get("dialogue"):
            errors.append(f"{event_id}: missing dialogue")
        if not row.get("effects"):
            errors.append(f"{event_id}: missing effects")


def _split_markdown_table_row(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def _strip_code(value: str) -> str:
    return value.strip().strip("`")


def _split_tags(value: str) -> list[str]:
    return [tag.strip() for tag in value.split(",") if tag.strip()]


def _extract_code_values(value: str) -> list[str]:
    found = re.findall(r"`([^`]+)`", value)
    return found if found else _split_tags(value)


def _parse_money(value: str) -> int:
    clean = value.replace(",", "").strip()
    if clean in {"", "-"}:
        return 0
    return int(clean)


def _parse_range_or_int(value: str):
    clean = value.strip()
    if "~" not in clean:
        return int(clean.replace("+", ""))
    start, end = [part.strip().replace("+", "") for part in clean.split("~", 1)]
    return [int(start), int(end)]


if __name__ == "__main__":
    sys.exit(main())
