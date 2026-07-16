# 🐳 Whale

역할 기반 에이전트 팀을 **슬래시 명령어**로 구동하는 경량 워크플로 프레임워크 — **Claude Code 플러그인**.

한 프로젝트에서 쓰던 에이전트 팀(dba·be·fe·qa + planner·designer·domain-expert)과 오케스트레이션 명령어를, 어느 프로젝트에서든 `/plugin install` 한 번으로 불러온다.

## 철학

- **에이전트 팀 + 발동 장치.** 7개 역할 정의는 플러그인이 제공하고, `/whale:*` 명령어가 그 팀을 발동한다. 그동안 수동/대화형이던 핸드오프("완료 후 X에게 알림")를 `/whale:next` 로 자동화한다.
- **자동 체인은 4역할만.** `dba→be-developer→fe-developer→qa`(구현·검증). planner·designer·domain-expert 는 온디맨드 보조다(기획은 사람이 화면정의서/PRD 로 제공, designer 는 신규 화면일 때만, domain-expert 는 구현 후 최종 리뷰어).
- **설계 결정권은 사람에게.** 기본 아키텍처는 단순 레이어드(Controller→Service→Repository). 전술 DDD 는 프로젝트가 명시 승인한 모듈에만. domain-expert 는 경계를 *창작*하지 않고 *검증*한다.
- **데이터 주도 이식성.** 명령어는 역할명·경로를 하드코딩하지 않고 **프로젝트 로컬 `.claude/whale/config.json`** 을 읽는다. 엔진(플러그인)은 그대로, 프로젝트 값만 바뀐다.

## 설치

```bash
# 1) 마켓플레이스 등록 (로컬 경로 또는 GitHub)
/plugin marketplace add /path/to/whale-plugin      # 로컬
# 또는
/plugin marketplace add <github-user>/whale-plugin # GitHub

# 2) 플러그인 설치
/plugin install whale

# 3) 프로젝트에 상태·설정 스캐폴드 (프로젝트마다 1회)
/whale:init
```

`/whale:init` 은 `templates/` 에서 다음을 프로젝트로 복사한다(기존 파일은 덮어쓰지 않음):
- `.claude/whale/config.json` — 역할 매핑·체인 순서·문서 경로 (**프로젝트에 맞게 수정**)
- `.claude/whale/state.md` — 흐름 상태(런타임)

## 명령어

**오케스트레이션**
- `/whale:init` — 프로젝트에 config/state 스캐폴드 (최초 1회)
- `/whale:start <feature>` — Mode A(순차) 흐름 시작. 마일스톤 범위 확인 → state 기록 → 첫 에이전트 dispatch.
- `/whale:next` — 현재 단계 산출물 검증 → 다음 에이전트로 핸드오프(미충족 시 블로커 보고).
- `/whale:status` — 흐름이 체인 어디에 있는지, 완료/대기/블로커 표시.
- `/whale:fix <desc>` — Mode B(피어). 고정 순서 없이 이슈에 맞는 에이전트 투입.

**역할 직접 호출 (애드혹)**
- `/whale:plan` · `/whale:design` · `/whale:domain` · `/whale:dba` · `/whale:be` · `/whale:fe` · `/whale:qa`

**산출물 작성** — 흐름: `프로토타입 + PRD → 화면정의서(planner) → 화면설계서(5역할) → 구현(be/fe)`
- `/whale:screen-spec <화면ID>` — 화면 정의서(개발 기준 정본) 작성.
- `/whale:screen-design <화면ID> [섹션]` — 화면설계서(정의↔구현 허브). 한 파일을 5역할이 섹션별 소유(§2 domain·§3 dba·§4 designer·§5 be·§6 fe).

**규율 / 모니터링**
- `/whale:spec-check <change>` — 요구사항 변경이 spec-first 절차를 요하는지 판단 + 갱신 문서 산출.
- `/whale:ctx` — 대화 컨텍스트 사용량(토큰 %) 측정, 50/75/90% 임계치 권고.

## Mode A / Mode B

- **Mode A (신규 개발):** `config.json.modeA_chain`(dba→be→fe→qa) 순서대로 순차 진행. 각 단계는 산출물 완료 후 `/whale:next` 로 넘어간다. 체인 종료(qa) 후 필요하면 `/whale:domain` 최종 리뷰 → 리더 검수.
- **Mode B (이슈 해결):** 고정 순서 없음. 이슈 성격에 맞는 역할(들)이 피어로 협업.

## 구성

```
whale-plugin/
├── .claude-plugin/
│   ├── plugin.json          # 플러그인 매니페스트
│   └── marketplace.json     # 이 레포를 마켓플레이스로 (source: ./)
├── commands/                # 16개 슬래시 명령어 (/whale:*)
├── agents/                  # 7개 역할 정의 (dba·be·fe·qa·planner·designer·domain-expert)
├── scripts/ctx-check.sh     # 컨텍스트 사용량 측정
├── templates/               # config.json·state.md (init 이 프로젝트로 복사)
└── README.md
```

## 프로젝트별 커스터마이징

플러그인은 손대지 않고 **프로젝트 로컬 `.claude/whale/config.json`** 만 수정한다:

| 키 | 용도 |
|----|------|
| `modeA_chain` | 자동 체인 순서 |
| `roles` | 역할 → agentType 매핑 (플러그인이 `whale:dba` 로 네임스페이스하면 그 값으로 교체) |
| `scopeDir` | 마일스톤 범위 문서 디렉토리 |
| `paths.*` | 화면정의서·설계서·PRD·프로토타입 경로 |
| `reviewer` | 최종 검수자 |

에이전트의 방법론(예: 행정안전부 DB 표준화 지침)은 플러그인에 내장되어 있고, 프로젝트 고유 규칙(테이블 프리픽스·동결 스키마·기술 스택)은 각 에이전트가 **프로젝트 `CLAUDE.md`** 를 읽어 적용한다.

## 라이선스

MIT
