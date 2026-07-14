# Event CG Review

게임 본편과 분리된 이벤트 CG 검수용 웹앱입니다.

## 실행

```bash
node tools/event_cg_review/server.js
```

브라우저에서 `http://127.0.0.1:4177`을 엽니다.

내부 네트워크의 다른 기기에서 접속할 때는 전체 인터페이스에 바인딩합니다.

```bash
HOST=0.0.0.0 node tools/event_cg_review/server.js
```

## 큰 이미지 검수

이미지 카드를 클릭하면 큰 검수창이 열립니다.

- `←` / `→`: 이전/다음 이미지
- `1`: 검수 완료 후 다음
- `2`: 수정 필요 후 다음
- `3`: 다시 만들기 후 다음

리스트에서는 판정된 이미지 위에 반투명 색이 표시됩니다.

## 검수 상태

검수 결과는 `tools/event_cg_review/review_state.json`에 저장됩니다.

- `approved`: 검수 완료
- `needs_edit`: 수정 필요
- `remake`: 다시 만들기
- `pending`: 미검수

`review_state.json`은 개인 검수 진행 파일이라 `.gitignore`에 포함되어 있습니다.

## 집계 기준

- `data/game/day_events.json`
- `data/game/special_annual_events.json`
- `data/game/market_fixed_events.json`
- 코드에서 직접 끼우는 공통 이벤트 CG
- 실제 이미지 폴더 `assets/events`
- 실제 이미지 폴더 `assets/events_summer`

여름 버전은 기본 이벤트와 별도 항목으로 검수합니다.

## V2 재생산 비교 검수

924장의 재생산 결과를 기존 게임 이미지와 좌우 비교합니다. V2 판정은 별도 `review_state_v2.json`에 저장되며 게임 파일을 자동으로 교체하지 않습니다.

```bash
HOST=0.0.0.0 node tools/event_cg_review/server_v2.js
```
