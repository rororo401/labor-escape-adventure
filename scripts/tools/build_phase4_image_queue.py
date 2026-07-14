#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter
from pathlib import Path
import json
import re
import sys


ROOT = Path(__file__).resolve().parents[2]
SCRIPT_DOC_PATH = ROOT / "docs/gameplay/phase4_new_event_scripts.md"
OUTPUT_PATH = ROOT / "data/game/phase4_image_queue.generated.json"
BATCH_DIR = ROOT / "docs/gameplay/phase4_image_batches"
BATCH_SIZE = 35

SECTION_TO_GROUP = {
    "회사/출근/퇴근 랜덤 사건 신규 80개": "weekday",
    "밤/돌발 신규 60개": "night",
}
GROUP_ORDER = {"weekday": 0, "night": 1}
OUTFIT_BY_GROUP = {
    "weekday": "startup office worker outfit, neat casual office wear suitable for a young Korean office worker",
    "night": "comfortable homewear or casual night outfit matching the late-night scene",
}
SETTING_BY_GROUP = {
    "weekday": "Korean office, commute route, lunch place, or workplace-adjacent life scene matching the event",
    "night": "cozy night-time room, small kitchen, convenience store, or late-night home setting matching the event",
}
STYLE_REFS = [
    "assets/events/weekend/stay_home/clean_room.png",
    "assets/events/weekend/go_out/flower_shop.png",
    "assets/events/weekday/overtime_request.png",
    "assets/events/weekday/mood_low_scroll.png",
    "assets/events/night/snacks/chimaek.png",
    "assets/events/night/rare/lucky_dream.png",
]


def main() -> int:
    if not SCRIPT_DOC_PATH.exists():
        SCRIPT_DOC_PATH.write_text(_source_doc(), encoding="utf-8")
        print(f"Wrote {SCRIPT_DOC_PATH.relative_to(ROOT)}")
    rows = _parse_script_doc(SCRIPT_DOC_PATH.read_text(encoding="utf-8"))
    errors = _validate_rows(rows)
    if errors:
        _print_errors(errors)
        return 1
    queue = [_queue_row(row, index) for index, row in enumerate(rows)]
    queue.sort(key=lambda row: (row["exists"], row["priority"], row["event_id"]))
    payload = {
        "version": 1,
        "note": "Generated image production queue for Phase 4 event CG. Missing assets are sorted first.",
        "source": str(SCRIPT_DOC_PATH.relative_to(ROOT)),
        "counts": {
            "total": len(queue),
            "existing": sum(1 for row in queue if row["exists"]),
            "missing": sum(1 for row in queue if not row["exists"]),
        },
        "queue": queue,
    }
    OUTPUT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    _write_batches(queue)
    print(f"Wrote {OUTPUT_PATH.relative_to(ROOT)}")
    print(f"Wrote {BATCH_DIR.relative_to(ROOT)}")
    print(json.dumps(payload["counts"], ensure_ascii=False, sort_keys=True))
    return 0


def _parse_script_doc(text: str) -> list[dict]:
    rows: list[dict] = []
    current_section = ""
    current: dict | None = None
    dialogue_mode = False
    for line in text.splitlines():
        if line.startswith("## "):
            if current is not None:
                rows.append(current)
                current = None
            current_section = line[3:].strip()
            dialogue_mode = False
            continue
        if current_section not in SECTION_TO_GROUP:
            continue
        if line.startswith("### "):
            if current is not None:
                rows.append(current)
            current = {"section": current_section, "group": SECTION_TO_GROUP[current_section], "title": line[4:].strip(), "dialogue": []}
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


def _validate_rows(rows: list[dict]) -> list[str]:
    errors: list[str] = []
    counts = Counter(row.get("group", "") for row in rows)
    if counts.get("weekday", 0) != 80:
        errors.append(f"weekday count should be 80, got {counts.get('weekday', 0)}")
    if counts.get("night", 0) != 60:
        errors.append(f"night count should be 60, got {counts.get('night', 0)}")
    for field in ["id", "tags", "rarity", "cooldown_days", "conditions", "cg_path", "effects", "image_prompt"]:
        missing = [row.get("title", "<unknown>") for row in rows if not row.get(field)]
        if missing:
            errors.append(f"missing {field}: {missing[:5]}")
    for duplicate in _duplicates([row.get("id", "") for row in rows]):
        errors.append(f"duplicate id: {duplicate}")
    for duplicate in _duplicates([row.get("cg_path", "") for row in rows]):
        errors.append(f"duplicate cg_path: {duplicate}")
    return errors


def _duplicates(values: list[str]) -> list[str]:
    counts = Counter(values)
    return [value for value, count in counts.items() if value and count > 1]


def _print_errors(errors: list[str]) -> None:
    for error in errors:
        print(error, file=sys.stderr)


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
    return [tag.strip().strip('"').strip("'").strip("`") for tag in tags.split(",") if tag.strip()]


def _priority(group: str, exists: bool, index: int) -> int:
    if exists:
        return 9000 + index
    return GROUP_ORDER.get(group, 9) * 1000 + index


def _prompt_for(row: dict) -> str:
    group = str(row.get("group", ""))
    return "\n".join([
        "Use case: illustration-story",
        "Asset type: vertical mobile game event CG for a Korean visual-novel life/stock simulation game",
        f"Primary request: {row.get('image_prompt', '')}",
        "Subject: the established cute chibi-style female protagonist from the project character sheet, expressive and clearly performing the event action",
        f"Outfit: {OUTFIT_BY_GROUP.get(group, 'consistent protagonist outfit')}",
        f"Scene/backdrop: {SETTING_BY_GROUP.get(group, 'setting matching the event')}",
        "Style/medium: polished cute 2D anime/chibi event illustration, warm Korean/Japanese casual game mood, clean line art, soft shading",
        "Composition/framing: 720x1280 vertical smartphone composition, complete finished illustration from top to bottom, protagonist and key action clearly readable, balanced foreground and background details",
        "Lighting/mood: cozy, readable, emotionally specific to the event",
        "Required finish: the full image must stand alone as a complete CG that also works in a gallery view.",
        "Constraints: no UI, no speech bubbles, no captions, no in-image text, no logos, no watermark; do not crop the protagonist's face or key action; keep the character design consistent across all event CG",
        "Avoid: blurred lower area, fade-out bottom, empty dialogue-box reservation area, board-game-card style vignette, photorealism, harsh horror mood, cluttered unreadable backgrounds, extra main characters unless the event explicitly requires social context",
        "Batch-specific reinforcement: full completed gallery-quality image, no blurred bottom, no fade-out bottom, no empty dialogue UI space, no readable text or logos.",
    ])


def _write_batches(queue: list[dict]) -> None:
    BATCH_DIR.mkdir(parents=True, exist_ok=True)
    readme_lines = [
        "# Phase 4 Image Batches",
        "",
        "Phase 4 신규 140개 이벤트 CG를 35장씩 4개 배치로 나눈 작업 문서다.",
        "",
        "| 배치 | 범위 | 장수 | 문서 |",
        "|---:|---|---:|---|",
    ]
    for batch_index, start in enumerate(range(0, len(queue), BATCH_SIZE), start=1):
        rows = queue[start:start + BATCH_SIZE]
        filename = f"phase4_image_batch_{batch_index:02d}.md"
        (BATCH_DIR / filename).write_text(_batch_doc(batch_index, rows), encoding="utf-8")
        readme_lines.append(f"| {batch_index:02d} | `{rows[0]['event_id']}` - `{rows[-1]['event_id']}` | {len(rows)} | `{filename}` |")
    (BATCH_DIR / "README.md").write_text("\n".join(readme_lines) + "\n", encoding="utf-8")


def _batch_doc(batch_index: int, rows: list[dict]) -> str:
    ids = [row["event_id"] for row in rows]
    counts = Counter(row["group"] for row in rows)
    id_set = "\n".join(f"    {event_id!r}," for event_id in ids)
    event_blocks = "\n\n".join(_event_block(index, row) for index, row in enumerate(rows, start=1))
    style_refs = "\n".join(f"- `{path}`" for path in STYLE_REFS)
    group_lines = "\n".join(f"- {group}: {count}장" for group, count in sorted(counts.items()))
    return f"""# Phase 4 Image Batch {batch_index:02d}: {ids[0]} to {ids[-1]}

## 다른 세션에 붙여넣을 작업 프롬프트

아래 문서의 35개 이벤트 이미지만 생성해줘.

- 작업 루트: `<PROJECT_ROOT>`
- 배치 문서: `docs/gameplay/phase4_image_batches/phase4_image_batch_{batch_index:02d}.md`
- 이 배치 범위: `{ids[0]}`부터 `{ids[-1]}`까지 {len(rows)}장
- 목적: `data/game/phase4_image_queue.generated.json` 기준 Phase 4 이벤트 CG 생성
- 생성 방식: Codex 기본 `image_gen` 내장 도구 사용
- 저장 방식: 생성 원본은 `$HOME/.codex/generated_images/...`에 남기고, 선택한 결과를 각 이벤트의 `workspace_path`로 복사
- 리사이즈: 저장 후 반드시 `sips -z 1280 720 <workspace_path>`로 720x1280 맞추기
- 큐 갱신: 저장 후 `python3 scripts/tools/build_phase4_image_queue.py` 실행

중요 품질 규칙:
- 기존 1차/2차/3차 이벤트 CG와 같은 치비풍 2D 모바일 VN 이벤트 CG 품질을 유지한다.
- 하단을 흐리게 뭉개거나 페이드아웃하지 않는다.
- 대화창용 빈 공간을 만들지 않는다.
- 이미지 자체가 갤러리에서 단독으로 봐도 완성된 그림이어야 한다.
- UI, 말풍선, 캡션, 워터마크, 로고, 읽을 수 있는 글자/숫자를 피한다.
- 패키지/간판/서류/폰/노트북 화면은 추상 도형, 빈 라벨, 색 블록으로 처리한다.
- 중요한 얼굴과 행동을 자르지 않는다.
- 이미 존재하는 파일은 덮어쓰지 말고, 이 배치의 TODO 중 없는 파일만 생성한다.

병렬 작업 주의:
- 여러 세션이 동시에 `data/game/phase4_image_queue.generated.json`을 갱신할 수 있다.
- 실제 결과물은 각 `workspace_path`의 PNG 파일이다.
- 큐 파일은 파일 존재 여부를 다시 읽어 생성되므로, 모든 세션이 끝난 뒤 한 번 더 `python3 scripts/tools/build_phase4_image_queue.py`를 실행하면 된다.

## 반드시 참조할 파일

- `docs/gameplay/phase4_new_event_scripts.md`
- `data/game/phase4_image_queue.generated.json`
- `scripts/tools/build_phase4_image_queue.py`

## 스타일 참조 이미지

{style_refs}

## 이 배치 구성

- 총 {len(rows)}장
{group_lines}

## 저장/검증 명령

생성 1장마다 아래 흐름을 반복한다.

```bash
mkdir -p "$(dirname "<workspace_path>")"
latest=$(find "$HOME/.codex/generated_images" -type f -name '*.png' -mmin -10 -print0 | xargs -0 ls -t | head -1)
cp "$latest" <workspace_path>
sips -z 1280 720 <workspace_path> >/dev/null
sips -g pixelWidth -g pixelHeight <workspace_path>
python3 scripts/tools/build_phase4_image_queue.py
```

배치 완료 후 검증한다.

```bash
python3 scripts/tools/build_phase4_image_queue.py
python3 - <<'PYCHECK'
import json, subprocess
from pathlib import Path
queue=json.loads(Path('data/game/phase4_image_queue.generated.json').read_text())['queue']
ids = {{
{id_set}
}}
errors=[]
checked=0
for row in queue:
    if row['event_id'] not in ids:
        continue
    checked += 1
    path=Path(row['workspace_path'])
    if not path.exists():
        errors.append(f"missing file: {{row['event_id']}} {{path}}")
        continue
    out=subprocess.check_output(['sips','-g','pixelWidth','-g','pixelHeight',str(path)], text=True, stderr=subprocess.DEVNULL)
    width=height=None
    for line in out.splitlines():
        if 'pixelWidth:' in line: width=int(line.rsplit(':',1)[1].strip())
        if 'pixelHeight:' in line: height=int(line.rsplit(':',1)[1].strip())
    if (width,height)!=(720,1280):
        errors.append(f"bad size: {{row['event_id']}} {{width}}x{{height}}")
if checked != len(ids):
    errors.append(f"checked count mismatch: {{checked}}/{{len(ids)}}")
print('checked', checked, 'errors', errors)
if errors:
    raise SystemExit(1)
PYCHECK
```

## 이벤트별 생성 프롬프트

{event_blocks}
"""


def _event_block(index: int, row: dict) -> str:
    tags = ", ".join(row["tags"])
    status = "EXISTS" if row["exists"] else "TODO"
    return f"""### {index}. {row['event_id']}
- name_ko: {row['name_ko']}
- group: {row['group']}
- category_id: {row['category_id']}
- tags: {tags}
- cg_path: `{row['cg_path']}`
- workspace_path: `{row['workspace_path']}`
- status: {status}

```text
{row['prompt']}
```"""


def _source_doc() -> str:
    lines = [
        "# 4차 신규 이벤트 원고",
        "",
        "이 문서는 4차 목표인 신규 140개 이벤트의 원고와 효과값을 작성하는 작업 파일이다. 이미지 생성 세션은 이 문서와 `data/game/phase4_image_queue.generated.json`을 기준으로 작업한다.",
        "",
        "현재 작성 범위:",
        "",
        "| 묶음 | 신규 목표 | 작성 완료 |",
        "|---|---:|---:|",
        "| 회사/출근/퇴근 랜덤 사건 | 80 | 80 |",
        "| 밤/돌발 | 60 | 60 |",
        "| 합계 | 140 | 140 |",
        "",
        "## 작성 형식",
        "",
        "- `effects`의 현금은 고정값이다.",
        "- `health_delta`, `mood_delta`, `fatigue_delta`는 범위 랜덤값이다.",
        "- 모든 이벤트는 이벤트 CG 1장을 전제로 한다.",
        "- 대사는 최소 4줄을 기준으로 한다.",
        "- 4차는 주말/집외출 이벤트를 늘리지 않고 회사/출근/퇴근 랜덤 사건과 밤/돌발만 보강한다.",
        "",
        _section_doc("회사/출근/퇴근 랜덤 사건 신규 80개", WEEKDAY_EVENTS),
        "",
        _section_doc("밤/돌발 신규 60개", NIGHT_EVENTS),
        "",
    ]
    return "\n".join(lines)


def _section_doc(title: str, events: list[dict]) -> str:
    parts = [f"## {title}"]
    for event in events:
        parts.append(_event_source(event))
    return "\n\n".join(parts)


def _event_source(event: dict) -> str:
    group = event["group"]
    effects = _effects_for(event)
    prompt = _image_prompt(event)
    dialogue = _dialogue_for(event)
    return f"""### {event['name']}

- id: `{event['id']}`
- group: `{group}`
- category_id: ``
- tags: {', '.join(f'`{tag}`' for tag in event['tags'])}
- rarity: `{event['rarity']}`
- cooldown_days: {event['cooldown']}
- conditions: {event['conditions']}
- cg_path: `{event['cg_path']}`
- effects: `cash_delta: {effects['cash_delta']}, health_delta: {effects['health_delta']}, mood_delta: {effects['mood_delta']}, fatigue_delta: {effects['fatigue_delta']}`
- image_prompt: {prompt}

대사:
1. {dialogue[0]}
2. {dialogue[1]}
3. {dialogue[2]}
4. {dialogue[3]}"""


def _effects_for(event: dict) -> dict:
    tags = set(event["tags"])
    if "commute" in tags:
        return {"cash_delta": -3000 if "money" in tags else 0, "health_delta": "[-2, 2]", "mood_delta": "[-8, 4]", "fatigue_delta": "[4, 16]"}
    if "stress" in tags or "trouble" in tags or "mistake" in tags:
        return {"cash_delta": -5000 if "money" in tags else 0, "health_delta": "[-4, 0]", "mood_delta": "[-18, -4]", "fatigue_delta": "[8, 24]"}
    if "money" in tags:
        return {"cash_delta": -12000, "health_delta": "[-1, 2]", "mood_delta": "[-8, 8]", "fatigue_delta": "[2, 12]"}
    if "recovery" in tags:
        return {"cash_delta": 0, "health_delta": "[2, 8]", "mood_delta": "[4, 12]", "fatigue_delta": "[-16, -4]"}
    if "food" in tags:
        return {"cash_delta": -9000, "health_delta": "[-2, 4]", "mood_delta": "[4, 14]", "fatigue_delta": "[0, 10]"}
    if "rare" in tags or "luck" in tags:
        return {"cash_delta": 10000, "health_delta": "[0, 4]", "mood_delta": "[10, 22]", "fatigue_delta": "[-6, 4]"}
    return {"cash_delta": 0, "health_delta": "[-1, 3]", "mood_delta": "[-4, 10]", "fatigue_delta": "[2, 14]"}


def _image_prompt(event: dict) -> str:
    prefix = "사무직 출근복 차림의 주인공이" if event["group"] == "weekday" else "편한 홈웨어 차림의 주인공이"
    setting = "출근길, 사무실, 회사 주변, 점심 장소 등 평일 생활 공간" if event["group"] == "weekday" else "밤의 방, 작은 주방, 침대 주변, 편의점 등 하루 마감 분위기의 공간"
    return f"{prefix} {event['brief']} 장면을 중심으로 행동하는 720x1280 세로형 모바일 게임 이벤트 CG, {setting}, 완성된 치비풍 2D 일러스트, 깨끗한 선화와 부드러운 채색, 하단 25퍼센트도 흐리게 뭉개지지 않은 완성 이미지, UI/말풍선/글자/로고/워터마크 없음"


def _dialogue_for(event: dict) -> list[str]:
    if event["group"] == "weekday":
        return [
            f"출근일의 틈에서 '{event['name']}' 일이 생겼다.",
            f"{event['brief']} 순간, 평소와 같은 하루가 조금 다른 표정으로 굴러갔다.",
            "큰 사건은 아니어도 회사 생활은 이런 작은 변수들이 모여 하루의 온도를 바꾼다.",
            "퇴근 무렵에는 피곤함과 함께 오늘을 지나왔다는 실감이 남았다.",
        ]
    return [
        f"하루를 마치려던 밤, '{event['name']}' 일이 생겼다.",
        f"{event['brief']} 장면이 조용한 방 안의 분위기를 바꿨다.",
        "낮에는 별일 아닌 것처럼 넘겼던 마음이 밤에는 조금 더 선명해졌다.",
        "잠들기 전의 작은 선택 하나가 내일 아침 컨디션까지 데리고 갈 것 같았다.",
    ]


WEEKDAY_EVENTS = [
    {"id": "weekday_subway_door_delay", "name": "지하철 문 앞 정체", "group": "weekday", "tags": ["commute", "stress"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "지하철 문 앞에서 사람들이 엉켜 한 정거장을 더 긴장하며 버티는", "cg_path": "res://assets/events/weekday/phase4/weekday_subway_door_delay.png"},
    {"id": "weekday_bus_missed_by_step", "name": "한 걸음 차이 버스", "group": "weekday", "tags": ["commute", "fatigue"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "눈앞에서 버스 문이 닫히고 손목시계를 보는", "cg_path": "res://assets/events/weekday/phase4/weekday_bus_missed_by_step.png"},
    {"id": "weekday_umbrella_left_train", "name": "전철에 두고 온 우산", "group": "weekday", "tags": ["commute", "rainy", "money"], "rarity": "uncommon", "cooldown": 90, "conditions": "비 오는 출근일", "brief": "전철 좌석 옆에 우산을 두고 내린 사실을 뒤늦게 깨닫는", "cg_path": "res://assets/events/weekday/phase4/weekday_umbrella_left_train.png"},
    {"id": "weekday_crosswalk_sprint", "name": "횡단보도 전력질주", "group": "weekday", "tags": ["commute", "health"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "초록불이 깜빡이는 횡단보도 앞에서 가방을 붙잡고 뛰는", "cg_path": "res://assets/events/weekday/phase4/weekday_crosswalk_sprint.png"},
    {"id": "weekday_taxi_temptation_morning", "name": "아침 택시 유혹", "group": "weekday", "tags": ["commute", "money"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "지각 직전 택시 호출 화면 앞에서 손가락을 멈추는", "cg_path": "res://assets/events/weekday/phase4/weekday_taxi_temptation_morning.png"},
    {"id": "weekday_convenience_breakfast", "name": "편의점 아침", "group": "weekday", "tags": ["food", "commute", "money"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "편의점에서 삼각김밥과 작은 음료를 들고 계산대를 기다리는", "cg_path": "res://assets/events/weekday/phase4/weekday_convenience_breakfast.png"},
    {"id": "weekday_elevator_line", "name": "엘리베이터 긴 줄", "group": "weekday", "tags": ["commute", "office"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "회사 로비 엘리베이터 앞 긴 줄에서 출근 시간을 확인하는", "cg_path": "res://assets/events/weekday/phase4/weekday_elevator_line.png"},
    {"id": "weekday_badge_forgotten", "name": "사원증 깜빡함", "group": "weekday", "tags": ["office", "mistake"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "회사 출입구 앞에서 가방을 뒤지며 사원증을 찾는", "cg_path": "res://assets/events/weekday/phase4/weekday_badge_forgotten.png"},
    {"id": "weekday_lobby_security_wait", "name": "보안 게이트 대기", "group": "weekday", "tags": ["office", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "보안 게이트 앞에서 방문객 줄과 직원 줄 사이에 서 있는", "cg_path": "res://assets/events/weekday/phase4/weekday_lobby_security_wait.png"},
    {"id": "weekday_morning_aircon_cold", "name": "아침 사무실 냉방", "group": "weekday", "tags": ["office", "health", "seasonal"], "rarity": "uncommon", "cooldown": 90, "conditions": "여름 출근일", "brief": "차가운 사무실 책상에서 가디건을 여미며 키보드를 보는", "cg_path": "res://assets/events/weekday/phase4/weekday_morning_aircon_cold.png"},
    {"id": "weekday_heater_dry_eye", "name": "난방에 건조한 눈", "group": "weekday", "tags": ["office", "health", "seasonal"], "rarity": "uncommon", "cooldown": 90, "conditions": "겨울 출근일", "brief": "따뜻하지만 건조한 사무실에서 인공눈물 병을 찾는", "cg_path": "res://assets/events/weekday/phase4/weekday_heater_dry_eye.png"},
    {"id": "weekday_morning_mail_overflow", "name": "아침 메일 폭주", "group": "weekday", "tags": ["work", "stress"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "노트북 메일함의 많은 알림을 보고 커피를 내려놓는", "cg_path": "res://assets/events/weekday/phase4/weekday_morning_mail_overflow.png"},
    {"id": "weekday_inbox_zero_attempt", "name": "메일함 비우기 시도", "group": "weekday", "tags": ["work", "routine"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "메일함을 정리하려고 체크박스를 하나씩 누르는", "cg_path": "res://assets/events/weekday/phase4/weekday_inbox_zero_attempt.png"},
    {"id": "weekday_calendar_invite_burst", "name": "회의 초대 연속 알림", "group": "weekday", "tags": ["work", "stress"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "캘린더 알림이 연달아 뜨자 의자에 살짝 기대는", "cg_path": "res://assets/events/weekday/phase4/weekday_calendar_invite_burst.png"},
    {"id": "weekday_meeting_room_hunt", "name": "회의실 찾아 삼만리", "group": "weekday", "tags": ["work", "office"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "복도에서 회의실 이름표들을 확인하며 헤매는", "cg_path": "res://assets/events/weekday/phase4/weekday_meeting_room_hunt.png"},
    {"id": "weekday_projector_cable_missing", "name": "프로젝터 케이블 실종", "group": "weekday", "tags": ["work", "trouble"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "회의실 테이블 아래에서 연결 케이블을 찾는", "cg_path": "res://assets/events/weekday/phase4/weekday_projector_cable_missing.png"},
    {"id": "weekday_minutes_taken", "name": "회의록 담당", "group": "weekday", "tags": ["work", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "회의실 한쪽에서 노트북으로 회의 내용을 빠르게 적는", "cg_path": "res://assets/events/weekday/phase4/weekday_minutes_taken.png"},
    {"id": "weekday_action_items_stack", "name": "할 일 목록 증가", "group": "weekday", "tags": ["work", "stress"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "포스트잇과 업무 목록이 늘어난 모니터 앞에서 숨을 고르는", "cg_path": "res://assets/events/weekday/phase4/weekday_action_items_stack.png"},
    {"id": "weekday_report_last_table", "name": "보고서 마지막 표", "group": "weekday", "tags": ["work", "fatigue"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "보고서의 마지막 표를 맞추며 숫자 칸을 확인하는", "cg_path": "res://assets/events/weekday/phase4/weekday_report_last_table.png"},
    {"id": "weekday_spreadsheet_filter_lost", "name": "엑셀 필터 미아", "group": "weekday", "tags": ["work", "mistake"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "스프레드시트 필터를 잘못 눌러 화면 앞에서 당황하는", "cg_path": "res://assets/events/weekday/phase4/weekday_spreadsheet_filter_lost.png"},
    {"id": "weekday_pdf_export_fail", "name": "PDF 내보내기 실패", "group": "weekday", "tags": ["work", "trouble"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "PDF 저장 창 앞에서 오류 느낌의 빈 알림을 보고 멈칫하는", "cg_path": "res://assets/events/weekday/phase4/weekday_pdf_export_fail.png"},
    {"id": "weekday_printer_paper_refill", "name": "복사용지 보충", "group": "weekday", "tags": ["office", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "프린터 옆에서 복사용지 묶음을 들고 서 있는", "cg_path": "res://assets/events/weekday/phase4/weekday_printer_paper_refill.png"},
    {"id": "weekday_toner_on_sleeve", "name": "소매에 묻은 토너", "group": "weekday", "tags": ["office", "trouble"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "소매에 묻은 검은 얼룩을 보고 난감해하는", "cg_path": "res://assets/events/weekday/phase4/weekday_toner_on_sleeve.png"},
    {"id": "weekday_shared_desk_clean", "name": "공용 책상 정리", "group": "weekday", "tags": ["office", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "공용 책상 위 케이블과 컵을 가지런히 정리하는", "cg_path": "res://assets/events/weekday/phase4/weekday_shared_desk_clean.png"},
    {"id": "weekday_sticky_note_reminder", "name": "모니터 포스트잇", "group": "weekday", "tags": ["work", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "모니터 옆 포스트잇을 떼어 작은 노트에 옮겨 적는", "cg_path": "res://assets/events/weekday/phase4/weekday_sticky_note_reminder.png"},
    {"id": "weekday_boss_quick_question", "name": "상사의 짧은 질문", "group": "weekday", "tags": ["work", "stress"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "상사가 책상 옆에 서자 급히 화면을 돌려보는", "cg_path": "res://assets/events/weekday/phase4/weekday_boss_quick_question.png"},
    {"id": "weekday_manager_good_timing", "name": "상사의 좋은 타이밍", "group": "weekday", "tags": ["work", "recovery"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "상사가 가볍게 엄지를 들어 보이고 주인공이 안도하는", "cg_path": "res://assets/events/weekday/phase4/weekday_manager_good_timing.png"},
    {"id": "weekday_peer_code_review", "name": "동료의 꼼꼼한 리뷰", "group": "weekday", "tags": ["work", "social"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "동료와 나란히 모니터를 보며 수정 지점을 짚는", "cg_path": "res://assets/events/weekday/phase4/weekday_peer_code_review.png"},
    {"id": "weekday_junior_thank_you", "name": "후배의 고맙다는 말", "group": "weekday", "tags": ["work", "social", "recovery"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "후배가 작은 메모와 함께 고맙다는 인사를 건네는", "cg_path": "res://assets/events/weekday/phase4/weekday_junior_thank_you.png"},
    {"id": "weekday_team_chat_silence", "name": "팀 채팅의 정적", "group": "weekday", "tags": ["work", "stress"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "팀 채팅창을 보며 답장을 기다리는", "cg_path": "res://assets/events/weekday/phase4/weekday_team_chat_silence.png"},
    {"id": "weekday_group_lunch_pressure", "name": "단체 점심 압박", "group": "weekday", "tags": ["lunch", "social", "money"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "팀원들 사이에서 점심 장소를 따라가며 지갑을 떠올리는", "cg_path": "res://assets/events/weekday/phase4/weekday_group_lunch_pressure.png"},
    {"id": "weekday_lunchbox_leak", "name": "도시락 국물 샘", "group": "weekday", "tags": ["lunch", "trouble", "food"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "도시락 가방 안쪽을 보고 휴지로 급히 닦는", "cg_path": "res://assets/events/weekday/phase4/weekday_lunchbox_leak.png"},
    {"id": "weekday_solo_lunch_window", "name": "창가 혼밥", "group": "weekday", "tags": ["lunch", "calm", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "식당 창가 자리에서 조용히 혼자 점심을 먹는", "cg_path": "res://assets/events/weekday/phase4/weekday_solo_lunch_window.png"},
    {"id": "weekday_cafeteria_new_menu", "name": "구내식당 신메뉴", "group": "weekday", "tags": ["lunch", "food", "mood"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "구내식당 배식대 앞에서 새 메뉴 접시를 받아드는", "cg_path": "res://assets/events/weekday/phase4/weekday_cafeteria_new_menu.png"},
    {"id": "weekday_coffee_coupon_used", "name": "커피 쿠폰 사용", "group": "weekday", "tags": ["coffee", "money", "mood"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "카페 계산대에서 모아둔 쿠폰으로 커피를 받는", "cg_path": "res://assets/events/weekday/phase4/weekday_coffee_coupon_used.png"},
    {"id": "weekday_second_coffee_regret", "name": "두 번째 커피 후회", "group": "weekday", "tags": ["coffee", "money", "stress"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "두 번째 커피잔을 들고 카드 알림을 바라보는", "cg_path": "res://assets/events/weekday/phase4/weekday_second_coffee_regret.png"},
    {"id": "weekday_vending_cheap_win", "name": "자판기 작은 승리", "group": "weekday", "tags": ["money", "mood"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "자판기에서 저렴한 음료를 뽑고 작게 만족하는", "cg_path": "res://assets/events/weekday/phase4/weekday_vending_cheap_win.png"},
    {"id": "weekday_snack_drawer_empty", "name": "비어 있는 간식 서랍", "group": "weekday", "tags": ["food", "mood"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "책상 서랍을 열었지만 간식이 없어 멈칫하는", "cg_path": "res://assets/events/weekday/phase4/weekday_snack_drawer_empty.png"},
    {"id": "weekday_colleague_snack_share", "name": "동료의 간식 나눔", "group": "weekday", "tags": ["food", "social", "recovery"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "동료가 작은 간식을 건네고 주인공이 웃는", "cg_path": "res://assets/events/weekday/phase4/weekday_colleague_snack_share.png"},
    {"id": "weekday_water_bottle_spill", "name": "텀블러 물 쏟음", "group": "weekday", "tags": ["office", "trouble"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "책상 위 텀블러가 넘어져 휴지로 급히 닦는", "cg_path": "res://assets/events/weekday/phase4/weekday_water_bottle_spill.png"},
    {"id": "weekday_phone_battery_office", "name": "회사에서 배터리 부족", "group": "weekday", "tags": ["office", "trouble"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "책상 아래 콘센트 근처에서 충전기를 찾는", "cg_path": "res://assets/events/weekday/phase4/weekday_phone_battery_office.png"},
    {"id": "weekday_charger_borrowed", "name": "충전기 빌리기", "group": "weekday", "tags": ["office", "social"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "동료에게 충전 케이블을 조심스럽게 빌리는", "cg_path": "res://assets/events/weekday/phase4/weekday_charger_borrowed.png"},
    {"id": "weekday_office_wifi_drop", "name": "사무실 와이파이 끊김", "group": "weekday", "tags": ["office", "trouble"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "노트북 연결 아이콘을 보며 회의 직전 당황하는", "cg_path": "res://assets/events/weekday/phase4/weekday_office_wifi_drop.png"},
    {"id": "weekday_vpn_login_loop", "name": "VPN 로그인 반복", "group": "weekday", "tags": ["work", "trouble"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "보안 로그인 화면 앞에서 인증 알림을 기다리는", "cg_path": "res://assets/events/weekday/phase4/weekday_vpn_login_loop.png"},
    {"id": "weekday_security_update_wait", "name": "보안 업데이트 대기", "group": "weekday", "tags": ["work", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "업데이트 진행 화면 앞에서 커피잔을 들고 기다리는", "cg_path": "res://assets/events/weekday/phase4/weekday_security_update_wait.png"},
    {"id": "weekday_file_share_permission", "name": "파일 권한 요청", "group": "weekday", "tags": ["work", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "공유 문서 권한 요청 화면을 보며 담당자에게 메시지를 보내는", "cg_path": "res://assets/events/weekday/phase4/weekday_file_share_permission.png"},
    {"id": "weekday_wrong_channel_message", "name": "잘못 보낸 채팅", "group": "weekday", "tags": ["work", "mistake"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일", "brief": "메신저 채널을 잘못 고른 걸 깨닫고 얼굴이 굳는", "cg_path": "res://assets/events/weekday/phase4/weekday_wrong_channel_message.png"},
    {"id": "weekday_polite_followup", "name": "정중한 재촉 메일", "group": "weekday", "tags": ["work", "stress"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "정중하지만 급한 느낌의 메일을 읽고 답장을 쓰는", "cg_path": "res://assets/events/weekday/phase4/weekday_polite_followup.png"},
    {"id": "weekday_client_small_thanks", "name": "거래처의 작은 감사", "group": "weekday", "tags": ["work", "recovery"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "거래처 감사 메시지를 보고 조용히 안도하는", "cg_path": "res://assets/events/weekday/phase4/weekday_client_small_thanks.png"},
    {"id": "weekday_customer_urgent_call", "name": "급한 고객 전화", "group": "weekday", "tags": ["work", "stress"], "rarity": "common", "cooldown": 45, "conditions": "출근일", "brief": "울리는 전화기를 보며 메모장을 급히 펼치는", "cg_path": "res://assets/events/weekday/phase4/weekday_customer_urgent_call.png"},
    {"id": "weekday_deadline_moved_up", "name": "앞당겨진 마감", "group": "weekday", "tags": ["work", "stress"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "마감 일정이 당겨졌다는 공지를 보고 달력을 다시 보는", "cg_path": "res://assets/events/weekday/phase4/weekday_deadline_moved_up.png"},
    {"id": "weekday_deadline_moved_back", "name": "미뤄진 마감", "group": "weekday", "tags": ["work", "recovery"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "마감이 미뤄졌다는 알림을 보고 의자에 기대는", "cg_path": "res://assets/events/weekday/phase4/weekday_deadline_moved_back.png"},
    {"id": "weekday_task_done_early", "name": "생각보다 빨리 끝난 일", "group": "weekday", "tags": ["work", "mood"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "예상보다 빨리 끝난 업무 파일을 저장하고 미소 짓는", "cg_path": "res://assets/events/weekday/phase4/weekday_task_done_early.png"},
    {"id": "weekday_task_reopened", "name": "다시 열린 업무", "group": "weekday", "tags": ["work", "stress"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "완료했다고 생각한 업무가 다시 돌아온 화면을 보는", "cg_path": "res://assets/events/weekday/phase4/weekday_task_reopened.png"},
    {"id": "weekday_quiet_afternoon", "name": "드문 조용한 오후", "group": "weekday", "tags": ["office", "calm", "recovery"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일", "brief": "조용한 오후 사무실에서 창밖 빛을 잠깐 보는", "cg_path": "res://assets/events/weekday/phase4/weekday_quiet_afternoon.png"},
    {"id": "weekday_noisy_keyboard", "name": "시끄러운 키보드", "group": "weekday", "tags": ["office", "stress"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "옆자리 키보드 소리에 살짝 집중이 흐트러지는", "cg_path": "res://assets/events/weekday/phase4/weekday_noisy_keyboard.png"},
    {"id": "weekday_office_window_rain", "name": "창밖 장대비", "group": "weekday", "tags": ["rainy", "office", "mood"], "rarity": "uncommon", "cooldown": 90, "conditions": "비 오는 출근일", "brief": "사무실 창밖 장대비를 보며 퇴근길을 걱정하는", "cg_path": "res://assets/events/weekday/phase4/weekday_office_window_rain.png"},
    {"id": "weekday_sunny_window_glare", "name": "눈부신 창가 자리", "group": "weekday", "tags": ["office", "seasonal"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "창가 자리 햇빛에 모니터 각도를 조절하는", "cg_path": "res://assets/events/weekday/phase4/weekday_sunny_window_glare.png"},
    {"id": "weekday_desk_plant_new_leaf", "name": "책상 화분 새잎", "group": "weekday", "tags": ["office", "recovery"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일", "brief": "책상 위 작은 화분의 새잎을 발견하고 물을 주는", "cg_path": "res://assets/events/weekday/phase4/weekday_desk_plant_new_leaf.png"},
    {"id": "weekday_chair_height_fix", "name": "의자 높이 조절", "group": "weekday", "tags": ["office", "health"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "책상 앞에서 의자 높이를 다시 맞춰 앉는", "cg_path": "res://assets/events/weekday/phase4/weekday_chair_height_fix.png"},
    {"id": "weekday_wrist_stretch", "name": "손목 스트레칭", "group": "weekday", "tags": ["health", "work", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "키보드 앞에서 손목을 천천히 돌리며 쉬는", "cg_path": "res://assets/events/weekday/phase4/weekday_wrist_stretch.png"},
    {"id": "weekday_stairs_health_choice", "name": "계단 선택", "group": "weekday", "tags": ["health", "commute"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "엘리베이터 대신 계단 앞에서 작게 마음을 다잡는", "cg_path": "res://assets/events/weekday/phase4/weekday_stairs_health_choice.png"},
    {"id": "weekday_after_lunch_walk", "name": "점심 뒤 짧은 산책", "group": "weekday", "tags": ["health", "lunch", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "점심 뒤 회사 근처 보도블록을 천천히 걷는", "cg_path": "res://assets/events/weekday/phase4/weekday_after_lunch_walk.png"},
    {"id": "weekday_pharmacy_detour", "name": "퇴근길 약국", "group": "weekday", "tags": ["health", "commute", "money"], "rarity": "uncommon", "cooldown": 120, "conditions": "건강 낮음", "brief": "퇴근길 약국 앞에서 작은 약봉투를 받아드는", "cg_path": "res://assets/events/weekday/phase4/weekday_pharmacy_detour.png"},
    {"id": "weekday_eye_drop_purchase", "name": "인공눈물 구매", "group": "weekday", "tags": ["health", "money"], "rarity": "common", "cooldown": 90, "conditions": "출근일", "brief": "약국 진열대 앞에서 인공눈물 작은 상자를 고르는", "cg_path": "res://assets/events/weekday/phase4/weekday_eye_drop_purchase.png"},
    {"id": "weekday_payday_budget_note", "name": "월급날 예산 메모", "group": "weekday", "tags": ["money", "routine"], "rarity": "uncommon", "cooldown": 120, "conditions": "월급일", "brief": "월급 알림 뒤 노트에 월세와 식비를 나눠 적는", "cg_path": "res://assets/events/weekday/phase4/weekday_payday_budget_note.png"},
    {"id": "weekday_card_bill_preview", "name": "카드값 미리보기", "group": "weekday", "tags": ["money", "stress"], "rarity": "common", "cooldown": 90, "conditions": "출근일", "brief": "점심시간에 카드앱 예상 청구액을 확인하는", "cg_path": "res://assets/events/weekday/phase4/weekday_card_bill_preview.png"},
    {"id": "weekday_transport_cost_check", "name": "교통비 확인", "group": "weekday", "tags": ["money", "commute"], "rarity": "common", "cooldown": 90, "conditions": "출근일", "brief": "교통카드 사용 내역을 보며 이번 달 교통비를 계산하는", "cg_path": "res://assets/events/weekday/phase4/weekday_transport_cost_check.png"},
    {"id": "weekday_wedding_envelope_talk", "name": "청첩장 봉투 고민", "group": "weekday", "tags": ["money", "social", "stress"], "rarity": "rare", "cooldown": 180, "conditions": "출근일", "brief": "동료 청첩장을 보고 축의금 봉투를 떠올리는", "cg_path": "res://assets/events/weekday/phase4/weekday_wedding_envelope_talk.png"},
    {"id": "weekday_company_dinner_notice", "name": "회식 공지", "group": "weekday", "tags": ["social", "stress"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일", "brief": "회식 공지를 보며 퇴근 후 시간을 계산하는", "cg_path": "res://assets/events/weekday/phase4/weekday_company_dinner_notice.png"},
    {"id": "weekday_no_dinner_escape", "name": "회식 없는 날", "group": "weekday", "tags": ["social", "recovery"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일", "brief": "오늘은 회식이 없다는 말을 듣고 조용히 안도하는", "cg_path": "res://assets/events/weekday/phase4/weekday_no_dinner_escape.png"},
    {"id": "weekday_friend_text_commute", "name": "퇴근길 친구 문자", "group": "weekday", "tags": ["social", "commute", "mood"], "rarity": "common", "cooldown": 90, "conditions": "출근일", "brief": "퇴근길 지하철에서 친구 메시지를 보고 살짝 웃는", "cg_path": "res://assets/events/weekday/phase4/weekday_friend_text_commute.png"},
    {"id": "weekday_parent_call_missed", "name": "부모님 부재중 전화", "group": "weekday", "tags": ["social", "stress"], "rarity": "common", "cooldown": 90, "conditions": "출근일", "brief": "업무 중 놓친 가족 전화를 보고 잠깐 고민하는", "cg_path": "res://assets/events/weekday/phase4/weekday_parent_call_missed.png"},
    {"id": "weekday_grocery_after_work", "name": "퇴근길 장보기 메모", "group": "weekday", "tags": ["commute", "food", "money"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "퇴근길 마트 앞에서 장보기 메모를 확인하는", "cg_path": "res://assets/events/weekday/phase4/weekday_grocery_after_work.png"},
    {"id": "weekday_parcel_after_work", "name": "퇴근길 택배 픽업", "group": "weekday", "tags": ["commute", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "무인택배함 앞에서 작은 상자를 꺼내는", "cg_path": "res://assets/events/weekday/phase4/weekday_parcel_after_work.png"},
    {"id": "weekday_dry_cleaning_ticket", "name": "세탁소 맡긴 옷", "group": "weekday", "tags": ["commute", "money", "routine"], "rarity": "common", "cooldown": 90, "conditions": "출근일", "brief": "퇴근길 세탁소 앞에서 맡긴 옷 표를 꺼내는", "cg_path": "res://assets/events/weekday/phase4/weekday_dry_cleaning_ticket.png"},
    {"id": "weekday_late_train_seat", "name": "늦은 지하철 빈자리", "group": "weekday", "tags": ["commute", "recovery"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일", "brief": "늦은 퇴근길 지하철 빈자리에 앉아 깊게 숨을 쉬는", "cg_path": "res://assets/events/weekday/phase4/weekday_late_train_seat.png"},
    {"id": "weekday_last_email_sent", "name": "마지막 메일 발송", "group": "weekday", "tags": ["work", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일", "brief": "퇴근 전 마지막 메일을 보내고 노트북을 닫는", "cg_path": "res://assets/events/weekday/phase4/weekday_last_email_sent.png"},
    {"id": "weekday_office_light_last", "name": "마지막으로 남은 불빛", "group": "weekday", "tags": ["work", "fatigue"], "rarity": "rare", "cooldown": 180, "conditions": "야근", "brief": "어두운 사무실에서 남은 불빛 아래 가방을 챙기는", "cg_path": "res://assets/events/weekday/phase4/weekday_office_light_last.png"},
    {"id": "weekday_salary_raise_rumor", "name": "연봉 인상 소문", "group": "weekday", "tags": ["money", "career", "mood"], "rarity": "rare", "cooldown": 180, "conditions": "출근일", "brief": "탕비실에서 연봉 인상 소문을 듣고 조심스레 귀를 기울이는", "cg_path": "res://assets/events/weekday/phase4/weekday_salary_raise_rumor.png"},
]


NIGHT_EVENTS = [
    {"id": "night_afterwork_toast", "name": "퇴근 후 토스트", "group": "night", "tags": ["food", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "작은 주방에서 토스트를 굽고 접시에 올리는", "cg_path": "res://assets/events/night/phase4/night_afterwork_toast.png"},
    {"id": "night_leftover_soup", "name": "남은 국 데우기", "group": "night", "tags": ["food", "money"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "작은 냄비에 남은 국을 데우며 김을 바라보는", "cg_path": "res://assets/events/night/phase4/night_leftover_soup.png"},
    {"id": "night_rice_ball_quick", "name": "주먹밥 한 개", "group": "night", "tags": ["food", "money"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "밥과 김을 뭉쳐 작은 주먹밥을 만드는", "cg_path": "res://assets/events/night/phase4/night_rice_ball_quick.png"},
    {"id": "night_microwave_egg", "name": "전자레인지 계란찜", "group": "night", "tags": ["food", "health"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "전자레인지 앞에서 작은 그릇의 계란찜을 기다리는", "cg_path": "res://assets/events/night/phase4/night_microwave_egg.png"},
    {"id": "night_banana_milk", "name": "바나나우유", "group": "night", "tags": ["drink", "mood"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "침대 옆에서 작은 바나나우유를 마시며 쉬는", "cg_path": "res://assets/events/night/phase4/night_banana_milk.png"},
    {"id": "night_sparkling_water", "name": "탄산수 한 캔", "group": "night", "tags": ["drink", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "냉장고 앞에서 탄산수 캔을 따고 한숨 돌리는", "cg_path": "res://assets/events/night/phase4/night_sparkling_water.png"},
    {"id": "night_cereal_bowl", "name": "시리얼 한 그릇", "group": "night", "tags": ["food", "convenience"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "밤에 작은 그릇에 시리얼과 우유를 붓는", "cg_path": "res://assets/events/night/phase4/night_cereal_bowl.png"},
    {"id": "night_canned_tuna_rice", "name": "참치캔 비빔밥", "group": "night", "tags": ["food", "korean"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "참치캔과 밥을 꺼내 간단히 비벼 먹는", "cg_path": "res://assets/events/night/phase4/night_canned_tuna_rice.png"},
    {"id": "night_frozen_pizza_slice", "name": "냉동 피자 한 조각", "group": "night", "tags": ["food", "mood"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "에어프라이어 앞에서 냉동 피자 조각을 꺼내는", "cg_path": "res://assets/events/night/phase4/night_frozen_pizza_slice.png"},
    {"id": "night_sweet_redbean_bun", "name": "단팥빵 야식", "group": "night", "tags": ["food", "dessert"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "책상 앞에서 단팥빵을 작게 베어 무는", "cg_path": "res://assets/events/night/phase4/night_sweet_redbean_bun.png"},
    {"id": "night_delivery_app_close", "name": "배달앱 닫기", "group": "night", "tags": ["money", "selfcare"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "배달앱 화면을 보다가 조용히 앱을 닫는", "cg_path": "res://assets/events/night/phase4/night_delivery_app_close.png"},
    {"id": "night_delivery_fee_shock", "name": "배달비 보고 멈춤", "group": "night", "tags": ["money", "stress"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "배달비 금액을 보고 손가락을 멈추는", "cg_path": "res://assets/events/night/phase4/night_delivery_fee_shock.png"},
    {"id": "night_coupon_expiring", "name": "오늘까지 쿠폰", "group": "night", "tags": ["money", "impulse"], "rarity": "uncommon", "cooldown": 90, "conditions": "출근일 밤", "brief": "만료 임박 쿠폰 알림을 보고 고민하는", "cg_path": "res://assets/events/night/phase4/night_coupon_expiring.png"},
    {"id": "night_budget_left_check", "name": "오늘 남은 예산", "group": "night", "tags": ["money", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "침대 위에서 가계부 앱의 남은 예산을 확인하는", "cg_path": "res://assets/events/night/phase4/night_budget_left_check.png"},
    {"id": "night_transport_refund", "name": "교통비 환급 알림", "group": "night", "tags": ["money", "luck", "rare"], "rarity": "rare", "cooldown": 180, "conditions": "출근일 밤", "brief": "늦은 밤 작은 환급 알림을 보고 놀라는", "cg_path": "res://assets/events/night/phase4/night_transport_refund.png"},
    {"id": "night_subscription_price_up", "name": "구독료 인상 알림", "group": "night", "tags": ["money", "stress"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일 밤", "brief": "구독료 인상 알림을 보고 결제 목록을 여는", "cg_path": "res://assets/events/night/phase4/night_subscription_price_up.png"},
    {"id": "night_card_points_found", "name": "카드 포인트 발견", "group": "night", "tags": ["money", "luck"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일 밤", "brief": "카드앱에서 잊고 있던 포인트를 발견하는", "cg_path": "res://assets/events/night/phase4/night_card_points_found.png"},
    {"id": "night_stock_app_reopen", "name": "증권앱 다시 열기", "group": "night", "tags": ["stock", "stress"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "불 꺼진 방에서 증권앱을 다시 열어 보는", "cg_path": "res://assets/events/night/phase4/night_stock_app_reopen.png"},
    {"id": "night_news_headline_scroll", "name": "경제뉴스 헤드라인", "group": "night", "tags": ["stock", "insomnia"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "침대 위에서 경제뉴스 헤드라인을 스크롤하는", "cg_path": "res://assets/events/night/phase4/night_news_headline_scroll.png"},
    {"id": "night_watchlist_before_sleep", "name": "잠들기 전 관심종목", "group": "night", "tags": ["stock", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "잠들기 전 관심종목 목록을 조용히 정리하는", "cg_path": "res://assets/events/night/phase4/night_watchlist_before_sleep.png"},
    {"id": "night_phone_brightness_low", "name": "밝기 낮춘 휴대폰", "group": "night", "tags": ["insomnia", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "어두운 방에서 휴대폰 밝기를 낮추고 화면을 보는", "cg_path": "res://assets/events/night/phase4/night_phone_brightness_low.png"},
    {"id": "night_alarm_three_times", "name": "알람 세 개 맞추기", "group": "night", "tags": ["routine", "stress"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "내일 출근 알람을 여러 개 맞추며 걱정하는", "cg_path": "res://assets/events/night/phase4/night_alarm_three_times.png"},
    {"id": "night_outfit_tomorrow", "name": "내일 입을 옷", "group": "night", "tags": ["routine", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "옷걸이에 내일 입을 옷을 미리 걸어두는", "cg_path": "res://assets/events/night/phase4/night_outfit_tomorrow.png"},
    {"id": "night_bag_repack", "name": "가방 다시 싸기", "group": "night", "tags": ["routine", "fatigue"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "책상 앞에서 가방 속 지갑과 충전기를 다시 확인하는", "cg_path": "res://assets/events/night/phase4/night_bag_repack.png"},
    {"id": "night_lunchbox_prep", "name": "내일 도시락 준비", "group": "night", "tags": ["food", "money", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "작은 반찬통에 내일 도시락을 나눠 담는", "cg_path": "res://assets/events/night/phase4/night_lunchbox_prep.png"},
    {"id": "night_tumbler_wash", "name": "텀블러 씻기", "group": "night", "tags": ["routine", "health"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "싱크대에서 텀블러를 씻고 물기를 털어내는", "cg_path": "res://assets/events/night/phase4/night_tumbler_wash.png"},
    {"id": "night_receipt_sort", "name": "영수증 정리", "group": "night", "tags": ["money", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "책상 위 영수증을 모아 가계부 옆에 정리하는", "cg_path": "res://assets/events/night/phase4/night_receipt_sort.png"},
    {"id": "night_coin_pouch_count", "name": "동전 지갑 세기", "group": "night", "tags": ["money", "calm"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "작은 동전 지갑을 열어 동전을 세어 보는", "cg_path": "res://assets/events/night/phase4/night_coin_pouch_count.png"},
    {"id": "night_dust_roll_uniform", "name": "출근복 먼지 제거", "group": "night", "tags": ["routine", "office"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "내일 입을 출근복에 돌돌이 테이프를 굴리는", "cg_path": "res://assets/events/night/phase4/night_dust_roll_uniform.png"},
    {"id": "night_shoes_dry_rain", "name": "젖은 신발 말리기", "group": "night", "tags": ["rainy", "routine"], "rarity": "uncommon", "cooldown": 90, "conditions": "비 오는 출근일 밤", "brief": "현관에서 젖은 신발 안에 신문지를 넣어 말리는", "cg_path": "res://assets/events/night/phase4/night_shoes_dry_rain.png"},
    {"id": "night_shoulder_patch", "name": "어깨 파스", "group": "night", "tags": ["health", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "어깨에 파스를 붙이며 거울을 보는", "cg_path": "res://assets/events/night/phase4/night_shoulder_patch.png"},
    {"id": "night_wrist_warm_pack", "name": "손목 온찜질", "group": "night", "tags": ["health", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "책상 앞에서 손목에 따뜻한 찜질팩을 올리는", "cg_path": "res://assets/events/night/phase4/night_wrist_warm_pack.png"},
    {"id": "night_foot_stretch_wall", "name": "벽 짚고 종아리 스트레칭", "group": "night", "tags": ["health", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "벽을 짚고 종아리를 천천히 늘리는", "cg_path": "res://assets/events/night/phase4/night_foot_stretch_wall.png"},
    {"id": "night_eye_mask_rest", "name": "온열 안대", "group": "night", "tags": ["health", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "침대에 앉아 온열 안대를 쓰고 쉬는", "cg_path": "res://assets/events/night/phase4/night_eye_mask_rest.png"},
    {"id": "night_water_bottle_bed", "name": "침대 옆 물병", "group": "night", "tags": ["health", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "침대 옆 협탁에 물병을 채워 두는", "cg_path": "res://assets/events/night/phase4/night_water_bottle_bed.png"},
    {"id": "night_pill_case_check", "name": "약통 확인", "group": "night", "tags": ["health", "routine"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "요일별 약통을 열어 내일 먹을 약을 확인하는", "cg_path": "res://assets/events/night/phase4/night_pill_case_check.png"},
    {"id": "night_room_airing", "name": "밤 환기", "group": "night", "tags": ["routine", "health"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "창문을 조금 열고 방 안 공기를 바꾸는", "cg_path": "res://assets/events/night/phase4/night_room_airing.png"},
    {"id": "night_blanket_cover_fix", "name": "이불커버 정리", "group": "night", "tags": ["routine", "fatigue"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "침대 위에서 삐뚤어진 이불커버를 바로잡는", "cg_path": "res://assets/events/night/phase4/night_blanket_cover_fix.png"},
    {"id": "night_pillow_spray", "name": "베개 향 스프레이", "group": "night", "tags": ["recovery", "mood"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "베개 위에 작은 향 스프레이를 뿌리는", "cg_path": "res://assets/events/night/phase4/night_pillow_spray.png"},
    {"id": "night_small_journal", "name": "세 줄 일기", "group": "night", "tags": ["calm", "selfcare"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "작은 노트에 오늘 하루를 세 줄로 적는", "cg_path": "res://assets/events/night/phase4/night_small_journal.png"},
    {"id": "night_gratitude_one_line", "name": "고마웠던 일 하나", "group": "night", "tags": ["calm", "recovery"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "노트 한쪽에 오늘 고마웠던 일 하나를 적는", "cg_path": "res://assets/events/night/phase4/night_gratitude_one_line.png"},
    {"id": "night_tomorrow_top_three", "name": "내일 할 일 세 개", "group": "night", "tags": ["routine", "stress"], "rarity": "common", "cooldown": 60, "conditions": "출근일 밤", "brief": "내일 할 일 세 개를 작은 메모지에 적는", "cg_path": "res://assets/events/night/phase4/night_tomorrow_top_three.png"},
    {"id": "night_calendar_payday_mark", "name": "월급일 표시", "group": "night", "tags": ["money", "routine"], "rarity": "common", "cooldown": 90, "conditions": "출근일 밤", "brief": "달력 앱에 월급일과 카드값 날짜를 표시하는", "cg_path": "res://assets/events/night/phase4/night_calendar_payday_mark.png"},
    {"id": "night_rent_transfer_check", "name": "월세 이체 확인", "group": "night", "tags": ["money", "stress"], "rarity": "uncommon", "cooldown": 120, "conditions": "월말 밤", "brief": "은행앱에서 월세 자동이체 상태를 확인하는", "cg_path": "res://assets/events/night/phase4/night_rent_transfer_check.png"},
    {"id": "night_sudden_power_blink", "name": "전등 깜빡임", "group": "night", "tags": ["trouble", "rare"], "rarity": "rare", "cooldown": 180, "conditions": "출근일 밤", "brief": "방 전등이 한 번 깜빡이자 천장을 올려다보는", "cg_path": "res://assets/events/night/phase4/night_sudden_power_blink.png"},
    {"id": "night_neighbors_noise", "name": "윗집 소음", "group": "night", "tags": ["trouble", "insomnia"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일 밤", "brief": "천장에서 들리는 소리에 베개를 끌어안고 멈칫하는", "cg_path": "res://assets/events/night/phase4/night_neighbors_noise.png"},
    {"id": "night_delivery_wrong_bell", "name": "잘못 울린 초인종", "group": "night", "tags": ["trouble", "stress"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일 밤", "brief": "밤에 울린 초인종 소리에 현관 쪽을 바라보는", "cg_path": "res://assets/events/night/phase4/night_delivery_wrong_bell.png"},
    {"id": "night_bug_screen_window", "name": "방충망의 작은 벌레", "group": "night", "tags": ["trouble", "routine"], "rarity": "common", "cooldown": 90, "conditions": "여름 밤", "brief": "방충망에 붙은 작은 벌레를 보고 창문을 다시 닫는", "cg_path": "res://assets/events/night/phase4/night_bug_screen_window.png"},
    {"id": "night_aircon_timer", "name": "에어컨 타이머", "group": "night", "tags": ["seasonal", "money"], "rarity": "common", "cooldown": 90, "conditions": "여름 밤", "brief": "에어컨 리모컨으로 타이머를 맞추며 전기요금을 떠올리는", "cg_path": "res://assets/events/night/phase4/night_aircon_timer.png"},
    {"id": "night_boiler_temperature", "name": "보일러 온도 조절", "group": "night", "tags": ["seasonal", "money"], "rarity": "common", "cooldown": 90, "conditions": "겨울 밤", "brief": "보일러 조절기를 보며 온도를 조금 낮추는", "cg_path": "res://assets/events/night/phase4/night_boiler_temperature.png"},
    {"id": "night_dry_lip_balm", "name": "립밤 찾기", "group": "night", "tags": ["health", "seasonal"], "rarity": "common", "cooldown": 90, "conditions": "겨울 밤", "brief": "건조한 밤 책상 서랍에서 립밤을 찾는", "cg_path": "res://assets/events/night/phase4/night_dry_lip_balm.png"},
    {"id": "night_rain_sound_focus", "name": "빗소리 듣기", "group": "night", "tags": ["rainy", "calm"], "rarity": "common", "cooldown": 90, "conditions": "비 오는 밤", "brief": "창가에 앉아 조용히 빗소리를 듣는", "cg_path": "res://assets/events/night/phase4/night_rain_sound_focus.png"},
    {"id": "night_moon_clouds", "name": "구름 사이 달", "group": "night", "tags": ["calm", "rare"], "rarity": "rare", "cooldown": 180, "conditions": "출근일 밤", "brief": "창문 밖 구름 사이로 보이는 달을 바라보는", "cg_path": "res://assets/events/night/phase4/night_moon_clouds.png"},
    {"id": "night_old_photo_box", "name": "오래된 사진 상자", "group": "night", "tags": ["memory", "calm"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일 밤", "brief": "작은 상자에서 오래된 사진을 꺼내 보는", "cg_path": "res://assets/events/night/phase4/night_old_photo_box.png"},
    {"id": "night_friend_voice_message", "name": "친구의 음성 메시지", "group": "night", "tags": ["social", "mood"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일 밤", "brief": "이어폰을 끼고 친구의 짧은 음성 메시지를 듣는", "cg_path": "res://assets/events/night/phase4/night_friend_voice_message.png"},
    {"id": "night_parent_goodnight_text", "name": "부모님의 잘 자 문자", "group": "night", "tags": ["social", "recovery"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일 밤", "brief": "가족의 짧은 안부 문자를 보고 표정이 풀리는", "cg_path": "res://assets/events/night/phase4/night_parent_goodnight_text.png"},
    {"id": "night_unexpected_compliment", "name": "뜻밖의 칭찬 알림", "group": "night", "tags": ["luck", "mood", "rare"], "rarity": "rare", "cooldown": 180, "conditions": "출근일 밤", "brief": "늦은 밤 업무 칭찬 메시지를 보고 조용히 미소 짓는", "cg_path": "res://assets/events/night/phase4/night_unexpected_compliment.png"},
    {"id": "night_small_lucky_receipt", "name": "영수증 작은 행운", "group": "night", "tags": ["luck", "money", "rare"], "rarity": "rare", "cooldown": 180, "conditions": "출근일 밤", "brief": "영수증 이벤트 당첨 알림을 보고 놀라는", "cg_path": "res://assets/events/night/phase4/night_small_lucky_receipt.png"},
    {"id": "night_late_email_resist", "name": "늦은 업무메일 참기", "group": "night", "tags": ["work", "stress", "selfcare"], "rarity": "uncommon", "cooldown": 120, "conditions": "출근일 밤", "brief": "밤에 도착한 업무메일 알림을 보고 노트북을 열지 않기로 하는", "cg_path": "res://assets/events/night/phase4/night_late_email_resist.png"},
    {"id": "night_sleep_before_midnight", "name": "자정 전 취침 성공", "group": "night", "tags": ["recovery", "rare"], "rarity": "rare", "cooldown": 180, "conditions": "피로 높음", "brief": "자정 전 불을 끄고 침대에 누워 안도하는", "cg_path": "res://assets/events/night/phase4/night_sleep_before_midnight.png"},
]


if __name__ == "__main__":
    sys.exit(main())
