---
description: 생애주기 품질 루프 시작 — run-id 발급 후 Researcher dispatch
argument-hint: <task 이름/설명>
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(grep:*), Read, Write, Edit, Agent
---
# /whale:start — 생애주기 품질 루프 시작

대상 task: **$ARGUMENTS**

## Whale 설정
@.claude/whale/config.json

## 현재 흐름 상태
@.claude/whale/state.md

## 현재 마일스톤 범위 (기본 .planning/milestone — config.json.scopeDir 이 다르면 그 경로 기준)
!`ls .planning/milestone/ 2>/dev/null; echo '---'; cat .planning/milestone/*.md 2>/dev/null | head -80`

## 절차

> **선행:** `.claude/whale/config.json` 이 없으면 먼저 `/whale:init` 을 안내하고 멈춘다.

1. **범위 확인:** 위 마일스톤 범위에 "$ARGUMENTS" 가 포함되는가? 범위 밖이면 **즉시 멈추고** 사용자에게 확인을 요청한다. (프로젝트 CLAUDE.md 에 범위 규칙이 있으면 우선.)
2. **활성 흐름 충돌 확인:** state.md 에 이미 진행 중인 run 이 있으면, 마치거나 보관할지 사용자에게 확인.
3. **run-id 발급:** `config.json.runId.format`(기본 `{date}-{slug}-{seq}`)으로 생성한다.
   - `date` = 오늘(YYYYMMDD).
   - `slug` = "$ARGUMENTS" 를 kebab-case 로 변환해 `slugMaxLen`(기본 24)까지 절단.
   - `seq` = state.md(활성+히스토리)에서 같은 `date-slug` 를 grep 해 충돌 없으면 `01`, 있으면 다음 번호.
   - 발급한 run-id 를 사용자에게 통지한다.

4. **강도 티어 분류 (`config.modes` 있을 때):** 이 작업을 `fast | normal | full` 중 하나로 판정한다. `modes` 블록이 없으면 이 단계를 건너뛰고 항상 full(lifecycle.phases 전체)로 진행(하위호환).
   - **명시 override:** 사용자가 `--tier=<t>` 를 주면 그 값을 채택한다(단 아래 승격 하드룰은 여전히 강제).
   - **자동 분류(`classify=auto`):** 작업 설명 + 위 마일스톤 범위 + 필요 시 코드 빠른 확인으로 판정:
     - **fast** — 단일 파일/함수 범위, 기존 패턴 답습, 신규 API/DB/계약 변경 없음, 보안 민감 영역 무관한 **작은 신규 변경**. (버그·이슈면 `/whale:fix` Mode B 가 더 적합함을 안내.)
     - **normal** — 신규 API 1~2개 / DB 컬럼·테이블 추가 / 신규 화면 / non-breaking 계약 확장 / 단일 BC 범위.
     - **full** — 아키텍처·인증 방식 변경 / 다중 BC / breaking 계약 / 동결 대상 변경 / 대규모 리팩터.
   - **승격 하드룰 (크기 무관, 절대 우회 금지):**
     - 변경이 `config.modes.autoEscalate.toNormalMin`(= `config.security.humanGateAreas`: 인증·암호화·입력검증·결제)에 저촉 → **최소 normal 로 승격**(fast 금지). qa 단계에서 security-reviewer 강제.
     - 변경이 `config.modes.autoEscalate.toFull`(아키텍처·인증방식·다중BC·breaking계약·동결대상) → **full 로 승격**.
   - 판정 티어와 (승격 시) 사유를 사용자에게 통지한다.

5. **산출물 디렉토리 준비:** `config.json.paths.runArtifacts/<run-id>/`(기본 `.claude/whale/runs/<run-id>/`)를 산출물 저장 위치로 삼는다(에이전트가 여기에 research.md 등을 쓴다).

6. **state 기록:** `.claude/whale/state.md` "활성 흐름" 블록을 Edit 으로 채운다 — run-id, Task=$ARGUMENTS, Mode=A(생애주기), **Tier=<판정 티어>**, 시작일=오늘, 마일스톤 범위, 승인 상태=`PENDING`, 재시도=`0 / {config.feedbackLoop.maxRetries}`.
   - **진행표는 선택된 티어의 phase 만** 넣는다: `config.modes.tiers[Tier].phases` 순서대로. 그 배열의 첫 phase 를 ▶ 진행중, 나머지 ⬜ 대기. (fast 면 implement 한 행만; normal 이면 plan·approve·implement·review·qa; full 이면 7개 전체.)
   - **현재 phase** = 그 배열의 첫 phase.

7. **첫 phase dispatch:** 선택된 티어 `phases[0]` 의 `role` 을 **Agent 툴로 dispatch**.
   - **full**: `research`(researcher) 부터. 컨텍스트: run-id, task, 마일스톤 범위, (있으면) `paths.screenSpecs`·`paths.prd` 를 **선택적 참조**. 산출물 `runs/<run-id>/research.md`.
   - **normal**: `plan`(planner) 부터(research 스킵 — planner 가 경량 조사 겸행). 산출물 `runs/<run-id>/plan.md`.
   - **fast**: `implement` 부터 — plan/approve 없이 곧장 `config.domainExperts.roles` 의 해당 전문가(변경 레이어에 맞는 be 또는 fe, 필요 시 dba)를 dispatch(TDD). review/qa/summarize 는 티어에 없고 **hooks 게이트가 품질 게이트**다. 완료 후 hooks 통과 확인 → DECISIONS 1줄 append → 흐름 종료(히스토리 이동).
8. 에이전트 완료 후 산출물 요약과 함께 "다음 단계 진행은 `/whale:next`" 를 안내한다(fast 는 단일 dispatch 후 종료라 next 불필요할 수 있음 — 상태에 맞게 안내).

**규칙:** phase 순서·역할·게이트·run-id·티어 규칙은 반드시 `config.json` 에서 읽는다(하드코딩 금지). 승격 하드룰(보안 영역→최소 normal)은 어떤 경우에도 우회하지 않는다. 하위호환: (1) `lifecycle` 이 없고 `modeA_chain` 만 있는 구 config 는 구 4역할 체인 모드. (2) `modes` 블록이 없으면 티어 분기 없이 항상 full. 각 phase 는 선행 phase 산출물 완료가 전제다.
