#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json
import re
import sys


ROOT = Path(__file__).resolve().parents[2]
SCRIPT_DOC_PATH = ROOT / "docs/gameplay/phase3_new_event_scripts.md"
OUTPUT_PATH = ROOT / "data/game/phase3_image_queue.generated.json"

SECTION_TO_GROUP = {
    "집에 있기 신규 40개": "stay_home",
    "외출하기 신규 40개": "go_out",
    "평일 사건 신규 40개": "weekday",
    "밤/돌발 신규 40개": "night",
}
GROUP_ORDER = {
    "stay_home": 0,
    "go_out": 1,
    "weekday": 2,
    "night": 3,
}
OUTFIT_BY_GROUP = {
    "stay_home": "homewear: cozy casual indoor outfit",
    "go_out": "casual Korean city outing outfit",
    "weekday": "startup office worker outfit",
    "night": "homewear or casual night outfit matching the scene",
}
SETTING_BY_GROUP = {
    "stay_home": "lovely feminine Korean studio apartment or small home interior",
    "go_out": "Korean city outing location matching the event",
    "weekday": "startup office, commute, or workplace-adjacent scene matching the event",
    "night": "cozy night-time room, convenience store, or late-night food setting matching the event",
}


def main() -> int:
    rows = _parse_script_doc(SCRIPT_DOC_PATH.read_text(encoding="utf-8"))
    queue = [_queue_row(row, index) for index, row in enumerate(rows)]
    queue.sort(key=lambda row: (row["exists"], row["priority"], row["event_id"]))
    payload = {
        "version": 1,
        "note": "Generated image production queue for Phase 3 event CG. Missing assets are sorted first.",
        "source": str(SCRIPT_DOC_PATH.relative_to(ROOT)),
        "counts": {
            "total": len(queue),
            "existing": sum(1 for row in queue if row["exists"]),
            "missing": sum(1 for row in queue if not row["exists"]),
        },
        "queue": queue,
    }
    OUTPUT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUTPUT_PATH.relative_to(ROOT)}")
    print(json.dumps(payload["counts"], ensure_ascii=False, sort_keys=True))
    return 0


def _parse_script_doc(text: str) -> list[dict]:
    rows: list[dict] = []
    current_section = ""
    current: dict | None = None
    for line in text.splitlines():
        if line.startswith("## "):
            current_section = line[3:].strip()
            continue
        if current_section not in SECTION_TO_GROUP:
            continue
        if line.startswith("### "):
            if current is not None:
                rows.append(current)
            current = {
                "section": current_section,
                "group": SECTION_TO_GROUP[current_section],
                "title": line[4:].strip(),
            }
            continue
        if current is None:
            continue
        match = re.match(r"^- ([^:]+):\s*(.*)$", line)
        if not match:
            continue
        key = match.group(1).strip()
        value = _strip_code(match.group(2).strip())
        current[key] = value
    if current is not None:
        rows.append(current)
    return rows


def _strip_code(value: str) -> str:
    if value.startswith("`") and value.endswith("`"):
        return value[1:-1]
    return value


def _queue_row(row: dict, index: int) -> dict:
    cg_path = str(row.get("cg_path", ""))
    workspace_path = cg_path.replace("res://", "")
    local_path = ROOT / workspace_path
    group = str(row.get("group", ""))
    exists = local_path.exists()
    return {
        "event_id": row.get("id", ""),
        "name_ko": _title_name(str(row.get("title", ""))),
        "group": group,
        "category_id": row.get("category_id", ""),
        "tags": _split_tags(str(row.get("tags", ""))),
        "cg_path": cg_path,
        "workspace_path": workspace_path,
        "exists": exists,
        "priority": _priority(group, exists, index),
        "prompt": _prompt_for(row),
    }


def _title_name(title: str) -> str:
    if ". " in title:
        return title.split(". ", 1)[1].strip()
    return title.strip()


def _split_tags(tags: str) -> list[str]:
    if tags.startswith("[") and tags.endswith("]"):
        tags = tags[1:-1]
    return [tag.strip().strip('"').strip("'").strip("`") for tag in tags.split(",") if tag.strip()]


def _priority(group: str, exists: bool, index: int) -> int:
    if exists:
        return 9000 + index
    return GROUP_ORDER.get(group, 9) * 1000 + index


def _prompt_for(row: dict) -> str:
    group = str(row.get("group", ""))
    event_prompt = str(row.get("image_prompt") or row.get("title") or row.get("id"))
    outfit = OUTFIT_BY_GROUP.get(group, "consistent protagonist outfit")
    setting = SETTING_BY_GROUP.get(group, "setting matching the event")
    return "\n".join([
        "Use case: illustration-story",
        "Asset type: vertical mobile game event CG for a Korean visual-novel life/stock simulation game",
        f"Primary request: {event_prompt}",
        "Subject: the established cute chibi-style female protagonist from the project character sheet, expressive and clearly performing the event action",
        f"Outfit: {outfit}",
        f"Scene/backdrop: {setting}",
        "Style/medium: polished cute 2D anime/chibi event illustration, warm Korean/Japanese casual game mood, clean line art, soft shading",
        "Composition/framing: 720x1280 vertical smartphone composition, complete finished illustration from top to bottom, protagonist and key action clearly readable, balanced foreground and background details",
        "Lighting/mood: cozy, readable, emotionally specific to the event",
        "Required finish: the full image must stand alone as a complete CG that also works in a gallery view.",
        "Constraints: no UI, no speech bubbles, no captions, no in-image text, no logos, no watermark; do not crop the protagonist's face or key action; keep the character design consistent across all event CG",
        "Avoid: blurred lower area, fade-out bottom, empty dialogue-box reservation area, board-game-card style vignette, photorealism, harsh horror mood, cluttered unreadable backgrounds, extra main characters unless the event explicitly requires social context",
    ])


if __name__ == "__main__":
    sys.exit(main())
