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
4. **산출물 디렉토리 준비:** `config.json.paths.runArtifacts/<run-id>/`(기본 `.claude/whale/runs/<run-id>/`)를 산출물 저장 위치로 삼는다(에이전트가 여기에 research.md 등을 쓴다).
5. **state 기록:** `.claude/whale/state.md` "활성 흐름" 블록을 Edit 으로 채운다 — run-id, Task=$ARGUMENTS, Mode=A(생애주기), 시작일=오늘, 마일스톤 범위, 현재 phase=`research`, 승인 상태=`PENDING`, 재시도=`0 / {config.feedbackLoop.maxRetries}`. `config.json.lifecycle.phases` 전체를 생애주기 진행표로(1단계 research ▶ 진행중, 나머지 ⬜ 대기).
6. **첫 phase dispatch:** `lifecycle.phases[0]`(research)의 `role`(`config.roles.researcher`)을 **Agent 툴로 dispatch**. 컨텍스트로 전달: run-id, task 설명, 마일스톤 범위, (있으면) `paths.screenSpecs`·`paths.prd` 를 **선택적 참조**(강제 아님). 산출물은 `runs/<run-id>/research.md`.
7. 에이전트 완료 후 산출물 요약과 함께 "다음 단계 진행은 `/whale:next`" 를 안내한다.

**규칙:** phase 순서·역할·게이트·run-id 규칙은 반드시 `config.json` 에서 읽는다(하드코딩 금지). 하위호환: `lifecycle` 이 없고 `modeA_chain` 만 있는 구(舊) config 는 구 4역할 체인 모드로 동작(run-id/research/approval 스킵, 첫 단계 dba). 각 phase 는 선행 phase 산출물 완료가 전제다.
