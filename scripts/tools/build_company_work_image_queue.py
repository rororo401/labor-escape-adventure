#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import json
import sys


ROOT = Path(__file__).resolve().parents[2]
SOURCE_PATH = ROOT / "data/game/company_work_variants_text_catalog.generated.json"
OUTPUT_PATH = ROOT / "data/game/company_work_image_queue.generated.json"
BATCH_DIR = ROOT / "docs/gameplay/company_work_image_batches"
BATCH_SIZE = 35

STYLE_REFS = [
    "assets/characters/protagonist/summer_office/standing_sheet.png",
    "assets/characters/protagonist/summer_homewear/standing_sheet.png",
    "assets/characters/protagonist/casual_default/standing_sheet.png",
    "assets/characters/protagonist/homewear/standing_sheet.png",
    "assets/events/weekend/stay_home/clean_room.png",
    "assets/events/weekend/go_out/flower_shop.png",
    "assets/events/weekday/overtime_request.png",
    "assets/events/weekday/mood_low_scroll.png",
    "assets/backgrounds/work/startup_office_morning.png",
]

CHARACTER_REFS = [
    "assets/characters/protagonist/summer_office/standing_sheet.png",
    "assets/characters/protagonist/summer_homewear/standing_sheet.png",
    "assets/characters/protagonist/casual_default/standing_sheet.png",
    "assets/characters/protagonist/homewear/standing_sheet.png",
]


def main() -> int:
    if not SOURCE_PATH.exists():
        print(f"missing source catalog: {SOURCE_PATH.relative_to(ROOT)}", file=sys.stderr)
        return 1
    source = json.loads(SOURCE_PATH.read_text(encoding="utf-8"))
    variants = source.get("variants", [])
    errors = _validate_source(variants)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    queue = [_queue_row(row, index) for index, row in enumerate(variants)]
    queue.sort(key=lambda row: (row["exists"], row["priority"], row["event_id"]))
    payload = {
        "version": 1,
        "note": "Generated image production queue for company work base-event CG. Missing assets are sorted first.",
        "source": str(SOURCE_PATH.relative_to(ROOT)),
        "counts": {
            "total": len(queue),
            "existing": sum(1 for row in queue if row["exists"]),
            "missing": sum(1 for row in queue if not row["exists"]),
            "dialogue_lines": sum(len(row["dialogue_ko"]) for row in queue),
            "batch_size": BATCH_SIZE,
            "batch_count": (len(queue) + BATCH_SIZE - 1) // BATCH_SIZE,
        },
        "queue": queue,
    }
    OUTPUT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    _write_batches(queue)
    print(f"Wrote {OUTPUT_PATH.relative_to(ROOT)}")
    print(f"Wrote {BATCH_DIR.relative_to(ROOT)}")
    print(json.dumps(payload["counts"], ensure_ascii=False, sort_keys=True))
    return 0


def _validate_source(variants: list[dict]) -> list[str]:
    errors: list[str] = []
    if len(variants) != 200:
        errors.append(f"company work variant count should be 200, got {len(variants)}")
    ids = [row.get("id", "") for row in variants]
    if len(ids) != len(set(ids)):
        errors.append("duplicate company work variant ids found")
    for field in ["id", "name_ko", "bucket_id", "bucket_ko", "summary_ko", "scene_ko", "dialogue_ko", "tone"]:
        missing = [row.get("id", "<unknown>") for row in variants if not row.get(field)]
        if missing:
            errors.append(f"missing {field}: {missing[:5]}")
    bad_dialogue = [
        row.get("id", "<unknown>")
        for row in variants
        if len(row.get("dialogue_ko", [])) != 3
    ]
    if bad_dialogue:
        errors.append(f"dialogue should be 3 lines each: {bad_dialogue[:5]}")
    return errors


def _queue_row(row: dict, index: int) -> dict:
    event_id = str(row["id"])
    cg_path = f"res://assets/events/company_work/phase5/{event_id}.png"
    workspace_path = cg_path.replace("res://", "")
    local_path = ROOT / workspace_path
    exists = local_path.exists()
    return {
        "event_id": event_id,
        "name_ko": row["name_ko"],
        "group": "company_work",
        "bucket_id": row["bucket_id"],
        "bucket_ko": row["bucket_ko"],
        "tone": row["tone"],
        "tags": row.get("tags", []),
        "summary_ko": row["summary_ko"],
        "scene_ko": row["scene_ko"],
        "dialogue_ko": row["dialogue_ko"],
        "cg_path": cg_path,
        "workspace_path": workspace_path,
        "exists": exists,
        "priority": 9000 + index if exists else index,
        "prompt": _prompt_for(row),
    }


def _prompt_for(row: dict) -> str:
    return "\n".join([
        "Use case: illustration-story",
        "Asset type: vertical mobile game event CG for a Korean visual-novel life/stock simulation game",
        f"Primary event: {row['name_ko']}",
        f"Work category: {row['bucket_ko']}",
        f"Scene brief in Korean: {row['scene_ko']}",
        f"Event summary in Korean: {row['summary_ko']}",
        f"Emotional tone: {row['tone']}",
        "Primary character reference files: assets/characters/protagonist/summer_office/standing_sheet.png and assets/characters/protagonist/summer_homewear/standing_sheet.png",
        "Backup identity reference files: assets/characters/protagonist/casual_default/standing_sheet.png and assets/characters/protagonist/homewear/standing_sheet.png",
        "Subject: the established cute chibi-style female protagonist from the project character sheet, expressive and clearly doing office work after arriving at the company",
        "Outfit: use the summer_office character sheet look: short-sleeve neat Korean summer office blouse, breathable light fabric, cropped office slacks, light flats, modest and office-appropriate; avoid cardigan, sweater, coat, heavy long sleeves, winter homewear, or cold-season styling",
        "Scene/backdrop: Korean startup office interior, desk, laptop, monitor, documents, meeting room, shared office equipment, or office-adjacent workspace matching the event",
        "Style/medium: polished cute 2D anime/chibi event illustration, warm Korean/Japanese casual game mood, clean line art, soft shading",
        "Composition/framing: 720x1280 vertical smartphone composition, complete finished illustration from top to bottom, protagonist and key work action clearly readable, balanced foreground and background details",
        "Lighting/mood: clean office lighting with a specific mood matching the event, readable and not overly dark",
        "Required finish: the full image must stand alone as a complete CG that also works in a gallery view.",
        "Constraints: no UI, no speech bubbles, no captions, no readable in-image text, no logos, no watermark; do not crop the protagonist's face or key action; keep the character design consistent across all event CG",
        "Avoid: blurred lower area, fade-out bottom, empty dialogue-box reservation area, card-frame vignette, photorealism, harsh horror mood, cluttered unreadable backgrounds, extra main characters unless the event requires office collaboration context",
        "Office object rule: monitors, documents, whiteboards, badges, receipts, and phones may show abstract blocks or simple marks, but must not contain readable letters, numbers, brand names, or logos.",
        "Batch-specific reinforcement: full completed gallery-quality image, no blurred bottom, no fade-out bottom, no empty dialogue UI space.",
    ])


def _write_batches(queue: list[dict]) -> None:
    BATCH_DIR.mkdir(parents=True, exist_ok=True)
    readme_lines = [
        "# Company Work Image Batches",
        "",
        "회사 기본업무 200개 이벤트 CG를 다른 세션에서 만들기 위한 35장 단위 작업 문서다.",
        "출근중 이벤트가 아니라, 회사에 도착한 뒤 고정으로 1개 발생하는 기본업무 이벤트용 이미지다.",
        "",
        "| 배치 | 범위 | 장수 | 문서 |",
        "|---:|---|---:|---|",
    ]
    for batch_index, start in enumerate(range(0, len(queue), BATCH_SIZE), start=1):
        rows = queue[start:start + BATCH_SIZE]
        filename = f"company_work_image_batch_{batch_index:02d}.md"
        (BATCH_DIR / filename).write_text(_batch_doc(batch_index, rows), encoding="utf-8")
        readme_lines.append(f"| {batch_index:02d} | `{rows[0]['event_id']}` - `{rows[-1]['event_id']}` | {len(rows)} | `{filename}` |")
    (BATCH_DIR / "README.md").write_text("\n".join(readme_lines) + "\n", encoding="utf-8")


def _batch_doc(batch_index: int, rows: list[dict]) -> str:
    ids = [row["event_id"] for row in rows]
    groups = {}
    for row in rows:
        groups[row["bucket_ko"]] = groups.get(row["bucket_ko"], 0) + 1
    lines = [
        f"# Company Work Image Batch {batch_index:02d}: {ids[0]} to {ids[-1]}",
        "",
        "## 다른 세션에 붙여넣을 작업 프롬프트",
        "",
        "아래 문서의 회사 기본업무 이벤트 이미지만 생성해줘.",
        "",
        f"- 작업 루트: `{ROOT}`",
        f"- 배치 문서: `docs/gameplay/company_work_image_batches/company_work_image_batch_{batch_index:02d}.md`",
        f"- 이 배치 범위: `{ids[0]}`부터 `{ids[-1]}`까지 {len(rows)}장",
        "- 목적: `data/game/company_work_image_queue.generated.json` 기준 회사 기본업무 이벤트 CG 생성",
        "- 생성 방식: Codex 기본 `image_gen` 내장 도구 사용",
        "- 저장 방식: 생성 원본은 `$HOME/.codex/generated_images/...`에 남기고, 선택한 결과를 각 이벤트의 `workspace_path`로 복사",
        "- 리사이즈: 저장 후 반드시 `sips -z 1280 720 <workspace_path>`로 720x1280 맞추기",
        "- 큐 갱신: 저장 후 `python3 scripts/tools/build_company_work_image_queue.py` 실행",
        "",
        "중요 품질 규칙:",
        "- 기존 이벤트 CG와 같은 치비풍 2D 모바일 VN 이벤트 CG 품질을 유지한다.",
        "- 회사에 도착한 뒤의 기본업무 장면이다. 출근길/퇴근길/밤 이벤트처럼 그리지 않는다.",
        "- 하단을 흐리게 뭉개거나 페이드아웃하지 않는다.",
        "- 대화창용 빈 공간을 만들지 않는다.",
        "- 이미지 자체가 갤러리에서 단독으로 봐도 완성된 그림이어야 한다.",
        "- UI, 말풍선, 캡션, 워터마크, 로고, 읽을 수 있는 글자/숫자를 피한다.",
        "- 문서/모니터/화이트보드/영수증/사원증은 추상 도형, 빈 라벨, 색 블록으로 처리한다.",
        "- 중요한 얼굴과 업무 행동을 자르지 않는다.",
        "- 이미 존재하는 파일은 덮어쓰지 말고, 이 배치의 TODO 중 없는 파일만 생성한다.",
        "",
        "병렬 작업 주의:",
        "- 여러 세션이 동시에 `data/game/company_work_image_queue.generated.json`을 갱신할 수 있다.",
        "- 실제 결과물은 각 `workspace_path`의 PNG 파일이다.",
        "- 큐 파일은 파일 존재 여부를 다시 읽어 생성되므로, 모든 세션이 끝난 뒤 한 번 더 `python3 scripts/tools/build_company_work_image_queue.py`를 실행하면 된다.",
        "",
        "## 반드시 참조할 파일",
        "",
        "- `docs/gameplay/company_work_variants_text_catalog.md`",
        "- `data/game/company_work_variants_text_catalog.generated.json`",
        "- `data/game/company_work_image_queue.generated.json`",
        "- `scripts/tools/build_company_work_image_queue.py`",
        "",
        "## 스타일 참조 이미지",
        "",
    ]
    lines.extend([f"- `{ref}`" for ref in STYLE_REFS])
    lines.extend([
        "",
        "## 캐릭터 시트 참조",
        "",
        "회사 기본업무 이미지는 여름 출근복 시트를 우선 참조하고, 기존 시트는 얼굴/체형/표정 정체성 보조 참조로만 쓴다.",
        "",
    ])
    lines.extend([f"- `{ref}`" for ref in CHARACTER_REFS])
    lines.extend([
        "",
        "## 이 배치 구성",
        "",
        f"- 총 {len(rows)}장",
    ])
    for group, count in groups.items():
        lines.append(f"- {group}: {count}장")
    lines.extend([
        "",
        "## 저장/검증 명령",
        "",
        "생성 1장마다 아래 흐름을 반복한다.",
        "",
        "```bash",
        'mkdir -p "$(dirname "<workspace_path>")"',
        "latest=$(find \"$HOME/.codex/generated_images\" -type f -name '*.png' -mmin -10 -print0 | xargs -0 ls -t | head -1)",
        'cp "$latest" <workspace_path>',
        "sips -z 1280 720 <workspace_path> >/dev/null",
        "sips -g pixelWidth -g pixelHeight <workspace_path>",
        "python3 scripts/tools/build_company_work_image_queue.py",
        "```",
        "",
        "배치 완료 후 검증한다.",
        "",
        "```bash",
        "python3 scripts/tools/build_company_work_image_queue.py",
        "python3 - <<'PYCHECK'",
        "import json, subprocess",
        "from pathlib import Path",
        "queue=json.loads(Path('data/game/company_work_image_queue.generated.json').read_text())['queue']",
        "ids = {",
    ])
    for event_id in ids:
        lines.append(f"    {event_id!r},")
    lines.extend([
        "}",
        "rows=[row for row in queue if row['event_id'] in ids]",
        "missing=[row['workspace_path'] for row in rows if not Path(row['workspace_path']).exists()]",
        "bad=[]",
        "for row in rows:",
        "    path=Path(row['workspace_path'])",
        "    if not path.exists():",
        "        continue",
        "    width=subprocess.check_output(['sips','-g','pixelWidth',str(path)], text=True).strip().split()[-1]",
        "    height=subprocess.check_output(['sips','-g','pixelHeight',str(path)], text=True).strip().split()[-1]",
        "    if (width, height) != ('720', '1280'):",
        "        bad.append((row['event_id'], width, height))",
        "print({'batch_total': len(rows), 'missing': len(missing), 'bad_dimensions': bad[:5]})",
        "raise SystemExit(1 if missing or bad else 0)",
        "PYCHECK",
        "```",
        "",
        "## TODO 이미지",
        "",
    ])
    for row in rows:
        status = "DONE" if row["exists"] else "TODO"
        lines.extend([
            f"### {row['event_id']} - {row['name_ko']} [{status}]",
            "",
            f"- bucket: `{row['bucket_ko']}`",
            f"- tone: `{row['tone']}`",
            f"- cg_path: `{row['cg_path']}`",
            f"- workspace_path: `{row['workspace_path']}`",
            f"- summary: {row['summary_ko']}",
            "- dialogue:",
        ])
        for dialogue in row["dialogue_ko"]:
            lines.append(f"  - {dialogue}")
        lines.extend([
            "- prompt:",
            "",
            "```text",
            row["prompt"],
            "```",
            "",
        ])
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    raise SystemExit(main())
