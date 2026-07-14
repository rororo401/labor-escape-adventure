#!/usr/bin/env python3
from pathlib import Path
import json
import sys


ROOT = Path(__file__).resolve().parents[2]
CATALOG_PATH = ROOT / "data/game/phase1_event_catalog.generated.json"
OUTPUT_PATH = ROOT / "data/game/phase1_image_queue.generated.json"

GROUP_ORDER = {
    "stay_home": 0,
    "go_out": 1,
    "weekday": 2,
    "night": 3,
}
OUTFIT_BY_GROUP = {
    "stay_home": "homewear: cozy long-sleeve top and long pants",
    "go_out": "casual outdoor outfit",
    "weekday": "startup office worker outfit",
    "night": "homewear: cozy long-sleeve top and long pants",
}
SETTING_BY_GROUP = {
    "stay_home": "lovely feminine Korean studio apartment or small home interior",
    "go_out": "Korean city outing location matching the event",
    "weekday": "startup office, commute, or workplace-adjacent scene matching the event",
    "night": "cozy night-time room or late-night food setting matching the event",
}


def main() -> int:
    data = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    rows = data.get("events", [])
    queue = [_queue_row(row, index) for index, row in enumerate(rows)]
    queue.sort(key=lambda row: (row["exists"], row["priority"], row["event_id"]))
    payload = {
        "version": 1,
        "note": "Generated image production queue for Phase 1 event CG. Missing assets are sorted first.",
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


def _queue_row(row: dict, index: int) -> dict:
    cg_path = str(row.get("cg_path", ""))
    workspace_path = cg_path.replace("res://", "")
    local_path = ROOT / workspace_path
    group = str(row.get("group", ""))
    prompt = _prompt_for(row)
    exists = local_path.exists()
    return {
        "event_id": row.get("id", ""),
        "name_ko": row.get("name_ko", ""),
        "group": group,
        "cg_path": cg_path,
        "workspace_path": workspace_path,
        "exists": exists,
        "priority": _priority(row, exists, index),
        "prompt": prompt,
    }


def _priority(row: dict, exists: bool, index: int) -> int:
    if exists:
        return 9000 + index
    return GROUP_ORDER.get(str(row.get("group", "")), 9) * 1000 + index


def _prompt_for(row: dict) -> str:
    group = str(row.get("group", ""))
    event_prompt = str(row.get("image_prompt") or row.get("cg_brief") or row.get("name_ko") or row.get("id"))
    outfit = OUTFIT_BY_GROUP.get(group, "consistent protagonist outfit")
    setting = SETTING_BY_GROUP.get(group, "setting matching the event")
    return "\n".join([
        "Use case: illustration-story",
        "Asset type: vertical mobile game event CG for a Korean visual-novel life/stock simulation game",
        f"Primary request: {event_prompt}",
        "Subject: the established chibi-style female protagonist from the project character sheet, expressive and clearly performing the event action",
        f"Outfit: {outfit}",
        f"Scene/backdrop: {setting}",
        "Style/medium: polished cute 2D anime/chibi event illustration, warm Korean/Japanese casual game mood, clean line art, soft shading",
        "Composition/framing: 720x1280 vertical smartphone composition, protagonist visible from upper body to at least thighs when possible, important face/action in upper and middle area, leave the lower 25 percent visually simple for dialogue UI",
        "Lighting/mood: cozy, readable, emotionally specific to the event",
        "Constraints: no UI, no speech bubbles, no captions, no in-image text, no logos, no watermark; do not crop the protagonist's face or key action; keep the character design consistent across all event CG",
        "Avoid: photorealism, harsh horror mood, cluttered unreadable backgrounds, extra main characters unless the event explicitly requires social context",
    ])


if __name__ == "__main__":
    sys.exit(main())
