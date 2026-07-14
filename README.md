# 노동탈출 대모험

10년 안에 10억 원을 모아 노동에서 탈출하는 것을 목표로 하는 2D 생활·주식 시뮬레이션 게임입니다. 평일의 회사 업무, 퇴근 후의 생활, 주말 활동, 건강·기분·피로 관리와 가상의 주식 거래가 하나의 장기 플레이 흐름으로 이어집니다.

이 저장소는 게임의 작동 방식과 데이터 구성을 투명하게 공개하고, 누구나 코드를 확인하거나 직접 빌드할 수 있도록 만든 공개 소스 저장소입니다.

> 이 게임은 실제 금융 거래나 투자 조언을 제공하지 않습니다. 게임 속 종목과 사건은 시뮬레이션을 위한 가상 구성입니다.

## 다운로드

Windows 10/11 64비트용 실행 파일은 [Releases](https://github.com/dorodo786-lang/labor-escape-adventure/releases)에서 받을 수 있습니다.

코드 서명을 하지 않은 개인 취미 프로젝트이므로 Windows SmartScreen 경고가 표시될 수 있습니다. 릴리스에 적힌 SHA-256과 내려받은 파일의 해시가 일치하는지 확인해 주세요.

## 제작 방식

프로젝트 소유자가 게임의 방향, 규칙, 밸런스, UI, 콘텐츠 기준을 정하고 반복 플레이와 이미지 검수를 진행했습니다. 구현과 정리의 대부분은 OpenAI Codex와의 대화형 작업으로 이루어졌습니다. 즉, 사람이 모든 코드를 한 줄씩 직접 작성한 프로젝트라기보다, 사람이 목표와 품질 기준을 결정하고 AI와 함께 구현·검증한 프로젝트입니다.

## 직접 실행하기

필요한 도구:

- Godot Engine 4.7
- Git
- Git LFS

```bash
git lfs install
git clone https://github.com/dorodo786-lang/labor-escape-adventure.git
cd labor-escape-adventure
```

그다음 Godot에서 `project.godot`을 열고 프로젝트를 실행합니다. 처음 열 때는 이미지 임포트에 시간이 걸릴 수 있습니다.

## 테스트

Godot 실행 파일이 `godot` 이름으로 PATH에 등록되어 있다면 다음 명령으로 테스트 모음을 실행할 수 있습니다.

```bash
./scripts/tests/run_tests.sh
```

다른 이름이나 경로를 사용한다면 `GODOT_BIN`을 지정합니다.

```bash
GODOT_BIN=/path/to/godot ./scripts/tests/run_tests.sh
```

## 빌드

Godot 4.7용 내보내기 템플릿을 설치한 뒤 다음 프리셋을 사용할 수 있습니다.

- `Windows Release`
- `macOS Test`
- `Android Test`

Windows 예시:

```bash
godot --headless --path . --export-release "Windows Release" build/windows/LaborEscapeAdventure.exe
```

## 저장소 용량

게임 이미지와 음원은 Git LFS로 관리합니다. 저장소를 ZIP으로 받는 대신 Git과 Git LFS로 복제해야 전체 원본 에셋을 안정적으로 받을 수 있습니다.

## 라이선스

- 소스 코드: [MIT License](LICENSE)
- 저장소 소유자가 권리를 가진 게임 텍스트·이미지·기타 원본 에셋: [CC BY 4.0](ASSET_LICENSE.md)
- 폰트: 각 파일과 함께 있는 SIL Open Font License 1.1
- 음원: [`assets/audio/ATTRIBUTION.md`](assets/audio/ATTRIBUTION.md)에 기재된 개별 라이선스

각 라이선스와 제3자 고지는 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)도 함께 확인해 주세요.

## 상태

현재 릴리스는 개인 취미 프로젝트의 첫 공개 테스트 버전입니다. 버그 제보는 GitHub Issues로 남길 수 있지만, 정기 업데이트나 지원을 보장하지는 않습니다.
