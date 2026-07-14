#!/usr/bin/env python3
from pathlib import Path
import json
import re
import sys
from typing import Optional


ROOT = Path(__file__).resolve().parents[2]
INVENTORY_PATH = ROOT / "docs/gameplay/phase1_130_event_inventory.md"
SCRIPTS_PATH = ROOT / "docs/gameplay/phase1_new_event_scripts.md"
GENERATED_CATALOG_PATH = ROOT / "data/game/phase1_event_catalog.generated.json"
IMAGE_QUEUE_PATH = ROOT / "data/game/phase1_image_queue.generated.json"

EXPECTED_INVENTORY_COUNTS = {
    "집에 있기 40개": 40,
    "외출하기 40개": 40,
    "평일 사건 25개": 25,
    "밤/돌발 이벤트 25개": 25,
}
EXPECTED_CG_PATHS = 130
EXPECTED_SCRIPT_COUNTS = {
    "집에 있기 신규 26개": 26,
    "외출하기 신규 24개": 24,
    "평일 사건 신규 16개": 16,
    "밤/돌발 신규 13개": 13,
}
EXPECTED_TOTAL_NEW_SCRIPTS = 79


def main() -> int:
    errors = []
    inventory = _read(INVENTORY_PATH, errors)
    scripts = _read(SCRIPTS_PATH, errors)
    if errors:
        return _finish(errors)

    inventory_counts = _count_numbered_table_rows_by_section(inventory)
    for section, expected in EXPECTED_INVENTORY_COUNTS.items():
        actual = inventory_counts.get(section, 0)
        if actual != expected:
            errors.append(f"{section}: expected {expected}, got {actual}")

    cg_paths = _find_cg_paths(inventory)
    if len(cg_paths) != EXPECTED_CG_PATHS:
        errors.append(f"inventory cg path count: expected {EXPECTED_CG_PATHS}, got {len(cg_paths)}")
    duplicates = sorted(path for path in set(cg_paths) if cg_paths.count(path) > 1)
    if duplicates:
        errors.append("duplicate cg paths: " + ", ".join(duplicates))

    script_counts = {
        section: _count_subheadings_under(scripts, section)
        for section in EXPECTED_SCRIPT_COUNTS
    }
    scripted_events = sum(script_counts.values())
    if scripted_events != EXPECTED_TOTAL_NEW_SCRIPTS:
        errors.append(f"total new scripts: expected {EXPECTED_TOTAL_NEW_SCRIPTS}, got {scripted_events}")
    for section, expected in EXPECTED_SCRIPT_COUNTS.items():
        actual = script_counts.get(section, 0)
        if actual != expected:
            errors.append(f"{section}: expected {expected}, got {actual}")

    prompts = scripts.count("- image_prompt:")
    if prompts != scripted_events:
        errors.append(f"image prompts should match scripted events: scripts={scripted_events}, prompts={prompts}")

    dialogues = _count_dialogue_blocks(scripts)
    if dialogues != scripted_events:
        errors.append(f"dialogue blocks should match scripted events: scripts={scripted_events}, dialogues={dialogues}")

    generated_counts = _validate_generated_catalog(errors)
    image_counts = _validate_image_queue(errors)
    return _finish(errors, inventory_counts, len(cg_paths), script_counts, generated_counts, image_counts)


def _read(path: Path, errors: list[str]) -> str:
    if not path.exists():
        errors.append(f"missing file: {path.relative_to(ROOT)}")
        return ""
    return path.read_text(encoding="utf-8")


def _count_numbered_table_rows_by_section(text: str) -> dict[str, int]:
    counts: dict[str, int] = {}
    current = ""
    for line in text.splitlines():
        if line.startswith("## "):
            current = line[3:].strip()
            counts.setdefault(current, 0)
            continue
        if not current or not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if cells and cells[0].isdigit():
            counts[current] = counts.get(current, 0) + 1
    return counts


def _find_cg_paths(text: str) -> list[str]:
    return re.findall(r"`(res://assets/events/[^`]+?\.png)`", text)


def _count_subheadings_under(text: str, section: str) -> int:
    in_section = False
    count = 0
    for line in text.splitlines():
        if line.startswith("## "):
            in_section = line[3:].strip() == section
            continue
        if in_section and line.startswith("### "):
            count += 1
    return count


def _count_dialogue_blocks(text: str) -> int:
    return sum(1 for line in text.splitlines() if line.strip() == "대사:")


def _validate_generated_catalog(errors: list[str]) -> dict[str, int]:
    if not GENERATED_CATALOG_PATH.exists():
        errors.append(f"missing generated catalog: {GENERATED_CATALOG_PATH.relative_to(ROOT)}")
        return {}
    data = json.loads(GENERATED_CATALOG_PATH.read_text(encoding="utf-8"))
    rows = data.get("events", [])
    if len(rows) != EXPECTED_CG_PATHS:
        errors.append(f"generated catalog event count: expected {EXPECTED_CG_PATHS}, got {len(rows)}")
    ids = [str(row.get("id", "")) for row in rows]
    duplicates = sorted(event_id for event_id in set(ids) if ids.count(event_id) > 1)
    if duplicates:
        errors.append("generated duplicate ids: " + ", ".join(duplicates))
    cg_paths = [str(row.get("cg_path", "")) for row in rows]
    cg_duplicates = sorted(path for path in set(cg_paths) if cg_paths.count(path) > 1)
    if cg_duplicates:
        errors.append("generated duplicate cg paths: " + ", ".join(cg_duplicates))
    counts = {group: sum(1 for row in rows if row.get("group") == group) for group in ["stay_home", "go_out", "weekday", "night"]}
    expected_by_group = {
        "stay_home": 40,
        "go_out": 40,
        "weekday": 25,
        "night": 25,
    }
    for group, expected in expected_by_group.items():
        if counts.get(group, 0) != expected:
            errors.append(f"generated {group}: expected {expected}, got {counts.get(group, 0)}")
    missing_dialogue = [str(row.get("id", "")) for row in rows if not row.get("dialogue")]
    if missing_dialogue:
        errors.append("generated missing dialogue: " + ", ".join(missing_dialogue))
    missing_effects = [str(row.get("id", "")) for row in rows if not row.get("effects")]
    if missing_effects:
        errors.append("generated missing effects: " + ", ".join(missing_effects))
    counts["total"] = len(rows)
    return counts


def _validate_image_queue(errors: list[str]) -> dict[str, int]:
    if not IMAGE_QUEUE_PATH.exists():
        errors.append(f"missing image queue: {IMAGE_QUEUE_PATH.relative_to(ROOT)}")
        return {}
    data = json.loads(IMAGE_QUEUE_PATH.read_text(encoding="utf-8"))
    rows = data.get("queue", [])
    if len(rows) != EXPECTED_CG_PATHS:
        errors.append(f"image queue count: expected {EXPECTED_CG_PATHS}, got {len(rows)}")
    event_ids = [str(row.get("event_id", "")) for row in rows]
    duplicates = sorted(event_id for event_id in set(event_ids) if event_ids.count(event_id) > 1)
    if duplicates:
        errors.append("image queue duplicate event ids: " + ", ".join(duplicates))
    paths = [str(row.get("workspace_path", "")) for row in rows]
    path_duplicates = sorted(path for path in set(paths) if paths.count(path) > 1)
    if path_duplicates:
        errors.append("image queue duplicate paths: " + ", ".join(path_duplicates))
    missing_prompt = [str(row.get("event_id", "")) for row in rows if not str(row.get("prompt", "")).strip()]
    if missing_prompt:
        errors.append("image queue missing prompts: " + ", ".join(missing_prompt))
    existing = 0
    for row in rows:
        workspace_path = str(row.get("workspace_path", ""))
        file_exists = (ROOT / workspace_path).exists()
        if bool(row.get("exists", False)) != file_exists:
            errors.append(f"image queue stale exists flag for {row.get('event_id', '')}: queue={row.get('exists')} actual={file_exists}")
        if file_exists:
            existing += 1
    return {
        "total": len(rows),
        "existing": existing,
        "missing": len(rows) - existing,
    }


def _finish(errors: list[str], inventory_counts: Optional[dict[str, int]] = None, cg_count: int = 0, script_counts: Optional[dict[str, int]] = None, generated_counts: Optional[dict[str, int]] = None, image_counts: Optional[dict[str, int]] = None) -> int:
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    if inventory_counts is not None:
        for section, expected in EXPECTED_INVENTORY_COUNTS.items():
            print(f"{section}: {inventory_counts.get(section, 0)}/{expected}")
    print(f"cg_paths: {cg_count}/{EXPECTED_CG_PATHS}")
    if script_counts is not None:
        for section, expected in EXPECTED_SCRIPT_COUNTS.items():
            print(f"{section}: {script_counts.get(section, 0)}/{expected}")
    if generated_counts is not None:
        print(
            "generated_catalog: total={total}, stay_home={stay_home}, go_out={go_out}, weekday={weekday}, night={night}".format(
                total=generated_counts.get("total", 0),
                stay_home=generated_counts.get("stay_home", 0),
                go_out=generated_counts.get("go_out", 0),
                weekday=generated_counts.get("weekday", 0),
                night=generated_counts.get("night", 0),
            )
        )
    if image_counts is not None:
        print(
            "image_queue: total={total}, existing={existing}, missing={missing}".format(
                total=image_counts.get("total", 0),
                existing=image_counts.get("existing", 0),
                missing=image_counts.get("missing", 0),
            )
        )
    print("Phase 1 event docs validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
