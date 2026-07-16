# 🐳 Whale

작업 한 건의 **생애주기 품질 루프**를 **슬래시 명령어**로 구동하는 워크플로 프레임워크 — **Claude Code 플러그인**.

역할을 나눈 AI 에이전트들(researcher·planner·dba·be·fe·reviewer·qa·summarizer)과 그걸 엮는 오케스트레이션을, 어느 프로젝트에서든 `/plugin install` 한 번으로 불러온다. 혼자서도 "나만의 개발팀"으로 개발한다.

## 철학

- **작업 생애주기가 백본.** 모든 작업은 `researcher → planner → [승인] → implementer → reviewer → qa → [재구현 루프] → summarizer` 를 지난다. 도메인 역할(dba/be/fe)은 **Implementer 단계가 계획에 따라 부르는 전문가**다.
- **컨텍스트 격리.** 각 단계는 독립 dispatch 된다. Reviewer/QA 는 구현 컨텍스트에 물들지 않고 **산출물만** 보고 객관적으로 판정한다.
- **강제 승인 게이트.** Planner 의 7섹션 계획은 사람이 `APPROVED: <run-id>` 를 명시해야 구현으로 넘어간다. "ok"·"진행해" 같은 느슨한 승인은 불허 — 사람이 계획을 실제로 읽게 강제한다.
- **명시적 피드백 루프.** Reviewer/QA 는 `재구현 필요: YES/NO` + 지적 범위 수정지침을 강제 출력한다. YES 면 지적 전문가에게만 되돌린다(전체 재구현 아님). **최대 1회**, 초과 시 리더 에스컬레이션(무한 루프 방지).
- **기록 강제.** Summarizer 가 변경파일·TDD 사이클·리뷰 이슈·QA 결과를 **작업 결과지(= PR 디스크립션)**로 남긴다.
- **E2E 무인 트리아지.** 야간에 e2e-tester 가 Playwright 로 critical path 를 실행하고, 진짜 앱버그(APP_BUG)만 골라 크리티컬리티순 리포트로 남긴다 — 테스트버그(TEST_BUG)·UI변경(UI_CHANGE)은 스스로 고치고(self-healing), APP_BUG 는 기존 피드백 루프로 재구현을 부른다.
- **강제 게이트(Hooks).** 리뷰·QA·보안은 에이전트 "판단"이지만, `/whale:hooks-init` 이 스캐폴드하는 Hooks 는 "무조건 실행"이다 — lint·test 게이트(PostToolUse)와 위험명령 차단(PreToolUse, `rm -rf`·강제푸시·prod 마이그레이션 등 exit 2)으로 권고를 강제로 바꾼다.
- **전담 보안 게이트.** security-reviewer 가 SAST(인젝션·인증우회·PII·site_id)와 SCA(신규 패키지 실존확인=환각/슬롭스쿼팅·취약버전)를 심층 검토한다. 인증·암호화·입력검증·결제 변경은 무결점이어도 **사람 승인 없이는 통과 못 함(HOLD)**, Critical/High 는 머지 차단.
- **계약 우선.** planner 가 레이어 경계마다 단일 진실원(SSOT)을 못박고 가능하면 스키마→타입 codegen 으로 FE/BE 드리프트를 원천 차단한다.
- **교차-run 학습.** DECISIONS.md(결정+이유)·LessonsLearned.md(반복 실패)를 run 간에 누적해 다음 세션이 승계한다.
- **부채 상환.** refactor 에이전트가 생애주기와 독립으로 복잡도·중복·부채를 주기적으로 갚는다(동작 불변 강제).
- **데이터 주도 이식성.** 명령어는 역할명·경로·순서를 하드코딩하지 않고 **프로젝트 로컬 `.claude/whale/config.json`** 을 읽는다. 엔진(플러그인)은 그대로, 프로젝트 값만 바뀐다.
- **범용 기본 + 선택적 도메인 프로필.** 기본은 **범용**(프로젝트 관례·CLAUDE.md 를 따름) — 특정 아키텍처나 표준을 강제하지 않는다. 공공기관 프로젝트라면 `config.profile.domain=public-sector-kr` 로 켜서 dba 에 내장된 행정안전부 DB 표준화 지침(표준도메인·감사컬럼·논리삭제·PII 암호화)을, `multitenant=true` 로 site_id 격리를 적용한다. **아키텍처(레이어드/DDD/피처슬라이스)는 전적으로 프로젝트 CLAUDE.md 가 결정**한다.

## 생애주기 (한눈에)

```
/whale:start <task>
  → run-id 발급 (예: 20260716-oauth-login-01)
  → [research]   researcher  → runs/<id>/research.md
  → [plan]       planner     → runs/<id>/plan.md (고정 7섹션 P1~P7) + 승인요청
  → [approve]    ⛔ /whale:approve <run-id>  (사람이 명시 승인)
  → [implement]  계획에 등장하는 dba/be/fe 전문가만 순차 dispatch, 각자 TDD
  → [review]     reviewer    → review.md  (재구현 필요: YES/NO)
  → [qa]         qa          → qa.md       (재구현 필요: YES/NO)
                └ critical path 있으면 e2e-tester 무인 실행 → e2e.md (APP_BUG → qa Blocker)
  → [loop]       YES면 implement로 복귀 (최대 1회, 지적 범위만)
  → [summarize]  summarizer  → summary.md (= PR 디스크립션)
  → 히스토리 이동 + 리더 최종 검수
```

각 단계 산출물은 `.claude/whale/runs/<run-id>/*.md` 파일로 남아, 다음 단계가 읽고 `/whale:next` 가 게이트를 검증한다.

## 슬래시 커맨드 없이 자동으로 쓰기

`/whale:*` 를 매번 치지 않아도 **개발 요청이 자동으로 whale 흐름으로 진행**되게 할 수 있다. Claude Code에 "강제 자동 위임"은 없지만(모델이 매번 판단), 아래 레버로 **기본 동작을 whale로 기울인다** — 승인 게이트는 그대로 유지된다.

1. **Output Style (내장, 권장).** 플러그인의 `output-styles/whale.md` 는 `force-for-plugin: true` 라 플러그인을 켜면 자동 적용된다. "OAuth 로그인 만들어줘"만 해도 researcher→planner→**⛔승인**→구현→리뷰→qa→요약으로 흐른다. `/output-style` 로 확인·전환.
2. **CLAUDE.md 라우팅.** `/whale:init` 이 심는 프로젝트 `CLAUDE.md §0` + 전역 `~/.claude/CLAUDE.md`(플러그인 `templates/user-CLAUDE-snippet.md` 블록)가 매 세션 라우팅 규칙을 로드한다.
3. **에이전트 description 트리거.** 각 에이전트에 "…할 때 사용" 키워드가 있어, "이 코드 리뷰해줘"→reviewer, "테이블 추가"→dba 처럼 단일 작업은 바로 해당 전문가로 자동 위임된다.

> **plan 모드**에서는 계획을 whale 7섹션(P1~P7)으로 산출한다. **사소한 작업**(오타·1줄)은 생애주기 없이 바로 처리된다. 완전 결정적 실행이 필요하면 여전히 `/whale:start`·`/whale:next` 를 쓰면 된다.

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
- `.claude/whale/config.json` — 생애주기 phase·역할 매핑·승인/루프 설정·경로 (**프로젝트에 맞게 수정**)
- `.claude/whale/state.md` — 흐름 상태(런타임)
- `.claude/whale/runs/` — run-id 별 산출물 저장 루트

## 명령어

**오케스트레이션 (Mode A — 생애주기 루프)**
- `/whale:init` — 프로젝트에 config/state 스캐폴드 (최초 1회)
- `/whale:start <task>` — 생애주기 시작. run-id 발급 → Researcher dispatch.
- `/whale:next` — 현재 phase 게이트 검증 → 다음 단계로 핸드오프(승인 게이트·피드백 루프 포함).
- `/whale:approve <run-id> [--reject]` — 계획 승인 게이트. 명시 승인해야 implement 진입.
- `/whale:status` — run-id·phase·승인 상태·재시도·implement 하위 진행 표시.

**Mode B — 이슈 해결 (피어)**
- `/whale:fix <desc>` — 고정 순서 없이 이슈에 맞는 역할 투입. run-id 생애주기와 독립.

**병렬 worktree**
- `/whale:worktree create <base> <name...>` — 작업별 git worktree(폴더·브랜치 물리 격리) 생성 + 의존성 설치 + 포트 분리.
- `/whale:worktree list` · `/whale:worktree remove <name>` — 목록 / 정리.

**역할 직접 호출 (온디맨드)**
- `/whale:research` · `/whale:plan` · `/whale:dba` · `/whale:be` · `/whale:fe` · `/whale:review` · `/whale:qa` · `/whale:summarize`
- `/whale:e2e`(e2e-tester 무인 E2E) · `/whale:security`(security-reviewer SAST/SCA) · `/whale:refactor`(부채 상환) · `/whale:design` · `/whale:domain`

**강제 게이트**
- `/whale:hooks-init` — 프로젝트 `.claude/settings.json` 에 lint/test 게이트 + 위험명령 차단 훅 스캐폴드(스택 감지·병합 안전, 최초 1회).

**E2E 하네스**
- `/whale:e2e-init` — 프로젝트에 Playwright 설정·Helper 스켈레톤·fixture·AI 가이드(`tests/README.e2e.md`)·CI 워크플로를 스캐폴드 (최초 1회).
- `/whale:e2e <시나리오>` — e2e-tester 를 dispatch 해 critical path 를 무인 실행·4분류 트리아지.

**산출물 (선택적 spec 문서)**
- `/whale:screen-spec <화면ID>` — (온디맨드) 화면 정의서 작성. 생애주기의 **선택적 입력 문서**.
- `/whale:spec-check <change>` — 변경이 spec-first 절차를 요하는지 판단 + 갱신 문서 산출.

**모니터링**
- `/whale:ctx` — 대화 컨텍스트 사용량(토큰 %) 측정, 50/75/90% 임계치 권고.

## 역할

| 역할 | 단계 | 책임 |
|------|------|------|
| **researcher** | research | 코드베이스·요구사항·수정후보 조사(읽기 전용). 리서치 브리프 R1~R7. |
| **planner** | plan | 고정 7섹션 구현계획서 + `APPROVED:<run-id>` 승인 요청. |
| **dba / be-developer / fe-developer** | implement | 계획 배정에 따라 dispatch 되는 도메인 전문가. TDD(Red-Green-Refactor). |
| **reviewer** | review | 아키텍처·보안·품질 3축 리뷰. CRITICAL/MAJOR/MINOR + 재구현 필요 YES/NO. |
| **qa** | qa | AC·BR·회귀 검증. Go/No-Go + 재구현 필요 YES/NO. |
| **summarizer** | summarize | 작업 결과지(PR 디스크립션) 기록. |
| e2e-tester | qa 종속(온디맨드) | Playwright critical path 무인 실행·4분류 트리아지(UI_CHANGE/TEST_BUG 자가수정, APP_BUG→qa Blocker→재구현 루프). |
| security-reviewer | qa 종속(온디맨드) | SAST+SCA 심층 검토. 환각/슬롭스쿼팅 패키지 탐지, 사람 필수 게이트(HOLD), Critical/High 머지 차단→재구현. |
| refactor | 생애주기 독립 | 주기적 부채 상환(복잡도·중복·대형모듈 분해·FEATURE.md 생성). 동작 불변 강제. |
| designer | 온디맨드 렌즈 | Planner/Implementer 보조 — 신규 화면 설계. |
| domain-expert | 온디맨드 렌즈 | Reviewer 렌즈 — 전술 DDD 경계·규칙·용어 드리프트 검증. |

## Mode A / Mode B

- **Mode A (신규 작업):** `/whale:start` → 생애주기 루프. 각 phase 는 산출물 완료 + 게이트 통과 후 `/whale:next` 로 넘어간다. approve 게이트는 `/whale:approve` 로, 재구현 루프는 자동(최대 1회).
- **Mode B (이슈 해결):** 고정 순서 없음. 이슈 성격에 맞는 역할(들)이 피어로 협업. run-id 생애주기와 독립.

## E2E 무인 테스트

야간·무인 상황에서 AI에게 테스트를 맡기는 흐름을 위한 하네스다.

1. **최초 1회:** `/whale:e2e-init` — 프로젝트 스택(pnpm/npm)·디자인 시스템을 감지해 Playwright 설정·6종 Helper(Form/Dialog/Select/Table/Navigation/Toast)·fixture·AI 가이드(`tests/README.e2e.md`)·CI 워크플로를 스캐폴드. 의존성 설치는 안내만(사용자 확인).
2. **실행:** qa 단계가 critical path 를 보고 자동으로 e2e-tester 를 부르거나, `/whale:e2e <시나리오>` 로 직접. e2e-tester 는 **셀렉터 우선순위(role>aria>data-slot)** 와 Helper 추상화로 스펙을 쓰고 실행한다.
3. **Self-healing 4분류:** 실패를 `UI_CHANGE`/`TEST_BUG`(→자가수정, 최대 `maxHealRetries`회) / `APP_BUG`/`ENV_ISSUE`(→고치지 말고 리포트)로 분류. **APP_BUG 만이 qa Blocker 로 승격 → 기존 피드백 루프로 재구현**.
4. **트리아지 리포트:** `runs/<run-id>/e2e.md` — 진짜 앱버그를 크리티컬리티순 최상단에. 아침에 5초 안에 판정. 비메인·비가역 시나리오는 스킵(사유 명시).
5. **CI(선택):** `.github/workflows/e2e.yml` 은 PR 에 `e2e`·`release` 라벨이 붙을 때만 실행(모든 PR 아님). 라벨 규칙은 `config.e2e.runOn.ciLabels` 와 워크플로 `if` 를 **함께** 수정한다.

> 무인 안전: e2e-tester 는 앱 코드·마이그레이션·서버를 변경하지 않는다(E2E 스펙·Helper·리포트만). 파괴적/비가역 시나리오는 실행하지 않는다.

## 병렬 worktree 오케스트레이션

터미널 여러 개로 병렬 작업할 때 **하나의 워킹 디렉토리를 공유해 소스가 섞이는 문제**를, 작업별 git worktree(폴더·브랜치 물리 격리)로 해결한다.

```
/whale:worktree create main login payment search notice
```
→ `../<repo>-login`·`-payment`·`-search`·`-notice` 폴더를 각각 `feature/login`… 브랜치로 생성하고, 스택을 감지해 의존성까지 설치한다. 그다음 각 폴더에서 터미널을 하나씩 연다:

```
cd ../<repo>-login && claude      # feature/login
cd ../<repo>-payment && claude    # feature/payment
```
각 터미널의 whale 에이전트 팀은 자기 폴더·자기 브랜치만 본다. checkout 충돌도 내용 섞임도 없다.

```
/whale:worktree list              # 목록(+PORT)
/whale:worktree remove payment    # 정리(브랜치는 유지)
```

> **설계:** worktree 세팅은 결정적 작업이라 command+script 층이 담당하고, 개발 지능은 각 worktree 안의 taskforce 에이전트가 담당한다(생애주기·run-id와 독립). whale을 유저 레벨(`~/.claude/`)에 설치하면 갈라진 폴더마다 자동으로 붙는다.
>
> **worktree가 격리 못 하는 것:** 의존성/빌드는 폴더마다 따로(pnpm 등 전역 캐시면 부담↓), 같은 브랜치 동시 체크아웃 불가, 로컬 DB/포트는 공유 시 충돌(→ `.env.worktree`의 PORT로 dev 서버 분리). **머지 차단 게이트(테스트·보안)는 이 층이 아니라 CI에서 강제**하라.

## 강제 게이트 · 보안 · 부채 상환

- **강제 게이트(Hooks):** `/whale:hooks-init` → 스택 감지 후 `.claude/settings.json` 에 PostToolUse(lint·typecheck 게이트, 기본 lint-only)·PreToolUse(위험명령 차단) 훅을 병합(덮어쓰지 않음). 기본 차단: `rm -rf /~.`·보호브랜치 강제푸시·`git reset --hard`+push·prod 마이그레이션·`DROP/TRUNCATE`·`curl|sh`·`terraform destroy` 등(exit 2).
- **보안 게이트(security-reviewer):** qa 가 보안 민감 변경(인증·PII·site_id·의존성·결제)이면 dispatch. `security.md` 의 Critical/High → qa Blocker → 재구현. 사람 필수 게이트(인증·암호화·입력검증·결제)는 무결점이어도 HOLD(리더 승인 대기). `config.security` 없으면 미사용.
- **계약 우선:** `config.contracts.ssot`(CLAUDE.md §3)에 경계별 단일 진실원을 두고 파생물은 codegen. planner 가 지정, be/fe 가 준수(같은 커밋에 파생물 갱신).
- **교차-run 메모리:** `.claude/whale/memory/{PROGRESS,DECISIONS,LessonsLearned}.md`. reviewer 가 반복 실패를 LessonsLearned 에 append, summarizer 가 정리. 다음 run 의 researcher 가 승계.
- **부채 상환(refactor):** `/whale:refactor` — 생애주기·run-id 독립. 동작 불변(리팩터 전후 동일 테스트) 강제, 기능 변경 금지. FEATURE.md 없는 핵심 모듈에 생성.

## 구성

```
whale-plugin/
├── .claude-plugin/
│   ├── plugin.json          # 플러그인 매니페스트
│   └── marketplace.json     # 이 레포를 마켓플레이스로 (source: ./)
├── commands/                # 슬래시 명령어 (/whale:*)
├── agents/                  # 13개 역할 (researcher·planner·dba·be·fe·reviewer·qa·e2e-tester·security-reviewer·refactor·summarizer·designer·domain-expert)
├── scripts/                 # ctx-check + hooks(guard-dangerous-cmd·detect-stack·run-gate) + whale-worktree
├── templates/               # config.json·state.md·CLAUDE.md·FEATURE.md (init 이 복사) + e2e/ (Playwright) + hooks/settings.json
└── README.md
```

## 프로젝트별 커스터마이징

플러그인은 손대지 않고 **프로젝트 로컬 `.claude/whale/config.json`** 만 수정한다:

| 키 | 용도 |
|----|------|
| `profile` | 도메인 특화 강도(`domain`: general 기본/public-sector-kr) · `multitenant`(site_id) · `architecture`(project — 내장 강제 없음) |
| `lifecycle.phases` | 생애주기 phase 구성(id·role·gate·produces) |
| `domainExperts` | Implementer 가 부르는 도메인 전문가(order·roles) |
| `approvalGate` | 승인 문구 규칙(`APPROVED: {runId}`, acceptLoose) |
| `feedbackLoop` | 재시도 상한(maxRetries)·복귀 대상·범위 |
| `roles` | 역할 → agentType 매핑 (플러그인이 `whale:dba` 로 네임스페이스) |
| `runId` | run-id 형식(티켓 체계 등으로 커스터마이즈) |
| `e2e` | E2E 설정(tool·testDir·runCommand·maxHealRetries·criticalPaths·runOn) — `/whale:e2e-init` 이 스택에 맞춰 조정 |
| `security` | 보안 게이트(sast·sca·humanGateAreas·failOn·runOn) — 없으면 미사용 |
| `refactor` | 부채 임계(complexity·moduleLine·duplication)·리포트 경로·주기 |
| `contracts.ssot` | 계약 경계별 단일 진실원·파생물·codegen |
| `coverage` | qa 여정 지표(journeys·검증밀도·깨진테스트율·계약테스트) |
| `hooks` | guard(위험명령)·gate(lint/test mode) — `/whale:hooks-init` 이 스택 명령 주입 |
| `scopeDir` | 마일스톤 범위 문서 디렉토리 |
| `paths.*` | `runArtifacts`·메모리(decisions·lessonsLearned)·claudeMd·featureDoc + (선택) 화면정의서·PRD |
| `reviewer` | 최종 검수자 |

에이전트의 방법론(컨텍스트 격리·피드백 루프·계약 우선 규율)은 플러그인에 내장되어 있고, 프로젝트 고유 규칙(아키텍처·테이블 프리픽스·동결 스키마·기술 스택)은 각 에이전트가 **프로젝트 `CLAUDE.md`** 를 읽어 적용한다. 공공기관 특화(행안부 표준·PII 암호화·site_id)는 `config.profile` 로 켤 때만 적용되는 옵션이다(기본은 범용).

> **하위호환:** `lifecycle` 키가 없고 `modeA_chain` 만 있는 구(舊) config 는 구 4역할 체인 모드(dba→be→fe→qa)로 동작한다. 새 기능을 쓰려면 `/whale:init` 재실행 또는 config 를 v2 스키마로 갱신한다.

## 라이선스

MIT
