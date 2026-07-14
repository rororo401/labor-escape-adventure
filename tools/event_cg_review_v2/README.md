# Event CG Review V2

924개의 재생산 이미지를 현재 게임 이미지와 좌우 비교하는 독립 검수 앱입니다.

```bash
HOST=0.0.0.0 PORT=4178 node tools/event_cg_review_v2/server.js
```

- 현재 게임 이미지는 수정하지 않습니다.
- 신규 이미지는 `tmp/event_cg_regen_v2`에서 읽습니다.
- V2 판정은 `review_state_v2.json`에 별도로 저장됩니다.
- `1`: 신규 이미지 승인, `2`: 수정 필요, `3`: 다시 만들기

## V3 연령감 교정 결과 검수

V2 서버를 버전 선택형으로 공유하며, V3 판정은 별도 상태 파일에 저장됩니다.

```bash
REVIEW_VERSION=3 HOST=0.0.0.0 PORT=4179 node tools/event_cg_review_v2/server.js
```

- V3 비교 대상은 회사 기본업무 400장과 회사 외 일상 523장, 총 923장입니다.
- V3 신규 이미지는 `tmp/event_cg_regen_v3`에서 읽습니다.
- V3 판정은 `review_state_v3.json`에 저장되며 V2 판정과 섞이지 않습니다.

## V4 재생성 결과 검수

V3 검수에서 재생성 대상으로 판정된 113장을 V3 후보와 나란히 비교합니다.

```bash
REVIEW_VERSION=4 HOST=0.0.0.0 PORT=4180 node tools/event_cg_review_v2/server.js
```

- V4 비교 대상은 회사 기본업무 66장과 회사 외 일상 47장입니다.
- 왼쪽은 탈락한 V3 후보, 오른쪽은 신규 V4 후보입니다.
- V4 판정은 `review_state_v4.json`에 별도로 저장됩니다.
